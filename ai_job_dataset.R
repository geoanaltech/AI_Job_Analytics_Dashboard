library(tidyverse)
library(lubridate)
library(janitor)

# Load data
df <- read_csv("ai_job_dataset.csv") %>%
  clean_names()  # standardize column names (lowercase, underscores):contentReference[oaicite:4]{index=4}

# Convert data types
df <- df %>%
  mutate(
    salary_usd = as.numeric(salary_usd),
    experience_level = factor(experience_level, 
                              levels=c("EN", "MI", "SE", "EX"),
                              labels=c("Entry", "Mid", "Senior", "Executive")),
    employment_type = factor(employment_type),
    company_size = factor(company_size),
    remote_ratio = as.numeric(remote_ratio)
  )

# Handle dates: parse posting and deadline
df <- df %>%
  mutate(
    posting_date = ymd(posting_date),
    application_deadline = ymd(application_deadline),
    posting_duration = as.numeric(application_deadline - posting_date, units="days")
  )

# Derived fields: e.g. salary quantiles
df <- df %>%
  drop_na(salary_usd) %>%       # drop rows with missing salary
  mutate(salary_quantile = ntile(salary_usd, 4))

# (Additional wrangling as needed: e.g. splitting required_skills into lists later)



library(ggplot2)
library(plotly)

# Salary by experience and employment type
ggplot(df, aes(x=experience_level, y=salary_usd, fill=employment_type)) +
  geom_boxplot(outlier.shape=NA) +
  scale_y_continuous(labels=scales::dollar_format()) +
  labs(title="Salary Distribution by Experience and Employment Type",
       x="Experience Level", y="Salary (USD)") +
  theme_minimal() -> p_salary
ggplotly(p_salary)  # make interactive:contentReference[oaicite:10]{index=10}

# Extract and count skills
skills_df <- df %>%
  separate_rows(required_skills, sep=",\\s*") %>%
  filter(required_skills != "") %>%
  count(required_skills, sort=TRUE)

top_skills <- skills_df %>% top_n(10, n)
ggplot(top_skills, aes(x=reorder(required_skills, n), y=n)) +
  geom_col(fill="steelblue") +
  coord_flip() +
  labs(title="Top 10 In-Demand Skills",
       x="Skill", y="Number of Postings") +
  theme_minimal() -> p_skills
ggplotly(p_skills)

# Job posting trend over time (monthly)
postings_time <- df %>%
  count(month = floor_date(posting_date, "month"))
ggplot(postings_time, aes(x=month, y=n)) +
  geom_line(color="darkgreen") +
  labs(title="AI Job Postings Over Time",
       x="Posting Month", y="Number of Postings") +
  theme_minimal()

# Remote work distribution
remote_dist <- df %>%
  mutate(remote_cat = case_when(
    remote_ratio == 100 ~ "Remote",
    remote_ratio == 50 ~ "Hybrid",
    TRUE ~ "On-site"
  )) %>%
  count(remote_cat)
ggplot(remote_dist, aes(x=remote_cat, y=n, fill=remote_cat)) +
  geom_col() +
  labs(title="Distribution of Remote vs On-site AI Jobs",
       x="Work Arrangement", y="Count of Postings") +
  theme_minimal()

# Hiring by region and company size
hire_patterns <- df %>%
  count(region = company_location, company_size) %>%
  filter(!is.na(region))
ggplot(hire_patterns, aes(x=region, y=n, fill=company_size)) +
  geom_col(position="dodge") +
  coord_flip() +
  labs(title="AI Jobs by Region and Company Size",
       x="Region (Country)", y="Job Postings") +
  theme_minimal()

# Top job titles
top_titles <- df %>%
  count(job_title, sort=TRUE) %>%
  top_n(10, n)
ggplot(top_titles, aes(x=reorder(job_title, n), y=n)) +
  geom_col(fill="#2c7fb8") +
  coord_flip() +
  labs(title="Top 10 AI Job Titles by Frequency",
       x="Job Title", y="Number of Postings") +
  theme_minimal()



df_remote_salary <- df %>%
  mutate(remote_category = case_when(
    remote_ratio == 0 ~ "On-site",
    remote_ratio == 50 ~ "Hybrid",
    remote_ratio == 100 ~ "Remote",
    TRUE ~ "Unknown"
  )) %>%
  group_by(remote_category) %>%
  summarise(mean_salary = mean(salary_usd, na.rm = TRUE))

ggplot(df_remote_salary, aes(x=remote_category, y=mean_salary, fill=remote_category)) +
  geom_col() +
  scale_y_continuous(labels = scales::dollar_format()) +
  labs(title="Average Salary by Work Arrangement", x="Work Type", y="Mean Salary (USD)") +
  theme_minimal()



df_company_salary <- df %>%
  group_by(company_size) %>%
  summarise(avg_salary = mean(salary_usd, na.rm = TRUE))

ggplot(df_company_salary, aes(x=company_size, y=avg_salary, fill=company_size)) +
  geom_col() +
  scale_y_continuous(labels = scales::dollar_format()) +
  labs(title="Average Salary by Company Size", x="Company Size", y="Average Salary (USD)") +
  theme_minimal()



df <- df %>%
  mutate(title_category = case_when(
    str_detect(tolower(job_title), "data") ~ "Data",
    str_detect(tolower(job_title), "ml|machine learning") ~ "ML",
    str_detect(tolower(job_title), "ai|artificial intelligence") ~ "AI",
    str_detect(tolower(job_title), "engineer") ~ "Engineer",
    TRUE ~ "Other"
  ))

title_summary <- df %>%
  count(title_category) %>%
  arrange(desc(n))

ggplot(title_summary, aes(x=reorder(title_category, n), y=n, fill=title_category)) +
  geom_col() +
  coord_flip() +
  labs(title="AI Job Titles by Category", x="Title Category", y="Count") +
  theme_minimal()



ggplot(df, aes(x=posting_duration)) +
  geom_histogram(fill="tomato", bins=30) +
  labs(title="Distribution of Job Posting Duration", x="Duration (Days)", y="Count") +
  theme_minimal()


library(corrplot)

df_numeric <- df %>%
  select(salary_usd, posting_duration, remote_ratio) %>%
  drop_na()

cor_matrix <- cor(df_numeric)

corrplot(cor_matrix, method="color", type="upper", tl.col="black", addCoef.col="black")



skill_by_exp <- df %>%
  separate_rows(required_skills, sep = ",\\s*") %>%
  filter(required_skills != "") %>%
  group_by(experience_level, required_skills) %>%
  summarise(n = n(), .groups = "drop") %>%
  group_by(experience_level) %>%
  slice_max(order_by = n, n = 10)

ggplot(skill_by_exp, aes(x=required_skills, y=experience_level, fill=n)) +
  geom_tile() +
  scale_fill_viridis_c() +
  labs(title="Top Skills by Experience Level", x="Skill", y="Experience Level") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle=45, hjust=1))



