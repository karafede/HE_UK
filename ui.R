
library(shiny)
library(rgdal)
library(raster)
library(dplyr)
library(leaflet)
library(RColorBrewer)
library(sp)
library(RCurl)
library(devtools)
library(shinyjs)
library(V8)
library(pbapply)
library(plotly)
# library(importr)
library(lubridate)
library(DT)


# devtools::install_github("rstudio/shinydashboard")
library(shinydashboard)

jscode <- "shinyjs.refresh = function() { history.go(0); }"
table <- read.csv("NAQMN.csv")

ui <- dashboardPage(skin = "blue",
                    dashboardHeader(title = "Highway England Sites"),
                    
                    dashboardSidebar(
                      width = 290,
                      paste("Time:",Sys.time()),
                      sidebarMenu(
                        
                        selectInput(
                          "name", "Site Location:",
                          c("All",
                            unique(as.character(table$Name)))
                        ),

                        selectInput(
                          "postal", "Postcode:",
                          c("All",
                            unique(as.character(table$Post_Code)))
                        ),
                        
                      menuItem("Map", tabName = "MAP", icon = icon("th")),
                      menuItem("Sites", tabName = "Data", icon = icon("th")),
                        
                      fluidRow(
                        column (3,offset = 1,
                                  br(), #hr()
                                  useShinyjs(),
                                  extendShinyjs(text = jscode),
                                  actionButton("refresh", "refresh", icon("paper-plane"),
                                               style="color: #000000; background-color: #ffff00; border-color: #2e6da4", width = 150)
                          ))
                        
                      )),
                    
                    
                    dashboardBody(
                      tags$head(
                        tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
                      ),
                      tabItems(
                        
                        # First tab content
                        tabItem(tabName = "MAP",
                                fluidRow(
                                  tabBox(
                                    height = 750, width = 950, selected = tags$b("Chosen sites"),
                                    tabPanel(
                                      tags$b("Chosen sites"), leafletOutput('myMap', height = 650, width = 750)
                                    )
                                  )
                                )),
                        
                        
                        
                        # Second tab content
                        tabItem(tabName = "Data",
                                fluidRow(
                                  tabBox(
                                    height = 1000, width = 950, selected = tags$b("Site Locations"),
                                    tabPanel(
                                      tags$b("Site Locations"), DT::dataTableOutput('data')
                                    )
                                  )
                                ))
                      ))
)


