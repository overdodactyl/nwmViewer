library(shinydashboard)
library(leaflet)
library(AOI)
library(RColorBrewer)
library(nwm)

header <- dashboardHeader(
  title = "Gridded Data Viewer"
)

body <- dashboardBody(
  fluidRow(
    column(width = 3,
           box(width = NULL, status = "primary",
               textInput(inputId = "search", label = NULL, value = "Colorado Springs", width = NULL, placeholder = "Search"),
               # selectInput(inputId = "type", "Type:", choices = c("channel", "land"), selected = "land"),
               selectInput(inputId = "forcast_input", label = "Forcast Type: ", 
                           choices = c("Short Range" = "short_range", 
                                       "Medium Range" = "medium_range",
                                       "Long Range" = "long_range"),
                           selected = "medium_range"),
               selectInput(inputId = "type", label = "Type:", choices = c("Land" = "land", "Forcing" = "forcing"), selected = "Land"),
               htmlOutput("param_selector"),
               htmlOutput("date_input"),
               htmlOutput("t_input"),
               htmlOutput("f_input"),
               # selectInput("f_input", "Hours Forward", choices = seq(3, 240, by = 3), selected = c(3,3,6,9,12), multiple = TRUE,
               #             selectize = TRUE, width = NULL, size = NULL),
               sliderInput(inputId = "clip_size", label = "Size:",
                           min = 5, max = 35,
                           value = 15),
               actionButton(inputId = "go", label = "Go", icon = NULL)
               
           ),
           box(width = NULL, status = "primary",
               textOutput("forcast_info")
           )
    ),
    column(width = 9,
           box(width = NULL, solidHeader = TRUE,
               plotOutput("plot", height = 500)
           ),
           box(width = NULL,
               leafletOutput("map", height = 500)
           )
    )
  ),
  tags$footer(HTML("<p>Developers <a href=\"https://overdodactyl.github.io\">Pat Johnson</a> ~ <a href=\"https://mikejohnson51.github.io\">Mike Johnson</a></p>
                   <p>R package: <a href=\"https://mikejohnson51.github.io/NWM/\">NWM</a>"))
)

dashboardPage(
  header,
  dashboardSidebar(disable = TRUE),
  body
)