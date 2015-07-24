getCensusEdgeData <-
  function(states, counties, location) {
    
    removeFlag <- F
    
    if( length(states) != length(counties)) {
      print("states and counties do not have same length")
      return(NA)
    }
    
    fips<-c()

    # if the location is missing we download from the internet
    if( missing(location) ) {
      fips <- mapply(countyfips,states,counties)
      removeFlag <- T
      urls <- list()
      # multiple connections are available via http, so using http now instead of ftp
      censusFtp <- "http://www2.census.gov/geo/tiger/TIGER2014/EDGES/" 
      
      for( i in 1:length(states)) {
        urls[i] <- sprintf("%stl_2014_%s_edges.zip",censusFtp,fips[i]) 
      }
      
      # set the file location    
      location <- tempdir() 
      
      # download the files 
      tiger.zip.files.name <- paste(location, sprintf("tl_2014_%s_edges.zip",fips),sep="/")
      tiger.zip.files <- mapply(download.file, unlist(urls), tiger.zip.files.name) 
  
     for(i in 1:length(states)){
        if( tiger.zip.files[i] == 0) {
          #unzip the shape file
          unzip(tiger.zip.files.name[i],exdir=location) 
          #delete the temp file
          unlink(tiger.zip.files.name[i])
        }
      }
    
    
    result <- list()
    # read files
    for( i in 1:length(states)) {
      #read file
      result[i] <- readOGR(location, sprintf("tl_2014_%s_edges",fips[i])) 
      
      if( removeFlag ) {
        unlink( sprintf( "%s/tl_2014_%s_edges.*",location,fips[i]) )
      }
    }
    
    return(result)
    
  }
  }
