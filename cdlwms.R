
library(rgdal)
library(raster)
library(rgeos)

########with year and bounding box#######################
########Web Map Service (WMS, CONUS)#####################  

getRaster=function(x,year){
  cdl.list <- list()
  for(year in year){
    download.file(sprintf("http://129.174.131.7/cgi/wms_cdlall.cgi?SERVICE=WMS&VERSION=1.1.1&REQUEST=GetMap&LAYERS=cdl_%d&STYLES=&SRS=EPSG:4326&BBOX=%f,%f,%f,%f&WIDTH=800&HEIGHT=400&FORMAT=gtiff",year,x[1,1],x[2,1],x[1,2],x[2,2]),destfile=sprintf("temp%d.tif",year),mode="wb")
    target<-raster(sprintf("temp%d.tif",year)) 
    names(target)<-year
    cdl.list[sprintf("%s",year)]<-target
  }
  return(cdl.list)
}

#######try US county shapefile to get CDL raster data###########
#read Shapefile into R
county<-readOGR("O:/Documents/CDL_R/cs","cb_2014_us_county_500k")

##example for get county tif####
##interested in Worcester,MA(FIPs code=25) from 2010 to 2014####
id=which((county@data$NAME =="Worcester")&(county@data$STATEFP==25))
#bbox
x<-bbox(county@polygons[[id]])
year<-seq(2010,2014)
wtemp<-getRaster(x,year)

########Web Map Service (WMS, each CONUS state)##########

getRasterS=function(x,year,state){
  cdl.list <- list()
  for(year in year){
    download.file(sprintf("http://129.174.131.7/cgi/wms_cdl_%s.cgi?SERVICE=WMS&VERSION=1.1.1&REQUEST=GetMap&LAYERS=cdl_%d_%s&STYLES=&SRS=EPSG:4326&BBOX=%f,%f,%f,%f&WIDTH=800&HEIGHT=400&FORMAT=gtiff",state,year,state,x[1,1],x[2,1],x[1,2],x[2,2]),destfile=sprintf("temp%s%d.tif",state,year),mode="wb")
    target<-raster(sprintf("temp%s%d.tif",state,year)) 
    names(target)<-year
    cdl.list[sprintf("%s",year)]<-target
  }
  return(cdl.list)
}
