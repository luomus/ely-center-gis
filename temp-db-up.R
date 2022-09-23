library(stevedore)

docker <- docker_client()

postgis <- docker$container$run(
  "crunchydata/crunchy-postgres-gis:centos8-13.6-3.1-4.7.5",
  name = "postgis-ely",
  ports = "5432",
  env = list(
    MODE = "postgres",
    PG_MODE = "primary",
    PG_PRIMARY_PORT = Sys.getenv("DB_PORT"),
    PG_DATABASE = Sys.getenv("DB_NAME"),
    PG_USER = Sys.getenv("DB_USER"),
    PG_PASSWORD = Sys.getenv("DB_USER_PASSWORD"),
    PG_PRIMARY_USER = Sys.getenv("DB_PRIMARY_USER"),
    PG_PRIMARY_PASSWORD = Sys.getenv("DB_PRIMARY_PASSWORD"),
    PG_ROOT_PASSWORD = Sys.getenv("DB_SUPER_PASSWORD")
  ),
  detach = TRUE
)

postgis <- docker$container$get(id = "postgis-ely")

Sys.setenv(
  PGHOST = "0.0.0.0",
  PGPORT = postgis$ports()$host_port[[1]],
  PGUSER = Sys.getenv("DB_SUPER_USER"),
  PGPASSWORD = Sys.getenv("DB_SUPER_PASSWORD")
)

Sys.sleep(10)
