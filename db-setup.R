con <- pool::dbPool(RPostgres::Postgres(), dbname = Sys.getenv("DB_NAME"))

is_db_setup <-
  dplyr::tbl(con, DBI::Id(schema = "information_schema", table = "schemata")) |>
  dplyr::filter(schema_name == "subsets") |>
  dplyr::pull(schema_name) |>
  identical("subsets")

if (!is_db_setup) {

  pool::dbExecute(con, "REVOKE ALL ON SCHEMA public FROM PUBLIC")

  pool::dbExecute(
    con,
    sprintf(
      "REVOKE ALL PRIVILEGES ON DATABASE %s FROM %s",
      Sys.getenv("DB_NAME"), Sys.getenv("DB_USER")
    )
  )

  pool::dbExecute(
    con,
    sprintf(
      "GRANT USAGE ON SCHEMA %s TO %s",
      Sys.getenv("DB_NAME"), Sys.getenv("DB_USER")
    )
  )

  pool::dbExecute(
    con,
    sprintf(
      "GRANT USAGE ON SCHEMA public TO %s", Sys.getenv("DB_USER")
    )
  )

  pool::dbExecute(
    con,
    sprintf(
      "ALTER DEFAULT PRIVILEGES IN SCHEMA %s GRANT SELECT ON TABLES TO %s",
      Sys.getenv("DB_NAME"), Sys.getenv("DB_USER")
    )
  )

  pool::dbExecute(con, "CREATE SCHEMA subsets")

  pool::dbWriteTable(
    con,
    DBI::Id(schema = "subsets", table = "mod_time"),
    data.frame(
      subset = integer(), time = as.POSIXct(numeric(), tz = Sys.timezone())
    )
  )

}
