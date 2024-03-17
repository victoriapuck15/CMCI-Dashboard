# Load necessary libraries
library(shiny)
library(ggplot2)
library(dplyr)
library(readr)
library(plotly)

# Read the data from CSV file
data2 <- read.csv("/Users/michaellicata/Documents/SeniorYear/SP '24/DS 440/CMCI-Dashboard/cmciGood2.csv")
compare_df <- read.csv("/Users/michaellicata/Documents/SeniorYear/SP '24/DS 440/CMCI-Dashboard/compare_data.csv")
colnames(data2)[1] <- "DATE"


# Convert the 'DATE' column to date format
data2$DATE <- as.Date(data2$DATE)
compare_df$DATE <- as.Date(compare_df$DATE)

# Define UI
ui <- fluidPage(
  titlePanel("CMCI Time Series"),
  sidebarLayout(
    sidebarPanel(
      tabsetPanel(
        tabPanel("CMCIPlot",
                 
                 dateRangeInput("date_range", "Date Range:",
                     start = min(data2$DATE),
                     end = max(data2$DATE),
                     min = min(data2$DATE),
                     max = max(data2$DATE)),
                 
                 hr(),
                 
                 checkboxGroupInput("countries", "Select Countries:", 
                         choices = colnames(data2)[-1], selected = colnames(data2)[-1])
      ),
      tabPanel("ComparisonPlot",
               
               dateRangeInput("date_range2", "Date Range:",
                              start = min(compare_df$DATE),
                              end = max(compare_df$DATE),
                              min = min(compare_df$DATE),
                              max = max(compare_df$DATE)),
               
               hr(),
               
               checkboxGroupInput("indexes", "Select Indexes:", 
                                  choices = colnames(compare_df)[-1], selected = colnames(compare_df)[-1])
      )
      )
      ),
    mainPanel(
      plotlyOutput("CMCIPlot"),
      plotlyOutput("ComparisonPlot"),
      textOutput("dataInfo")
  )
)
)

# Define server logic
server <- function(input, output) {
  
  # Reactive expression for data subset based on date range
  selectedData <- reactive({
    data2 %>%
      filter(DATE >= input$date_range[1] & DATE <= input$date_range[2]) %>%
      select(c("DATE", input$countries))
  })
  
  # Reactive expression for data subset based on date range for ComparisonPlot
  selectedData2 <- reactive({
    compare_df %>%
      filter(DATE >= input$date_range2[1] & DATE <= input$date_range2[2]) %>%
      select(c("DATE", input$indexes))
  })
  
  output$CMCIPlot <- renderPlotly({
    # Filter data based on selected countries
    dataSelected <- selectedData()
    
    # Convert to long format for plotting with plotly
    dataLong <- reshape2::melt(dataSelected, id.vars = "DATE", variable.name = "Country", value.name = "Index")
    
    # Generate plot
    p <- plot_ly(dataLong, x = ~DATE, y = ~Index, color = ~Country, type = 'scatter', mode = 'lines') %>%
      layout(title = "Country Index Over Time",
             xaxis = list(title = "Date"),
             yaxis = list(title = "Index"))
    
    return(p)
  })
  
  output$ComparisonPlot <- renderPlotly({
    # Filter data based on selected countries
    dataSelected <- selectedData2()
    
    # Convert to long format for plotting with plotly
    dataLong <- reshape2::melt(dataSelected, id.vars = "DATE", variable.name = "Index", value.name = "Value")
    
    # Generate plot
    p <- plot_ly(dataLong, x = ~DATE, y = ~Value, color = ~Index, type = 'scatter', mode = 'lines') %>%
      layout(title = "Country Index Over Time",
             xaxis = list(title = "Date"),
             yaxis = list(title = "Value of Index"))
    
    return(p)
  })
  
}

# Run the application
shinyApp(ui = ui, server = server)


