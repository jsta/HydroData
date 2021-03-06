#' @title Find Neareast COMIDs
#' @description \code{findNearestCOMID} returns a \code{SpatialPointsDataFrame} of the 'n' number of COMIDs closest to a declared point.
#' @param point a point described by lat/long, can be piped from \link[AOI]{geocode}
#' @param n the number of COMIDs to find (default = 5)
#' @param ids If TRUE,  a vector of NHD COMIDs is added to retuned list (default = \code{FALSE})
#' @param bb If TRUE, the geometry of the minimum bounding area of the features is added to returned list  (default = \code{FALSE})
#' @export
#' @seealso findAirports
#' @return a list() of minimum length 2: AOI and ap
#' @author Mike Johnson
#' @examples
#' \dontrun{
#' pt = geocode("University of Oregon") %>% findNearestCOMID(n = 5)
#' }

findNearestCOMID = function(point = NULL, n = 5, ids = FALSE, streamorder = NULL, bb = FALSE){

  h = 5
  w = 5
  lines = data.frame()
  fin = list(loc = point)

  while (dim(lines)[1] < n) {
    lines <-  suppressWarnings(
      findNHD(
        AOI = suppressMessages(AOI::aoi_get( x = c(point$lat, point$lon, h, w ))),
        streamorder = streamorder)
    )

    lines = lines[['nhd']]

    if (is.null(lines)) {
      lines = data.frame()
    }

    h = h + 2
    w = w + 2
  }

  lines = lines %>% sf::st_as_sf()
  point = sf::st_as_sf(x = point,  coords = c("lon", "lat"), crs = as.character(AOI::aoiProj))
  dist = data.frame(comid = lines$comid, Distance_km = sf::st_distance(x = lines, y = point))
  dist = dist[order(dist$Distance_km)[1:n], ]

  fin[["nhd"]] = as_Spatial(merge(lines, dist, by = "comid"))
  if (bb) { fin[["AOI"]] = AOI::getBoundingBox(fin$nhd) }
  if (ids) { fin[["comids"]] = unique(fin$nhd$comid) }

  return(fin)

}


