#' ---
#' title: "Geospatial Data & Maps in R, pt 2"
#' author: "Patty Frontiera"
#' date: "February 2018"
#' output: 
#'   ioslides_presentation:
#'     widescreen: true
#'     smaller: true
#' ---
#' 
## ----setup, include=FALSE------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)

#' 
#' ## Part II Overview
#' 
#' Mapping spatial objects with tmap
#' 
#' Taste of Spatial Analysis
#' 
#' ## Part II Prep
#' 
#' 1. https://github.com/dlab-geo/r-geospatial-workshop
#' 
#' - Click *Clone or Download* and download the zip file
#' - Upzip the zip file and make a note of the folder in which it is located
#' 
#' 2. Open RStudio and start a new script
#' 
#' 3. Set your working directory to where you downloaded and unzipped the files
#' 
#' 4. Follow along by opening `r-geospatial-workshop-feb2018-pt2.html` in a web browser
#' 
#' 5. Make sure required libraries are installed. 
#' 
#' - sp, rgdal, rgeos, tmap, ggplot2, RColorbrewer, classInt
#' 
#' 
#' 
#' ## R Spatial Libraries
#' 
#' Let's load the R libraries we will use
#' 
#' ### Load Libraries
## ---- eval=FALSE---------------------------------------------------------
## library(sp)     # spatial objects and methods
## library(rgdal)  # read/write from file; manage CRSs
## library(rgeos)  # geometric operations
## library(tmap)   # mapping spatial objects

#' 
#' ##
## ---- echo=FALSE---------------------------------------------------------
library(sp)     # spatial objects and methods
library(rgdal)  # read and write from file
library(rgeos)  # geometric operations
library(tmap)   # mapping spatial objects

#'  
#' ## Recap
#' 
#' In the last workshop we:
#' 
#' - Loaded geodata from CSV files into data frames with `read.csv`
#' - Mapped geographic data frames with `ggplot` and `ggmap`
#' - Promoted data frames to `SpatialPointsDataFrames` with the `sp::coordinates`
#' - Loaded geodata from shapefiles with `rgdal::readOGR`
#' - Defined `CRSs` with the function `sp::proj4string` and `sp::CRS`
#' - Transformed CRSs with the function `sp::spTransform`
#' - Saved the sp object `sfboundary_lonlat` as a shapefile using `rgdal::writeOGR`
#' 
#' ## Load files from last workshop
#' 
#' Below are the files we will work with.
#' 
#' All of these are in the `data` folder.
#' 
#' - sf_properties_25ksample.csv
#' - sf_boundary.shp 
#' - sf_highways.shp
#' - bart.csv
#' 
#' ## Set your working directory
#' 
#' Use `setwd` to set your working directory to the location of the tutorial files.
#' 
#' For example:
#' 
## ---- eval=FALSE---------------------------------------------------------
## setwd("~/Documents/Dlab/workshops/2018/rgeo/r-geospatial-workshop/r-geospatial-workshop")

#' 
#' 
#' ## SF Properties 2015
#' 
#' Read in from CSV file
## ------------------------------------------------------------------------
sfhomes <- read.csv('data/sf_properties_25ksample.csv', stringsAsFactors = FALSE)
sfhomes15 <- subset(sfhomes, as.numeric(SalesYear) == 2015)
class(sfhomes15)

#' 
#' ## SF Properties 2015
#' 
#' Make it spatial
## ------------------------------------------------------------------------
sfhomes15_sp <- sfhomes15  # why do we do this?
coordinates(sfhomes15_sp) <- c('lon','lat') 
proj4string(sfhomes15_sp) <- CRS("+init=epsg:4326")

#' 
#' ## SF Boundary and SF Highways
#' 
#' Read in the `sf_boundary.shp` and `sf_highways.shp` shapefiles
#' 
#' - what function will you use?
#' 
#' ## SF Boundary and SF Highways
#' 
## ------------------------------------------------------------------------
sf_boundary <- readOGR(dsn="data", layer="sf_boundary")

sf_highways <- readOGR(dsn="data", layer="sf_highways")

#' 
#' ## SF BART Stations
#' 
#' Read in the `bart.csv` file
#' 
#' Promote the data frame to a `SpatialPointsDataFrame`
#' 
#' ## SF BART Stations
#' 
## ------------------------------------------------------------------------

bart<- read.csv("data/bart.csv", stringsAsFactors = FALSE)

