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
        vapply(getElement, "", "table") |>
        setdiff("mod_time")

      unlink("ely.gpkg")

      for (geom in geoms) {

        message(sprintf("INFO [%s] %s layer updating...", Sys.time(), geom))

        tbl <- DBI::Id(schema = "subsets", table = geom)

        ely <-
          dplyr::tbl(con, tbl) |>
          dplyr::group_by(
            taxon = ifelse(is.na(taxon_id), reported_name, taxon_id),
            dplyr::across(
              dplyr::all_of(
                sub(
                  "wgs84",
                  "euref",
                  c(select[["grp"]], facts[["grp"]], "ely_center", "geom")
                )
              )
            )
          ) |>
          dplyr::mutate(
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
            group_count = dplyr::n(),
            .groups = "drop"
          ) |>
          dplyr::select(all_of(names(cols))) |>
          dplyr::rename_with(~cols, names(cols)) |>
          dplyr::arrange(.data[[!!cols[["date_start"]]]])

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
            sprintf("'ely.%s'", geom),
            if (file.exists("ely.gpkg")) "-update" else NULL,
            "-nln",
            geom
          )
        )

      }

      zip("var/ely.zip", "ely.gpkg" , flags = "-rj9qX")

    }

    message(sprintf("INFO [%s] Compute job complete", Sys.time()))

    "true"

  },
  error = function(e) {

    message(sprintf("ERROR [%s] %s", Sys.time(), e[["message"]]))

    "false"

  }

) |>
cat(file = "var/status/compute-success.txt")

cat(
  format(Sys.time(), usetz = TRUE), file = "var/status/compute-last-update.txt"
)
