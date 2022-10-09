library(tidyverse)
library(shiny)
library(leaflet)

#PATH <- dirname(sys.frame(1)$ofile) 
#setwd(PATH)
DATA_DIR <- file.path("")

venueData <- read_csv("trivia_venues_loc_new.csv")

days <- c("Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday")
dayColors <- c("red","blue","orange","green","purple","cyan","pink")
names(dayColors) <- days
days <- days[days %in% unique(venueData$day)]


r_colors <- rgb(t(col2rgb(colors()) / 255))
names(r_colors) <- colors()


myColors <- unname(dayColors[venueData$Day])
icons <- awesomeIcons(
  icon = 'glydeployphicon-question-sign',
  iconColor = 'white',
  library = 'glyphicon',
  markerColor = myColors
)

ui <- fluidPage(
  fluidRow(h1('District Trivia Venue Map')),
  fluidRow(
    column(2,
           checkboxGroupInput('daySelect',"Trivia Day",choices=days,selected = days),
           radioButtons('colorSelect',"Select Color Function",choices = c("Day","Distance"),selected = "Day")
    ),
    column(10,
      leafletOutput("mymap", height=800),
      p()
    )
  )
)

server <- function(input, output, session) {
  
  filteredVenues <- reactive({
    filter(venueData,day %in% input$daySelect)
  })  
  
  output$mymap <- renderLeaflet({
    leaflet(data = venueData) %>%
      addProviderTiles(providers$Stamen.TonerLite,
                       options = providerTileOptions(noWrap = TRUE)
      ) %>%
      addAwesomeMarkers(label=~name,icon=icons,
                 popup=paste(venueData$name,"<br>",venueData$day,"at",venueData$time))
  })
  
  observe({
    venues <- filteredVenues()
    if(length(venues)>0){
      myColors <- unname(dayColors[venues$day])
      icons <- awesomeIcons(
        icon = 'glyphicon-question-sign',
        iconColor = 'white',
        library = 'glyphicon',
        markerColor = myColors
      )
      leafletProxy("mymap", data = venues) %>%
        clearMarkers() %>%
        addAwesomeMarkers(label=~name,icon=icons,
                          popup=paste(venues$name,"<br>",venues$day,"at",venues$time))
    } else {
      leafletProxy("mymap") %>%
        clearMarkers()
    }
    
  })
  
}



shinyApp(ui, server)
