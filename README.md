# Oil Data Exploration and Transformation with Shiny  

This repository contains a Shiny app for exploring and transforming oil price data using various statistical techniques. The app provides tools for data transformation, visualization, and metadata analysis, making it an effective solution for exploratory data analysis (EDA) on time series data.

---

## Features  

1. **Data Transformation**:  
   - **Rolling Mean**  
   - **Rolling Standard Deviation**  
   - **Lagging**  
   - **Differencing**  

2. **Visualizations**:  
   - Line plot for oil prices over time.  
   - Histogram to visualize the distribution of oil prices.  
   - Boxplot for statistical summary and anomaly detection.  

3. **Metadata Generation**:  
   - Transformation type and parameters.  
   - Normality test (Shapiro-Wilk test).  
   - Stationarity test (Augmented Dickey-Fuller test).  
   - Correlation with original oil prices.  

4. **Data Export**:  
   - Export transformed data as a CSV file.  
   - Export metadata as a CSV file.  

---

## Installation  

1. Install R and RStudio.  
2. Install the required R packages:  
   ```R
   install.packages(c("shiny", "gamlss.data", "zoo", "tseries", "dplyr"))
   ```
3. Clone this repository:  
   ```bash
   git clone https://github.com/yourusername/oil-data-shiny.git
   cd oil-data-shiny
   ```
4. Run the app:  
   ```R
   shiny::runApp()
   ```

---

## Usage  

1. Open the app in your browser.  
2. Select the desired transformation type and parameters (e.g., window size, lag).  
3. View interactive plots to analyze trends, distributions, and summary statistics.  
4. Download transformed data and metadata for further analysis.

---
