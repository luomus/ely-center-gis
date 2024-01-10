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

  status <- grepl("logs|status|healthz", req[["PATH_INFO"]])

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

  callr::r_bg(
    source,
    args = list(file = "ely.R"),
    poll_connection = FALSE,
    cleanup = FALSE
  )

  "success"

}

#* @assets ./var /
list()
