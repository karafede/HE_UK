
library(shiny)
library(rgdal)
library(raster)
library(dplyr)
library(leaflet)
library(RColorBrewer)
library(sp)
library(shinydashboard)
# library(importr)
library(lubridate)
library(DT)

# setwd("C:/RICARDO-AEA/Highway_England")

## load data with locations on the highway 
table <- read.csv("NAQMN.csv")

shinyServer(function(input, output, session) {


  output$data <- DT::renderDataTable(DT::datatable ({
    table <- read.csv("NAQMN.csv")

    if (input$name != "All") {
      table <- table[table$Name == input$name,] 
      updateSelectInput(session, "postal", "Postcode:",
                        c("All",
                          unique(as.character(table$Post_Code))))
    }
    if (input$postal != "All") {
      table <- table[table$Post_Code == input$postal,]
      updateSelectInput(session, "name", "Site Location:",
                        c("All",
                          unique(as.character(table$Name))))
    }

    table
  }))




## Map------------------------------------------------------------------------------------------   

finalMap <- reactive({

   data <- read.csv("NAQMN.csv")
   coord_HE <- data
  # coord_HE <- table
   
   # filter coordinates by date

   if (input$name != "All") {
     coord_HE <- filter(table, Name == input$name)
     
   }
   if (input$postal != "All") {
     coord_HE <- filter(table, Post_Code == input$postal)
   }
   
  
  popup_postcode <- paste0("<strong><i>",
                           coord_HE$Name,
                      "</i></strong><br>Post Code: <strong> ", coord_HE$Post_Code)
  
  
  map <- leaflet(coord_HE) %>%
    addTiles() %>%
    setView(lng = coord_HE$Long, lat = coord_HE$Lat, zoom = 4) %>%
    fitBounds(lng1 = max(coord_HE$Long)+(0.003),lat1 = max(coord_HE$Lat)-0.003,
                 lng2 = min(coord_HE$Long)+0.003,lat2 = min(coord_HE$Lat)+0.003) %>%
    
        addProviderTiles("OpenStreetMap.Mapnik", group = "Road map") %>%
    addProviderTiles("Thunderforest.Landscape", group = "Topographical") %>%
    addProviderTiles("Esri.WorldImagery", group = "Satellite") %>%
    addProviderTiles("Stamen.TonerLite", group = "Toner Lite") %>%
    addCircleMarkers(
      lng = ~ Long, lat = ~ Lat,
      popup = ~popup_postcode,
      weight = 3, radius = 10,
      group = "variable"
    ) %>%

  addLayersControl(
    # baseGroups = background,
    baseGroups = c("Road map", "Topographical", "Satellite", "Toner Lite"),
    overlayGroups = c("variable"),
    options = layersControlOptions(collapsed = TRUE)
  )
  
  
  map
  
})
  

# Return to client
output$myMap = renderLeaflet(finalMap())


observeEvent(input$refresh, {
  js$refresh();
})

})

    
