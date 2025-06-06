tryCatch(

  {

    timeout_in_secs <- as.integer(Sys.getenv("TIMEOUT_IN_HOURS")) * 60L * 60L

    start_timer <- tictoc::tic()

    n_subsets <- as.integer(Sys.getenv("N_SUBSETS"))

    mod_time_subsets <- dplyr::tbl(
      con, dbplyr::in_schema(schema = "subsets", table = "mod_time")
    )

    last_subset <-
      mod_time_subsets |>
      dplyr::slice_max(time, with_ties = FALSE, na.rm = TRUE) |>
      dplyr::pull(subset)

    start <- 1L

    if (isTRUE(last_subset < n_subsets)) {

      start <- last_subset + start

    }

    for (subset in c(seq.int(start, n_subsets), seq_len(start - 1L))) {

      fltr <- c(filter, list(subset = c(subset, n_subsets)))

      last_mod_subset <-
        mod_time_subsets |>
        dplyr::filter(subset == !!subset) |>
        dplyr::pull(time)

      last_mod_origin <- finbif::finbif_occurrence(
        filter = fltr,
        select = "load_date",
        order_by = "-load_date",
        n = 1L
      ) |>
      dplyr::pull(load_date)

      if (isTRUE(Sys.getenv("TRIGGER") > last_mod_origin)) {

        last_mod_origin <- Sys.getenv("TRIGGER")

      }

      if (!isTRUE(last_mod_origin <= last_mod_subset)) {

        message(
          sprintf("INFO [%s] Subset %s updating...", format(Sys.time()), subset)
        )

        slct <- unlist(select, use.names = FALSE)

        names(slct) <- slct

        slct[slct == "bio_province"] <- "bio_province_interpreted"
        slct[slct == "municipality"] <- "finnish_municipality"

        data <-
          finbif::finbif_occurrence(
            filter = fltr,
            select = slct,
            order_by = "record_id",
            facts = unlist(facts, use.names = FALSE),
            n = "all",
            locale = "fi",
            unlist = TRUE
          ) |>
          dplyr::mutate(
            subset = subset,
            atlas_code = as.integer(sub("\\D+", "", atlas_code)),
            atlas_class = dplyr::recode(
              atlas_class,
              "Epätodennäköinen pesintä" = 1,
              "Mahdollinen pesintä" = 2,
              "Todennäköinen pesintä" = 3,
              "Varma pesintä" = 4
            )
          ) |>
          dplyr::mutate(
            atlas_code = ifelse(atlas_code < 10, atlas_code * 10L, atlas_code)
          ) |>
          transform_footprint() |>
          dplyr::mutate(
            ely_center = purrr::map_chr(
              sf::st_intersects(geom, ely_centers),
              ~{ paste(ely_centers[.x, ][["name"]], collapse = ", ") }
            )
          )

        geoms <-
          data |>
          geometry_type_chr() |>
          sub("^MULTI", "", x = _) |>
          tolower() |>
          paste0("s")

        for (geom in unique(geoms)) {

          tbl <- DBI::Id(schema = "subsets", table = geom)

          if (DBI::dbExistsTable(con, tbl)) {

            DBI::dbExecute(
              con,
              sprintf(
                "DELETE FROM \"subsets\".\"%s\" WHERE \"subset\" = %s",
                geom, subset
              )
            )

            sf::st_write(
              data[geoms == geom, ], con, tbl, quiet = TRUE, append = TRUE
            )

          } else {

            sf::st_write(
              data[geoms == geom, ], con, tbl, quiet = TRUE, append = FALSE
            )

            DBI::dbExecute(
              con,
              sprintf(
                "CREATE INDEX %1$s_subset_idx ON subsets.%1$s(subset)", geom
              )
            )

          }

        }

        DBI::dbExecute(
          con,
          sprintf(
            "DELETE FROM \"subsets\".\"mod_time\" WHERE \"subset\" = %s", subset
          )
        )

        DBI::dbWriteTable(
          con,
          DBI::Id(schema = "subsets", table = "mod_time"),
          data.frame(subset = subset, time = Sys.time()),
          append = TRUE
        )

      }

      stop_timer <- tictoc::toc(quiet = TRUE)

      tictoc::tic()

      if (stop_timer[["toc"]] - start_timer > timeout_in_secs) {

        message(
          sprintf(
            "INFO [%s] Reached time limit. Job exiting", format(Sys.time())
          )
        )

        break

      }

    }

    message(sprintf("INFO [%s] Subsets job complete", format(Sys.time())))

    "true"

  },
  error = function(e) {

    message(sprintf("ERROR [%s] %s", format(Sys.time()), e[["message"]]))

    "false"

  }

) |>
cat(file = "var/status/subsets-success.txt")

cat(
  format(Sys.time(), usetz = TRUE), file = "var/status/subsets-last-update.txt"
)
