library(dbplyr, quietly = TRUE)
library(finbif, quietly = TRUE)

options(
  finbif_api_url = Sys.getenv("FINBIF_API_URL"),
  finbif_warehouse_query = Sys.getenv("FINBIF_WAREHOUSE"),
  finbif_email = Sys.getenv("FINBIF_EMAIL")
)

if (identical(getOption("finbif_api_url"), "https://apitest.laji.fi")) {

  assignInNamespace("var_names", finbif:::var_names_test, "finbif")

}
