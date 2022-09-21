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
        dplyr::all_of(sub("wgs84", "euref", c(select[["grp"]], facts[["grp"]])))
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
      across(
        all_of(c(select[["collapse"]], facts[["collapse"]])),
        ~ {
          if (all(is.na(.x))) NA else stringr::str_flatten(.x, collapse = "; ")
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

}
