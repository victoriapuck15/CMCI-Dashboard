# Load necessary libraries
library(shiny)
library(ggplot2)
library(dplyr)
library(readr)

# Read the data from CSV file
data <- read.csv("/Users/victoriapuck-karam/Documents/CMCI-Dashboard/CMCI_FINAL_DATA.csv")

# Comment to test git

# Convert the 'DATE' column to date format
data$DATE <- as.Date(data$DATE)

# Define UI
ui <- fluidPage(
  titlePanel("CMCI Time Series"),
  sidebarLayout(
    sidebarPanel(
      dateRangeInput("date_range", "Date Range:",
                     start = min(data$DATE),
                     end = max(data$DATE),
                     min = min(data$DATE),
                     max = max(data$DATE))
    ),
    mainPanel(
      plotOutput("linePlot"),
      textOutput("dataInfo")
    )
  )
)

# Define server logic
server <- function(input, output) {
  
  # Reactive expression for data subset based on date range
  selectedData <- reactive({
    data %>%
      filter(DATE >= input$date_range[1] & DATE <= input$date_range[2])
  })
  
  # Generate the line plot
  output$linePlot <- renderPlot({
    ggplot(selectedData(), aes(x = DATE, y = CMCI)) +
      geom_line() +
      labs(x = "Date", y = "CMCI", title = "CMCI Time Series") +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
  })
  
  # Render text explaining the data
  output$dataInfo <- renderText({
    "This is a placeholder for where the educational information will go and the data transparency statements"
  })
}

# Run the application
shinyApp(ui = ui, server = server)


