tryCatch(

  {

    timeout_in_secs <- as.integer(Sys.getenv("TIMEOUT_IN_HOURS")) * 60L * 60L

    start_timer <- tictoc::tic()

    n_subsets <- as.integer(Sys.getenv("N_SUBSETS"))

    mod_time_subsets <- dplyr::tbl(
      con, DBI::Id(schema = "subsets", table = "mod_time")
    )

    for (subset in seq_len(n_subsets)) {

      fltr <- c(filter, list(subset = c(subset, n_subsets)))

      last_mod_subset <-
        mod_time_subset |>
        dplyr::filter(subset == !!subset) |>
        dplyr::pull(time)

      last_mod_origin <- finbif::finbif_occurrence(
        filter = fltr,
        select = "load_date",
        order_by = "-load_date",
        n = 1L
      ) |>
      dplyr::pull(load_date)

      if (isTRUE(last_mod_origin > last_mod_subset)) {

        data <-
          finbif::finbif_occurrence(
            filter = fltr,
            select = unlist(select, use.names = FALSE),
            facts = unlist(facts, use.names = FALSE),
            n = "all",
            locale = "fi",
            unlist = TRUE
          ) |>
          dplyr::mutate(subset = subset) |>
          transform_footprint()

        geoms <-
          data |>
          geometry_type_chr() |>
          sub("^MULTI", "", x = _) |>
          tolower() |>
          paste0("s")

        for (geom in unique(geoms)) {

          tbl <- DBI::Id(schema = "subsets", table = geom)

          if (pool::dbExistsTable(con, tbl)) {

            pool::dbExecute(
              con,
              sprintf(
                "DELETE FROM \"subsets\".\"%s\" WHERE \"subset\" = %s",
                geom, subset
              )
            )

            sf::st_write(data[geoms == geom, ], con, tbl, append = TRUE)

          } else {

            sf::st_write(data[geoms == geom, ], con, tbl, append = FALSE)

            pool::dbExecute(
              con,
              sprintf(
                "CREATE INDEX %1$s_subset_idx ON subsets.%1$s(subset)", geom
              )
            )

          }

        }

        pool::dbExecute(
          con,
          sprintf(
            "DELETE FROM \"subsets\".\"mod_time\" WHERE \"subset\" = %s", subset
          )
        )

        pool::dbWriteTable(
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
          sprintf("INFO [%s] Reached time limit. Job exiting", Sys.time())
        )

        break

      }

    }

    message(sprintf("INFO [%s] Job complete", Sys.time()))

    "true"

  },
  error = function(e) {

    message(sprintf("ERROR [%s] %s", Sys.time(), e[["message"]]))

    "false"

  }

) |>
cat(file = "subsets-success.txt")

cat(format(Sys.time(), usetz = TRUE), file = "subsets-last-update.txt")