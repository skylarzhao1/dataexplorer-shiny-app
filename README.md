#  DataExplorer Pro — Shiny App

An interactive data analysis web application built with R Shiny.
This app provides a full pipeline for **data loading, cleaning, feature engineering, and exploratory data analysis (EDA)**.

---

##  Live Demo

👉 https://project2-team-webapplication.shinyapps.io/project2/

---

##  Features

### Data Loading

* Upload datasets: CSV, Excel (.xlsx/.xls), JSON, RDS
* Built-in datasets: `iris`, `mtcars`, `diamonds`, `airquality`
* Automatic preview, summary statistics, and column insights

###  Data Cleaning

* Missing value handling (mean, median, mode, constant)
* Duplicate removal
* Outlier detection (IQR, Z-score)
* Scaling (Min-Max, Z-score, Robust)

###  Feature Engineering

* Mathematical transformations (log, sqrt, square, etc.)
* Interaction features (A×B, A/B, etc.)
* Binning (equal width / quantile)

###  Exploratory Data Analysis (EDA)

* Interactive Plotly visualizations:

  * Histogram, density, box, violin, scatter
* Correlation heatmap
* Row filtering and dynamic statistics
* Download processed dataset

---

##  Tech Stack

* **R**
* **Shiny**
* **shinydashboard**
* **plotly**
* **dplyr**
* **DT**

---

## Installation

Clone the repository:

```bash
git clone https://github.com/skylarzhao1/dataexplorer-shiny-app.git
cd dataexplorer-shiny-app
```

Install required R packages:

```r
install.packages(c(
  "shiny",
  "shinydashboard",
  "shinyWidgets",
  "DT",
  "ggplot2",
  "plotly",
  "dplyr",
  "tidyr",
  "readr",
  "readxl",
  "jsonlite",
  "e1071",
  "scales"
))
```

---

## Run Locally

```r
shiny::runApp()
```

---

## Project Structure

```
dataexplorer-shiny-app/
 ├── app.R
 ├── README.md
 └── .gitignore
```

---

##  Highlights

* End-to-end data workflow in a single Shiny application
* Fully interactive UI with real-time feedback
* Modular design supporting multiple datasets and transformations
* Deployable to cloud via shinyapps.io

---

