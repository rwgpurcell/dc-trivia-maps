library(tidyverse)
library(shiny)
library(leaflet)



#PATH <- dirname(sys.frame(1)$ofile) 
#setwd(PATH)
DATA_DIR <- file.path("../")

venueData <- read_csv(file.path(DATA_DIR,"trivia_venues_loc.csv"))

print(head(venueData))
days <- c("Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday")
days <- days[days %in% unique(venueData$Day)]
print(days)

r_colors <- rgb(t(col2rgb(colors()) / 255))
names(r_colors) <- colors()


ui <- fluidPage(
  fluidRow(h1('District Trivia Venue Map')),
  fluidRow(
    column(2,
           checkboxGroupInput('daySelect',"Trivia Day",choices=days,selected = days)
    ),
    column(10,
      leafletOutput("mymap", height=800),
      p()
    )
  )
)

server <- function(input, output, session) {
  
  filteredVenues <- reactive({
    filter(venueData,Day %in% input$daySelect)
  })  
  
  output$mymap <- renderLeaflet({
    leaflet(data = venueData) %>%
      addProviderTiles(providers$Stamen.TonerLite,
                       options = providerTileOptions(noWrap = TRUE)
      ) %>%
      addMarkers(label=~Venue,
                 popup=paste(venueData$Venue,"<br>",venueData$Day,"at",venueData$Time))
  })
  
  observe({
    venues <- filteredVenues()
    leafletProxy("mymap", data = venues) %>%
      clearMarkers() %>%
      addMarkers(label=~Venue,
                 popup=paste(venues$Venue,"<br>",venues$Day,"at",venues$Time))
  })
  
}



shinyApp(ui, server)
