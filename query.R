filter <- list(
  status_filter_operator = "OR",
  regulatory_status = c(
    "FNLX160_97_LBP", "FNLX160_97_2A", "FNLX160_97_2B", "FNLX160_97_3A",
    "FNLX160_97_3B", "FNLX160_97_3C", "FNLX160_97_4_2021",
    "FNLX160_97_4_SI_2021", "HABDIR2", "HABDIR4", "BDS1", "BDSMB"
  ),
  red_list_status = c("CR", "EN", "VU", "NT"),
  country = "Finland",
  date_range_ymd = c("1990-01-01", ""),
  abundance_min = 0,
  coordinates_uncertainty_max = 1000,
  collection_and_record_quality = c(
    "PROFESSIONAL:EXPERT_VERIFIED,COMMUNITY_VERIFIED,NEUTRAL,UNCERTAIN",
    "HOBBYIST:EXPERT_VERIFIED,COMMUNITY_VERIFIED,NEUTRAL",
    "AMATEUR:EXPERT_VERIFIED,COMMUNITY_VERIFIED"
  )
)

select <- list(
  grp = c(
    "scientific_name",
    "common_name_finnish",
    "common_name_swedish",
    "red_list_status",
    "threatened_status",
    "regulatory_status",
    "informal_groups",
    "taxonomic_order",
    "primary_habitat",
    "sensitive",
    "occurrence_status",
    "abundance_unit",
    "is_breeding_location",
    "team",
    "municipality",
    "locality",
    "province",
    "date_start",
    "date_end",
    "footprint_wgs84",
    "lat_euref",
    "lon_euref",
    "coordinates_uncertainty",
    "state_land",
    "collection_id",
    "collection",
    "collection_quality",
    "data_source",
    "site_type",
    "site_status"
  ),
  collapse = c(
    "taxon_id",
    "reported_name",
    "record_quality",
    "determiner",
    "record_id",
    "record_keywords",
    "abundance_verbatim",
    "record_basis",
    "sex",
    "life_stage",
    "record_notes",
    "event_notes",
    "restriction_reasons",
    "document_notes",
    "document_id",
    "event_id"
  ),
  sum = c(
    "abundance_interpreted"
  ),
  max = c(
    "atlas_code",
    "atlas_class"
  )
)

facts <- list(
  grp = c(
    "Seurattava laji",
    "Sijainnin tarkkuusluokka",
    "Havainnon laatu",
    "Peittävyysprosentti",
    "Havainnon määrän yksikkö"
  ),
  collapse = c(
    "Vesistöalue",
    "Merialueen tunniste"
  )
)
