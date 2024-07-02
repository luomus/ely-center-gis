con <- DBI::dbConnect(RPostgres::Postgres(), dbname = Sys.getenv("DB_NAME"))

is_db_setup <-
  dplyr::tbl(con, dbplyr::in_schema(
    schema = "information_schema", table = "schemata")
  ) |>
  dplyr::filter(schema_name == "subsets") |>
  dplyr::pull(schema_name) |>
  identical("subsets")

if (!is_db_setup) {

  DBI::dbExecute(con, "CREATE SCHEMA subsets")

  DBI::dbWriteTable(
    con,
    DBI::Id(schema = "subsets", table = "mod_time"),
    data.frame(
      subset = integer(), time = as.POSIXct(numeric(), tz = Sys.timezone())
    )
  )

}
