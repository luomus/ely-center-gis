library(plumber)

p <- pr()

p <- pr_filter(
  p,
  function(req, res) {

    token <- identical(
      req[["argsQuery"]]["access_token"], Sys.getenv("USER_ACCESS_TOKEN")
    )

    status <- grepl("status", req[["PATH_INFO"]])

    if (token | status) {

      forward()

    } else {

      res[["status"]] <- 401
      list(error = "Access token required")

    }

  }
)

p <- pr_static(p, "/", "./var")

p <- pr_set_docs(p, FALSE)

pr_run(p, host = "0.0.0.0", port = as.integer(Sys.getenv("SVR_PORT")))