coordinates(bart) <- c("X","Y")

#' 
#' ## Get the CRS of each sp object
#' 
#' Are they all the same? Describe.
## ------------------------------------------------------------------------
proj4string(sf_highways)
proj4string(sf_boundary)
proj4string(bart)
proj4string(sfhomes15_sp)

#' 
#' ## Define the CRS for SF BART stations
#' 
#' `SpatialPointsDataFrame` will not have a defined CRS if they were created from a data frame
#' 
#' We need to define the CRS of the 'bart' object
#' 
#' What do we need to know to do this
#' 
#' Try it for the `bart` layer
#' 
#' ## Terminology
#' 
#' In `GIS` a spatial object is called a `layer`
#' 
#' One element in a layer is called a `feature`
#' 
#' A `feature` consists of the `geometry` and the `attribute data` that describe it
#' 
#' ## Define CRS
#' 
#' Where is the CRS definition coming from?
#' 
## ------------------------------------------------------------------------
proj4string(bart) <- CRS("+init=epsg:4326")

#' 
#' *How else could we reference the CRS?*
#' 
#' 
#' ## Transform data to common CRS
#' 
#' In order to perform spatial analysis we need to first convert all data objects to a common CRS.
#' 
#' Which type? Projected or Geographic CRS?
#' 
#' 
#' ## Geographic vs. Projected CRS
#' 
#' If my goal is to create maps, I may convert all data to a geographic CRS.
#' 
#' - Which one?
#' 
#' If my goal is to do spatial analysis, I will convert to a projected CRS.
#' 
#' - Which one?
#' 
#' 
#' ## Common CRS Codes
#' 
#' **Geographic CRSs**
#' 
#' * `4326` Geographic, WGS84 (default for lon/lat)
#' 
#' * `4269` Geographic, NAD83 (USA Fed agencies like Census)
#' 
#' 
#' **Projected CRSs**
#' 
#' * `5070` USA Contiguous Albers Equal Area Conic
#' 
#' * `3310` CA ALbers Equal Area
#' 
#' * `26910` UTM Zone 10, NAD83 (Northern Cal)
#' 
#' * `3857` Web Mercator (web maps)
#' 
#' 
#' ## Transform all layers to UTM 10N, NAD83
#' 
#' Use `spTransform` to transform `bart` and `sfhomes15_sp` to `UTM 10N, NAD83`
#' 
#' `sf_highways` and `sf_boundary` already have this CRS
#' 
#' Recall, this transformation is called `projecting` or `reprojecting`
#' 
#' Try it....
#' 
#' ## Transform all layers to UTM 10, NAD83
#' 
#' Note the two methods for doing same thing.
#' 
## ------------------------------------------------------------------------
sfhomes15_utm <- spTransform(sfhomes15_sp, CRS("+init=epsg:26910"))

bart_utm <- spTransform(bart, CRS(proj4string(sf_boundary)))

#' 
#' 
#' ## Check
#' 
#' Do they match?
#' 
## ------------------------------------------------------------------------
proj4string(bart_utm) 

proj4string(sfhomes15_utm)

#' 
#' ## Reproject the CRS AGAIN!
#' 
## ------------------------------------------------------------------------
#sfhomes15_utm <- spTransform(sfhomes15_sp, CRS("+init=epsg:26910"))

sfhomes15_utm <- spTransform(sfhomes15_sp, CRS(proj4string(sf_boundary)))

# check
proj4string(sfhomes15_utm)
proj4string(sf_boundary)

#' 
#' 
#' 
#' ## Map all layers
#' 
## ------------------------------------------------------------------------
plot(sf_boundary)
lines(sf_highways, col='purple', lwd=4)
points(sfhomes15_utm)
plot(bart_utm, col="red", pch=15, add=T)

#' 
#' # tmap
#' 
#' ## tmap
#' 
#' `tmap` stands for thematic map
#' 
#' It's a powerful toolkit for creating maps with `sp` objects
#' 
#' yet, with less code than the alternatives
#' 
#' Syntax should be familar to ggplot2 users, but simpler
#' 
#' Relatively easy to create & save interactive maps
#' 
#' 
#' ## tmap
#' 
#' Load the library
#' 
## ------------------------------------------------------------------------
library(tmap)

#' You may need to install /load dependencies
#' - ggplot2, RColorbrewer, classInt, leaflet libraries
#' 
#' ## Mapping Spatial Objects
#' 
## ---- eval=F-------------------------------------------------------------
## tm_shape(sf_boundary) +
##   tm_polygons(col="beige", border.col="black")

