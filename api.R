#* Check if token is needed and present
#* @filter token
function(req, res) {

  token <- identical(
    req[["argsQuery"]][["access_token"]], Sys.getenv("USER_ACCESS_TOKEN")
  )

  status <- grepl("status|healthz", req[["PATH_INFO"]])

  secret <- identical(req[["argsQuery"]][["secret"]], Sys.getenv("JOB_SECRET"))

  job <- secret && grepl("job", req[["PATH_INFO"]])

  if (token || status || job) {

    forward()

  } else {

    res[["status"]] <- 401
    list(error = "Access token required")

  }

}

#* Check the liveness of the API
#* @head /healthz
#* @get /healthz
#* @tag status
#* @response 200 A json object
#* @serializer unboxedJSON
function() {
  ""
}

#* Run job
#* @get /job
#* @tag status
#* @response 200 A json object
#* @serializer unboxedJSON
function() {

  on.exit({

    sink(type = "message")

    sink()

  })

  log_file_name <- sprintf("/var/logs/job-%s.txt", Sys.Date())

  log_file <- file(log_file_name, open = "wt")

  sink(log_file)

  sink(log_file, type = "message")

  source("ely.R")

  "success"

}

#* @assets ./var /
list()
