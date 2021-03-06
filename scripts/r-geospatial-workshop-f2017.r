
setwd("/Users/patty/Documents/Dlab/dlab_workshops/r-geospatial-f2017")


## ------------------------------------------------------------------------
cafes <- read.csv('data/cafes.csv')
head(cafes)


## ------------------------------------------------------------------------
plot(cafes$long,cafes$lat)

## ---- eval=F-------------------------------------------------------------
## library(ggplot2)
## library(ggmap)
## ggplot() + geom_point(data=cafes, aes(long,lat), col="red", size=2)

## ------------------------------------------------------------------------
library(sp)
getClass("Spatial") # See all sp object types

## ------------------------------------------------------------------------
rentals <- read.csv('data/sf_airbnb_2bds.csv')
class(rentals)
dim(rentals)


## ------------------------------------------------------------------------
str(rentals)

## ------------------------------------------------------------------------
head(rentals)

## ------------------------------------------------------------------------
hist(rentals$price)

## ------------------------------------------------------------------------
cheap <- subset(rentals, price < 401)
hist(cheap$price)

## ------------------------------------------------------------------------
cheap_good <- subset(cheap, review_scores_rating > 98)
hist(cheap$price)

## ------------------------------------------------------------------------

#First make a copy
cheap_good_orig <- cheap_good

coordinates(cheap_good) <- c('longitude','latitude')
class(cheap_good)

## ------------------------------------------------------------------------
str(cheap_good_orig)

## ---- eval=F-------------------------------------------------------------
## str(cheap_good)

## ---- eval=F-------------------------------------------------------------
## summary(cheap_good)
## head(cheap_good@coords)
## head(cheap_good@data)
## cheap_good@bbox
## cheap_good@proj4string

## ------------------------------------------------------------------------

cheap_good@proj4string # get a CRS object