#' 
#' Use `tm_shape(<sp_object>)`  to specifiy a sp object
#' 
#' Add `+ tm_<element>(...)` to style the layer symbology
#' 
#' ...and other options for creating a publication ready map
#' 
#' ## Mapping polygons
#' 
## ------------------------------------------------------------------------
tm_shape(sf_boundary) + 
  tm_polygons(col="beige", border.col="black")

#' 
#' 
#' ## tmap starting points
#' 
#' ?tmap
#' 
#' ?tmap_shape
#' 
#' ?tmap_element
#' 
#' - ?tm_polygons (tm_fill, tm_borders)
#' - ?tm_symbols (tm_dots, etc...)
#' 
#' - [tmap in a Nutshell](https://cran.r-project.org/web/packages/tmap/vignettes/tmap-nutshell.html) 
#' 
#' 
#' ## Mapping Points
#' 
## ------------------------------------------------------------------------
tm_shape(sfhomes15_utm) + 
  tm_dots(col="red", size=.25)

#' 
#' ## Mapping Lines
## ------------------------------------------------------------------------
tm_shape(sf_highways) + 
  tm_lines(col="black")

#' 
#' ## Symbolizing Point Colors by Data Values
#' 
## ------------------------------------------------------------------------
tm_shape(sfhomes15_sp) + 
  tm_dots(col="totvalue", size=.25)    # column names must be quoted

#' 
#' ## Layering data
#' 
#' How do you think we would map all sp objects together?
#' 
#' 
#' ## Combining the layers
## ---- eval=F-------------------------------------------------------------
## tm_shape(sf_boundary) +
##   tm_polygons(col="beige", border.col="black") +
## tm_shape(sf_highways) +
##   tm_lines(col="black") +
## tm_shape(sfhomes15_utm) +
##   tm_dots(col="totvalue", size=.25)
## 

#' ## Combining the layers
## ---- echo=F-------------------------------------------------------------
tm_shape(sf_boundary) + 
  tm_polygons(col="beige", border.col="black") +
tm_shape(sf_highways) + 
  tm_lines(col="black") +
tm_shape(sfhomes15_utm) + 
  tm_dots(col="totvalue", size=.25) 
 

#' 
#' 
#' ## CRS management in tmap
#' 
#' Below we are mapping `sf_boundary` (UTM10) and `sfhomes15_sp` (WGS84)
## ---- eval=F-------------------------------------------------------------
## tm_shape(sf_boundary) +
##   tm_polygons(col="beige", border.col="black") +
## tm_shape(sfhomes15_sp) +
##   tm_dots(col="totvalue", size=.25)

#' 
#' ## CRS management in tmap
#' 
#' If the CRSs are defined, `tmap` will use that info
#' 
#' If not, `tmap` will assume `WGS84` 
#' 
#' and dynamically `reproject` subsequent layers to match first one added to map
## ---- echo=F-------------------------------------------------------------
tm_shape(sf_boundary) + 
  tm_polygons(col="beige", border.col="black") +
tm_shape(sfhomes15_sp) + 
  tm_dots(col="totvalue", size=.25) 

#' 
#' ## Making it more Polished
#' 
## ---- eval=F-------------------------------------------------------------
## tm_shape(sf_boundary) +
##   tm_polygons(col="beige", border.col="black") +
## tm_shape(sfhomes15_utm) +
##   tm_dots(col="totvalue", size=.25, title = "San Francisco Property Values (2015)") +
## tm_layout(inner.margins=c(.05, .2, .15, .05)) # bottom, left, top, right

#' 
#' ## Making it more Polished
#' 
## ---- echo=F-------------------------------------------------------------
tm_shape(sf_boundary) + 
  tm_polygons(col="beige", border.col="black") +
tm_shape(sfhomes15_utm) + 
  tm_dots(col="totvalue", size=.25, title = "San Francisco Property Values (2015)") + 
tm_layout(inner.margins=c(.05, .2, .15, .05)) # bottom, left, top, right

#' 
#' ## Interactive mapping
#' 
## ------------------------------------------------------------------------
tmap_mode("view")

#' 
#' ## Handy Shortcut
## ---- eval=F-------------------------------------------------------------
## 
## last_map()  # display the last map
## 

#' 
#' ## Handy Shortcut
## ------------------------------------------------------------------------

