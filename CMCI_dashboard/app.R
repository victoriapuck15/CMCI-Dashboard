# Load necessary libraries
library(shiny)
library(plotly)
library(bslib)

# Read the data from CSV file
data2 <- read.csv("/Users/michaellicata/Documents/SeniorYear/SP '24/DS 440/CMCI-Dashboard/cmciGood2.csv")
compare_df <- read.csv("/Users/michaellicata/Documents/SeniorYear/SP '24/DS 440/CMCI-Dashboard/compare_data.csv")
cci_cmci_df <- read.csv("/Users/michaellicata/Documents/SeniorYear/SP '24/DS 440/CMCI-Dashboard/CMCI_FINAL.csv")

colnames(data2)[1] <- "DATE"
cci_cmci_df <- as.data.frame(cci_cmci_df)

# Convert the 'DATE' column to date format
cci_cmci_df$DATE <- as.Date(cci_cmci_df$DATE)
data2$DATE <- as.Date(data2$DATE)
compare_df$DATE <- as.Date(compare_df$DATE)

names(cci_cmci_df) <- gsub("\\.", " ", names(cci_cmci_df))


ui <- page_navbar(
  theme = bs_theme(version = 5, bootswatch = "morph"),
  title = "My App",
  inverse = TRUE,
  nav_panel(title = "One", 
            
            page_fillable(
              card(
                card_header("CMCI Time Series"),
                layout_sidebar(
                  sidebar = sidebar(
                    dateRangeInput("date_range", "Date Range:",
                                   start = min(data2$DATE),
                                   end = max(data2$DATE),
                                   min = min(data2$DATE),
                                   max = max(data2$DATE)),
                    
                    hr(),
                    
                    checkboxGroupInput("countries", "Select Countries:", 
                                       choices = colnames(data2)[-1], selected = colnames(data2)[-1])
                  ),
                  plotlyOutput("CMCIPlot")
                ))
            )
            ),
  nav_panel(title = "Two", 
            
            page_fillable(
              
              card(
                card_header("United States Index Comparison Plot"),
                layout_sidebar(
                  sidebar = sidebar(
                    dateRangeInput("date_range2", "Date Range:",
                                   start = min(compare_df$DATE),
                                   end = max(compare_df$DATE),
                                   min = min(compare_df$DATE),
                                   max = max(compare_df$DATE)),
                    
                    hr(),
                    
                    checkboxGroupInput("indexes", "Select Indexes:", 
                                       choices = colnames(compare_df)[-1], selected = colnames(compare_df)[-1])
                  ),
                  plotlyOutput("ComparisonPlot")
                ))
              
            )
            
            ),
  nav_panel(title = "Three", 
            
            page_fillable(
              
              card(
                card_header("Full Country CCI and CMCI Comparison Graph"),
                layout_sidebar(
                  sidebar = sidebar(
                    dateRangeInput("date_range3", "Date Range:",
                                   start = min(cci_cmci_df$DATE),
                                   end = max(cci_cmci_df$DATE),
                                   min = min(cci_cmci_df$DATE),
                                   max = max(cci_cmci_df$DATE)),
                    
                    hr(),
                    
                    varSelectInput("cmci", "CMCI Country", cci_cmci_df[2:15], selected = "USA CMCI"),
                    hr(),
                    varSelectInput("cci", "CCI Country", cci_cmci_df[16:30], selected = "USA CCI")
                  ),
                  plotlyOutput("CMCIvsCCI")
                ))
              
            )
            
            ),
  nav_spacer(),
  nav_menu(
    title = "Links",
    align = "right",
    nav_item(tags$a("Posit", href = "https://posit.co")),
    nav_item(tags$a("Shiny", href = "https://shiny.posit.co"))
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
  
  selectedData3 <- reactive({
    cci_cmci_df %>%
      filter(DATE >= input$date_range3[1] & DATE <= input$date_range3[2]) %>%
      select(c("DATE", c(input$cmci, input$cci)))
  })

  
  output$CMCIPlot <- renderPlotly({
    # Filter data based on selected countries
    dataSelected <- selectedData()
    
    # Convert to long format for plotting with plotly
    dataLong <- reshape2::melt(dataSelected, id.vars = "DATE", variable.name = "Country", value.name = "Index")
    
    # Generate plot
    p <- plot_ly(dataLong, x = ~DATE, y = ~Index, color = ~Country, type = 'scatter', mode = 'lines') %>%
      layout(title = "CMCI Index Country Data Over Time",
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
    p <- plot_ly(data = dataLong, x = ~DATE, y = ~Value, color = ~Index, type = 'scatter', mode = 'lines',
                 line = list(width = 2), # Adjust line width for better visibility
                 hoverinfo = 'text', # Customize hover text
                 text = ~paste('Date: ', DATE, '<br>Value: ', Value, '<br>Index: ', Index)) %>%
      layout(
        title = list(text = "Comparative Consumer Index Graph", font = list(size = 24, color = 'blue')), # Customize title font size and color
        xaxis = list(
          title = list(text = "AHHHH", font = list(size = 18, color = "blue")),
          tickfont = list(size = 12), # Customize axis tick font sizes
          zeroline = F, # Remove zero line for a cleaner look
          gridcolor = 'lightgrey' # Lighten grid lines for less visual clutter
        ),
        yaxis = list(
          title = list(text = "Value of Index", font = list(size = 18, color = "blue")),
          tickfont = list(size = 12),
          zeroline = F,
          gridcolor = 'lightgrey'
        ),
        legend = list(
          orientation = "h", # Horizontal legend for better layout
          y = -0.2, # Adjust legend position
          xanchor = "center",
          x = 0.5,
          font = list(size = 12) # Customize legend font size
        ),
        margin = list( # Adjust margins to make better use of space
          l = 50,
          r = 50,
          t = 100,
          b = 50
        ),
        plot_bgcolor = 'white', # Set background color to white for a clean look
        paper_bgcolor = 'white'
      ) %>%
      config( # Add config options for interactivity
        scrollZoom = TRUE,
        displayModeBar = TRUE,
        displaylogo = FALSE,
        modeBarButtonsToRemove = list('select2d', 'lasso2d')
      )
    
    return(p)
    
  })
  
  output$CMCIvsCCI <- renderPlotly({
    
    dataSelected <- selectedData3()
    
    
    # Filter data based on selected countries
    p <- ggplot(dataSelected, aes(x = DATE)) +
      geom_line(aes(y = !!input$cmci, color = "CMCI Line")) +  
      geom_line(aes(y = !!input$cci, color = "CCI Line")) +    
      labs(
        title = "Full Country CCI and CMCI Comparison Graph",
        x = "Date",
        y = "Index Value",
        color = "Legend"
      ) +
      theme_minimal() +
      scale_color_manual(values = c("CMCI Line" = "blue", "CCI Line" = "red"))  # Set custom colors
    
    return(ggplotly(p))
    
    
  })
  
  
}

# Run the application
shinyApp(ui = ui, server = server)


