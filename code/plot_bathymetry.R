###############################################################################################
# PLOT bathymetry within US West Coast Groundfish bottom trawl survey area
###############################################################################################

library(raster)
library(rgdal)
library(viridis)

# create maps of US west coast states
states <- c('California', 'Oregon', 'Washington', "Idaho", "Nevada", "Montana")
US <- raster::getData("GADM", country="USA", level=1)
US_states <- US[US$NAME_1 %in% states,]
US_WestCoast <- spTransform(US_states, CRS("+proj=tmerc +lat_0=31.96 +lon_0=-121.6 +k=1 +x_0=390000 +y_0=15000 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0"))

##############################################################################################
## Plot Fig. 1: map of study region, including bathymetry

## load custom bathymetry raster
raster_hiRes <- raster("C:/Users/cjcco/Box/Best Practices paper/bathy_clipped")
raster_hiRes = raster_hiRes / 10 # units were originally decimeters, so convert to meters
# set cells outside survey bounds to NA
raster_hiRes = reclassify(raster_hiRes, c(-Inf, -1280, NA))
raster_hiRes = reclassify(raster_hiRes, c(-50, Inf, NA), right = FALSE)

# load Cowcod Conservation Areas, not included in trawl survey
CCA = rgdal::readOGR('C:/Users/cjcco/Box/Best Practices paper/spatial_closure_boundaries/kv299cy7357.shp')
identical(crs(CCA),crs(raster_hiRes)) # check that have same CRS
# mask CCA from bathymetry raster
raster_masked = raster::mask(raster_hiRes, CCA, inverse = TRUE)

# plot map with bathymetry
pdf(file = "C:/Users/cjcco/Box/Best Practices paper/Fig2_bathymetry.pdf", width = 3.7, height = 6)
par(mar = c(3.1,3,0.1,0.1), mgp=c(2, 1, 0))
plot(raster_masked, xlim = c(-126.1,-117.1), ylim = c(32,49), legend = FALSE,
     col = viridis(255), xlab = "Longitude", ylab = "Latitude", cex.axis = 0.8)
plot(US_states, add = TRUE, col = "grey")
plot(raster_masked, legend.only=TRUE, col = viridis(255), legend.width = 0.4,
     axis.args=list(at = seq(-100,-1200,-150), labels = seq(100,1200,150), cex.axis=0.75),
     legend.args=list(text='Depth (m)', side = 4, line=2.3, cex=0.8))
compassRose(-124.5, 36.5, cex=0.6)
dev.off()