last_map()  # display the last map 


#' 
#' ## Reset the mode to static plot
#' 
## ------------------------------------------------------------------------
tmap_mode("plot")

#' 
#' 
#' ## tmap
#' 
#' Questions?
#' 
#' Check out [tmap in a Nutshell](https://cran.r-project.org/web/packages/tmap/vignettes/tmap-nutshell.html) 
#' 
#' # Spatial Analysis
#' 
#' ## Spatial Analysis
#' 
#' 1. Mapping / plotting to see location and distribution
#' 
#' 2. **Asking questions of, or querying, your data. **
#' 
#' 3. Cleaning & reshaping the data
#' 
#' 4. Applying analysis methods
#' 
#' 5. Mapping analysis results
#' 
#' 6. Repeat as needed
#' 
#' 
#' ## Spatial Queries
#' 
#' There are two key types of spatial queries
#' 
#' - **spatial measurement** queries, 
#'     - e.g. area, length, distance
#' 
#' 
#' - **spatial relationship** queries, 
#'     - e.g. what locations in A are also in B.
#' 
#' These types are often combined, e.g.
#' 
#' - What is the area of region A is within region B?
#' 
#' # Spatial Measurement Queries
#' 
#' ## Computing Area
#' 
#' What is the area of SF Boundary?
#' 
#' - Use `rgeos::gArea` to compute
#' - What are the units?
#' 
#' 
## ------------------------------------------------------------------------
gArea(sf_boundary)

#' 
#' ## Area in sq km
#' 
#' Use the `rgeos` function `gArea` to compute area of polygon spatial objects.
#' 
#' - Check results against Wikipedia for [SF](https://en.wikipedia.org/wiki/San_Francisco)
#' 
## ------------------------------------------------------------------------
gArea(sf_boundary) / (1000 * 1000)

#' 
#' ## Length of highways
#' 
#' Use the `rgeos` function `gLength` to compute length of linear spatial objects.
## ------------------------------------------------------------------------
gLength(sf_highways) / 1000

#' 
#' ## Distance
#' 
#' The `rgeos` function `gDistance` will return the min distance between two geometries.
#' 
#' Distance in KM between Embarcadero & Powell St Bart stations
#' 
#' - You can check on Google Maps (always spot check!)
## ------------------------------------------------------------------------
gDistance(bart_utm[bart_utm$STATION == 'EMBARCADERO',],
          bart_utm[bart_utm$STATION == 'POWELL STREET',]) /1000

#' 
#' ## Distance between locations
#' 
#' Get distance between all `sfhomes` and `Embarcadero` BART
#' 
## ------------------------------------------------------------------------
dist2emb<- gDistance(bart_utm[bart_utm$STATION == 'EMBARCADERO',],
                     sfhomes15_utm, byid=TRUE) /1000
# check output
nrow(dist2emb)
nrow(sfhomes15_utm)
head(dist2emb)

#' 
#' ## Distance between locations
#' 
#' *How is the output different if `byid=FALSE`* (default)
## ------------------------------------------------------------------------
#dist2emb<- gDistance(bart_utm[bart_utm$STATION == 'EMBARCADERO',],
#                     sfhomes15_utm, byid=TRUE) /1000

gDistance(bart_utm[bart_utm$STATION == 'EMBARCADERO',],
                     sfhomes15_utm) /1000

#' 
#' 
#' # Spatial Relationships
#' 
#' ## Spatial Relationships
#' 
#' **Spatial relationship queries** compare the geometries of two spatial objects in the same coordinate space (CRS).
#' 
#' There are many, often similar, functions to perform these queries (can be confusing!).
#' 
#' These operations may return logical values, lists, matrices, dataframes, geometries or spatial objects
#' 
#' - you need to check what type of object is returned 
#' 
#' - you need to check what values are returned to make sure they make sense
#' 
#' ## Spatial Relationship Queries
#' 
#' CRSs `DO` need to match
#' 
#' But ...
#' 
#' they don't need to be Projected CRSs
#' 
#' They can be any CRS
#' 
#' 
#' ## Are there any BART stations in SF?
#' 
#' This is a very common type of spatial query called a `point-in-polygon` query.
#' 
#' We can use the `rgeos` function `gIntersects` to answer this.
#' 
#' We already know the answer but we want to see how it is done.
#' 
#' 
#' ## Are there any BART stations in SF?
#' 
#' *What is the output of gIntersects?*
#' 
#'  - uncomment to find out
#'  
## ---- eval=FALSE---------------------------------------------------------
## bart_stations_in_sf <-gIntersects(bart_utm, sf_boundary)
## 
## # bart_stations_in_sf

