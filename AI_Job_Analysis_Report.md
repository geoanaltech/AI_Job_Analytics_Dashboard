
# AI Job Market Analysis Report

**Objective**: Analyze global AI job market trends, skills in demand, and regional hiring patterns using `ai_job_dataset.csv`.

**Stakeholders**: Recruiters, Job Seekers, Hiring Managers, Policy Makers

---

## Part 2 – Extended Data Analysis

### 1. Salary vs Remote Ratio
- **Insight**: Remote jobs tend to offer higher average salaries.
- **Method**: Grouped by work arrangement (On-site, Hybrid, Remote) and calculated mean salaries.

### 2. Salary by Company Size
- **Insight**: Larger companies tend to offer higher salaries due to budget and market competition.
- **Method**: Average salary by company size category.

### 3. Job Title Keyword Clustering
- **Insight**: Titles containing “Data”, “ML”, “AI”, and “Engineer” dominate.
- **Method**: Pattern matching to cluster similar job roles.

### 4. Job Posting Duration
- **Insight**: Jobs remain open for ~20–30 days on average.
- **Method**: Histogram of days between `posting_date` and `application_deadline`.

### 5. Correlation Analysis
- **Insight**: Remote ratio and salary show mild correlation.
- **Method**: Pearson correlation among `salary_usd`, `remote_ratio`, and `posting_duration`.

### 6. Top Skills by Experience Level
- **Insight**:
  - Entry-level: SQL, Excel, Python
  - Mid-level: ML, Python, TensorFlow
  - Senior/Executive: NLP, Cloud, Strategy
- **Method**: Top 10 most frequent skills per experience level.

---

## Recommended KPIs
- Average Salary (Overall and by Country)
- Top In-demand Skills by Experience Level
- Job Count by Location, Employment Type, and Experience Level
- Average Job Posting Duration
- Skill-Salary Influence Correlation

---

## Dashboard Requirements

**Filters**:
- Country
- Job Type (e.g., Full-time, Part-time, Contract)
- Experience Level
- Date Range

**Interactive Elements**:
- Salary and remote work visualizations
- Top skills by experience level heatmap
- Job posting trends over time
- Correlation matrix and skill cluster plots

**Hosting**: Deploy to [shinyapps.io](https://www.shinyapps.io)

---

**Next Step**: Integrate this into an R Shiny dashboard with complete filtering UI and corresponding outputs.
