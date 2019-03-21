library(tidyverse)
library(shiny)
library(leaflet)



#PATH <- dirname(sys.frame(1)$ofile) 
#setwd(PATH)
DATA_DIR <- file.path("../")

venueData <- read_csv(file.path(DATA_DIR,"trivia_venues_loc.csv"))

print(head(venueData))
r_colors <- rgb(t(col2rgb(colors()) / 255))
names(r_colors) <- colors()


ui <- fluidPage(
  fluidRow(
    column(3,
           actionButton("recalc", "New points")
    ),
    column(9,
      leafletOutput("mymap", height=800),
      p()
    )
  )
)

server <- function(input, output, session) {
  
  points <- eventReactive(input$recalc, {
    cbind(rnorm(40) * 2 + 13, rnorm(40) + 48)
  }, ignoreNULL = FALSE)
  
  output$mymap <- renderLeaflet({
    leaflet(height = "600px") %>%
      addProviderTiles(providers$Stamen.TonerLite,
                       options = providerTileOptions(noWrap = TRUE)
      ) %>%
      addMarkers(data = venueData)
  })
}

shinyApp(ui, server)
