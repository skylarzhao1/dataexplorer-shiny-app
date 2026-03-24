# =============================================================================
# Project 2: DataExplorer Pro — Single File R Shiny App
# All features in one file: UI + Server
# NEW additions vs original code are marked with: # [NEW] ...
# =============================================================================

# [NEW] Added: shinydashboard, shinyWidgets, DT, plotly, tidyr, readxl,
#              jsonlite, e1071, scales — original only had shiny + ggplot2 + readxl
library(shiny)
library(shinydashboard)   # [NEW] professional dashboard layout (replaces fluidPage)
library(shinyWidgets)     # [NEW] enhanced UI widgets
library(DT)               # [NEW] interactive data tables
library(ggplot2)
library(plotly)           # [NEW] interactive plots (replaces base R plot/hist)
library(dplyr)            # [NEW] data wrangling
library(tidyr)            # [NEW] pivot_longer for transform preview
library(readr)
library(readxl)
library(jsonlite)         # [NEW] JSON file support
library(e1071)            # [NEW] skewness calculation in EDA
library(scales)           # [NEW] axis formatting helpers

# =============================================================================
# UI
# =============================================================================
ui <- dashboardPage(
  skin = "blue",   # [NEW] themed dashboard skin
  
  # [NEW] Dashboard header (replaces titlePanel)
  dashboardHeader(title = "DataExplorer Pro", titleWidth = 220),
  
  # [NEW] Sidebar navigation with icons (replaces tabsetPanel tabs)
  dashboardSidebar(
    width = 220,
    sidebarMenu(
      id = "tabs",
      menuItem("User Guide",          tabName = "guide",   icon = icon("book-open")),
      menuItem("Load Data",           tabName = "upload",  icon = icon("upload")),
      menuItem("Data Cleaning",       tabName = "clean",   icon = icon("broom")),
      menuItem("Feature Engineering", tabName = "feature", icon = icon("cogs")),
      menuItem("EDA",                 tabName = "eda",     icon = icon("chart-bar"))
    ),
    hr(),
    # [NEW] Live dataset status shown in sidebar
    div(style = "padding:8px 15px; color:#bbb; font-size:12px;",
        strong("Dataset:"), br(),
        textOutput("sb_name", inline = TRUE), br(),
        textOutput("sb_dim",  inline = TRUE))
  ),
  
  # Body
  dashboardBody(
    
    # [NEW] Custom CSS for polished look
    tags$head(tags$style(HTML("
      .skin-blue .main-header .logo,
      .skin-blue .main-header .navbar { background:#1a2a3a !important; }
      .skin-blue .main-sidebar        { background:#1e3248 !important; }
      .skin-blue .sidebar-menu>li.active>a,
      .skin-blue .sidebar-menu>li:hover>a { background:#2c4d6e !important; }
      .content-wrapper { background:#f0f3f7; }
      .box { border-radius:8px; box-shadow:0 2px 8px rgba(0,0,0,.1); border-top:none !important; }
      .box-header { border-radius:8px 8px 0 0; }
      /* stat tiles for overview numbers */
      .stat-tile { background:#fff; border-radius:8px; padding:14px 18px;
                   box-shadow:0 2px 6px rgba(0,0,0,.08); text-align:center; }
      .stat-tile h2 { margin:4px 0 0; font-size:26px; font-weight:700; }
      .stat-tile p  { margin:0; font-size:12px; color:#888; }
      /* guide page cards */
      .g-card { background:#fff; border-radius:10px; padding:20px;
                margin-bottom:18px; border-left:5px solid #3498db;
                box-shadow:0 2px 6px rgba(0,0,0,.07); }
      .g-card.green  { border-left-color:#27ae60; }
      .g-card.orange { border-left-color:#e67e22; }
      .g-card.red    { border-left-color:#e74c3c; }
      .step-num { display:inline-block; background:#3498db; color:#fff;
                  border-radius:50%; width:26px; height:26px;
                  text-align:center; line-height:26px; font-weight:700;
                  margin-right:6px; font-size:13px; }
      /* log console style */
      .log-box { background:#1e1e1e; color:#9cdcfe; font-family:monospace;
                 font-size:11px; border-radius:6px; padding:10px;
                 max-height:180px; overflow-y:auto; white-space:pre-wrap; }
      label { font-weight:600; font-size:13px; }
      .btn-block { width:100%; }
    "))),
    
    tabItems(
      
      # ======================================================================
      # TAB 1: USER GUIDE  [NEW] — original had a 3-line placeholder
      # ======================================================================
      tabItem("guide",
              fluidRow(column(12,
                              div(class = "g-card",
                                  h2(icon("rocket"), " Welcome to DataExplorer Pro"),
                                  p("A complete interactive data science workflow: upload → clean →
               engineer features → explore. Follow the four steps below.")
                              )
              )),
              fluidRow(
                column(6,
                       div(class = "g-card",
                           h4(tags$span(class="step-num","1"), " Load Dataset"),
                           tags$ul(
                             tags$li("Upload CSV, Excel (.xlsx/.xls), JSON, or RDS files"),  # [NEW] JSON + RDS
                             tags$li("Or pick a built-in dataset: iris, mtcars, diamonds, airquality"),
                             tags$li("Instant preview, column type badges, and missing-value counts")
                           )
                       ),
                       div(class = "g-card orange",
                           h4(tags$span(class="step-num","3"), " Feature Engineering"),  # [NEW] entire tab
                           tags$ul(
                             tags$li("Math transforms: log, sqrt, square, reciprocal, cube root"),
                             tags$li("Interaction features: multiply, divide, add, subtract, ratio"),
                             tags$li("Bin numeric columns into equal-width or quantile buckets"),
                             tags$li("Before/after density preview for every transform")
                           )
                       )
                ),
                column(6,
                       div(class = "g-card green",
                           h4(tags$span(class="step-num","2"), " Data Cleaning"),  # [NEW] expanded
                           tags$ul(
                             tags$li("Remove or impute missing values (mean / median / mode / constant)"),
                             tags$li("Remove duplicate rows"),
                             tags$li("Handle outliers via IQR or Z-score: remove, cap, or NA-replace"),
                             tags$li("Min-Max / Z-score / Robust scaling"),
                             tags$li("Label encoding or One-Hot encoding for categorical columns")
                           )
                       ),
                       div(class = "g-card red",
                           h4(tags$span(class="step-num","4"), " EDA"),  # [NEW] expanded
                           tags$ul(
                             tags$li("Interactive Plotly plots: histogram, density, box, violin, bar"),
                             tags$li("Scatter plot with optional colour grouping and trend line"),
                             tags$li("Correlation heatmap with selectable columns"),
                             tags$li("Row-level filter slider + downloadable processed CSV")
                           )
                       )
                )
              ),
              fluidRow(column(12,
                              div(class = "g-card",
                                  h4(icon("lightbulb"), " Quick Tips"),
                                  fluidRow(
                                    column(4, p("💡 Always load a dataset first — all other tabs depend on it.")),
                                    column(4, p("💡 Cleaning and feature steps are cumulative; use Reset to undo all.")),
                                    column(4, p("💡 Download your final processed data from the EDA tab."))
                                  )
                              )
              ))
      ),
      
      # ======================================================================
      # TAB 2: LOAD DATA
      # Original: only CSV + Excel, 2 built-in datasets, basic tableOutput preview
      # [NEW]: added JSON + RDS support, 4 built-in datasets, DT preview,
      #        col info table, summary stats, stat tiles
      # ======================================================================
      tabItem("upload",
              fluidRow(
                box(title = "Load Dataset", width = 4, status = "primary", solidHeader = TRUE,
                    h4("Upload a File"),
                    fileInput("file_up", NULL,
                              accept      = c(".csv",".xlsx",".xls",".json",".rds"),
                              buttonLabel = "Browse…",
                              placeholder = "CSV / Excel / JSON / RDS"),  # [NEW] JSON, RDS
                    tags$small(style = "color:#888", "Supported: .csv  .xlsx  .xls  .json  .rds"),
                    hr(),
                    h4("Built-in Datasets"),
                    # [NEW] 4 built-in datasets (original had only mtcars + iris)
                    selectInput("builtin", NULL,
                                choices = c("-- select --" = "",
                                            "iris", "mtcars", "diamonds", "airquality")),
                    actionButton("load_builtin", "Load Selected Dataset",
                                 class = "btn-primary btn-block", icon = icon("database")),
                    hr(),
                    h4("CSV Options"),
                    checkboxInput("csv_header", "Header row", TRUE),
                    selectInput("csv_sep", "Separator",
                                choices = c("Comma (,)" = ",", "Semicolon (;)" = ";",
                                            "Tab" = "\t", "Pipe (|)" = "|"))
                ),
                
                box(title = "Dataset Overview", width = 8, status = "info", solidHeader = TRUE,
                    # [NEW] stat tiles (original had none)
                    fluidRow(
                      column(3, div(class="stat-tile",
                                    p("Rows"),       h2(textOutput("ov_rows", inline=TRUE), style="color:#3498db"))),
                      column(3, div(class="stat-tile",
                                    p("Columns"),   h2(textOutput("ov_cols", inline=TRUE), style="color:#27ae60"))),
                      column(3, div(class="stat-tile",
                                    p("Missing"),   h2(textOutput("ov_miss", inline=TRUE), style="color:#e74c3c"))),
                      column(3, div(class="stat-tile",
                                    p("Duplicates"),h2(textOutput("ov_dup",  inline=TRUE), style="color:#e67e22")))
                    ),
                    br(),
                    uiOutput("ov_badges"),  # [NEW] column type badges
                    br(),
                    # [NEW] three preview sub-tabs (original had only one tableOutput)
                    tabsetPanel(
                      tabPanel("Preview",  br(), DTOutput("tbl_preview")),
                      tabPanel("Summary",  br(), verbatimTextOutput("tbl_summary")),
                      tabPanel("Col Info", br(), DTOutput("tbl_colinfo"))
                    )
                )
              )
      ),
      
      # ======================================================================
      # TAB 3: DATA CLEANING
      # Original: only remove_na checkbox + remove_dup checkbox
      # [NEW] entire cleaning interface below
      # ======================================================================
      tabItem("clean",
              fluidRow(
                # -- Missing values --
                column(4,
                       box(title = "Missing Values", width = NULL, status = "warning", solidHeader = TRUE,
                           plotlyOutput("miss_bar", height = "160px"),  # [NEW] missing value bar chart
                           br(),
                           # [NEW] 6 strategies (original had only remove)
                           selectInput("miss_strat", "Strategy:",
                                       choices = c("Remove rows (any NA)"  = "rm_any",
                                                   "Remove rows (all NA)"  = "rm_all",
                                                   "Impute: Mean"          = "mean",
                                                   "Impute: Median"        = "median",
                                                   "Impute: Mode"          = "mode",
                                                   "Impute: Constant"      = "const")),
                           conditionalPanel("input.miss_strat == 'const'",
                                            textInput("const_val", "Constant value:", "0")),
                           uiOutput("ui_miss_cols"),   # [NEW] column selector
                           actionButton("do_miss", "Apply", class="btn-warning btn-sm", icon=icon("check"))
                       ),
                       box(title = "Duplicate Rows", width = NULL, status = "danger", solidHeader = TRUE,
                           verbatimTextOutput("dup_info"),
                           actionButton("do_dup", "Remove Duplicates",
                                        class = "btn-danger btn-sm", icon = icon("trash"))
                       )
                ),
                
                # -- Outliers [NEW] --
                column(4,
                       box(title = "Outlier Handling", width = NULL, status = "primary", solidHeader = TRUE,
                           uiOutput("ui_out_col"),
                           selectInput("out_method", "Detection method:",
                                       choices = c("IQR ×1.5"       = "iqr",
                                                   "IQR ×3"          = "iqr3",
                                                   "Z-score |z|>3"   = "z")),
                           selectInput("out_action", "Action:",
                                       choices = c("Remove rows"      = "remove",
                                                   "Cap (Winsorise)"  = "cap",
                                                   "Replace with NA"  = "na")),
                           plotlyOutput("out_box", height = "150px"),  # [NEW] live boxplot
                           br(),
                           actionButton("do_out", "Apply", class="btn-primary btn-sm", icon=icon("check"))
                       )
                ),
                
                # -- Scale & Encode [NEW] --
                column(4,
                       box(title = "Scaling / Normalisation", width = NULL,
                           status = "success", solidHeader = TRUE,
                           uiOutput("ui_scale_cols"),
                           selectInput("scale_method", "Method:",
                                       choices = c("Min-Max (0–1)"      = "minmax",
                                                   "Z-score"             = "zscore",
                                                   "Robust (median/IQR)" = "robust",
                                                   "Log(x+1)"            = "log")),
                           actionButton("do_scale", "Apply Scaling",
                                        class = "btn-success btn-sm", icon = icon("check"))
                       ),
                       box(title = "Categorical Encoding", width = NULL,
                           status = "info", solidHeader = TRUE,
                           uiOutput("ui_enc_cols"),
                           selectInput("enc_method", "Method:",
                                       choices = c("Label (0, 1, 2…)" = "label",
                                                   "One-Hot"           = "onehot")),
                           actionButton("do_enc", "Apply Encoding",
                                        class = "btn-info btn-sm", icon = icon("check"))
                       ),
                       # [NEW] reset button + audit log
                       box(width = NULL, status = "primary",
                           actionButton("reset_clean", "↩ Reset All Cleaning",
                                        class = "btn-default btn-block", icon = icon("undo")),
                           br(),
                           div(class = "log-box", textOutput("clean_log"))
                       )
                )
              ),
              fluidRow(
                box(title = "Cleaned Data Preview", width = 12,
                    status = "success", solidHeader = TRUE, collapsible = TRUE,
                    DTOutput("tbl_clean"))
              )
      ),
      
      # ======================================================================
      # TAB 4: FEATURE ENGINEERING  [NEW] — did not exist in original
      # ======================================================================
      tabItem("feature",
              fluidRow(
                # Math transforms
                column(4,
                       box(title = "Math Transform", width = NULL, status = "primary", solidHeader = TRUE,
                           uiOutput("ui_fe_col"),
                           selectInput("fe_type", "Transform:",
                                       choices = c("Log(x+1)"     = "log1p",
                                                   "Square Root"  = "sqrt",
                                                   "Square x²"   = "sq",
                                                   "Reciprocal"   = "recip",
                                                   "Absolute Value" = "abs",
                                                   "Cube Root"    = "cbrt")),
                           textInput("fe_name", "New column name:", placeholder = "auto-generated"),
                           actionButton("do_fe", "Create Feature",
                                        class = "btn-primary btn-block", icon = icon("plus")),
                           br(),
                           plotlyOutput("fe_prev", height = "190px")  # live before/after density
                       )
                ),
                # Interaction + Binning
                column(4,
                       box(title = "Interaction Feature", width = NULL,
                           status = "warning", solidHeader = TRUE,
                           uiOutput("ui_ia_a"),
                           uiOutput("ui_ia_b"),
                           selectInput("ia_op", "Operation:",
                                       choices = c("A × B"    = "mul",
                                                   "A / B"    = "div",
                                                   "A + B"    = "add",
                                                   "A − B"    = "sub",
                                                   "A/(A+B)"  = "ratio")),
                           textInput("ia_name", "New column name:", placeholder = "auto-generated"),
                           actionButton("do_ia", "Create Feature",
                                        class = "btn-warning btn-block", icon = icon("plus"))
                       ),
                       box(title = "Binning (Discretisation)", width = NULL,
                           status = "success", solidHeader = TRUE,
                           uiOutput("ui_bin_col"),
                           numericInput("n_bins", "Number of bins:", 5, 2, 30),
                           selectInput("bin_method", "Method:",
                                       choices = c("Equal Width" = "width",
                                                   "Quantile"    = "qtile")),
                           textInput("bin_name", "New column name:", placeholder = "auto-generated"),
                           actionButton("do_bin", "Create Feature",
                                        class = "btn-success btn-block", icon = icon("plus"))
                       )
                ),
                # Log + reset
                column(4,
                       box(title = "Feature Engineering Log", width = NULL, status = "primary",
                           div(class = "log-box", textOutput("feat_log")),
                           br(),
                           actionButton("reset_feat", "↩ Reset Feature Engineering",
                                        class = "btn-default btn-block", icon = icon("undo"))
                       )
                )
              ),
              fluidRow(
                box(title = "Data with Engineered Features", width = 12,
                    status = "primary", solidHeader = TRUE, collapsible = TRUE,
                    DTOutput("tbl_feat"))
              )
      ),
      
      # ======================================================================
      # TAB 5: EDA
      # Original: static hist() / plot(), basic summary table, no filter
      # [NEW]: Plotly interactive plots, correlation heatmap, row filter,
      #        stat tiles, distribution stats, download button
      # ======================================================================
      tabItem("eda",
              fluidRow(
                column(3,
                       box(title = "Controls", width = NULL, status = "primary", solidHeader = TRUE,
                           
                           h4("Distribution Plot"),
                           uiOutput("ui_dist_col"),
                           # [NEW] 5 plot types (original: only hist + scatter)
                           selectInput("dist_type", "Plot type:",
                                       choices = c("Histogram"     = "hist",
                                                   "Density"       = "dens",
                                                   "Box Plot"      = "box",
                                                   "Violin"        = "vio",
                                                   "Bar (categorical)" = "bar")),
                           conditionalPanel("input.dist_type == 'hist'",
                                            sliderInput("hist_bins", "Bins:", 5, 100, 30)),
                           uiOutput("ui_dist_color"),   # [NEW] colour grouping
                           hr(),
                           
                           h4("Scatter Plot"),
                           uiOutput("ui_sc_x"),
                           uiOutput("ui_sc_y"),
                           uiOutput("ui_sc_col"),
                           checkboxInput("sc_lm", "Add trend line", FALSE),  # [NEW]
                           hr(),
                           
                           # [NEW] dynamic row filter
                           h4("Row Filter"),
                           uiOutput("ui_flt_col"),
                           uiOutput("ui_flt_rng"),
                           br(),
                           
                           # [NEW] download button
                           downloadButton("dl_data", "Download CSV", class = "btn-success btn-block")
                       )
                ),
                
                column(9,
                       # [NEW] stat tiles
                       fluidRow(
                         column(3, div(class="stat-tile",
                                       p("Rows (filtered)"),  h2(textOutput("e_rows"),  style="color:#3498db"))),
                         column(3, div(class="stat-tile",
                                       p("Numeric cols"),     h2(textOutput("e_num"),   style="color:#27ae60"))),
                         column(3, div(class="stat-tile",
                                       p("Categorical cols"), h2(textOutput("e_cat"),   style="color:#9b59b6"))),
                         column(3, div(class="stat-tile",
                                       p("Complete rows %"),  h2(textOutput("e_cmplt"), style="color:#e74c3c")))
                       ),
                       br(),
                       tabsetPanel(
                         tabPanel("Distribution",
                                  br(),
                                  plotlyOutput("plt_dist", height = "380px"),  # [NEW] Plotly
                                  br(),
                                  DTOutput("tbl_dist_stats")),                 # [NEW] per-column stats
                         tabPanel("Scatter",
                                  br(),
                                  plotlyOutput("plt_sc", height = "420px")),   # [NEW] Plotly
                         tabPanel("Correlation",                        # [NEW] entire tab
                                  br(),
                                  uiOutput("ui_corr_cols"),
                                  plotlyOutput("plt_corr", height = "430px")),
                         tabPanel("Data Table",                         # [NEW]
                                  br(),
                                  DTOutput("tbl_eda")),
                         tabPanel("Stat Summary",                       # [NEW] formatted table
                                  br(),
                                  uiOutput("ui_stat_sum"))
                       )
                )
              )
      )
      
    )   # end tabItems
  )     # end dashboardBody
)       # end dashboardPage


# =============================================================================
# SERVER
# =============================================================================
server <- function(input, output, session) {
  
  # --------------------------------------------------------------------------
  # Shared reactive state
  # --------------------------------------------------------------------------
  rv <- reactiveValues(
    raw   = NULL,            # original loaded data
    clean = NULL,            # after cleaning steps
    final = NULL,            # after feature engineering
    name  = "No dataset loaded",
    clog  = character(0),    # cleaning audit log
    flog  = character(0)     # feature engineering audit log
  )
  
  # Helpers
  num_cols  <- function(df) names(df)[sapply(df, is.numeric)]
  cat_cols  <- function(df) names(df)[sapply(df, function(x) is.factor(x) || is.character(x))]
  notify_ok <- function(msg) showNotification(msg, type = "message", duration = 3)
  notify_er <- function(msg) showNotification(msg, type = "error",   duration = 5)
  
  # Helper: set all three reactive data slots at once
  set_data <- function(df, name) {
    rv$raw   <- df
    rv$clean <- df
    rv$final <- df
    rv$name  <- name
    rv$clog  <- character(0)
    rv$flog  <- character(0)
    notify_ok(paste0("Loaded '", name, "' — ",
                     nrow(df), " rows × ", ncol(df), " cols"))
  }
  
  # ==========================================================================
  # LOAD DATA
  # Original: supported CSV + Excel only, no JSON/RDS
  # [NEW] added JSON and RDS; 4 built-in datasets
  # ==========================================================================
  
  observeEvent(input$file_up, {
    req(input$file_up)
    path <- input$file_up$datapath
    nm   <- input$file_up$name
    ext  <- tolower(tools::file_ext(nm))
    tryCatch({
      df <- switch(ext,
                   csv  = read.csv(path, header = input$csv_header,
                                   sep = input$csv_sep, stringsAsFactors = FALSE),
                   xlsx = as.data.frame(read_excel(path)),
                   xls  = as.data.frame(read_excel(path)),
                   json = as.data.frame(fromJSON(path)),   # [NEW]
                   rds  = readRDS(path),                   # [NEW]
                   stop("Unsupported format: .", ext)
      )
      set_data(df, nm)
    }, error = function(e) notify_er(paste("Load error:", e$message)))
  })
  
  observeEvent(input$load_builtin, {
    req(input$builtin != "")
    df <- switch(input$builtin,
                 iris       = as.data.frame(iris),
                 mtcars     = as.data.frame(mtcars),
                 diamonds   = as.data.frame(ggplot2::diamonds),   # [NEW]
                 airquality = as.data.frame(airquality)            # [NEW]
    )
    set_data(df, input$builtin)
  })
  
  # --------------------------------------------------------------------------
  # Sidebar status
  # --------------------------------------------------------------------------
  output$sb_name <- renderText({ rv$name })
  output$sb_dim  <- renderText({
    if (is.null(rv$final)) "" else
      paste0(nrow(rv$final), " rows × ", ncol(rv$final), " cols")
  })
  
  # ==========================================================================
  # UPLOAD TAB outputs
  # ==========================================================================
  output$ov_rows <- renderText({ if (is.null(rv$raw)) "—" else nrow(rv$raw) })
  output$ov_cols <- renderText({ if (is.null(rv$raw)) "—" else ncol(rv$raw) })
  output$ov_miss <- renderText({ if (is.null(rv$raw)) "—" else sum(is.na(rv$raw)) })
  output$ov_dup  <- renderText({ if (is.null(rv$raw)) "—" else sum(duplicated(rv$raw)) })
  
  # [NEW] column-type badges
  output$ov_badges <- renderUI({
    req(rv$raw)
    n  <- sum(sapply(rv$raw, is.numeric))
    c_ <- length(cat_cols(rv$raw))
    tagList(
      tags$span(style="display:inline-block;background:#3498db;color:#fff;padding:2px 9px;
                       border-radius:10px;font-size:11px;font-weight:700;margin:2px",
                paste(n,  "Numeric")),
      tags$span(style="display:inline-block;background:#27ae60;color:#fff;padding:2px 9px;
                       border-radius:10px;font-size:11px;font-weight:700;margin:2px",
                paste(c_, "Categorical"))
    )
  })
  
  # [NEW] DT preview (original used tableOutput with only head())
  output$tbl_preview <- renderDT({
    req(rv$raw)
    datatable(head(rv$raw, 200),
              options = list(scrollX = TRUE, pageLength = 10), rownames = FALSE)
  })
  
  output$tbl_summary <- renderPrint({ req(rv$raw); summary(rv$raw) })
  
  # [NEW] per-column info table
  output$tbl_colinfo <- renderDT({
    req(rv$raw)
    df   <- rv$raw
    info <- data.frame(
      Column   = names(df),
      Type     = sapply(df, function(x) class(x)[1]),
      Missing  = sapply(df, function(x) sum(is.na(x))),
      Miss_pct = sapply(df, function(x) paste0(round(mean(is.na(x)) * 100, 1), "%")),
      Unique   = sapply(df, function(x) length(unique(x))),
      Sample   = sapply(df, function(x) paste(head(na.omit(x), 3), collapse = ", ")),
      stringsAsFactors = FALSE
    )
    datatable(info, options = list(scrollX = TRUE, pageLength = 20), rownames = FALSE)
  })
  
  # ==========================================================================
  # CLEANING TAB — dynamic UIs
  # ==========================================================================
  
  # [NEW] column selector for missing-value imputation
  output$ui_miss_cols <- renderUI({
    req(rv$clean)
    selectInput("miss_cols", "Apply to:",
                choices  = c("All columns" = "__all__",
                             "All numeric" = "__num__",
                             names(rv$clean)),
                multiple = TRUE, selected = "__all__")
  })
  
  # [NEW] outlier column selector
  output$ui_out_col <- renderUI({
    req(rv$clean)
    selectInput("out_col", "Column:", choices = num_cols(rv$clean))
  })
  
  # [NEW] scaling column checkboxes
  output$ui_scale_cols <- renderUI({
    req(rv$clean)
    checkboxGroupInput("scale_cols", "Columns:",
                       choices  = num_cols(rv$clean),
                       selected = num_cols(rv$clean)[1])
  })
  
  # [NEW] encoding column checkboxes
  output$ui_enc_cols <- renderUI({
    req(rv$clean)
    cc <- cat_cols(rv$clean)
    if (length(cc) == 0) return(p("No categorical columns.", style = "color:gray"))
    checkboxGroupInput("enc_cols", "Columns:", choices = cc)
  })
  
  # [NEW] missing-value bar chart
  output$miss_bar <- renderPlotly({
    req(rv$clean)
    df   <- rv$clean
    pct  <- sapply(df, function(x) round(mean(is.na(x)) * 100, 1))
    miss <- data.frame(col = names(pct), pct = pct) %>%
      filter(pct > 0) %>% arrange(desc(pct)) %>% head(15)
    if (nrow(miss) == 0) {
      p <- ggplot() +
        annotate("text", x=.5, y=.5, label="No missing values",
                 size=5, color="#27ae60") + theme_void()
    } else {
      p <- ggplot(miss, aes(reorder(col, pct), pct, fill = pct)) +
        geom_col() + coord_flip() +
        scale_fill_gradient(low = "#f39c12", high = "#e74c3c") +
        labs(x = NULL, y = "Missing %") +
        theme_minimal(base_size = 11) + theme(legend.position = "none")
    }
    ggplotly(p, height = 155) %>% config(displayModeBar = FALSE)
  })
  
  output$dup_info <- renderText({
    req(rv$clean)
    paste(sum(duplicated(rv$clean)), "duplicate row(s) found.")
  })
  
  # [NEW] live boxplot for outlier preview
  output$out_box <- renderPlotly({
    req(rv$clean, input$out_col)
    x <- rv$clean[[input$out_col]]
    p <- ggplot(data.frame(y = x), aes(y = y)) +
      geom_boxplot(fill = "#3498db", alpha = .7, outlier.colour = "red") +
      labs(y = input$out_col, x = "") + theme_minimal()
    ggplotly(p, height = 145) %>% config(displayModeBar = FALSE)
  })
  
  # ── Apply: missing values ────────────────────────────────────────────────
  # [NEW] entire block (original only had na.omit)
  observeEvent(input$do_miss, {
    req(rv$clean)
    df   <- rv$clean
    cols <- input$miss_cols
    if ("__all__" %in% cols) cols <- names(df)
    if ("__num__" %in% cols) cols <- num_cols(df)
    
    tryCatch({
      df <- switch(input$miss_strat,
                   rm_any = df[complete.cases(df[, cols, drop = FALSE]), ],
                   rm_all = df[!apply(is.na(df[, cols, drop = FALSE]), 1, all), ],
                   mean   = { for (c in cols) if (is.numeric(df[[c]]))
                     df[[c]][is.na(df[[c]])] <- mean(df[[c]], na.rm = TRUE); df },
                   median = { for (c in cols) if (is.numeric(df[[c]]))
                     df[[c]][is.na(df[[c]])] <- median(df[[c]], na.rm = TRUE); df },
                   mode   = {
                     gmode <- function(x) { ux <- unique(na.omit(x)); ux[which.max(tabulate(match(x,ux)))] }
                     for (c in cols) df[[c]][is.na(df[[c]])] <- gmode(df[[c]]); df },
                   const  = {
                     v <- input$const_val
                     for (c in cols) {
                       if (is.numeric(df[[c]])) df[[c]][is.na(df[[c]])] <- suppressWarnings(as.numeric(v))
                       else df[[c]][is.na(df[[c]])] <- v
                     }; df }
      )
      rv$clean <- df; rv$final <- df
      rv$clog  <- c(rv$clog, paste0("[", Sys.time(), "] Missing → ", input$miss_strat))
      notify_ok("Missing values handled.")
    }, error = function(e) notify_er(e$message))
  })
  
  # ── Apply: duplicates ────────────────────────────────────────────────────
  observeEvent(input$do_dup, {
    req(rv$clean)
    before   <- nrow(rv$clean)
    rv$clean <- rv$clean[!duplicated(rv$clean), ]
    rv$final <- rv$clean
    n        <- before - nrow(rv$clean)
    rv$clog  <- c(rv$clog, paste0("[", Sys.time(), "] Removed ", n, " duplicate(s)."))
    notify_ok(paste("Removed", n, "duplicate rows."))
  })
  
  # ── Apply: outliers [NEW] ────────────────────────────────────────────────
  observeEvent(input$do_out, {
    req(rv$clean, input$out_col)
    df  <- rv$clean; col <- input$out_col; x <- df[[col]]
    
    bounds <- if (input$out_method %in% c("iqr", "iqr3")) {
      k  <- if (input$out_method == "iqr") 1.5 else 3
      q1 <- quantile(x, .25, na.rm = TRUE); q3 <- quantile(x, .75, na.rm = TRUE)
      c(q1 - k * (q3 - q1), q3 + k * (q3 - q1))
    } else {
      mu <- mean(x, na.rm = TRUE); s <- sd(x, na.rm = TRUE)
      c(mu - 3*s, mu + 3*s)
    }
    
    is_out <- !is.na(x) & (x < bounds[1] | x > bounds[2])
    
    if (input$out_action == "remove") {
      df <- df[!is_out, ]
    } else if (input$out_action == "cap") {
      df[[col]] <- pmax(pmin(x, bounds[2]), bounds[1])
    } else {
      df[[col]][is_out] <- NA
    }
    
    rv$clean <- df; rv$final <- df
    rv$clog  <- c(rv$clog, paste0("[", Sys.time(), "] Outliers (", col, "): ",
                                  input$out_method, " → ", input$out_action,
                                  " [", sum(is_out), " pts]"))
    notify_ok(paste("Handled", sum(is_out), "outliers."))
  })
  
  # ── Apply: scaling [NEW] ────────────────────────────────────────────────
  observeEvent(input$do_scale, {
    req(rv$clean, input$scale_cols)
    df <- rv$clean
    for (c in input$scale_cols) {
      x <- df[[c]]
      df[[c]] <- switch(input$scale_method,
                        minmax = (x - min(x, na.rm=TRUE)) / (max(x, na.rm=TRUE) - min(x, na.rm=TRUE) + 1e-9),
                        zscore = as.numeric(scale(x)),
                        robust = (x - median(x, na.rm=TRUE)) / (IQR(x, na.rm=TRUE) + 1e-9),
                        log    = log1p(pmax(x, 0))
      )
    }
    rv$clean <- df; rv$final <- df
    rv$clog  <- c(rv$clog, paste0("[", Sys.time(), "] Scale (", input$scale_method, "): ",
                                  paste(input$scale_cols, collapse = ", ")))
    notify_ok("Scaling applied.")
  })
  
  # ── Apply: encoding [NEW] ────────────────────────────────────────────────
  observeEvent(input$do_enc, {
    req(rv$clean, input$enc_cols)
    df <- rv$clean
    for (c in input$enc_cols) {
      if (input$enc_method == "label") {
        df[[c]] <- as.integer(factor(df[[c]])) - 1L
      } else {
        for (lvl in unique(na.omit(df[[c]])))
          df[[paste0(c, "_", lvl)]] <- as.integer(df[[c]] == lvl)
        df[[c]] <- NULL
      }
    }
    rv$clean <- df; rv$final <- df
    rv$clog  <- c(rv$clog, paste0("[", Sys.time(), "] Encode (", input$enc_method, "): ",
                                  paste(input$enc_cols, collapse = ", ")))
    notify_ok("Encoding applied.")
  })
  
  # ── Reset cleaning ───────────────────────────────────────────────────────
  observeEvent(input$reset_clean, {
    req(rv$raw)
    rv$clean <- rv$raw; rv$final <- rv$raw
    rv$clog  <- c(rv$clog, paste0("[", Sys.time(), "] Reset to raw data."))
    notify_ok("Cleaning steps reset.")
  })
  
  output$clean_log <- renderText({
    if (length(rv$clog) == 0) "No steps applied yet."
    else paste(rev(rv$clog), collapse = "\n")
  })
  
  output$tbl_clean <- renderDT({
    req(rv$clean)
    datatable(head(rv$clean, 200),
              options = list(scrollX = TRUE, pageLength = 8), rownames = FALSE)
  })
  
  # ==========================================================================
  # FEATURE ENGINEERING TAB  [NEW — entire section]
  # ==========================================================================
  
  output$ui_fe_col  <- renderUI({ req(rv$final); selectInput("fe_col",  "Column:", choices = num_cols(rv$final)) })
  output$ui_ia_a    <- renderUI({ req(rv$final); selectInput("ia_a", "Column A:", choices = num_cols(rv$final)) })
  output$ui_ia_b    <- renderUI({
    req(rv$final); nc <- num_cols(rv$final)
    selectInput("ia_b", "Column B:", choices = nc,
                selected = if (length(nc) >= 2) nc[2] else nc[1])
  })
  output$ui_bin_col <- renderUI({ req(rv$final); selectInput("bin_col", "Column:", choices = num_cols(rv$final)) })
  
  # Before/after density preview
  output$fe_prev <- renderPlotly({
    req(rv$final, input$fe_col)
    x  <- rv$final[[input$fe_col]]
    xt <- switch(input$fe_type,
                 log1p = log1p(pmax(x, 0)),
                 sqrt  = sqrt(pmax(x, 0)),
                 sq    = x^2,
                 recip = 1 / (x + 1e-9),
                 abs   = abs(x),
                 cbrt  = sign(x) * abs(x)^(1/3)
    )
    df2 <- data.frame(Value = c(x, xt),
                      Type  = rep(c("Original","Transformed"), each = length(x)))
    p <- ggplot(df2, aes(x = Value, fill = Type)) +
      geom_density(alpha = .5) +
      scale_fill_manual(values = c("#3498db","#e74c3c")) +
      labs(title = "Before vs After", x = NULL, y = NULL) +
      theme_minimal(base_size = 10) + theme(legend.position = "bottom")
    ggplotly(p, height = 185) %>% config(displayModeBar = FALSE)
  })
  
  # Apply: math transform
  observeEvent(input$do_fe, {
    req(rv$final, input$fe_col)
    df  <- rv$final; col <- input$fe_col; x <- df[[col]]
    nm  <- if (nchar(trimws(input$fe_name)) > 0) trimws(input$fe_name)
    else paste0(col, "_", input$fe_type)
    df[[nm]] <- switch(input$fe_type,
                       log1p = log1p(pmax(x, 0)), sqrt = sqrt(pmax(x, 0)),
                       sq    = x^2, recip = 1/(x + 1e-9), abs = abs(x),
                       cbrt  = sign(x) * abs(x)^(1/3)
    )
    rv$final <- df
    rv$flog  <- c(rv$flog, paste0("[", Sys.time(), "] Transform (", input$fe_type, "): ",
                                  col, " → ", nm))
    notify_ok(paste("Created:", nm))
  })
  
  # Apply: interaction
  observeEvent(input$do_ia, {
    req(rv$final, input$ia_a, input$ia_b)
    df <- rv$final; a <- df[[input$ia_a]]; b <- df[[input$ia_b]]
    nm <- if (nchar(trimws(input$ia_name)) > 0) trimws(input$ia_name)
    else paste0(input$ia_a, "_", input$ia_op, "_", input$ia_b)
    df[[nm]] <- switch(input$ia_op,
                       mul = a*b, div = a/(b+1e-9), add = a+b, sub = a-b,
                       ratio = a/(a+b+1e-9)
    )
    rv$final <- df
    rv$flog  <- c(rv$flog, paste0("[", Sys.time(), "] Interact (", input$ia_op, "): ",
                                  input$ia_a, " & ", input$ia_b, " → ", nm))
    notify_ok(paste("Created:", nm))
  })
  
  # Apply: binning
  observeEvent(input$do_bin, {
    req(rv$final, input$bin_col)
    df  <- rv$final; x <- df[[input$bin_col]]
    nm  <- if (nchar(trimws(input$bin_name)) > 0) trimws(input$bin_name)
    else paste0(input$bin_col, "_bin")
    tryCatch({
      df[[nm]] <- if (input$bin_method == "qtile")
        cut(x, breaks = quantile(x, probs = seq(0,1,length.out=input$n_bins+1), na.rm=TRUE),
            include.lowest = TRUE, labels = paste0("Q", seq_len(input$n_bins)))
      else
        cut(x, breaks = input$n_bins, include.lowest = TRUE)
      rv$final <- df
      rv$flog  <- c(rv$flog, paste0("[", Sys.time(), "] Bin (", input$bin_method,
                                    ", n=", input$n_bins, "): ", input$bin_col, " → ", nm))
      notify_ok(paste("Created:", nm))
    }, error = function(e) notify_er(e$message))
  })
  
  # Reset features
  observeEvent(input$reset_feat, {
    req(rv$clean)
    rv$final <- rv$clean
    rv$flog  <- c(rv$flog, paste0("[", Sys.time(), "] Reset feature engineering."))
    notify_ok("Feature engineering reset.")
  })
  
  output$feat_log <- renderText({
    if (length(rv$flog) == 0) "No features created yet."
    else paste(rev(rv$flog), collapse = "\n")
  })
  
  output$tbl_feat <- renderDT({
    req(rv$final)
    datatable(head(rv$final, 200),
              options = list(scrollX = TRUE, pageLength = 8), rownames = FALSE)
  })
  
  # ==========================================================================
  # EDA TAB
  # ==========================================================================
  
  # Row-filtered data for all EDA plots
  eda_df <- reactive({
    req(rv$final)
    df <- rv$final
    if (!is.null(input$flt_col) && input$flt_col != "" &&
        is.numeric(df[[input$flt_col]]) && !is.null(input$flt_rng)) {
      x  <- df[[input$flt_col]]
      df <- df[!is.na(x) & x >= input$flt_rng[1] & x <= input$flt_rng[2], ]
    }
    df
  })
  
  # Dynamic UI elements
  output$ui_dist_col   <- renderUI({ req(rv$final); selectInput("dist_col", "Column:", choices = names(rv$final)) })
  output$ui_dist_color <- renderUI({
    req(rv$final)
    cc <- names(rv$final)[sapply(rv$final,
                                 function(x) is.factor(x) || is.character(x) || length(unique(x)) <= 10)]
    selectInput("dist_color", "Colour by:", choices = c("None" = "", cc))
  })
  output$ui_sc_x <- renderUI({ req(rv$final); selectInput("sc_x", "X:", choices = num_cols(rv$final)) })
  output$ui_sc_y <- renderUI({
    req(rv$final); nc <- num_cols(rv$final)
    selectInput("sc_y", "Y:", choices = nc,
                selected = if (length(nc) >= 2) nc[2] else nc[1])
  })
  output$ui_sc_col  <- renderUI({ req(rv$final); selectInput("sc_col",  "Colour:", choices = c("None" = "", names(rv$final))) })
  output$ui_flt_col <- renderUI({ req(rv$final); selectInput("flt_col", "Filter by:", choices = c("None" = "", num_cols(rv$final))) })
  output$ui_flt_rng <- renderUI({
    req(input$flt_col, input$flt_col != "")
    x  <- rv$final[[input$flt_col]]
    mn <- min(x, na.rm=TRUE); mx <- max(x, na.rm=TRUE)
    sliderInput("flt_rng", "Range:", min=mn, max=mx, value=c(mn,mx), step=(mx-mn)/100)
  })
  output$ui_corr_cols <- renderUI({
    req(rv$final)
    nc <- num_cols(rv$final)
    checkboxGroupInput("corr_cols", "Select columns:",
                       choices = nc, selected = nc[1:min(8, length(nc))], inline = TRUE)
  })
  
  # Stat tiles
  output$e_rows  <- renderText({ nrow(eda_df()) })
  output$e_num   <- renderText({ length(num_cols(eda_df())) })
  output$e_cat   <- renderText({ length(cat_cols(eda_df())) })
  output$e_cmplt <- renderText({ paste0(round(mean(complete.cases(eda_df())) * 100, 1), "%") })
  
  # ── Distribution plot [NEW] Plotly replaces base-R hist/plot ─────────────
  output$plt_dist <- renderPlotly({
    req(eda_df(), input$dist_col)
    df   <- eda_df(); col <- input$dist_col; x <- df[[col]]
    ccol <- if (!is.null(input$dist_color) && input$dist_color != "") input$dist_color else NULL
    
    p <- if (input$dist_type == "hist") {
      gd <- data.frame(x=x); if (!is.null(ccol)) gd$grp <- as.factor(df[[ccol]])
      ggplot(gd, aes(x=x, fill=if(!is.null(ccol)) grp else NULL)) +
        geom_histogram(bins=input$hist_bins, alpha=.75, position="stack") +
        labs(x=col, y="Count", fill=ccol) + theme_minimal()
    } else if (input$dist_type == "dens") {
      gd <- data.frame(x=x); if (!is.null(ccol)) gd$grp <- as.factor(df[[ccol]])
      ggplot(gd, aes(x=x, fill=if(!is.null(ccol)) grp else NULL)) +
        geom_density(alpha=.5) + labs(x=col, y="Density", fill=ccol) + theme_minimal()
    } else if (input$dist_type == "box") {
      gd <- data.frame(y=x); if (!is.null(ccol)) gd$grp <- as.factor(df[[ccol]])
      ggplot(gd, aes(x=if(!is.null(ccol)) grp else factor(1), y=y,
                     fill=if(!is.null(ccol)) grp else NULL)) +
        geom_boxplot(alpha=.75) + labs(x=ccol, y=col) + theme_minimal()
    } else if (input$dist_type == "vio") {
      gd <- data.frame(y=x); if (!is.null(ccol)) gd$grp <- as.factor(df[[ccol]])
      ggplot(gd, aes(x=if(!is.null(ccol)) grp else factor(1), y=y,
                     fill=if(!is.null(ccol)) grp else NULL)) +
        geom_violin(alpha=.75) + labs(x=ccol, y=col) + theme_minimal()
    } else {
      cnt <- as.data.frame(table(x)) %>% arrange(desc(Freq)) %>% head(30)
      ggplot(cnt, aes(reorder(x, -Freq), Freq, fill=x)) +
        geom_col(show.legend=FALSE) + labs(x=col, y="Count") +
        theme_minimal() + theme(axis.text.x=element_text(angle=45, hjust=1))
    }
    ggplotly(p, height=375) %>% config(displayModeBar=TRUE)
  })
  
  # [NEW] per-column stats table below distribution plot
  output$tbl_dist_stats <- renderDT({
    req(eda_df(), input$dist_col)
    x <- eda_df()[[input$dist_col]]
    if (is.numeric(x)) {
      stats <- data.frame(
        Stat  = c("N","Mean","Median","SD","Min","Q1","Q3","Max","Skewness","Missing"),
        Value = c(length(x),
                  round(mean(x,na.rm=TRUE),4), round(median(x,na.rm=TRUE),4),
                  round(sd(x,na.rm=TRUE),4),
                  round(min(x,na.rm=TRUE),4),
                  round(quantile(x,.25,na.rm=TRUE),4),
                  round(quantile(x,.75,na.rm=TRUE),4),
                  round(max(x,na.rm=TRUE),4),
                  round(e1071::skewness(x,na.rm=TRUE),4),
                  sum(is.na(x)))
      )
    } else {
      tbl   <- sort(table(x), decreasing=TRUE)
      stats <- data.frame(Category = names(tbl), Count = as.integer(tbl),
                          Pct = paste0(round(as.integer(tbl)/length(x)*100,1),"%"))
    }
    datatable(stats, options=list(dom="t", pageLength=15), rownames=FALSE)
  })
  
  # ── Scatter plot [NEW] Plotly replaces base-R plot ───────────────────────
  output$plt_sc <- renderPlotly({
    req(eda_df(), input$sc_x, input$sc_y)
    df   <- eda_df()
    ccol <- if (!is.null(input$sc_col) && input$sc_col != "") input$sc_col else NULL
    gd   <- data.frame(x = df[[input$sc_x]], y = df[[input$sc_y]])
    if (!is.null(ccol)) gd$col <- as.factor(df[[ccol]])
    p <- ggplot(gd, aes(x=x, y=y, color=if(!is.null(ccol)) col else NULL)) +
      geom_point(alpha=.6, size=1.5) +
      labs(x=input$sc_x, y=input$sc_y, color=ccol) + theme_minimal()
    if (input$sc_lm)  # [NEW] optional trend line
      p <- p + geom_smooth(method="lm", se=TRUE, color="navy", linewidth=.8)
    ggplotly(p, height=415) %>% config(displayModeBar=TRUE)
  })
  
  # ── Correlation heatmap [NEW] ────────────────────────────────────────────
  output$plt_corr <- renderPlotly({
    req(eda_df(), input$corr_cols, length(input$corr_cols) >= 2)
    df <- eda_df()[, input$corr_cols, drop=FALSE]
    df <- df[, sapply(df, is.numeric), drop=FALSE]
    if (ncol(df) < 2) return(NULL)
    cm <- cor(df, use="pairwise.complete.obs")
    plot_ly(
      x = colnames(cm), y = rownames(cm), z = cm, type = "heatmap",
      colorscale = list(c(0,"rgb(49,54,149)"), c(.5,"white"), c(1,"rgb(165,0,38)")),
      zmin = -1, zmax = 1,
      text = round(cm, 2), texttemplate = "%{text}",
      hovertemplate = "%{y} vs %{x}: %{z:.3f}<extra></extra>"
    ) %>% layout(height=425, xaxis=list(tickangle=-45), margin=list(b=100)) %>%
      config(displayModeBar=FALSE)
  })
  
  # ── Full data table with column filter [NEW] ─────────────────────────────
  output$tbl_eda <- renderDT({
    req(eda_df())
    datatable(eda_df(),
              options    = list(scrollX=TRUE, pageLength=10,
                                dom="Bfrtip", buttons=c("copy","csv","excel")),
              extensions = "Buttons", rownames=FALSE, filter="top")
  })
  
  # ── Formatted stat summary table [NEW] ───────────────────────────────────
  output$ui_stat_sum <- renderUI({
    req(eda_df())
    df <- eda_df(); nc <- num_cols(df)
    if (length(nc) == 0) return(p("No numeric columns."))
    rows <- lapply(nc, function(c) {
      x <- df[[c]]
      tags$tr(
        tags$td(strong(c)), tags$td(length(x)),
        tags$td(round(mean(x,na.rm=TRUE),3)), tags$td(round(sd(x,na.rm=TRUE),3)),
        tags$td(round(min(x,na.rm=TRUE),3)),  tags$td(round(median(x,na.rm=TRUE),3)),
        tags$td(round(max(x,na.rm=TRUE),3)),  tags$td(sum(is.na(x)))
      )
    })
    tagList(tags$table(
      class = "table table-striped table-bordered table-hover",
      tags$thead(tags$tr(
        tags$th("Column"), tags$th("N"), tags$th("Mean"), tags$th("SD"),
        tags$th("Min"), tags$th("Median"), tags$th("Max"), tags$th("NA")
      )),
      tags$tbody(rows)
    ))
  })
  # ── Download processed data [NEW] ────────────────────────────────────────
  output$dl_data <- downloadHandler(
    filename = function() paste0("data_processed_", Sys.Date(), ".csv"),
    content  = function(f) write.csv(rv$final, f, row.names = FALSE)
  )
}

# =============================================================================
# Launch
# =============================================================================
shinyApp(ui = ui, server = server)