#' 
#' ## Are there any BART stations in SF?
#' 
#' What is the output of gIntersects?
#' 
#' - uncomment to find out!
## ------------------------------------------------------------------------
bart_stations_in_sf <-gIntersects(bart_utm, sf_boundary)

bart_stations_in_sf

#' 
#' ## WHAT Bart stations are in SF
#' 
#' Same function, but `byid=TRUE`
#' What is the output of gIntersects this time?
#' 
#' - uncomment to find out!
#' 
## ------------------------------------------------------------------------
sfbart_stations <-gIntersects(bart_utm, sf_boundary, byid=TRUE)

# class(sfbart_stations)
# sfbart_stations

#' 
#' 
#' ## What Bart stations are in SF
#' 
#' What is the output of gIntersects?
#' 
#' - why is it different?
## ------------------------------------------------------------------------
sfbart_stations <-gIntersects(bart_utm, sf_boundary, byid=TRUE)

class(sfbart_stations)
sfbart_stations

#' 
#' *Why is it different?*
#' 
#' ## What are the names of the SF BART stations?
#' 
#' We can use the result of `gIntersects` to view the names of the bart stations
#' 
## ------------------------------------------------------------------------
bart_utm[as.vector(sfbart_stations),]$STATION

#' 
#' 
#' ## Subset the SPDF
#' 
#' We can use the result of `gIntersects` to subset `bart_utm`
#' 
## ------------------------------------------------------------------------
sfbart_utm <- bart_utm[as.vector(sfbart_stations),]

#' 
#' 
#' 
#' ## Map the BART stations
#' 
## ------------------------------------------------------------------------
tmap_mode("view")

tm_shape(sf_boundary) + 
  tm_polygons(col="beige", border.col="black") +
tm_shape(sfbart_utm) + 
  tm_dots(col="red")

#' 
#' 
#' 
#' ## Reset `tmap` to plot mode
#' 
#' 
## ------------------------------------------------------------------------
tmap_mode("plot")

#' 
#' ## gIntersects recap
#' 
#' `rgeos::gIntersects(geom1, geom2)` returns 
#' 
#' - returns a single TRUE/FALSE value indicating if any feature in geom1 intersects any feature in geom2 
#'     - if `byid=FALSE` (the default when not specified)
#' 
#' 
#' - returns a TRUE/FALSE matrix indicating what features in geom1 intersect features geom2 
#'     - if `byid=TRUE` 
#' 
#' 
#' ## SF Census Tracts
#' 
#' Let's consider the `sfhomes15_utm` data along with SF Census tract data 
#' 
#' 
#' ## SF Census Tracts
#' 
#' Use `readOGR` to load the shapefile `sftracts_wpop.shp`
#' 
#' - it's in the `data` folder
#' 
#' Explore the data
#' 
#' - What type of `sp` object is it?
#' - What is its CRS?
#' - What column contains the population data?
#' 
#' ## SF Census Tracts
## ------------------------------------------------------------------------
sftracts <- readOGR(dsn="./data", layer="sftracts_wpop")

class(sftracts)
proj4string(sftracts)


#' 
#' ## SF Census Tracts
## ------------------------------------------------------------------------
head(sftracts@data)

#' 
#' ## Make a Quick Plot
#' 
## ------------------------------------------------------------------------
plot(sftracts)  

#' 
#' ## Spatial Join
#' 
#' A spatial join associates rows of data in one object with rows in another object based on the spatial relationship between the two objects.
#' 
#' A spatial join is based on the comparison of two sets of geometries in the same coordinate space. 
#' 
#'  - This is also called a **spatial overlay**.
#' 
#' The default spatial relationship is `intersects`
#' 
#' 
#' 
#' 
#' ## In what census tract is each property located?
#' 
#' We need to **spatially join** the `sftracts` and `sfhomes15_utm` to answer this.
#' 
#' What spatial object are we joining data from? to?
#' 
#'  
#' ## sp::over / rgeos::over
#' 
#' Spatial overlay operations in R are implemented using `over`
#' 
#' Simple point-in-polygon operations use `sp::over`
#' 
#' More complex geometric comparisons use `rgeos::over`
#' 
#' You need to have `rgeos` package installed!
#' 
#' ##  `over(x,y)`
#' 
#' You can interperet `over(x,y)`  as:
#' 
#' - for each feature in X give me information about the first feature in Y at the corresponding location. 
#' 
#' You can interperet `over(x,y, returnList=TRUE)`  as:
#' 
#' - for each feature in X give me information about the all features in Y at the corresponding location. 
#' 
#' See `?over` for details.
#' 
#' 
#' ## So here goes...
#' 
#' *In what census tract is each SF property located?* 
#' 
## ---- eval=F-------------------------------------------------------------
## homes_with_tracts <- over(sfhomes15_utm, sftracts)

