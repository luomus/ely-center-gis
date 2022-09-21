#' @noRd
#' @importFrom dplyr rowwise ungroup
#' @importFrom sf st_as_sfc st_is_empty st_multipoint st_transform
transform_footprint <- function(df) {

  footprint <- df[["footprint_wgs84"]]

  df[["footprint_wgs84"]] <- NULL

  footprint[is.na(footprint)] <- "POLYGON EMPTY"

  footprint <- sf::st_as_sfc(footprint, crs = 4326L)

  footprint <- sf::st_transform(footprint, crs = 3067L)

  geoms <- geometry_type_chr(footprint)

  gc <- geoms == "GEOMETRYCOLLECTION"

  uncollected <- lapply(footprint[gc], uncollect)

  footprint[gc] <- sf::st_as_sfc(uncollected, crs = 3067L)

  footprint <- lapply(footprint, cast_to_multi)

  footprint <- sf::st_as_sfc(footprint, crs = 3067L)

  sub <- sf::st_is_empty(footprint) | geoms == "POINT"

  sub <- !is.na(df[["lon_euref"]]) & !is.na(df[["lat_euref"]]) & sub

  if (any(sub)) {

    points <- dplyr::rowwise(df[sub, c("lon_euref", "lat_euref")])

    points <- dplyr::mutate(
      points,
      point = list(
        sf::st_multipoint(
          matrix(c(.data[["lon_euref"]], .data[["lat_euref"]]), 1L, 2L)
        )
      )
    )

    points <- dplyr::ungroup(points)

    footprint[sub] <- points[["point"]]

  }

  df[["footprint_euref"]] <- footprint

  sf::st_geometry(df) <- "footprint_euref"

  df

}

#' @noRd
#' @importFrom sf st_multilinestring st_multipoint st_multipolygon
uncollect <- function(x) {

  gtype <- geometry_type_chr(x)

  if (identical(gtype, "GEOMETRYCOLLECTION")) {

    cgtypes <- vapply(x, geometry_type_chr, character(1L))

    utype <- unique(sub("^MULTI", "", cgtypes))

    if (identical(length(utype), 1L)) {

      x <- switch(
        utype,
        "POINT" = sf::st_multipoint(matrix(unlist(x), ncol = 2L, byrow = TRUE)),
        "LINESTRING" = sf::st_multilinestring(x),
        "POLYGON" = sf::st_multipolygon(x),
        x
      )

    } else {

      x <- lapply(x, to_polygon)

      x <- sf::st_multipolygon(x)

    }

  }

  x

}

#' @noRd
#' @importFrom sf st_cast
cast_to_multi <- function(x) {

  gtype <- geometry_type_chr(x)

  if (!grepl("MULTI", gtype)) {

    x <- sf::st_cast(x, paste0("MULTI", gtype))

  }

  x

}

#' @noRd
#' @importFrom sf st_buffer
to_polygon <- function(x) {

  geometries <- c("LINESTRING", "POINT", "MULTILINESTRING", "MULTIPOINT")

  if (geometry_type_chr(x) %in% geometries) {

    x <- sf::st_buffer(x, .5, 1L)

  }

  x

}

#' @noRd
#' @importFrom sf st_geometry_type
geometry_type_chr <- function(x) {

  as.character(sf::st_geometry_type(x))

}