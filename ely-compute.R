tryCatch(

  {

    all_subsets <-
      dplyr::tbl(con, DBI::Id(schema = "subsets", table = "mod_time")) |>
      dplyr::summarise(n = dplyr::n()) |>
      dplyr::pull(n) |>
      as.character() |>
      identical(Sys.getenv("N_SUBSETS"))

    if (all_subsets) {

      geoms <-
        pool::dbListObjects(con, DBI::Id(schema = "subsets")) |>
        getElement("table") |>
        lapply(methods::slot, "name") |>
        vapply(getElement, "", "table") |>
        setdiff("mod_time")

      unlink("ely.gpkg")

      for (geom in geoms) {

        message(sprintf("INFO [%s] %s layer updating...", Sys.time(), geom))

        tbl <- DBI::Id(schema = "subsets", table = geom)

        ely <-
          dplyr::tbl(con, tbl) |>
          dplyr::group_by(
            taxon = ifelse(is.na(taxon_id), reported_name, taxon_id),
            dplyr::across(
              dplyr::all_of(
                sub(
                  "wgs84",
                  "euref",
                  c(select[["grp"]], facts[["grp"]], "ely_center", "geom")
                )
              )
            )
          ) |>
          dplyr::summarise(
            dplyr::across(
              dplyr::all_of(select[["sum"]]),
              ~ {
                if (all(is.na(.x))) NA else sum(.x, na.rm = TRUE)
              }
            ),
            dplyr::across(
              dplyr::all_of(select[["max"]]),
              ~ {
                if (all(is.na(.x))) NA else max(.x, na.rm = TRUE)
              }
            ),
            dplyr::across(
              dplyr::all_of(c(select[["collapse"]], facts[["collapse"]])),
              ~ {

                if (all(is.na(.x))) {

                  NA

                } else {

                  stringr::str_flatten(distinct(.x), "; ")

                }

              }
            ),
            group_count = dplyr::n(),
            .groups = "drop"
          ) |>
          dplyr::mutate(
            atlas_code = dplyr::case_when(
              atlas_code == 10 ~ "1 Epätodennäköinen pesintä: havaittu lajin yksilö, havainto ei viittaa pesintään.",
              atlas_code == 20 ~ "2 Mahdollinen pesintä: yksittäinen lintu kerran, on sopivaa pesimäympäristöä.",
              atlas_code == 30 ~ "3 Mahdollinen pesintä: pari kerran, on sopivaa pesimäympäristöä.",
              atlas_code == 40 ~ "4 Todennäköinen pesintä: koiras reviirillä (esim. laulaa) eri päivinä.",
              atlas_code == 50 ~ "5 Todennäköinen pesintä: naaras tai pari reviirillä eri päivinä.",
              atlas_code == 60 ~ "6 Todennäköinen pesintä: linnun tai parin havainto viittaa vahvasti pesintään.",
              atlas_code == 61 ~ "61 Todennäköinen pesintä: lintu tai pari käy usein todennäköisellä pesäpaikalla.",
              atlas_code == 62 ~ "62 Todennäköinen pesintä: lintu tai pari rakentaa pesää tai vie pesämateriaalia.",
              atlas_code == 63 ~ "63 Todennäköinen pesintä: lintu tai pari varoittelee ehkä pesästä tai poikueesta.",
              atlas_code == 64 ~ "64 Todennäköinen pesintä: lintu tai pari houkuttelee pois ehkä pesältä / poikueelta.",
              atlas_code == 65 ~ "65 Todennäköinen pesintä: lintu tai pari hyökkäilee, lähellä ehkä pesä / poikue.",
              atlas_code == 66 ~ "66 Todennäköinen pesintä; Nähty pesä, jossa samanvuotista rakennusmateriaalia tai ravintojätettä; ei kuitenkaan varmaa todistetta munista tai poikasista.",
              atlas_code == 70 ~ "7 Varma pesintä: havaittu epäsuora todiste varmasta pesinnästä.",
              atlas_code == 71 ~ "71 Varma pesintä: nähty pesässä saman vuoden munia, kuoria, jäänteitä. Voi olla epäonnistunut.",
              atlas_code == 72 ~ "72 Varma pesintä: käy pesällä pesintään viittaavasti. Munia / poikasia ei havaita (kolo tms.).",
              atlas_code == 73 ~ "73 Varma pesintä: juuri lentokykyiset poikaset tai untuvikot oletettavasti ruudulta.",
              atlas_code == 74 ~ "74 Varma pesintä: emo kantaa ruokaa tai poikasten ulosteita, pesintä oletettavasti ruudulla.",
              atlas_code == 75 ~ "75 Varma pesintä; Havaittu epäsuora todiste varmasta pesinnästä: nähty pesässä hautova emo.",
              atlas_code == 80 ~ "8 Varma pesintä: havaittu suora todiste varmasta pesinnästä.",
              atlas_code == 81 ~ "81 Varma pesintä: kuultu poikasten ääntelyä pesässä (kolo / pesä korkealla).",
              atlas_code == 82 ~ "82 Varma pesintä: nähty pesässä munia tai poikasia.",
              atlas_code == 0 ~ NA_character_,
              atlas_code == 69 ~ NA_character_,
              atlas_code == 53 ~ NA_character_,
              atlas_code == 775 ~ NA_character_
            ),
            atlas_class = dplyr::case_when(
              atlas_class == 1 ~ "Epätodennäköinen pesintä",
              atlas_class == 2 ~ "Mahdollinen pesintä",
              atlas_class == 3 ~ "Todennäköinen pesintä",
              atlas_class == 4 ~ "Varma pesintä"
            )
          ) |>
          dplyr::select(all_of(names(cols))) |>
          dplyr::rename_with(~cols, names(cols)) |>
          dplyr::arrange(.data[[!!cols[["date_start"]]]])

        tbl <- DBI::Id(schema = "ely", table = geom)

        ely <- dplyr::compute(ely, tbl, temporary = FALSE)

        for (ely_center in ely_centers[["name"]]) {

          ely_layer_name <- sub("-keskus", "", ely_center)
          ely_layer_name <- sub(" ", "_", ely_layer_name)

          system2(
            'ogr2ogr',
            args = c(
              "-where",
              sprintf("\"\\\"Vastuualue\\\" LIKE '%%%s%%'\"", ely_center),
              "-f",
              "GPKG",
              "ely.gpkg",
              sprintf(
                "'PG:host=%s dbname=%s user=%s password=%s port=%s'",
                Sys.getenv("PGHOST"), Sys.getenv("DB_NAME"),
                Sys.getenv("PGUSER"), Sys.getenv("PGPASSWORD"),
                Sys.getenv("PGPORT")
              ),
              sprintf("'ely.%s'", geom),
              if (file.exists("ely.gpkg")) "-update" else NULL,
              "-nln",
              sprintf("%s_%s", ely_layer_name, geom)
            )
          )

        }

        pool::dbRemoveTable(con, tbl)

      }

      zip("var/ely.zip", "ely.gpkg" , flags = "-rj9qX")

    }

    message(sprintf("INFO [%s] Compute job complete", Sys.time()))

    "true"

  },
  error = function(e) {

    message(sprintf("ERROR [%s] %s", Sys.time(), e[["message"]]))

    "false"

  }

) |>
cat(file = "var/status/compute-success.txt")

cat(
  format(Sys.time(), usetz = TRUE), file = "var/status/compute-last-update.txt"
)
