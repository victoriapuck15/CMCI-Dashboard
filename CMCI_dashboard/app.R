# Load necessary libraries
library(shiny)
library(plotly)
library(bslib)
library(dplyr)
library(lubridate)
library(leaflet)
library(shinytest)



# Read the data from CSV file
data2 <- read.csv("cmciGood2.csv")
compare_df <- read.csv("compare_data.csv")
cci_cmci_df <- read.csv("CMCI_FINAL.csv")

data2[2:14]

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
  
  # CMCI Index Info page as the first page
  
  
  nav_panel(title = "CMCI Index Info", 
            
            page_fillable(
              card(
                HTML('<p class="fs-2">Composite Macroeconomic Consumer Index (CMCI)</p>'),
                #<p class="lh-base">This is a long paragraph written to show how the line-height of an element is affected by our utilities. Classes are applied to the element itself or sometimes the parent element. These classes can be customized as needed with our utility API.</p>
                HTML('<div class="p-3 mb-n6 bg-light-subtle text-dark "><p class="lh-base">In the aftermath of the COVID-19 pandemic, the global economy has experienced unprecedented shifts. The pandemic gave rise to supply chain disruptions, hindered economic growth, and introduced economic challenges on a global scale. These multifaceted issues have contributed to heightened volatility in the stock market and unpredictable fluctuations in business dynamics. Despite the effectiveness of traditional economic tools such as GDP Now models and indicators like the Consumer Confidence Index (CCI) in the past, their predictive capabilities have been challenged by the unique confluence of challenges brought about by the pandemic. <br><br> The CMCI index offers an alternative to traditional measures of consumer sentiment, without the use of expensive survey data.<br><br> Addressing the limitations of the CCI and single-value indicators, the CMCI is a composite index that serves as a proxy for consumer sentiment. The CMCI incorporates eleven distinct macroeconomic indicators collectively influencing consumer confidence and expectations as shown below. The eleven macroeconomic factors were collected from 14 different, high earning nations.</p> </div>'),
                HTML('<p class="fs-4 ">CMCI Variables</p>'),
                HTML('<div class="container">
  <div class="row">
    <!-- First column -->
    <div class="col-md-6">
      <div class="accordion accordion-flush" id="accordionFlushExampleLeft">
        <!-- First accordion item -->
        <div class="accordion-item">
          <h2 class="accordion-header">
            <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#flush-collapseOne" aria-expanded="false" aria-controls="flush-collapseOne">
              <p class="fw-bold">Gross Domestic Product (GDP)</p> 
            </button>
          </h2>
          <div id="flush-collapseOne" class="accordion-collapse collapse" data-bs-parent="#accordionFlushExampleLeft">
            <div class="accordion-body">The value of the goods and services produced by the nations economy minus the value of the goods and services used up in production. GDP is more often used by the government of a single country to measure its economic health.</div>
          </div>
        </div>
        
        <div class="accordion-item">
          <h2 class="accordion-header">
            <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#flush-collapseTwo" aria-expanded="false" aria-controls="flush-collapseTwo">
              <p class="fw-bold">Household Disposible Income </p> 
            </button>
          </h2>
          <div id="flush-collapseTwo" class="accordion-collapse collapse" data-bs-parent="#accordionFlushExampleLeft">
            <div class="accordion-body">Household disposable income is income available to households such as wages and salaries, income from self-employment and unincorporated enterprises, income from pensions and other social benefits, and income from financial investments (less any payments of tax, social insurance contributions and interest on financial liabilities).</div>
          </div>
        </div>
        
                <div class="accordion-item">
          <h2 class="accordion-header">
            <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#flush-collapseThree" aria-expanded="false" aria-controls="flush-collapseThree">
              <p class="fw-bold">Household Gross Savings</p> 
            </button>
          </h2>
          <div id="flush-collapseThree" class="accordion-collapse collapse" data-bs-parent="#accordionFlushExampleLeft">
            <div class="accordion-body">Net household saving is defined as household net disposable income plus the adjustment for the change in pension entitlements less household final consumption expenditure (households also include non-profit institutions serving households). The adjustment item concerns (mandatory) saving of households, by building up funds in employment-related pension schemes. Household saving is the main domestic source of funds to finance capital investments, a major impetus for long-term economic growth.</div>
          </div>
        </div>
        
        
                <div class="accordion-item">
          <h2 class="accordion-header">
            <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#flush-collapseFour" aria-expanded="false" aria-controls="flush-collapseFour">
              <p class="fw-bold">Employee Compensation</p> 
            </button>
          </h2>
          <div id="flush-collapseFour" class="accordion-collapse collapse" data-bs-parent="#accordionFlushExampleLeft">
            <div class="accordion-body">Earnings and wages are defined as "the total remuneration, in cash or in kind, payable to all persons counted on the payroll (including homeworkers), in return for work done during the accounting period", regardless of whether it is paid on the basis of working time, output or piecework and whether it is paid regularly or not.

</div>
          </div>
        </div>
        
        <div class="accordion-item">
          <h2 class="accordion-header">
            <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#flush-collapseFive" aria-expanded="false" aria-controls="flush-collapseFive">
              <p class="fw-bold">Employment Rate </p>  
            </button>
          </h2>
          <div id="flush-collapseFive" class="accordion-collapse collapse" data-bs-parent="#accordionFlushExampleRight">
            <div class="accordion-body">
Employment rates are defined as a measure of the extent to which available labour resources (people available to work) are being used. They are calculated as the ratio of the employed to the working age population. <br> <br> Employment rates are sensitive to the economic cycle, but in the longer term they are significantly affected by governments higher education and income support policies and by policies that facilitate employment of women and disadvantaged groups. Employed people are those aged 15 or over who report that they have worked in gainful employment for at least one hour in the previous week or who had a job but were absent from work during the reference week. The working age population refers to people aged 15 to 64.</div>
          </div>
        </div>
        
        
        
      </div>
    </div>

    <!-- Second column -->
    <div class="col-md-6">
      <div class="accordion accordion-flush" id="accordionFlushExampleRight">
        <!-- Second accordion item -->

        
        
                
                <div class="accordion-item">
          <h2 class="accordion-header">
            <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#flush-collapseSix" aria-expanded="false" aria-controls="flush-collapseSix">
              <p class="fw-bold">Consumer Loan Interest Rates</p> 
            </button>
          </h2>
          <div id="flush-collapseSix" class="accordion-collapse collapse" data-bs-parent="#accordionFlushExampleLeft">
            <div class="accordion-body">Interest rates on personal loans taken out at commercial bank. This does not include loans for business or home purchases.</div>
          </div>
        </div>
        
                        <div class="accordion-item">
          <h2 class="accordion-header">
            <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#flush-collapseSeven" aria-expanded="false" aria-controls="flush-collapseSeven">
              <p class="fw-bold">Mortagage Loan Interest Rates</p> 
            </button>
          </h2>
          <div id="flush-collapseSeven" class="accordion-collapse collapse" data-bs-parent="#accordionFlushExampleLeft">
            <div class="accordion-body">Interest rates on loans taken to purchase a home.</div>
          </div>
        </div>

        
                                        <div class="accordion-item">
          <h2 class="accordion-header">
            <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#flush-collapseEight" aria-expanded="false" aria-controls="flush-collapseEight">
              <p class="fw-bold">Share Price Index</p> 
            </button>
          </h2>
          <div id="flush-collapseEight" class="accordion-collapse collapse" data-bs-parent="#accordionFlushExampleLeft">
            <div class="accordion-body">Share price indices are calculated from the prices of common shares of companies traded on national or foreign stock exchanges. They are usually determined by the stock exchange, using the closing daily values for the monthly data, and normally expressed as simple arithmetic averages of the daily data. A share price index measures how the value of the stocks in the index is changing. </div>
          </div>
        </div>
        
                                                <div class="accordion-item">
          <h2 class="accordion-header">
            <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#flush-collapseNine" aria-expanded="false" aria-controls="flush-collapseNine">
              <p class="fw-bold">Terms of Trade</p> 
            </button>
          </h2>
          <div id="flush-collapseNine" class="accordion-collapse collapse" data-bs-parent="#accordionFlushExampleLeft">
            <div class="accordion-body">Terms of trade are defined as the ratio between the index of export prices and the index of import prices. If the export prices increase more than the import prices, a country has a positive terms of trade, as for the same amount of exports, it can purchase more imports. </div>
          </div>
        </div>
        
                
                                <div class="accordion-item">
          <h2 class="accordion-header">
            <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#flush-collapseTen" aria-expanded="false" aria-controls="flush-collapseTen">
              <p class="fw-bold">Home Price Index</p> 
            </button>
          </h2>
          <div id="flush-collapseTen" class="accordion-collapse collapse" data-bs-parent="#accordionFlushExampleLeft">
            <div class="accordion-body">Housing prices include housing rent prices indices, real and nominal house prices indices, and ratios of price to rent and price to income. In most cases, the nominal house price index covers the sales of newly-built and existing dwellings, following the recommendations from the RPPI (Residential Property Prices Indices) manual. The real house price index is given by the ratio of the nominal house price index to the consumers’ expenditure deflator in each country from the OECD national accounts database. Both indices are seasonally adjusted. The price to income ratio is the nominal house price index divided by the nominal disposable income per head and can be considered as a measure of affordability. The price to rent ratio is the nominal house price index divided by the housing rent price index and can be considered as a measure of the profitability of house ownership. The price to income and price to rent ratios are indices with base year 2015.</div>
          </div>
        </div>
        
                        
                                <div class="accordion-item">
          <h2 class="accordion-header">
            <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#flush-collapseEleven" aria-expanded="false" aria-controls="flush-collapseEleven">
              <p class="fw-bold">Effective Exchange Rate</p> 
            </button>
          </h2>
          <div id="flush-collapseEleven" class="accordion-collapse collapse" data-bs-parent="#accordionFlushExampleLeft">
            <div class="accordion-body">	Real effective exchange rate is the nominal effective exchange rate (a measure of the value of a currency against a weighted average of several foreign currencies) divided by a price deflator or index of costs.</div>
          </div>
        </div>
       
        
      </div>
    </div>
  </div>
</div>')
                
                
                ,HTML('<p class="fs-4 ">Evaluating CMCI Accuracy</p>'),
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
'),                HTML('<div class="container">
 <p class="fs-5 ">Evaluating CMCI Predictive Power</p>
  <div class="row">
    <div class="col-md-6">
      <div class="p-1 mb-n6 bg-light-subtle text-dark">
        <p class="lh-base"> In the table to the right, the high 𝜇 values for the β coefficients indicates that the CMCI index has a high predictive power for the y variable, which in this case is the CCI. In addition to the high 𝜇 values seen in the table, there are also very low variance values, indicating that the statistically significant region for the 𝜇 value would not include zero, meaning that the CMCI has significant impact on predicting the CCI.  <br> <br>The best result in this table is when the CMCI is lagged to t-3, which means the data is moved backward 3 quarters, making it a predictor for the CCI. In this scenario the 95% credible interval of the 𝜇 value for the β coefficient is (0.090,0.792). Being that zero is not included in this interval shows that the CMCI is a statistically significant predictor variable for the CCI in this case.
        </p>
      </div>
    </div>
    <div class="col-md-6">
      <div class="table-responsive">
        <table class="table table-hover table-sm">
          <thead>
            <tr>
              <th scope="col" class="font-weight-bold text-dark">Lag of CMCI</th>
              <th scope="col" class="font-weight-bold text-dark">Beta μ Value</th>
              <th scope="col" class="font-weight-bold text-dark">Beta Variance Value</th>
            </tr>
          </thead>
          <p class="fs-5 ">Values</p>
          <tbody class="table-light">
            <tr>
              <th scope="row" class="fw-normal">t-1 Lag</th>
              <td>0.3994</td>
              <td>0.0381</td>
            </tr>
            <tr>
              <th scope="row" class="fw-normal">t-2 Lag</th>
              <td>0.4417</td>
              <td>0.0321</td>
            </tr>
            <tr>
              <th scope="row" class="fw-normal">t-3 Lag</th>
              <td>0.3942</td>
              <td>0.0386</td>
            </tr>
            
          </tbody>
        </table>
      </div>
    </div>
  </div>
</div>
') ,HTML('<div class="container">
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
</div>')
              ))
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
                    
                    varSelectInput("indicatorTwo", "Indicator", compare_df[3:5], 
                                   selected = "CSI"),
                    hr(),
                    sliderInput("cmciLead", "Lead CMCI by:",
                                min = 0, max = 4, value = 0, step = 1)
                    
                  ),
                  plotlyOutput("LeadPlot")
                ))
              
            )
            
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
      select(c("DATE", c("CMCI", input$indicatorTwo)))
  })
  
  
  
  output$CMCIPlot <- renderPlotly({
    # Filter data based on selected countries
    
    if (length(input$countries) == 0) {
      # When no countries are selected, display a placeholder message
      p <- plot_ly() %>%
        layout(
          title = list(
            text = "No Data Selected",
            font = list(size = 30, color = '#333333', family = "Arial, sans-serif"),
            x = 0.5
          ),
          plot_bgcolor = 'rgba(0, 0, 0, 0)', # Set background color to white for a clean look
          paper_bgcolor = 'rgba(0, 0, 0, 0)',
          xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
          yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
          annotations = list(
            list(
              text = "It seems as though you haven't selected <br> any countries to plot!<br><br>Please select at least one country<br>to display the data.",
              x = 0.5,
              y = 0.5,
              xref = "paper",
              yref = "paper",
              showarrow = FALSE,
              font = list(
                family = "Arial, sans-serif",
                size = 25,
                color = '#666666'
              ),
              align = "center"
            )
          ),
          margin = list(l = 50, r = 50, t = 50, b = 50)
        ) %>%
        config(displayModeBar = FALSE) # Hide the mode bar for a cleaner look
    } else {
    
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
      
    }
    
    
      return(p)
    
  })
  
  output$ComparisonPlot <- renderPlotly({
    # Filter data based on selected countries
    
    if (length(input$indexes) == 0) {
      # When no countries are selected, display a placeholder message
      p <- plot_ly() %>%
        layout(
          title = list(
            text = "No Data Selected",
            font = list(size = 30, color = '#333333', family = "Arial, sans-serif"),
            x = 0.5
          ),
          plot_bgcolor = 'rgba(0, 0, 0, 0)', # Set background color to white for a clean look
          paper_bgcolor = 'rgba(0, 0, 0, 0)',
          xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
          yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
          annotations = list(
            list(
              text = "It seems as though you haven't selected <br> any indexes to plot!<br><br>Please select at least one index<br>to display the data.",
              x = 0.5,
              y = 0.5,
              xref = "paper",
              yref = "paper",
              showarrow = FALSE,
              font = list(
                family = "Arial, sans-serif",
                size = 25,
                color = '#666666'
              ),
              align = "center"
            )
          ),
          margin = list(l = 50, r = 50, t = 50, b = 50)
        ) %>%
        config(displayModeBar = FALSE) # Hide the mode bar for a cleaner look
    } else {
    
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
    }
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
    cor_test <- cor.test(dataSelected[["CMCI_led"]], dataSelected[[input$indicatorTwo]], use = "complete.obs")
    cor_text <- sprintf("Correlation: %.4f\np-value: %.4f", cor_test$estimate, cor_test$p.value)
    
    # Plotly graph creation code remains the same, just change `y = ~dataSelected[["CMCI"]]` 
    # to `y = ~dataSelected[["CMCI_lagged"]]` for the CMCI line
    
    p <- plot_ly(data = dataSelected, x = ~DATE) %>%
      add_lines(y = ~dataSelected[["CMCI_led"]], name = "CMCI Line", line = list(color = 'darkgreen', width = 2),
                hoverinfo = 'text', text = ~paste('Date: ', DATE, '<br>Value: ', CMCI_led, '<br>Index: CMCI Line')) %>%
      add_lines(y = ~dataSelected[[input$indicatorTwo]], name = "Indicator Line", line = list(color = 'navy', width = 2),
                hoverinfo = 'text', text = ~paste('Date: ', DATE, '<br>Value: ', dataSelected[[input$indicatorTwo]], '<br>Index: Indicator Line')) %>%
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



