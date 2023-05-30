library(dbplyr, quietly = TRUE)
library(finbif, quietly = TRUE)

options(
  finbif_api_url = Sys.getenv("FINBIF_API_URL"),
  finbif_warehouse_query = Sys.getenv("FINBIF_WAREHOUSE"),
  finbif_email = Sys.getenv("FINBIF_EMAIL"),
  finbif_rate_limit = Inf,
  finbif_use_cache = TRUE,
  finbif_hide_progress = TRUE,
  finbif_retry_times = 10,
  finbif_retry_pause_base = 2,
  finbif_retry_pause_cap = 5e3
)

ely_centers <- readRDS("ely-centers.rds")
ely_centers <- sf::st_transform(ely_centers, 3067L)
