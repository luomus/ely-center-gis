library(plumber)

p <- pr()

p <- pr_static(p, "/", "./var")

p <- pr_set_docs(p, FALSE)

pr_run(p, host = "0.0.0.0", port = as.integer(Sys.getenv("SVR_PORT")))