#' 
#' ## Did it work?
#' 
#' If not, why not?
#' 
#' 
#' # Coordinate reference systems (CRS) must be the same!
#' 
#' 
#' ## CRSs must be the same
#' 
#' The `over` function, like almost all spatial analysis functions, requires that both data sets be spatial objects (they are) with the same coordinate reference system (CRS). Let's investigate
#' 
## ---- eval=F-------------------------------------------------------------
## # What is the CRS of the property data?
## proj4string(sfhomes15_utm)
## 
## # What is the CRS of the census tracts?
## proj4string(sftracts)

#' 
#' 
#' ## Transform the CRS
#' 
## ------------------------------------------------------------------------
# Transform the CRS for tracts to be the same as that for sfhomes15_sp
sftracts_utm <- spTransform(sftracts, CRS(proj4string(sfhomes15_utm)))

# make sure the CRSs are the same
proj4string(sftracts_utm) == proj4string(sfhomes15_utm) 

#' 
#' Now let's try that overlay operation again
#' 
#' ## Try 2
#' 
#' *In what tract is each SF property is located?* 
#' 
## ------------------------------------------------------------------------

homes_with_tracts <- over(sfhomes15_utm, sftracts_utm)

#' 
#' 
#' 
#' 
#' ## `over` output
#' 
#' What is our output? Does it answer our question?
#' 
#' What type of data object did the over function return?
#' 
#' Do we need to add `returnList = TRUE`
#' 
## ---- eval=F-------------------------------------------------------------
## homes_with_tracts <- over(sfhomes15_utm, sftracts_utm)
## 
## class(homes_with_tracts)
## nrow(homes_with_tracts)
## nrow(sftracts_utm)
## nrow(sfhomes15_utm)

#' 
#' ## Review the Over output
#' 
## ------------------------------------------------------------------------
homes_with_tracts <- over(sfhomes15_utm, sftracts_utm)
class(homes_with_tracts)
nrow(homes_with_tracts)
nrow(sftracts_utm)
nrow(sfhomes15_utm)


#' 
#' ## Review the over output
## ------------------------------------------------------------------------
head(homes_with_tracts)

#' 
#' 
#' 
#' ## `over` discussion
#' 
#' Our output *homes_with_tracts* is a **data frame** that contains 
#' 
#' - the same number of rows as `sfhomes15_utm` - in same order
#' - the id of each property in `sfhomes15_utm`
#' - the data columns from `sftracts_utm@data` including the census tract id (GEOID) 
#' 
#' So we are close to answering our question.
#' 
#' But for the data to be useful we need 
#' - to add the `GEOID` column in `homes_with_tracts` to `sfhomes15_utm`
#' 
#' ## Add the GEOID column
#' 
#' *CAUTION: this only works because the data are in the same order!*
## ------------------------------------------------------------------------
sfhomes15_utm$home_geoid <- homes_with_tracts$GEOID

# Review and note the change
#head(sfhomes15_utm@data)

#' 
#' 
#' ## WOW
#' 
#' Data linkage via space!
#' 
#' The `over` operation gave us the census tract data info for each point in `sfhomes15_utm`
#' 
#' We added the `GEOID` for each point to the `@data` slot of `sfhomes15_utm`
#' 
#' We can now join `sfhomes15_utm` points by `GEOID` to any census variable, eg median household income, and then do an analysis of the relationship between, for example, property value and that variable.
#' 
#' **How would we do that?**
#' 
#' ## Read in the census data
#' 
#' Because `GEOIDs` can have leading zeros, we set the `colClasses` to make sure they are not stripped.
## ------------------------------------------------------------------------
med_hh_inc <- read.csv("data/sf_med_hh_income2015.csv", stringsAsFactors = F, 
                       colClasses = c("character","numeric"))

