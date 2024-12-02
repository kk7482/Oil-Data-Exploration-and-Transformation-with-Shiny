# Loading required packages
library(shiny)
library(gamlss.data)
library(zoo)
library(tseries)
library(dplyr)



# Loading the oil data
data(oil, package = "gamlss.data")
oil_data <- as.data.frame(oil)

# Defining transformation functions

roll_sd <- function(x, window) {
  rollapply(x, width = window, FUN = sd, align = "right", fill = NA)
}

roll_mean <- function(x, window) {
  rollapply(x, width = window, FUN = mean, align = "right", fill = NA)
}

lag_data <- function(x, lag) {
  stats::lag(x, k = lag)
}
diff_data <- function(x) {
  c(NA, diff(x))  
}

# calculating statistics
calculate_statistics <- function(x, y) {
  list(
    normality = tryCatch({
      shapiro.test(x)$p.value
    }, error = function(e) NA),
    stationarity = tryCatch({
      adf.test(na.omit(x))$p.value  
    }, error = function(e) NA),
    correlation = tryCatch({
      cor(x, y, use = "complete.obs")
    }, error = function(e) NA)
  )
}

# Defining UI
ui <- fluidPage(
  titlePanel("Oil Data Exploration and Transformation"),
  sidebarLayout(
    sidebarPanel(
      selectInput("transformation", "Select Transformation", choices = c(
        "Rolling Mean" = "Rolling Mean",
        "Rolling SD" = "Rolling SD",
        "Lagging" = "Lagging",
        "Differencing" = "Differencing"
      )),
      numericInput("window", "Window Size", value = 5, min = 1),
      numericInput("lag", "Lag Order", value = 1, min = 1),
      textInput("new_col_name", "New Column Name", value = "transformed_data"),
      actionButton("apply_transformation", "Apply Transformation"),
      downloadButton("download_data", "Download Data"),
      downloadButton("download_metadata", "Download Metadata")
    ),
    mainPanel(
      plotOutput("oilprice_plot"),
      verbatimTextOutput("oilprice_plot_description"),
      plotOutput("histogram_plot"),
      verbatimTextOutput("histogram_plot_description"),
      plotOutput("boxplot_plot"),
      verbatimTextOutput("boxplot_plot_description"),
      tableOutput("metadata_table")
    )
  )
)

# Defining server logic
server <- function(input, output, session) {
  transformations <- reactiveValues(data = oil_data, meta = list())
  
  observeEvent(input$apply_transformation, {
    new_data <- switch(input$transformation,
                       "Rolling Mean" = roll_mean(oil_data$OILPRICE, input$window),
                       "Rolling SD" = roll_sd(oil_data$OILPRICE, input$window),
                       "Lagging" = lag_data(oil_data$OILPRICE, input$lag),
                       "Differencing" = diff_data(oil_data$OILPRICE)
    )
    
    # Updating the data and metadata
    transformations$data[[input$new_col_name]] <- new_data
    
    # making metadata
    meta_data <- list(
      transformation = input$transformation,
      parameters = list(window = input$window, lag = input$lag),
      stats = calculate_statistics(new_data, oil_data$OILPRICE)
    )
    
    transformations$meta[[input$new_col_name]] <- meta_data
  })
  
  output$oilprice_plot <- renderPlot({
    plot(oil_data$OILPRICE, type = "l", main = "Oil Price Over Time", xlab = "Time", ylab = "Oil Price")
  })
  
  output$oilprice_plot_description <- renderText({
    "This line plot shows the oil prices over the recorded time period. It helps visualize the trend and fluctuations in oil prices, identifying long-term trends, seasonal patterns, and anomalies."
  })
  
  output$histogram_plot <- renderPlot({
    hist(oil_data$OILPRICE, main = "Histogram of Oil Prices", xlab = "Oil Price", breaks = 20)
  })
  
  output$histogram_plot_description <- renderText({
    "This histogram displays the distribution of oil prices. It provides insight into the frequency distribution of oil prices, helping to identify the most common price ranges and the spread of the data."
  })
  
  output$boxplot_plot <- renderPlot({
    boxplot(oil_data$OILPRICE, main = "Boxplot of Oil Prices", ylab = "Oil Price")
  })
  
  output$boxplot_plot_description <- renderText({
    "This boxplot presents the summary statistics of oil prices, including the median, quartiles, and potential outliers. It helps in understanding the central tendency and variability of the oil prices."
  })
  
  output$metadata_table <- renderTable({
    do.call(rbind, lapply(names(transformations$meta), function(col) {
      c(
        Driver = col,
        Transformation = transformations$meta[[col]]$transformation,
        Parameters = paste("Window:", transformations$meta[[col]]$parameters$window, "Lag:", transformations$meta[[col]]$parameters$lag),
        Normality = transformations$meta[[col]]$stats$normality,
        Stationarity = transformations$meta[[col]]$stats$stationarity,
        Correlation = transformations$meta[[col]]$stats$correlation
      )
    }))
  })
  
  output$download_data <- downloadHandler(
    filename = function() { "transformed_data.csv" },
    content = function(file) {
      write.csv(transformations$data, file, row.names = FALSE)
    }
  )
  
  output$download_metadata <- downloadHandler(
    filename = function() { "metadata.csv" },
    content = function(file) {
      write.csv(do.call(rbind, lapply(names(transformations$meta), function(col) {
        c(
          Driver = col,
          Transformation = transformations$meta[[col]]$transformation,
          Parameters = paste("Window:", transformations$meta[[col]]$parameters$window, "Lag:", transformations$meta[[col]]$parameters$lag),
          Normality = transformations$meta[[col]]$stats$normality,
          Stationarity = transformations$meta[[col]]$stats$stationarity,
          Correlation = transformations$meta[[col]]$stats$correlation
        )
      })), file, row.names = FALSE)
    }
  )
}

# Running on the Shiny App
shinyApp(ui = ui, server = server)
