dir.create("var/logs", showWarnings = FALSE)

log_file_name <- sprintf("var/logs/update-%s.txt", Sys.Date())

log_file <- file(log_file_name, open = "wt")

sink(log_file)

sink(log_file, type = "message")

res <- tryCatch(
  {

    source("setup.R")
    source("db-setup.R")
    source("query.R")
    source("transform-footprint.R")
    source("ely-subsets.R")
    source("ely-compute.R")

    system2(
      "rclone",
      c(
        "sync",
        "\"var\"",
        sprintf(
          "\"default:%s-%s\"", Sys.getenv("OBJECT_STORE"), Sys.getenv("BRANCH")
        )
      )
    )

    message(sprintf("INFO [%s] Job complete", format(Sys.time())))

    "true"

  },
  error = function(e) {

    message(sprintf("ERROR [%s] %s", format(Sys.time()), e$message))

    "false"

  }
)

dir.create("var/status", showWarnings = FALSE)

cat(res, file = "var/status/success.txt")

cat(format(Sys.time(), usetz = TRUE), file = "var/status/last-update.txt")

DBI::dbDisconnect(con)

sink(type = "message")

sink()

file.copy(log_file_name, "var/logs/update-latest.txt", TRUE)