head(med_hh_inc)

#' 
#' ## Spatial*DataFrame to Data Frame Joins
#' 
#' We can use `sp::merge` to join the `med_hh_inc` DF to the `sfhomes15_utm` SPDF.
#' 
#' We should make sure that they share a column of common values - GEOID / home_geoid
#' 
#' We use `sp:merge` not regular `merge` to maintain the integrity of the `sp` object
#' 
#'   - i.e., make sure that the geometry and attribute data slots all stay aligned.
#' 
#' ## Join by Attribute
#' 
#' Join two data objects based on common values in a column.
#' 
#' Use `sp:merge` to join a data frame to a spatial object with a data frames (`S*DF` objects)
#' 
## ------------------------------------------------------------------------

sfhomes15_utm <- merge(sfhomes15_utm, 
                       med_hh_inc, by.x="home_geoid", by.y="GEOID")

#' 
#' **IMPORTANT:** DO NOT merge a data frame to the @data slot! 
#' 
#' -Join it to the SPDF!
#' 
#' ## Take a look at output
#' 
## ------------------------------------------------------------------------
head(sfhomes15_utm@data, 2)  # take a look 

#' 
#' 
#' ## Check the `sp::merge` results
#' 
## ------------------------------------------------------------------------
tmap_mode("view")
tm_shape(sfhomes15_utm) + tm_dots(col="medhhinc")

#' 
#' ## Reset plot mode
## ------------------------------------------------------------------------
tmap_mode("plot")

#' 
#' ## The Census Tract Perspective
#' 
#' We now know the tract for each property.
#' 
#' Now let's think about this question from the tract perspective. 
#' 
#' Let's ask the question
#' 
#' - What is the average propety value per tract?
#' 
#' 
#' 
#' ## Non-Spatial Aggregation
#' 
#' Since we joined GEOID to each property we can use the non-spatial `aggregate` function to compute the mean of totvalues for each GEOID.
#' 
#' But let's use the `sp` aggregate function instead!
#' 
#' It's actually more straight forward.
#' 
#' ## sp::aggregate
#' 
#' Aggregate data values in one spatial object by the geometry of another using the specified function.
#' 
## ------------------------------------------------------------------------

tracts_with_mean_val <- aggregate(x = sfhomes15_utm["totvalue"], 
                                        by = sftracts_utm, FUN = mean)

#' 
#' Wow, so simple. What does that give us?
#' 
#' 
#' ## Examine output
#' 
#' What type of spatial object is returned by `sp::aggregate`
#' 
#' What values are in the `@data` slot?
## ------------------------------------------------------------------------
class(tracts_with_mean_val)
head(tracts_with_mean_val@data)
nrow(tracts_with_mean_val) == nrow(sftracts_utm)

#' 
#' ## sp::aggregate output
#' 
#' `sp::aggregate` returned a SpatialPolygonsDataFrame
#' 
#' The SPDF has the same geometry as `sftracts_utm`
#' 
#' But the `tracts_with_mean_val@data` slot only contains the mean totvalue for each tract.
#' 
#' To make these data more useful, let's add this value to `sftracts_utm`
#' 
#' ## 
#' 
#' This only works because their are the same number of elements both @data slots and they are in the same order!
## ------------------------------------------------------------------------

sftracts_utm$mean_totvalue <- tracts_with_mean_val$totvalue

head(sftracts_utm@data) # check it

#' 
#' ## Map it - do the results make sense
#' 
## ------------------------------------------------------------------------
tmap_mode("view")
tm_shape(sftracts_utm) +
  tm_polygons(col="mean_totvalue", border.col=NA)

#' 
#' ## Why no values for some tracts?
## ------------------------------------------------------------------------
tmap_mode("view")
tm_shape(sftracts_utm) +
  tm_polygons(col="mean_totvalue", border.col=NA) +
tm_shape(sfhomes15_utm) + tm_dots()