## ------------------------------------------------------------------------
# Create a CRS object from its proj4 string
WGS84_CRS <- CRS("+proj=longlat +datum=WGS84 +no_defs 
                    +ellps=WGS84 +towgs84=0,0,0") 

# Set the CRS of the SPDF
proj4string(cheap_good) <- WGS84_CRS

# check it
cheap_good@proj4string

## ---- eval=F-------------------------------------------------------------
## 
## # or use the EPSG code directly
## proj4string(cheap_good) <- CRS("+init=epsg:4326")
## 
## # or enter the string
## proj4string(cheap_good) <- CRS("+proj=longlat
##                                +ellps=WGS84 +datum=WGS84 +no_defs")
## 

## ---- eval=F-------------------------------------------------------------
## 
## # 4326 is the code for WGS84
## proj4string(cheap_good) <- CRS("+init=epsg:4326")
## 

## ------------------------------------------------------------------------

plot(cheap_good)


## ------------------------------------------------------------------------

plot(cheap_good, col="red", bg="lightblue", pch=21, cex=2)


## ------------------------------------------------------------------------

spplot(cheap_good,"price")


## ------------------------------------------------------------------------

library(rgdal)

# See what file types are supported by rgdal drivers
# ogrDrivers()$name


## ------------------------------------------------------------------------

sfboundary <- readOGR(dsn="data",layer="sf_boundary")


## ------------------------------------------------------------------------

sfboundary <- readOGR(dsn="data",layer="sf_boundary")

# or
# sfboundary <- readOGR("data","sf_boundary")
# but not
#sfboundary <- readOGR(dsn="data/",layer="sf_boundary")


## ---- eval=F-------------------------------------------------------------
## str(sfboundary)
## summary(sfboundary)

## ------------------------------------------------------------------------

plot(sfboundary)


## ------------------------------------------------------------------------
head(sfboundary@data)   

## ------------------------------------------------------------------------

sfboundary@proj4string


## ------------------------------------------------------------------------

plot(sfboundary)
points(cheap_good, col="red")


## ------------------------------------------------------------------------
plot(sfboundary)
points(cheap_good, col="red")

## ---- eval=F-------------------------------------------------------------
## 
## proj4string(sfboundary)
## proj4string(cheap_good)
## proj4string(sfboundary) == proj4string(cheap_good)
## 

## ------------------------------------------------------------------------

proj4string(sfboundary)
proj4string(cheap_good)
proj4string(sfboundary) == proj4string(cheap_good)


## ------------------------------------------------------------------------
sfboundary@bbox
cheap_good@bbox

## ------------------------------------------------------------------------

sf_lonlat <- spTransform(sfboundary, WGS84_CRS)



## ---- eval=F-------------------------------------------------------------
## proj4string(cheap_good) == proj4string(sf_lonlat)
## 

## ------------------------------------------------------------------------
plot(sf_lonlat)
points(cheap_good, col="red")
points(cheap_good[cheap_good$price<100,], col="green", pch=19)


## ---- eval=F-------------------------------------------------------------
## # write transformed data to a new shapefile
## writeOGR(sf_lonlat, dsn = "data", layer =  "sf_bounary_geo",
##           driver="ESRI Shapefile")
## 
## # is it there?
## dir("data")

## ------------------------------------------------------------------------
sf_streets <- readOGR(dsn='data/sf_highways.geojson', layer="OGRGeoJSON")

## ------------------------------------------------------------------------
plot(sf_streets)


## ---- eval=F-------------------------------------------------------------
## str(sf_streets)
## summary(sf_streets)

## ------------------------------------------------------------------------
plot(sf_lonlat)
lines(sf_streets)
points(cheap_good, col="red")
points(cheap_good[cheap_good$price<200,], col="green")

## ------------------------------------------------------------------------
plot(cheap_good, col="red")
lines(sf_streets)
plot(sf_lonlat, add=TRUE)  # note syntax

## ------------------------------------------------------------------------
library(tmap)


## ------------------------------------------------------------------------
uspop <- readOGR("./data", "us_states_pop")

plot(uspop)

## ------------------------------------------------------------------------

qtm(uspop)


## ------------------------------------------------------------------------
qtm(uspop,"POPULATION")

## ------------------------------------------------------------------------
tm_shape(uspop) + tm_polygons(col="beige", border.col = "red")


## ------------------------------------------------------------------------
tm_shape(uspop) + tm_polygons(col="#f6e6a2", border.col = "white")

## ------------------------------------------------------------------------
tm_shape(uspop) + tm_polygons(col="#f6e6a2", border.col = "black", alpha=0.5, lwd=0.5)


## ------------------------------------------------------------------------
tm_shape(uspop) + tm_polygons(col="#f6e6a2", border.col = "white")

## ------------------------------------------------------------------------
tm_shape(uspop, projection="+init=epsg:5070") + tm_polygons(col="#f6e6a2", border.col = "white")

## ------------------------------------------------------------------------
uspop_5070 <- spTransform(uspop, CRS("+init=epsg:5070"))


## ------------------------------------------------------------------------
tm_shape(uspop_5070) + tm_polygons(col="#f6e6a2", border.col = "white")

## ------------------------------------------------------------------------
tm_shape(uspop_5070) + tm_polygons(col="#f6e6a2", border.col="#f6e6a2") +
tm_shape(uspop) + tm_borders(col="purple")

## ------------------------------------------------------------------------
tm_shape(uspop_5070) + tm_polygons(col="POPULATION")

## ------------------------------------------------------------------------
library(RColorBrewer)

## ------------------------------------------------------------------------
display.brewer.all()


## ------------------------------------------------------------------------
display.brewer.all(type="qual")

## ------------------------------------------------------------------------
display.brewer.all(type="seq")

## ------------------------------------------------------------------------
display.brewer.all(type="div")

## ------------------------------------------------------------------------
tm_shape(uspop_5070) + tm_polygons(col="POPULATION", palette="BuPu")

## ------------------------------------------------------------------------
tm_shape(uspop_5070) + tm_polygons(col="POPULATION", palette="Spectral", 
                                auto.palette.mapping=FALSE)

## ------------------------------------------------------------------------
tm_shape(uspop_5070) + tm_polygons(col="POPULATION", style="quantile")

## ------------------------------------------------------------------------
tm_shape(uspop_5070) + tm_polygons(col="POPULATION", style="jenks")

## ---- eval=F-------------------------------------------------------------
## tm_shape(uspop_5070) + tm_polygons(col="POPULATION", palette="BuPu",
##                                     style="jenks", n=9)

## ------------------------------------------------------------------------
tm_shape(uspop_5070) + tm_polygons(col=c("POPULATION","popdens"), 
                              style=c("jenks","jenks"))

## ------------------------------------------------------------------------
tm_shape(uspop_5070) + tm_symbols(col="popdens", style="jenks")

## ------------------------------------------------------------------------
tm_shape(uspop_5070) + tm_symbols(col="popdens", style="jenks")

## ------------------------------------------------------------------------
tm_shape(uspop_5070) + tm_polygons(col="white", border.alpha = 0.5) + 
  tm_shape(uspop_5070) + tm_symbols(col="popdens", style="jenks")

## ---- echo=F-------------------------------------------------------------
tm_shape(uspop_5070) + tm_polygons(col="white", border.alpha = 0.5) + 
  tm_shape(uspop_5070) + tm_symbols(col="popdens", style="jenks")

## ---- echo=F-------------------------------------------------------------

  tm_shape(uspop_5070) + tm_squares(col="popdens", style="jenks")

## ------------------------------------------------------------------------
tm_shape(uspop_5070) + tm_polygons(col="white", border.alpha = 0.5) + 
  tm_shape(uspop_5070) + tm_symbols(size="popdens", style="jenks")

## ---- eval=F-------------------------------------------------------------
## tm_shape(uspop_5070) + tm_polygons(col="white", border.alpha = 0.5) +
##   tm_shape(uspop_5070) + tm_symbols(size="popdens", style="sd",
##      size.lim=c(1,500), col="purple", alpha=0.5, border.col="grey",
##      title.size="Population Density (km2)")

## ---- eval=F-------------------------------------------------------------
## tm_shape(uspop_5070 ) + tm_polygons("POPULATION") +
##     tm_scale_bar(position=c("left","bottom")) +
##     tm_compass(position=c("right","center")) +
##     tm_style_classic(title="Patty's Map",
##     title.position=c("center","top"), inner.margins=c(.05,.05, .15, .25))

## ---- echo=F-------------------------------------------------------------
tm_shape(uspop_5070 ) + tm_polygons("POPULATION") + 
    tm_scale_bar(position=c("left","bottom")) + 
    tm_compass(position=c("right","center")) + 
    tm_style_classic(title="Patty's Map", 
    title.position=c("center","top"), inner.margins=c(.05,.05, .15, .25))

## ---- echo=F-------------------------------------------------------------
tm_shape(uspop_5070) + tm_polygons(col="white", border.alpha = 0.5) + 
  tm_shape(uspop_5070) + tm_symbols(size="popdens", style="sd", 
     size.lim=c(1,500), col="purple", alpha=0.5, border.col="grey", 
     title.size="Population Density (km2)")

## ---- eval=F-------------------------------------------------------------
## 
## tmap_mode("view")
## 
## tm_shape(uspop_5070) + tm_symbols(size="popdens", style="sd",
##     col="purple", border,col="black", alpha=0.5)

## ---- eval=F-------------------------------------------------------------
## 
## tmap_mode("view")
## 
## tm_shape(uspop_5070) + tm_symbols(size="popdens", style="sd",
##     col="purple", border.col="black", alpha=0.5,
##     popup.vars=c("NAME","POPULATION","popdens"))

## ------------------------------------------------------------------------
tmap_mode('plot')

## ---- eval=F-------------------------------------------------------------
## 
## mymap <- tm_shape(uspop_5070) +
##   tm_polygons("popdens", style="jenks", title="Population Density")
## 
## tm_view(mymap)

## ---- eval=F-------------------------------------------------------------
## tm_shape(sf_lonlat) +
##     tm_polygons(col="beige", border.col = "blue") +
## tm_shape(sf_streets) +
##     tm_lines(col="black", lwd = 3) +
## tm_shape(sf_streets) +
##     tm_lines(col="white", lwd = 1) +
## tm_shape(cheap_good) +
##     tm_symbols(col="red", size=0.5, alpha=0.5, style="jenks")
## 

## ---- echo=F-------------------------------------------------------------
tm_shape(sf_lonlat) + 
    tm_polygons(col="beige", border.col = "blue") + 
tm_shape(sf_streets) + 
    tm_lines(col="black", lwd = 3) +
tm_shape(sf_streets) + 
    tm_lines(col="white", lwd = 1) +
tm_shape(cheap_good) + 
    tm_symbols(col="red", size=0.5, alpha=0.5, style="jenks")


## ---- eval=F-------------------------------------------------------------
## tm_shape(sf_lonlat) +
##     tm_polygons(col="beige", border.col = "blue") +
## tm_shape(sf_streets) +
##     tm_lines(col="black", lwd = 3) +
## tm_shape(sf_streets) +
##     tm_lines(col="white", lwd = 1) +
## tm_shape(cheap_good) +
##     tm_symbols(col="red", size = 0.5, alpha=0.5, style="jenks",
##     popup.vars=c("name","price","listing_url"))
## 
## tmap_mode("view")

## ---- eval=F-------------------------------------------------------------
## tm_shape(sfboundary) +
##   tm_polygons(col="beige") +
## tm_shape(cheap_good) +
##   tm_symbols(shape="property_type", size=0.5)

## ---- echo=F-------------------------------------------------------------
tm_shape(sfboundary) + 
  tm_polygons(col="beige") + 
tm_shape(cheap_good) + 
  tm_symbols(shape="property_type", size=0.5)

## ---- eval=F-------------------------------------------------------------
## bigmap <- tm_shape(sfboundary) + tm_polygons(col="beige") +
##   tm_shape(cheap_good) +
##   tm_symbols(size="accommodates", title.size="Accomodates", col="price",
##       title.col="Price", shape="property_type", title.shape="Property Type") +
##   tm_layout( legend.bg.color="white",inner.margins=c(.05,.05, .15, .25),
##       title="Airbnb 2 Bedroom Rentals, San Francisco Fall 2017",
##       legend.position=c("right","center"))
## 
##  bigmap

## ---- echo=F-------------------------------------------------------------
bigmap <- tm_shape(sfboundary) + tm_polygons(col="beige") + 
  tm_shape(cheap_good) + 
  tm_symbols(size="accommodates", title.size="Accomodates", col="price", 
      title.col="Price", shape="property_type", title.shape="Property Type") +
  tm_layout( legend.bg.color="white",inner.margins=c(.05,.05, .15, .25), 
      title="Airbnb 2 Bedroom Rentals, San Francisco Fall 2017", 
      legend.position=c("right","center"))
 
 bigmap

## ---- eval=F-------------------------------------------------------------
## map1 <- tm_shape(uspop_5070) + tm_polygons(col="POPULATION", style="jenks")
## save_tmap(map1, "tmap_choropleth.png", height=4) # Static image file
## save_tmap(map1, "tmap_choropleth.html") # interactive web map

## ---- eval=F-------------------------------------------------------------
## library(leaflet)
## leaflet(cheap_good) %>% addTiles() %>%
##     addCircleMarkers(data = cheap_good, radius = 5, stroke=F,
##     color = "purple", fillOpacity = 0.75
##   )

## ---- eval=F-------------------------------------------------------------
## pal <- colorQuantile("Reds",NULL,5)
## leaflet(cheap_good) %>% addTiles() %>%
##     addCircleMarkers(
##       data = cheap_good,
##       radius = 6,
##       color = ~pal(price),
##       stroke = F,
##       fillOpacity = 0.75
##   )

## ---- eval=F-------------------------------------------------------------
## popup_content <- cheap_good$name
## popup_content <- paste0(popup_content, "<br>Price per night: $", cheap_good$price)
## popup_content <- paste0(popup_content, "<br><a href=",cheap_good$listing_url,">More info...</a>")
## 
## leaflet(cheap_good) %>% addTiles() %>%
##     addCircleMarkers(
##       data = cheap_good,
##       radius = 6,
##       color = ~pal(price),
##       stroke = F,
##       fillOpacity = 0.75,
##       popup = popup_content)

## ---- eval=F-------------------------------------------------------------
## 
## coit_tower <- c("-122.405837,37.802032")
## 
## cheap_good$coit_dist <-
##   spDistsN1(cheap_good,c(-122.405837,37.802032), longlat = T)
## 
## head(cheap_good@data)
## 

## ------------------------------------------------------------------------
sessionInfo()

## ---- eval=F-------------------------------------------------------------
## library(knitr)
## purl("r-geospatial-workshop-f2017.Rmd", output = "scripts/r-geospatial-workshop-f2017.r", documentation = 1)

