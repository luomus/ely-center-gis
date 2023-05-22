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
    "bio_province_interpreted",
    "formatted_date_time",
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
    "restriction_reason",
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

cols <- c(
  "scientific_name" = "Tieteellinen_nimi",
  "common_name_finnish" = "Suomenkielinen_nimi",
  "common_name_swedish" = "Ruotsinkielinen_nimi",
  "reported_name" = "Alkuperäinen_nimi",
  "record_id" = "Havainnon_tunniste",
  "group_count" = "Yhdistetty",
  "taxon_id" = "Taksonin_tunniste",
  "taxonomic_order" = "Taksonominen_järjestys",
  "informal_groups" = "Eliöryhmä",
  "abundance_interpreted" = "Yksilömäärä_tulkittu",
  "abundance_verbatim" = "Määrä",
  "abundance_unit" = "Määrän_yksikkö",
  "record_basis" = "Havaintotapa",
  "sex" = "Sukupuoli",
  "occurrence_status" = "Esiintymän_tila",
  "is_breeding_location" = "Pesintäpaikka",
  "life_stage" = "Elinvaihe",
  "red_list_status" = "Uhanalaisuusluokka",
  "sensitive" = "Sensitiivinen_laji",
  "threatened_status" = "Lajiturva",
  "regulatory_status" = "Hallinnollinen_asema",
  "primary_habitat" = "Ensisijainen_biotooppi",
  "record_keywords" = "Avainsanat",
  "record_quality" = "Havainnon_luotettavuus",
  "record_notes" = "Havainnon_lisätiedot",
  "determiner" = "Määrittäjä",
  "team" = "Havainnoijat",
  "event_notes" = "Keruutapahtuman_lisätiedot",
  "event_id" = "Keruutapahtuman_tunniste",
  "formatted_date_time" = "Aika",
  "date_start" = "Keruu_aloitus_pvm",
  "date_end" = "Keruu_lopetus_pvm",
  "locality" = "Sijainti",
  "municipality" = "Kunta",
  "bio_province" = "Eliömaakunta",
  "coordinates_uncertainty" = "Paikan_tarkkuus_metreinä",
  "state_land" = "Valtion_maalla",
  "footprint_euref" = "ETRS_TM35FIN_WKT",
  "lat_euref" = "ETRS_TM35FIN_N",
  "lon_euref" = "ETRS_TM35FIN_E",
  "document_id" = "Havaintoerän_tunniste",
  "collection_id" = "Aineiston_tunniste",
  "collection" = "Aineisto",
  "data_source" = "Aineistolähde",
  "collection_quality" = "Aineiston_laatu",
  "restriction_reason" = "Karkeistuksen_syy",
  "document_notes" = "Havaintoerän_lisätiedot",
  "atlas_code" = "Atlaskoodi",
  "atlas_class" = "Atlasluokka",
  "site_type" = "Seurantapaikan_tyyppi",
  "site_status" = "Seurantapaikan_tila",
  "Seurattava laji" = "Seurattava_laji",
  "Sijainnin tarkkuusluokka" = "Sijainnin_tarkkuusluokka",
  "Havainnon laatu" = "Havainnon_laatu",
  "Peittävyysprosentti" = "Peittävyysprosentti",
  "Havainnon määrän yksikkö" = "Havainnon_määrän_yksikkö",
  "Vesistöalue" = "Vesistöalue",
  "Merialueen tunniste" = "Merialueen_tunniste",
  "ely_center" = "Vastuualue",
  "geom" = "geom"
)
