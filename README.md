# 📊 SQL Business Analysis | MySQL

## 📌 Project Overview

This project demonstrates practical **MySQL 8+** skills through business-oriented data analysis and advanced SQL problem solving.

The project focuses on transforming relational data into meaningful analysis using **JOINs, aggregations, CASE statements, subqueries, CTEs, and window functions**.

The SQL work covers two analytical areas:

- **Entertainment Data Analysis:** movie, financial, language, and actor analysis
- **AtliQ Business Analysis:** sales, customers, products, markets, expenses, and forecast accuracy

The primary objective is to demonstrate not only **how to write SQL**, but also **why a particular SQL technique is useful and how it can solve a real analytical problem**.

---

## 🎯 Business Objectives

The analysis is designed to answer practical questions such as:

- Which customers and markets contribute the most sales?
- Which products perform best within each division?
- How can customer sales contribution be measured?
- Which expenses contribute most to category-level costs?
- How can actual sales be compared with forecast quantities?
- Which customers have lower forecast accuracy?
- How can relational data from multiple tables be combined efficiently?
- How can complex SQL logic be structured for readability and maintainability?

---

## ⭐ Project Highlights

| Metric | Scope |
|---|---:|
| Curated SQL Queries | **16** |
| SQL Dialect | **MySQL 8+** |
| Core Focus | **Business & Data Analysis** |
| Advanced Techniques | **CTEs & Window Functions** |
| Analysis Areas | **Sales, Customers, Products, Markets, Expenses & Forecasts** |

---

## 🛠️ Tools & Technologies

- **MySQL 8+**
- SQL
- JOINs
- Aggregate Functions
- CASE Statements
- Subqueries
- Common Table Expressions (CTEs)
- Window Functions
- `GROUP_CONCAT()`
- `COALESCE()`
- `NULLIF()`
- `ABS()`
- `GREATEST()`

---

## 🗂️ Project Structure

```text
SQL-Business-Analysis/
│
├── README.md
│
└── SQL/
    └── SQL_Portfolio_Queries.sql
```

---

# 🔍 Analysis Performed

## 1. 🎬 Entertainment Data Analysis

The first set of queries demonstrates relational data analysis using movie, financial, language, and actor data.

### Key Analysis

- Combined movie and financial information using `LEFT JOIN`
- Counted movies by language while retaining languages with no matching movies
- Combined multiple actors into a single readable list using `GROUP_CONCAT()`
- Standardized movie profit values stored in thousands, millions, and billions
- Identified highly profitable movies with below-average ratings
- Calculated actor age using a CTE

### Business / Analytical Value

These queries demonstrate how SQL can combine related datasets, handle different data representations, aggregate many-to-many relationships, and identify patterns from raw data.

---

# 💰 2. AtliQ Sales & Business Analysis

The second part focuses on business analysis using sales, customer, product, market, expense, and forecast data.

## Sales Analysis

The project analyzes sales using customer, product, price, and fiscal-year information.

### Key Analysis

- Calculated monthly gross sales for a selected customer
- Joined product pricing using both `product_code` and `fiscal_year`
- Identified top customers by net sales
- Calculated each customer's contribution to total sales

### Business Value

This analysis helps understand revenue contribution, customer performance, and sales patterns while ensuring that fiscal-year-specific pricing is applied correctly.

---

## 🌍 Customer & Market Analysis

The project performs market and customer-level analysis to identify high-performing business areas.

### Key Analysis

- Classified markets using sales-volume thresholds
- Identified top customers by revenue
- Calculated customer contribution percentage
- Ranked markets within each region
- Retained tied results using `DENSE_RANK()`

### Business Value

These analyses help identify high-value customers and markets and support prioritization of commercial efforts.

---

## 📦 Product Performance Analysis

Product sales are aggregated and ranked within each division.

### Key Analysis

- Calculated product-level sales quantities
- Ranked products within each division
- Identified the top three products per division
- Preserved ties using `DENSE_RANK()`

### Business Value

Product-level ranking can support product prioritization, sales planning, and portfolio performance analysis.

---

## 💸 Expense Analysis

Expense data is analyzed at category level using window functions.

### Key Analysis

- Calculated each expense's percentage contribution within its category
- Calculated cumulative expense over time
- Used `PARTITION BY` to perform category-level calculations
- Used an ordered window frame to generate running totals

### Business Value

This helps identify major expense contributors and understand how costs accumulate over time.

---

# 📈 Forecast vs. Actual Analysis

A key part of the project focuses on comparing actual sales with forecast quantities.

## Data Preparation

An `fact_act_est` table is created by combining actual sales and forecast data.

Since MySQL does not provide a native `FULL OUTER JOIN`, the solution uses:

- `LEFT JOIN`
- `UNION`
- `COALESCE()`

This approach preserves records available in either source and replaces missing actual or forecast quantities with zero.

### Business Value

Creating a combined actual-versus-forecast dataset provides a consistent foundation for forecast performance analysis.

---

## 🎯 Forecast Accuracy Analysis

Forecast accuracy is calculated at customer level using:

- Actual quantity
- Forecast quantity
- Absolute error
- Absolute error percentage
- Forecast accuracy percentage

### SQL Techniques Applied

- `ABS()` to measure the magnitude of forecast error
- `NULLIF()` to prevent division-by-zero errors
- `GREATEST()` to prevent negative accuracy values
- CTEs to structure the calculation into logical steps

### Business Value

