tryCatch(

  {

    all_subsets <-
      dplyr::tbl(con, DBI::Id(schema = "subsets", table = "mod_time")) |>
      dplyr::summarise(n = dplyr::n()) |>
      dplyr::pull(n) |>
      as.character() |>
      identical(Sys.getenv("N_SUBSETS"))

    if (all_subsets) {

      geoms <-
        pool::dbListObjects(con, DBI::Id(schema = "subsets")) |>
        getElement("table") |>
        lapply(methods::slot, "name") |>
        vapply(getElement, "", "table")

      for (geom in geoms) {

        tbl <- DBI::Id(schema = "subsets", table = geom)

        ely <-
          dplyr::tbl(con, tbl) |>
          dplyr::group_by(
            taxon = ifelse(is.na(taxon_id), reported_name, taxon_id),
            dplyr::across(
              dplyr::all_of(
                sub("wgs84", "euref", c(select[["grp"]], facts[["grp"]]))
              )
            )
          ) |>
          mutate(
            dplyr::across(
              dplyr::all_of(select[["sum"]]),
              ~ {
                if (all(is.na(.x))) NA else sum(.x, na.rm = TRUE)
              }
            ),
            dplyr::across(
              dplyr::all_of(select[["max"]]),
              ~ {
                if (all(is.na(.x))) NA else max(.x, na.rm = TRUE)
              }
            )
          ) |>
          dplyr::distinct() |>
          dplyr::summarise(
            dplyr::across(
              dplyr::all_of(c(select[["sum"]], select[["max"]])),
              ~ {
                if (all(is.na(.x))) NA else max(.x, na.rm = TRUE)
              }
            ),
            dplyr::across(
              dplyr::all_of(c(select[["collapse"]], facts[["collapse"]])),
              ~ {
                if (all(is.na(.x))) NA else stringr::str_flatten(.x, "; ")
              }
            ),
            .groups = "keep"
          ) |>
          dplyr::ungroup() |>
          dplyr::select(!c(taxon, occurrence_status))

        tbl <- DBI::Id(schema = "ely", table = geom)

        if (pool::dbExistsTable(con, tbl)) {

          pool::dbRemoveTable(con, tbl)

        }

        ely <- dplyr::compute(ely, tbl, temporary = FALSE)

        system2(
          'ogr2ogr',
          args = c(
            "-f",
            "GPKG",
            "ely.gpkg",
            sprintf(
              "'PG:host=%s dbname=%s user=%s password=%s port=%s'",
              Sys.getenv("PGHOST"), Sys.getenv("DB_NAME"), Sys.getenv("PGUSER"),
              Sys.getenv("PGPASSWORD"), Sys.getenv("PGPORT")
            ),
            sprintf("'subsets.%s'", geom),
            if (file.exists("ely.gpkg")) "-update" else NULL,
            "-nln",
            geom
          )
        )

      }

    }

  },
  error = function(e) {

    message(sprintf("ERROR [%s] %s", Sys.time(), e[["message"]]))

    "false"

  }

) |>
cat(file = "compute-success.txt")

cat(format(Sys.time(), usetz = TRUE), file = "compute-last-update.txt")
