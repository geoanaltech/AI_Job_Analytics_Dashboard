# app.R

library(markdown)
library(shiny)
library(dplyr)
library(ggplot2)
library(plotly)
library(readr)
library(lubridate)

# Load dataset (ensure this is saved and cleaned as needed)
data <- read_csv("ai_job_dataset.csv")

# Convert posting_date to Date
if (!inherits(data$posting_date, "Date")) {
  data$posting_date <- as.Date(data$posting_date)
}

# UI
ui <- fluidPage(
  titlePanel("AI Job Market Trends Dashboard"),
  
  sidebarLayout(
    sidebarPanel(
      selectInput("country", "Select Company Location:",
                  choices = c("All", sort(unique(data$company_location))), selected = "All"),
      selectInput("job_type", "Select Employment Type:",
                  choices = c("All", unique(data$employment_type)), selected = "All"),
      selectInput("experience", "Select Experience Level:",
                  choices = c("All", unique(data$experience_level)), selected = "All"),
      dateRangeInput("date_range", "Select Posting Date Range:",
                     start = min(data$posting_date, na.rm = TRUE),
                     end = max(data$posting_date, na.rm = TRUE))
    ),
    
    mainPanel(
      h3("Summary Statistics"),
      verbatimTextOutput("summary_stats"),
      
      h3("Key Plots"),
      tabsetPanel(
        tabPanel("Job Postings Over Time", plotlyOutput("posting_plot")),
        tabPanel("Salary Distribution", plotlyOutput("salary_plot")),
        tabPanel("Jobs by Company Location", plotlyOutput("location_plot")),
        tabPanel("Required Skills Word Cloud", plotOutput("skills_wordcloud"))
      ),
      
      h3("Report"),
      includeMarkdown("AI_Job_Analysis_Report.md")
    )
  )
)

# Server
server <- function(input, output) {
  
  filtered_data <- reactive({
    df <- data
    if (input$country != "All") {
      df <- df %>% filter(company_location == input$country)
    }
    if (input$job_type != "All") {
      df <- df %>% filter(employment_type == input$job_type)
    }
    if (input$experience != "All") {
      df <- df %>% filter(experience_level == input$experience)
    }
    df <- df %>% filter(posting_date >= input$date_range[1] & posting_date <= input$date_range[2])
    df
  })
  
  output$summary_stats <- renderPrint({
    df <- filtered_data()
    df %>% summarise(
      Total_Jobs = n(),
      Avg_Salary_USD = round(mean(salary_usd, na.rm = TRUE), 2),
      Median_Experience = median(years_experience, na.rm = TRUE),
      Avg_Description_Length = round(mean(job_description_length, na.rm = TRUE), 2)
    )
  })
  
  output$posting_plot <- renderPlotly({
    df <- filtered_data()
    plot_df <- df %>% count(posting_date)
    p <- ggplot(plot_df, aes(x = posting_date, y = n)) +
      geom_line(color = "steelblue") +
      labs(title = "Job Postings Over Time", x = "Date", y = "Number of Postings") +
      theme_minimal()
    ggplotly(p)
  })
  
  output$salary_plot <- renderPlotly({
    df <- filtered_data()
    p <- ggplot(df, aes(x = salary_usd)) +
      geom_histogram(binwidth = 10000, fill = "skyblue", color = "black") +
      labs(title = "Salary Distribution (USD)", x = "Salary (USD)", y = "Count") +
      theme_minimal()
    ggplotly(p)
  })
  
  output$location_plot <- renderPlotly({
    df <- filtered_data()
    loc_df <- df %>% count(company_location, sort = TRUE)
    p <- ggplot(loc_df, aes(x = reorder(company_location, -n), y = n)) +
      geom_bar(stat = "identity", fill = "orange") +
      coord_flip() +
      labs(title = "Top Hiring Locations", x = "Location", y = "Number of Jobs") +
      theme_minimal()
    ggplotly(p)
  })
  
  output$skills_wordcloud <- renderPlot({
    library(tm)
    library(wordcloud)
    
    df <- filtered_data()
    text <- tolower(paste(df$required_skills, collapse = ", "))
    text <- removePunctuation(text)
    text <- removeNumbers(text)
    text <- removeWords(text, stopwords("en"))
    text_corpus <- Corpus(VectorSource(text))
    wordcloud(text_corpus, max.words = 100, random.order = FALSE, colors = brewer.pal(8, "Dark2"))
  })
}

# Run app
shinyApp(ui = ui, server = server)
