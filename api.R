#* Check if token is needed and present
#* @filter token
function(req, res) {

  token <- identical(
    req[["argsQuery"]][["access_token"]], Sys.getenv("USER_ACCESS_TOKEN")
  )

  status <- grepl("status|healthz", req[["PATH_INFO"]])

  if (token || status) {

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

#* @assets ./var /
list()