#' 
#' # Distance
#' 
#' ## Distance queries
#' 
#' Many methods of spatial analysis are based on distance queries.
#' 
#' For example, point pattern analysis considers the distance between features to determine whether or not they are clustered.
#' 
#' We can also use distance as a way to select features spatially.
#' 
#' ## Proximity
#' 
#' The other side of distance!
#' 
#' What properties are within walking distance of BART?
#' 
#' ## Selecting by Distance
#' 
#' In order to select properties with 1KM of BART
#' - create a 1KM radius buffer polygon around each BART point
#' 
#' We then do a point-in-polygon operation to either count the number of properties within the buffer or compute the mean totvalue.
#' 
#' ## rgeos
#' 
#' `rgeos` is the muscle for 
#' 
#' - creating new geometries from exisiting ones
#' - calculating spatial metrics like area, length, distance
#' - calculating the spatial relationship between two geometries.
#' 
#' We can use the `rgeos::gBuffer` function to create our buffer polygon
#' 
#' ## Creating Buffers
#' 
#' The `rgeos::gBuffer` function takes as input a spatial object or objects to buffer and a buffer distance.
#' 
#' Let's assume 1KM is standard walking distance.
## ------------------------------------------------------------------------

bart_1km_buffer <- gBuffer(sfbart_utm, width=1000)


#' 
#' ## Map the Buffer
## ------------------------------------------------------------------------
tmap_mode("view") 
tm_shape(bart_1km_buffer) + tm_polygons(col="red") +
tm_shape(sfbart_utm) + tm_dots()

#' 
#' ## Try This
#' 
#' How does this differ when we add `byid=TRUE`
## ------------------------------------------------------------------------
bart_1km_buffer_byid <- gBuffer(sfbart_utm, width=1000, byid=TRUE)

tmap_mode("view")
tm_shape(bart_1km_buffer_byid) + tm_polygons(col="red") +
tm_shape(sfbart_utm) + tm_dots()



#' 
#' ## What sfhomes are within 1km of any bart station?
#' 
#' What operation could we use?
#' 
#' Which buffer polygons?
#' 
#' ##  What sfhomes are within 1km of any bart station?
#' 
#' Why `byid=TRUE`
#' 
#' What is the output?
## ------------------------------------------------------------------------
homes_near_bart <-  gIntersects(bart_1km_buffer, sfhomes15_utm, byid=TRUE) 
class(homes_near_bart)
head(homes_near_bart)

#' 
#' ## Select the sfhomes15_utm points in the buffer
#' 
## ------------------------------------------------------------------------
# subset
sfhomes15_utm_near_bart <- sfhomes15_utm[as.vector(homes_near_bart),]

#' 
#' ## Map it
## ------------------------------------------------------------------------
tm_shape(bart_1km_buffer) + tm_polygons(col="red") +
tm_shape(sfhomes15_utm_near_bart) + tm_dots()

#' 
#' 
#' ## Questions
#' 
#' 
#' ## Summary
#' 
#' That was a whirlwind tour of just some of the methods of spatial analysis.
#' 
#' There was a lot we didn't and can't cover.
#' 
#' `sf` package is emerging and will eclipse `sp`
#' 
#' Raster data is a another major topic!
#' - but the `raster` package is the key
#' 
#' 
#' ## Selected  References & Tutorials
#' 
#' - [Spatial Data in R tutorial](https://cengel.github.io/rspatial)
#' - [An Introduction to Spatial Data Analysis and Visualisation in R](https://data.cdrc.ac.uk/tutorial/an-introduction-to-spatial-data-analysis-and-visualisation-in-r)
#' - [NEON Spatial Data tutorials](http://neondataskills.org/tutorial-series/)
#' - [GIS in R](http://www.nickeubank.com/gis-in-r)
#' - [Spatial Data Analysis and Modeling in R](http://www.rspatial.org/index.html)
#' - [Intro to visualizing Spatial Dat in R](https://github.com/Robinlovelace/Creating-maps-in-R)
#' - [RStudio Leaflet in R tutorial](https://rstudio.github.io/leaflet)
#' - [Blog on mapping census data in R](http://zevross.com/blog/2015/10/14/manipulating-and-mapping-us-census-data-in-r-using-the-acs-tigris-and-leaflet-packages-3/)
#' - [Geocomputation in R online book featuring sf Package](http://robinlovelace.net/geocompr/ )
#' - [CRAN Task View: Analysis of Spatial Data](https://cran.r-project.org/web/views/Spatial.html)
#' - http://rstudio-pubs-static.s3.amazonaws.com/6577_3b66f8d8f4984fb2807e91224defa854.html
#' 
#' 
#' ## Output code to script
#' 
## ---- eval=F-------------------------------------------------------------
## library(knitr)
## purl("r-geospatial-workshop-feb2018-pt2.Rmd", output = "scripts/r-geospatial-workshop-feb2018-pt2.r", documentation = 2)

#' 
#' 