Forecast accuracy analysis helps identify customers where demand forecasting performs well and customers that may require further investigation.

---

## 📊 Year-over-Year Forecast Accuracy

The project compares forecast accuracy between **FY2020 and FY2021**.

### Analysis Steps

1. Calculate customer-level forecast accuracy for each fiscal year.
2. Separate FY2020 and FY2021 accuracy using conditional aggregation.
3. Compare the two fiscal years.
4. Identify customers whose forecast accuracy declined.
5. Quantify the decrease in accuracy.

### Business Value

This analysis helps identify customers with deteriorating forecast performance so that forecasting processes can be reviewed and improved.

---

# 🧠 SQL Techniques Demonstrated

## 🔗 JOINs

### Why?

Business data is often distributed across multiple related tables. JOINs allow these datasets to be combined for analysis.

### Used For

- Combining movies with financial information
- Connecting customers with sales
- Connecting products with sales
- Combining actual and forecast data

---

## 📊 Aggregations

### Why?

Detailed transactional records need to be summarized before they can be used for business analysis.

### Used For

- Total sales
- Customer-level sales
- Product-level sales
- Market-level sales
- Expense calculations

Functions used include:

`SUM()` · `COUNT()` · `AVG()`

---

## 🧠 CASE Statements

### Why?

`CASE` allows business rules to be translated into analytical classifications.

### Example

Classifying a market as **Gold** or **Silver** based on sales volume.

### Business Value

It converts raw numerical conditions into meaningful business categories.

---

## 🔎 Subqueries

### Why?

Subqueries are useful when one calculation is required as a benchmark or input for another analysis.

### Example

Comparing a movie's rating against the overall average rating.

---

## 🧩 Common Table Expressions (CTEs)

### Why?

CTEs divide complex SQL logic into clear, logical steps.

### Used For

- Calculating movie profit before filtering
- Preparing customer-level sales
- Preparing product-level sales before ranking
- Calculating yearly forecast accuracy
- Comparing forecast accuracy across years

### Business Benefit

CTEs improve **readability, maintainability, and debugging** of analytical SQL.

---

## 📈 Window Functions

### Why?

Window functions perform calculations across related rows without collapsing the result into a single row.

### Used For

- Product ranking within divisions
- Market ranking within regions
- Customer contribution to total sales
- Category-level expense contribution
- Cumulative expense calculations

Functions and patterns used include:

`DENSE_RANK()` · `SUM() OVER()` · `PARTITION BY` · `ORDER BY` · window frames

---

## 🧮 NULL & Error Handling

The project also applies SQL functions to make analytical calculations more robust.

- `COALESCE()` handles missing values
- `NULLIF()` prevents division-by-zero errors
- `ABS()` calculates absolute forecast error
- `GREATEST()` prevents negative forecast accuracy

These techniques help make analytical queries safer and more reliable.

---

# 💼 Business Questions Answered

### Sales & Customers

- Who are the top customers by net sales?
- What percentage of total sales does each customer contribute?
- What are the monthly gross sales for a selected customer?

### Products & Markets

- Which products are the top performers within each division?
- Which markets perform best within each region?
- Which markets cross a defined sales-volume threshold?

### Expenses

- What percentage of category expense does each expense represent?
- How does cumulative expense change over time?

### Forecasting

- How accurate is the forecast for each customer?
- Which customers have lower forecast accuracy?
- Which customers experienced a decline in forecast accuracy from FY2020 to FY2021?

### Entertainment Analysis

- Which movies have matching financial information?
- How many movies exist for each language?
- Which movies generated the highest normalized profit?
- Which highly profitable movies have below-average ratings?

---

# 💡 Key Insights

The project demonstrates how SQL can be used to:

- Identify high-value customers and markets
- Rank products within business segments
- Measure contribution to total sales
- Analyze expense distribution and cumulative costs
- Compare forecasted and actual demand
- Identify changes in forecast performance
- Combine and analyze data across multiple relational tables
- Convert raw data into structured, decision-support information

> **Note:** Specific numerical findings are generated when the queries are executed against the underlying database.

---

# 📚 Key Learnings

Through this project, I strengthened my ability to:

- Write structured and business-focused MySQL queries
- Work with multiple relational tables
- Translate business questions into SQL solutions
- Use CTEs for multi-step analysis
- Apply window functions for ranking and comparative analysis
- Handle NULL values and calculation errors
- Combine actual and forecast datasets
- Build analytical queries that are readable and maintainable
- Focus on both the **technical solution and the business purpose**

---

# 🚀 Project Outcome

This project demonstrates practical SQL beyond basic data retrieval.

The emphasis is on **solving business questions with SQL**, selecting the appropriate analytical technique, and producing structured outputs that can support data-driven decision-making.

The project contains **16 curated SQL queries** covering relational analysis, sales, customers, products, markets, expenses, and forecast performance.

---

# 👨‍💻 Author

**Amol Ashok Idhate**

Aspiring Data Analyst

**GitHub:** [Amol-Idhate](https://github.com/Amol-Idhate)

**LinkedIn:** [Amol Ashok Idhate](https://www.linkedin.com/in/amol-ashok-idhate-691b753b2/)

---

## ⭐ Skills Demonstrated

**MySQL 8+** · **SQL** · **JOINs** · **CTEs** · **Subqueries** · **Window Functions** · **Aggregations** · **CASE Statements** · **Data Analysis** · **Business Intelligence**
