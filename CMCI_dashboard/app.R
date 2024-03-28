# Load necessary libraries
library(shiny)
library(plotly)
library(bslib)
library(dplyr)
library(lubridate)
library(leaflet)




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
  tags$head(
    tags$style(HTML("
      :root {
        --accordion-bg-color: #B1B5C8; 
        --accordion-text-color: black; 
      }
      .accordion-item {
        background-color: white; /* Set background color using CSS variable */
        color: black; /* Set text color using CSS variable */
      }
      .accordion-button {
        background-color: #B1B5C8; /* Set background color for accordion buttons */
        color: black; /* Set text color for accordion buttons */
      }
    "))
    ),
  nav_panel(title = "CMCI Data", 
            
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
  nav_panel(title = "U.S Index Data", 
            
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
  nav_panel(title = "Comparitive CMCI and CCI Data", 
            
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
  nav_panel(title = "U.S Lag Data", 
            
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
  
  nav_panel(title = "U.S Lead Data", 
            
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
                HTML('<p class="fs-2">Composite Macroeconomic Consumer Index (CMCI)</p>'),
                #<p class="lh-base">This is a long paragraph written to show how the line-height of an element is affected by our utilities. Classes are applied to the element itself or sometimes the parent element. These classes can be customized as needed with our utility API.</p>
                HTML('<div class="p-3 mb-n6 bg-light-subtle text-dark "><p class="lh-base">In the aftermath of the COVID-19 pandemic, the global economy has experienced unprecedented shifts. The pandemic gave rise to supply chain disruptions, hindered economic growth, and introduced economic challenges on a global scale. These multifaceted issues have contributed to heightened volatility in the stock market and unpredictable fluctuations in business dynamics. Despite the effectiveness of traditional economic tools such as GDP Now models and indicators like the Consumer Confidence Index (CCI) in the past, their predictive capabilities have been challenged by the unique confluence of challenges brought about by the pandemic. <br><br> The CMCI index offers an alternative to traditional measures of consumer sentiment, without the use of expensive survey data.<br><br> Addressing the limitations of the CCI and single-value indicators, the CMCI is a composite index that serves as a proxy for consumer sentiment. The CMCI incorporates eleven distinct macroeconomic indicators collectively influencing consumer confidence and expectations as shown below. The eleven macroeconomic factors were collected from 14 different, high earning nations.</p> </div>'),
                HTML('<p class="fs-4 ">CMCI Variables</p>'),
                HTML('<div class="accordion accordion-flush" id="accordionFlushExample">
  <div class="accordion-item">
    <h2 class="accordion-header">
      <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#flush-collapseOne" aria-expanded="false" aria-controls="flush-collapseOne">
        <p class="fw-bold">Gross Domestic Product (GDP)</p> 
      </button>
    </h2>
    <div id="flush-collapseOne" class="accordion-collapse collapse" data-bs-parent="#accordionFlushExample">
      <div class="accordion-body">Information on GDP. </div>
                       </div>
                       </div>
                       
               <div class="accordion-item">
               <h2 class="accordion-header">
               <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#flush-collapseTwo" aria-expanded="false" aria-controls="flush-collapseTwo">
               <p class="fw-bold">Household Disposible Income</p> 
             </button>
               </h2>
               <div id="flush-collapseTwo" class="accordion-collapse collapse" data-bs-parent="#accordionFlushExample">
               <div class="accordion-body">Information on HDI. </div>
               </div>
               </div>
               
               <div class="accordion-item">
               <h2 class="accordion-header">
               <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#flush-collapseThree" aria-expanded="false" aria-controls="flush-collapseThree">
              <p class="fw-bold">Gross Household Savings</p>  
             </button>
               </h2>
               <div id="flush-collapseThree" class="accordion-collapse collapse" data-bs-parent="#accordionFlushExample">
               <div class="accordion-body">Information on GHS </div>
</div>
  </div>
</div>
                     
                     
                     
                     
                     
                     
                     
                     '
                     
                     
                     
                     
                     
                     ),HTML('<p class="fs-4 ">Evaluating CMCI Accuracy</p>'),
               HTML('<div class="container">
  <div class="row">
    <div class="col-md-6">
      <div class="p-1 mb-n6 bg-light-subtle text-dark">
        <p class="lh-base">In order to most accurately evaluate the accuracy of the CMCI, a Princple Component Analysis (PCA) must first be conducted. <br>  <br> PCA is a multivariate statistical technique that aims to uncover the latent structures within a dataset, revealing the key variables that contribute significantly to the cumulative variance observed in the macroeconomic factors comprising the CMCI. <br> <br> Notably, the analysis revealed that a substantial portion, about 25.21% of the variance is explained by the Gross Domestic Product (GDP) macroeconomic indicator. This finding underscores the significance of GDP in predicting future values using the CMCI index.The second largest contributor to the variance of the data set is household disposable income, contributing  12.49% of the variance. 
        </p>
      </div>
    </div>
    <div class="col-md-6">
      <div class="table-responsive">
        <table class="table table-hover table-sm">
          <thead>
            <tr>
              <th scope="col" class="font-weight-bold text-dark">Component #</th>
              <th scope="col" class="font-weight-bold text-dark">% of Variance Explained</th>
            </tr>
          </thead>
          <p class="fs-5 ">PCA Results</p>
          <tbody class="table-light">
            <tr>
              <th scope="row" class="fw-normal">PC 1: Quarterly Gross Domestic Product</th>
              <td>25.21%</td>
            </tr>
            <tr>
              <th scope="row" class="fw-normal">PC 2: Household Disposable Income</th>
              <td>12.59</td>
            </tr>
            <tr>
              <th scope="row" class="fw-normal">PC 3: Gross Household Savings</th>
              <td>12.02%</td>
            </tr>
            
            <tr>
              <th scope="row" class="fw-normal">PC 4: Employee Compensation</th>
              <td>10.98%</td>
            </tr>            

            <tr>
              <th scope="row" class="fw-normal">PC 5: Employment Rate</th>
              <td>9.10%</td>
            </tr>
            
            <tr>
              <th scope="row" class="fw-normal">PC 6: Share Price Index</th>
              <td>8.09%</td>
            </tr>
            
            <tr>
              <th scope="row" class="fw-normal">PC 7: Effective Exchange Rate</th>
              <td>7.48%</td>
            </tr>

            <tr>
              <th scope="row" class="fw-normal">PC 8: Terms of Trade</th>
              <td>5.56%</td>
            </tr>

            <tr>
              <th scope="row" class="fw-normal">PC 9: House Price Index</th>
              <td>4.87%</td>
            </tr>

            <tr>
              <th scope="row" class="fw-normal">PC 10: Interest Rates on Mortgages</th>
              <td>2.33%</td>
            </tr>
            
            <tr>
              <th scope="row" class="fw-normal">PC 11: Interest Rates on Consumer Loans</th>
              <td>1.59%</td>
            </tr>            
            
          </tbody>
        </table>
      </div>
    </div>
  </div>
</div>
'), HTML('<div class="container">
  <div class="row">
    <div class="col-md-6">
      <p class="fs-5">GARCH Volatility Analysis</p>
      <div class="accordion accordion-flush" id="accordionFlushExample">
        <div class="accordion-item">
          <h2 class="accordion-header">
            <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#flush-collapseOne" aria-expanded="false" aria-controls="flush-collapseOne">
              <p class="fw-bold">Mean Model</p> 
            </button>
          </h2>
          <div id="flush-collapseOne" class="accordion-collapse collapse" data-bs-parent="#accordionFlushExample">
            <div class="accordion-body">The mean model revealed a negative constant mean coefficient μ of -0.1476. <br> <br> This suggests a tendency for the home index to experience below-average returns during the analyzed period.</div>
          </div>
        </div>
        
        <div class="accordion-item">
          <h2 class="accordion-header">
            <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#flush-collapseTwo" aria-expanded="false" aria-controls="flush-collapseTwo">
              <p class="fw-bold">Volatility Model</p> 
            </button>
          </h2>
          <div id="flush-collapseTwo" class="accordion-collapse collapse" data-bs-parent="#accordionFlushExample">
            <div class="accordion-body">The Volaitility Model reveals three different parameters: <br> <br> <ul>
  <li>Constant Variance (ω) = 1.9712e-03 </li>
  <li>ARCH coefficient (α[1]) = 0.8758 </li>
  <li>GARCH Coefficient (β[1]) = 0.1242 </li>
</ul>  The positive ARCH coefficient (α[1]) implies a significant impact of past volatility shocks on the current volatility level, indicating volatility clustering. Additionally, the GARCH coefficient GARCH Coefficient (β[1]) of 0.1242 signifies the persistence of the  impact of past volatility on future volatility, showcasing a degree of memory in the volatility process.</div>
          </div>
        </div>
        
        <div class="accordion-item">
          <h2 class="accordion-header">
            <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#flush-collapseThree" aria-expanded="false" aria-controls="flush-collapseThree">
              <p class="fw-bold">Model Fit</p>  
            </button>
          </h2>
          <div id="flush-collapseThree" class="accordion-collapse collapse" data-bs-parent="#accordionFlushExample">
            <div class="accordion-body">The Fit Model of reveals three different parameters: <br> <br> <ul>
  <li>Log-Likelihood = -9.09875 </li>
  <li>AIC= 26.1975 </li>
  <li>BIC= 32.0604 </li>
</ul> The low log-likelihood and associated AIC and BIC values indicate a relatively good fit of the GARCH model to the data. </div>
          </div>
        </div>
      </div>
    </div>
    <div class="col-md-6">
      <!-- Second column of just text -->
      <div class="p-1 mb-n6 bg-light-subtle text-dark">
        <p class="lh-base"> <br> <br> <br> 
          The generalized autoregressive conditional heteroskedasticity (GARCH) process, as employed by Abosedra et al., is utilized to analyze the data comprising the novel CMCI index. <br> <br> 
          Widely acknowledged as the industry standard for estimating volatility in financial markets and the economy, the application of the GARCH process aims to unveil insights into the dynamics between consumer sentiment (represented by the CMCI index) and macroeconomic factors. This approach seeks to identify symmetries between variables, with a particular focus on discerning the variables that contribute the most to the cumulative variance of the dataset.
          <br> <br>
          The results of the GARCH analysis for the CMCI shed light on the presence of volatility clustering, leverage effects, and the persistence of past volatility. This analysis goes beyond conventional measures of risk and return, offering a dynamic perspective on the underlying volatility.
        </p>
      </div>
    </div>
  </div>
</div>

')

                ))
  ),
  nav_spacer(),
  nav_menu(
    title = "Sources",
    align = "right",
    nav_item(tags$a("Parent Paper", href = "https://link.springer.com/article/10.1007/s11205-021-02626-6")),
    nav_item(tags$a("Our Paper", href = "https://www.overleaf.com/read/btjkspsqpdjq#5f5c4e"))
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


