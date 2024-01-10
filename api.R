#* Check if token is needed and present
#* @filter token
function(req, res) {

  ely_token <- identical(
    req[["argsQuery"]][["access_token"]],
    Sys.getenv("ELY_ACCESS_TOKEN")
  )

  mh_token <- identical(
    req[["argsQuery"]][["access_token"]],
    Sys.getenv("MH_ACCESS_TOKEN")
  )

  token <- ely_token || mh_token

  allow <- grepl("logs|status|healthz|robots|favicon", req[["PATH_INFO"]])

  secret <- identical(req[["argsQuery"]][["secret"]], Sys.getenv("JOB_SECRET"))

  job <- secret && grepl("job", req[["PATH_INFO"]])

  if (token || allow || job) {

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

  callr::r_bg(
    source,
    args = list(file = "ely.R"),
    poll_connection = FALSE,
    cleanup = FALSE
  )

  "success"

}

#* @get /favicon.ico
#* @serializer contentType list(type="image/x-icon")
function() {

  readBin("favicon.ico", "raw", n = file.info("favicon.ico")$size)

}

#* @get /robots.txt
#* @serializer contentType list(type="text/plain")
function() {

  readBin("robots.txt", "raw", n = file.info("robots.txt")$size)

}

#* @assets ./var /
list()
