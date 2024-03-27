# Load necessary libraries
library(shiny)
library(plotly)
library(bslib)
library(dplyr)
library(lubridate)

# Read the data from CSV file
data2 <- read.csv("cmciGood2.csv")
compare_df <- read.csv("compare_data.csv")
cci_cmci_df <- read.csv("CMCI_FINAL.csv")

colnames(data2)[1] <- "DATE"
cci_cmci_df <- as.data.frame(cci_cmci_df)

# Convert the 'DATE' column to date format
cci_cmci_df$DATE <- as.Date(cci_cmci_df$DATE)
data2$DATE <- as.Date(data2$DATE)
compare_df$DATE <- as.Date(compare_df$DATE)

names(cci_cmci_df) <- gsub("\\.", " ", names(cci_cmci_df))


ui <- page_navbar(
  theme = bs_theme(version = 5, bootswatch = "morph"),
  title = "CMCI Dashboard",
  nav_panel(title = "Full Country CMCI Data", 
            
            page_fillable(
              card(
                card_header("CMCI Index Country Data Over Time"),
                layout_sidebar(
                  sidebar = sidebar(
                    dateRangeInput("date_range", "Date Range:",
                                   start = min(data2$DATE),
                                   end = max(data2$DATE),
                                   min = min(data2$DATE),
                                   max = max(data2$DATE)),
                    
                    hr(),
                    
                    checkboxGroupInput("countries", "Select Countries:", 
                                       choices = colnames(data2)[-1], 
                                       selected = colnames(data2)[-1])
                  ),
                  plotlyOutput("CMCIPlot")
                ))
            )
            ),
  nav_panel(title = "United States Index Data", 
            
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
                                       choices = colnames(compare_df)[-1], 
                                       selected = colnames(compare_df)[-1])
                  ),
                  plotlyOutput("ComparisonPlot")
                ))
              
            )
            
            ),
  nav_panel(title = "Country by Country CMCI and CCI Data", 
            
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
                    
                    varSelectInput("cmci", "CMCI Country", cci_cmci_df[2:15], 
                                   selected = "USA CMCI"),
                    hr(),
                    varSelectInput("cci", "CCI Country", cci_cmci_df[16:30], 
                                   selected = "USA CCI")
                  ),
                  plotlyOutput("CMCIvsCCI")
                ))
              
            )
            
            ),
  nav_panel(title = "United States Lag Data", 
            
            page_fillable(
              
              card(
                card_header("United States CMCI Lag Plot"),
                layout_sidebar(
                  sidebar = sidebar(
                    dateRangeInput("date_range4", "Date Range:",
                                   start = min(compare_df$DATE),
                                   end = max(compare_df$DATE),
                                   min = min(compare_df$DATE),
                                   max = max(compare_df$DATE)),
                    
                    hr(),
                    
                    varSelectInput("indicator", "Indicator", compare_df[3:5], 
                                   selected = "CSI"),
                    hr(),
                    sliderInput("cmciLag", "Lag CMCI by:",
                                min = 0, max = 4, value = 0, step = 1)
                    
                  ),
                  plotlyOutput("LagPlot")
                ))
              
            )
            
  ),
  
  nav_panel(title = "United States Lead Data", 
            
            page_fillable(
              
              card(
                card_header("United States CMCI Lead Plot"),
                layout_sidebar(
                  sidebar = sidebar(
                    dateRangeInput("date_range5", "Date Range:",
                                   start = min(compare_df$DATE),
                                   end = max(compare_df$DATE),
                                   min = min(compare_df$DATE),
                                   max = max(compare_df$DATE)),
                    
                    hr(),
                    
                    varSelectInput("indicator", "Indicator", compare_df[3:5], 
                                   selected = "CSI"),
                    hr(),
                    sliderInput("cmciLead", "Lead CMCI by:",
                                min = 0, max = 4, value = 0, step = 1)
                    
                  ),
                  plotlyOutput("LeadPlot")
                ))
              
            )
            
  ),
  
  nav_panel(title = "CMCI Index Info", 
            
            page_fillable(
              card(
                card_header("CMCI Index Info")
                ))
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
  
  selectedData4 <- reactive({
     compare_df %>%
      filter(DATE >= input$date_range4[1] & DATE <= input$date_range4[2]) %>%
      select(c("DATE", c("CMCI", input$indicator)))
  })
  
  selectedData5 <- reactive({
    compare_df %>%
      filter(DATE >= input$date_range5[1] & DATE <= input$date_range5[2]) %>%
      select(c("DATE", c("CMCI", input$indicator)))
  })

  
  output$CMCIPlot <- renderPlotly({
    # Filter data based on selected countries
    dataSelected <- selectedData()
    
    # Convert to long format for plotting with plotly
    dataLong <- reshape2::melt(dataSelected, id.vars = "DATE", 
                               variable.name = "Country", value.name = "Index")
    
    # Generate plot
    p <- plot_ly(dataLong, x = ~DATE, y = ~Index, color = ~Country, type = 'scatter', 
                 mode = 'lines',
                 line = list(width = 2), # Adjust line width for better visibility
                 hoverinfo = 'text', # Customize hover text
                 text = ~paste('Date: ', DATE, '<br>Index: ', Index, '<br>Country: ', Country)) %>%
      
      layout(
        title = list(text = "CMCI Index Country Data Over Time", 
                     font = list(size = 24, color = "black")), # Customize title font size and color
        xaxis = list(
          title = list(text = "Date", font = list(size = 18, color = "black")),
          tickfont = list(size = 12), # Customize axis tick font sizes
          zeroline = F, # Remove zero line for a cleaner look
          gridcolor = "lightgrey" # Lighten grid lines for less visual clutter
        ),
        yaxis = list(
          title = list(text = "Value of Index", font = list(size = 18, color = "black")),
          tickfont = list(size = 12),
          zeroline = F,
          gridcolor = "lightgrey"
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
        plot_bgcolor = 'rgba(0, 0, 0, 0)', # Set background color to white for a clean look
        paper_bgcolor = 'rgba(0, 0, 0, 0)'
      ) %>%
      config( # Add config options for interactivity
        scrollZoom = TRUE,
        displayModeBar = TRUE,
        displaylogo = FALSE,
        modeBarButtonsToRemove = list('select2d', 'lasso2d')
      )
    
    return(p)
  })
  
  output$ComparisonPlot <- renderPlotly({
    # Filter data based on selected countries
    dataSelected <- selectedData2()
    
    # Convert to long format for plotting with plotly
    dataLong <- reshape2::melt(dataSelected, id.vars = "DATE", 
                               variable.name = "Index", value.name = "Value")
    
    # Generate plot
    p <- plot_ly(data = dataLong, x = ~DATE, y = ~Value, color = ~Index, type = 'scatter', mode = 'lines',
                 line = list(width = 2), # Adjust line width for better visibility
                 hoverinfo = 'text', # Customize hover text
                 text = ~paste('Date: ', DATE, '<br>Value: ', Value, '<br>Index: ', Index)) %>%
      layout(
        title = list(text = "Comparative Consumer Index Graph", 
                     font = list(size = 24, color = 'black')), # Customize title font size and color
        xaxis = list(
          title = list(text = "Date", font = list(size = 18, color = "black")),
          tickfont = list(size = 12), # Customize axis tick font sizes
          zeroline = F, # Remove zero line for a cleaner look
          gridcolor = 'lightgrey' # Lighten grid lines for less visual clutter
        ),
        yaxis = list(
          title = list(text = "Value of Index", font = list(size = 18, color = "black")),
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
        plot_bgcolor = 'rgba(0, 0, 0, 0)', # Set background color to white for a clean look
        paper_bgcolor = 'rgba(0, 0, 0, 0)'
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
    dataSelected$DATE <- as.Date(dataSelected$DATE)
    
    # Calculate correlation and p-value
    cor_test <- cor.test(dataSelected[[input$cci]], dataSelected[[input$cmci]])
    cor_text <- sprintf("Correlation: %.4f\np-value: %.4f", cor_test$estimate, cor_test$p.value)
    
    # Create the plot with styling similar to the provided example
    p <- plot_ly(data = dataSelected, x = ~DATE) %>%
      add_lines(y = ~dataSelected[[input$cmci]], name = "CMCI Line", line = list(color = 'darkgreen', width = 2),
                hoverinfo = 'text', text = ~paste('Date: ', DATE, '<br>Value: ', dataSelected[[input$cmci]], '<br>Index: CMCI Line')) %>%
      add_lines(y = ~dataSelected[[input$cci]], name = "CCI Line", line = list(color = 'navy', width = 2),
                hoverinfo = 'text', text = ~paste('Date: ', DATE, '<br>Value: ', dataSelected[[input$cci]], '<br>Index: CCI Line')) %>%
      layout(
        title = list(text = "Full Country CCI and CMCI Comparison Graph", font = list(size = 24, color = 'black')),
        xaxis = list(title = list(text = "Date", font = list(size = 18, color = "black")),
                     tickfont = list(size = 12),
                     zeroline = F,
                     gridcolor = 'lightgrey'),
        yaxis = list(title = list(text = "Index Value", font = list(size = 18, color = "black")),
                     tickfont = list(size = 12),
                     zeroline = F,
                     gridcolor = 'lightgrey'),
        legend = list(orientation = "h", y = -0.2, xanchor = "center", x = 0.5, font = list(size = 12)),
        margin = list(l = 50, r = 50, t = 100, b = 50),
        plot_bgcolor = 'rgba(0, 0, 0, 0)',
        paper_bgcolor = 'rgba(0, 0, 0, 0)',
        annotations = list(x = min(dataSelected$DATE) %m+% years(1), y = min(c(min(dataSelected[[input$cci]], na.rm = TRUE), min(dataSelected[[input$cmci]], na.rm = TRUE))), 
                           text = cor_text, showarrow = F, xanchor = 'left', yanchor = 'bottom', font = list(size = 12))
      ) %>%
      config(scrollZoom = TRUE, displayModeBar = TRUE, displaylogo = FALSE, modeBarButtonsToRemove = list('select2d', 'lasso2d'))
    
    
    return(p)
    
    
  })
  
  
  output$LagPlot <- renderPlotly({
    
    dataSelected <- selectedData4()
    dataSelected$DATE <- as.Date(dataSelected$DATE)
    
    # Adjust the CMCI column based on the selected lag amount
    dataSelected <- dataSelected %>%
      arrange(DATE) %>%
      mutate(CMCI_lagged = lag(CMCI, as.numeric(input$cmciLag)))
    
    # Recalculate correlation and p-value with lagged CMCI
    cor_test <- cor.test(dataSelected[["CMCI_lagged"]], dataSelected[[input$indicator]], use = "complete.obs")
    cor_text <- sprintf("Correlation: %.4f\np-value: %.4f", cor_test$estimate, cor_test$p.value)
    
    # Plotly graph creation code remains the same, just change `y = ~dataSelected[["CMCI"]]` 
    # to `y = ~dataSelected[["CMCI_lagged"]]` for the CMCI line
    
    p <- plot_ly(data = dataSelected, x = ~DATE) %>%
      add_lines(y = ~dataSelected[["CMCI_lagged"]], name = "CMCI Line", line = list(color = 'darkgreen', width = 2),
                hoverinfo = 'text', text = ~paste('Date: ', DATE, '<br>Value: ', CMCI_lagged, '<br>Index: CMCI Line')) %>%
      add_lines(y = ~dataSelected[[input$indicator]], name = "Indicator Line", line = list(color = 'navy', width = 2),
                hoverinfo = 'text', text = ~paste('Date: ', DATE, '<br>Value: ', dataSelected[[input$indicator]], '<br>Index: Indicator Line')) %>%
      layout(
        title = list(text = "United States Indicator Comparison Graph", font = list(size = 24, color = 'black')),
        xaxis = list(title = list(text = "Date", font = list(size = 18, color = "black")),
                     tickfont = list(size = 12),
                     zeroline = F,
                     gridcolor = 'lightgrey'),
        yaxis = list(title = list(text = "Index Value", font = list(size = 18, color = "black")),
                     tickfont = list(size = 12),
                     zeroline = F,
                     gridcolor = 'lightgrey'),
        legend = list(orientation = "h", y = -0.2, xanchor = "center", x = 0.5, font = list(size = 12)),
        margin = list(l = 50, r = 50, t = 100, b = 50),
        plot_bgcolor = 'rgba(0, 0, 0, 0)',
        paper_bgcolor = 'rgba(0, 0, 0, 0)',
        annotations = list(x = min(dataSelected$DATE) %m+% years(1), y = -4, 
                           text = cor_text, showarrow = F, xanchor = 'left', yanchor = 'bottom', font = list(size = 12))
      ) %>%
      config(scrollZoom = TRUE, displayModeBar = TRUE, displaylogo = FALSE, modeBarButtonsToRemove = list('select2d', 'lasso2d'))
    
    
    return(p)
    
  })
  
  output$LeadPlot <- renderPlotly({
    
    dataSelected <- selectedData5()
    dataSelected$DATE <- as.Date(dataSelected$DATE)
    
    # Adjust the CMCI column based on the selected lag amount
    dataSelected <- dataSelected %>%
      arrange(DATE) %>%
      mutate(CMCI_led = lead(CMCI, as.numeric(input$cmciLead)))
    
    # Recalculate correlation and p-value with lagged CMCI
    cor_test <- cor.test(dataSelected[["CMCI_led"]], dataSelected[[input$indicator]], use = "complete.obs")
    cor_text <- sprintf("Correlation: %.4f\np-value: %.4f", cor_test$estimate, cor_test$p.value)
    
    # Plotly graph creation code remains the same, just change `y = ~dataSelected[["CMCI"]]` 
    # to `y = ~dataSelected[["CMCI_lagged"]]` for the CMCI line
    
    p <- plot_ly(data = dataSelected, x = ~DATE) %>%
      add_lines(y = ~dataSelected[["CMCI_led"]], name = "CMCI Line", line = list(color = 'darkgreen', width = 2),
                hoverinfo = 'text', text = ~paste('Date: ', DATE, '<br>Value: ', CMCI_led, '<br>Index: CMCI Line')) %>%
      add_lines(y = ~dataSelected[[input$indicator]], name = "Indicator Line", line = list(color = 'navy', width = 2),
                hoverinfo = 'text', text = ~paste('Date: ', DATE, '<br>Value: ', dataSelected[[input$indicator]], '<br>Index: Indicator Line')) %>%
      layout(
        title = list(text = "United States Indicator Comparison Graph", font = list(size = 24, color = 'black')),
        xaxis = list(title = list(text = "Date", font = list(size = 18, color = "black")),
                     tickfont = list(size = 12),
                     zeroline = F,
                     gridcolor = 'lightgrey'),
        yaxis = list(title = list(text = "Index Value", font = list(size = 18, color = "black")),
                     tickfont = list(size = 12),
                     zeroline = F,
                     gridcolor = 'lightgrey'),
        legend = list(orientation = "h", y = -0.2, xanchor = "center", x = 0.5, font = list(size = 12)),
        margin = list(l = 50, r = 50, t = 100, b = 50),
        plot_bgcolor = 'rgba(0, 0, 0, 0)',
        paper_bgcolor = 'rgba(0, 0, 0, 0)',
        annotations = list(x = min(dataSelected$DATE) %m+% years(1), y = -4, 
                           text = cor_text, showarrow = F, xanchor = 'left', yanchor = 'bottom', font = list(size = 12))
      ) %>%
      config(scrollZoom = TRUE, displayModeBar = TRUE, displaylogo = FALSE, modeBarButtonsToRemove = list('select2d', 'lasso2d'))
    
    
    return(p)
    
  })
  
}

# Run the application
shinyApp(ui = ui, server = server)


