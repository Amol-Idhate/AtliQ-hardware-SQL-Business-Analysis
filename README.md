# 📊 SQL Business Analysis | MySQL

## 📌 Project Overview

This project demonstrates practical **MySQL 8+** skills through business-oriented data analysis and advanced SQL problem solving.

The project focuses on transforming relational data into meaningful analysis using **JOINs, aggregations, CASE statements, subqueries, CTEs, and window functions**.

The SQL work focuses on **AtliQ business analysis**, covering sales, customers, products, markets, expenses, and forecast accuracy.

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
| Business Analysis Queries | **10** |
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

## 💰 1. Sales & Customer Analysis

The project uses sales, customer, product, pricing, and fiscal-year information to answer practical business questions.

### Key Analysis

- Calculated monthly gross sales for a selected customer
- Applied fiscal-year-specific product pricing
- Classified markets using sales-volume thresholds
- Identified top customers by net sales
- Calculated customer contribution to total sales

### Business Value

This analysis helps understand customer performance, revenue contribution, market segmentation, and sales patterns.

---

## 📦 2. Product Performance Analysis

Product sales are aggregated and ranked within each division.

### Key Analysis

- Calculated product-level sales quantities
- Ranked products within each division
- Identified the top three products per division
- Preserved ties using `DENSE_RANK()`

### Business Value

Product-level ranking can support product prioritization, sales planning, and portfolio performance analysis.

---

## 🌍 3. Market Analysis

Market performance is evaluated both through threshold-based classification and regional ranking.

### Key Analysis

- Assigned market badges based on sales volume
- Ranked markets within regions
- Identified the top two markets per region
- Preserved tied results using `DENSE_RANK()`

### Business Value

These analyses help identify high-performing markets and support regional prioritization.

---

## 💸 4. Expense Analysis

Expense data is analyzed at category level using window functions.

### Key Analysis

- Calculated each expense's percentage contribution within its category
- Calculated cumulative expense over time
- Used `PARTITION BY` for category-level calculations
- Used an ordered window frame to generate running totals

### Business Value

This helps identify major expense contributors and understand how costs accumulate over time.

---

# 📈 5. Forecast vs. Actual Analysis

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

# 💼 Business Question → SQL Solution

This section connects each business question directly to the SQL solution used in the project.

The goal is to show the complete analytical thought process:

**Business Question → SQL Technique → Approach → SQL Solution → Business Value**

## 7. Monthly Gross Sales by Customer

**Business Question:**  
> Calculate monthly gross sales for a selected customer using the price applicable to each fiscal year.

**SQL Concepts Used:**  
`JOIN`

**Approach:**  
Both `product_code` and `fiscal_year` are required in the price join so the correct fiscal-year-specific price is applied.

**SQL Solution:**

```sql
SELECT
    s.date,
    ROUND(SUM(g.gross_price * s.sold_quantity), 2) AS gross_sales
FROM fact_sales_monthly AS s
JOIN fact_gross_price AS g
    ON g.product_code = s.product_code
   AND g.fiscal_year = get_fiscal_year(s.date)
WHERE s.customer_code = 90002002
GROUP BY s.date
ORDER BY s.date;
```

**Business Value:**  
Supports customer-level sales reporting and ensures historical pricing is applied correctly.

---

## 8. Market Classification

**Business Question:**  
> Assign a business-friendly badge to a market based on FY2021 sales volume.

**SQL Concepts Used:**  
`CASE` + `GROUP BY`

**Approach:**  
The aggregated sales quantity is converted into a business classification using a defined threshold.

**SQL Solution:**

```sql
SELECT
    c.market,
    SUM(s.sold_quantity) AS total_sold_quantity,
    CASE
        WHEN SUM(s.sold_quantity) > 5000000 THEN 'Gold'
        ELSE 'Silver'
    END AS market_badge
FROM dim_customer AS c
JOIN fact_sales_monthly AS s
    ON c.customer_code = s.customer_code
WHERE c.market = 'indonesia'
  AND get_fiscal_year(s.date) = 2021
GROUP BY c.market;
```

**Business Value:**  
Helps segment markets and prioritize commercial attention based on sales volume.

---

## 9. Top Customers by Net Sales

**Business Question:**  
> Identify the top three customers by net sales in FY2020.

**SQL Concepts Used:**  
`JOIN` + `GROUP BY` + `ORDER BY` + `LIMIT`

**Approach:**  
Customer-level sales are aggregated and ranked to identify the highest-value customers.

**SQL Solution:**

```sql
SELECT
    c.customer,
    ROUND(SUM(ns.net_sales) / 1000000, 2) AS net_sales_mln
FROM net_sale AS ns
JOIN dim_customer AS c
    ON c.customer_code = ns.customer_code
WHERE ns.fiscal_year = 2020
GROUP BY c.customer_code, c.customer
ORDER BY net_sales_mln DESC
LIMIT 3;
```

**Business Value:**  
Helps identify high-value customers for retention, account management, and revenue planning.

---

## 10. Expense Contribution & Cumulative Expense

**Business Question:**  
> Show each expense's percentage contribution to its category and cumulative category expense over time.

**SQL Concepts Used:**  
`Window Functions` + `PARTITION BY`

**Approach:**  
Window functions calculate category contribution and running expense totals without losing row-level detail.

**SQL Solution:**

```sql
SELECT
    date,
    category,
    amount,
    ROUND(amount * 100.0 / SUM(amount) OVER (PARTITION BY category), 2) AS category_pct,
    SUM(amount) OVER (
        PARTITION BY category
        ORDER BY date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_category_expense
FROM expenses
ORDER BY category, date;
```

**Business Value:**  
Helps identify major cost contributors and understand how expenses accumulate over time.

---

## 11. Customer Sales Contribution

**Business Question:**  
> Calculate each FY2021 customer's contribution to overall net sales.

**SQL Concepts Used:**  
`CTE` + `Window Function`

**Approach:**  
A customer-level result is created first, then the grand total is calculated with `SUM() OVER()`.

**SQL Solution:**

```sql
WITH customer_sales AS (
    SELECT
        c.customer,
        ROUND(SUM(ns.net_sales) / 1000000, 2) AS net_sales_mln
    FROM net_sale AS ns
    JOIN dim_customer AS c
        ON c.customer_code = ns.customer_code
    WHERE ns.fiscal_year = 2021
    GROUP BY c.customer_code, c.customer
)
SELECT
    customer,
    net_sales_mln,
    ROUND(net_sales_mln * 100.0 / SUM(net_sales_mln) OVER (), 2) AS total_sales_pct
FROM customer_sales
ORDER BY net_sales_mln DESC;
```

**Business Value:**  
Shows revenue concentration and which customers contribute most to overall business sales.

---

## 12. Top Products by Division

**Business Question:**  
> Find the three highest-selling products in each division in FY2021 while retaining ties.

**SQL Concepts Used:**  
`CTE` + `DENSE_RANK()`

**Approach:**  
Products are aggregated first and then ranked within each division; `DENSE_RANK()` preserves ties.

**SQL Solution:**

```sql
WITH product_sales AS (
    SELECT
        p.division,
        p.product,
        SUM(s.sold_quantity) AS total_sold_quantity
    FROM fact_sales_monthly AS s
    JOIN dim_product AS p
        ON p.product_code = s.product_code
    WHERE s.fiscal_year = 2021
    GROUP BY p.division, p.product
), ranked_products AS (
    SELECT
        division,
        product,
        total_sold_quantity,
        DENSE_RANK() OVER (
            PARTITION BY division
            ORDER BY total_sold_quantity DESC
        ) AS sales_rank
    FROM product_sales
)
SELECT division, product, total_sold_quantity, sales_rank
FROM ranked_products
WHERE sales_rank <= 3
ORDER BY division, sales_rank, product;
```

**Business Value:**  
Supports product prioritization, portfolio analysis, and sales planning within each division.

---

## 13. Top Markets by Region

**Business Question:**  
> Find the top two markets by gross sales within every region for FY2021 while retaining ties.

**SQL Concepts Used:**  
`CTE` + `DENSE_RANK()` + `PARTITION BY`

**Approach:**  
Markets are ranked against other markets in the same region rather than against the entire dataset.

**SQL Solution:**

```sql
WITH market_sales AS (
    SELECT
        c.region,
        c.market,
        ROUND(SUM(g.gross_price_total) / 1000000, 2) AS gross_sales_mln
    FROM dim_customer AS c
    JOIN gross_sale AS g
        ON g.customer_code = c.customer_code
    WHERE g.fiscal_year = 2021
    GROUP BY c.region, c.market
), ranked_markets AS (
    SELECT
        region,
        market,
        gross_sales_mln,
        DENSE_RANK() OVER (
            PARTITION BY region
            ORDER BY gross_sales_mln DESC
        ) AS sales_rank
    FROM market_sales
)
SELECT region, market, gross_sales_mln, sales_rank
FROM ranked_markets
WHERE sales_rank <= 2
ORDER BY region, sales_rank, market;
```

**Business Value:**  
Helps identify the strongest markets within each region and supports regional prioritization.

---

## 14. Actual vs Forecast Data Preparation

**Business Question:**  
> Build an actual-versus-forecast table that preserves records existing in either source.

**SQL Concepts Used:**  
`LEFT JOIN` + `UNION` + `COALESCE`

**Approach:**  
MySQL has no native `FULL OUTER JOIN`, so two `LEFT JOIN` results are combined and missing quantities are replaced with zero.

**SQL Solution:**

```sql
CREATE TABLE fact_act_est AS
SELECT
    s.date,
    s.fiscal_year,
    s.product_code,
    s.customer_code,
    COALESCE(s.sold_quantity, 0) AS sold_quantity,
    COALESCE(f.forecast_quantity, 0) AS forecast_quantity
FROM fact_sales_monthly AS s
LEFT JOIN fact_forecast_monthly AS f
    USING (date, product_code, customer_code)
UNION
SELECT
    f.date,
    f.fiscal_year,
    f.product_code,
    f.customer_code,
    COALESCE(s.sold_quantity, 0) AS sold_quantity,
    COALESCE(f.forecast_quantity, 0) AS forecast_quantity
FROM fact_forecast_monthly AS f
LEFT JOIN fact_sales_monthly AS s
    USING (date, product_code, customer_code);
```

**Business Value:**  
Creates a reliable foundation for comparing actual demand with forecast demand.

---

## 15. FY2021 Forecast Accuracy

**Business Question:**  
> Calculate customer-level forecast accuracy using absolute error and rank customers from most to least accurate.

**SQL Concepts Used:**  
`CTE` + `ABS` + `NULLIF` + `GREATEST`

**Approach:**  
`ABS()` measures error magnitude, `NULLIF()` prevents division by zero, and `GREATEST()` prevents negative accuracy.

**SQL Solution:**

```sql
WITH forecast_error AS (
    SELECT
        s.customer_code,
        SUM(s.sold_quantity) AS total_sold_quantity,
        SUM(s.forecast_quantity) AS total_forecast_quantity,
        SUM(ABS(s.forecast_quantity - s.sold_quantity)) AS absolute_error
    FROM fact_act_est AS s
    WHERE s.fiscal_year = 2021
    GROUP BY s.customer_code
)
SELECT
    c.customer,
    c.market,
    fe.total_sold_quantity,
    fe.total_forecast_quantity,
    ROUND(fe.absolute_error * 100.0 / NULLIF(fe.total_forecast_quantity, 0), 2) AS absolute_error_pct,
    GREATEST(
        0,
        ROUND(100 - fe.absolute_error * 100.0 / NULLIF(fe.total_forecast_quantity, 0), 2)
    ) AS forecast_accuracy_pct
FROM forecast_error AS fe
JOIN dim_customer AS c
    ON c.customer_code = fe.customer_code
ORDER BY forecast_accuracy_pct DESC, c.customer;
```

**Business Value:**  
Helps identify customers where forecasting performs well and where forecast quality needs investigation.

---

## 16. YoY Forecast Accuracy Decline

**Business Question:**  
> Identify customers whose forecast accuracy fell from FY2020 to FY2021 and quantify the decrease.

**SQL Concepts Used:**  
`CTEs` + `CASE` + `Conditional Aggregation`

**Approach:**  
Yearly accuracy is calculated first, then FY2020 and FY2021 are compared side by side to identify deterioration.

**SQL Solution:**

```sql
WITH yearly_accuracy AS (
    SELECT
        s.customer_code,
        s.fiscal_year,
        GREATEST(
            0,
            100 - SUM(ABS(s.forecast_quantity - s.sold_quantity)) * 100.0
                  / NULLIF(SUM(s.forecast_quantity), 0)
        ) AS forecast_accuracy_pct
    FROM fact_act_est AS s
    WHERE s.fiscal_year IN (2020, 2021)
    GROUP BY s.customer_code, s.fiscal_year
), accuracy_comparison AS (
    SELECT
        customer_code,
        MAX(CASE WHEN fiscal_year = 2020 THEN forecast_accuracy_pct END) AS forecast_accuracy_2020,
        MAX(CASE WHEN fiscal_year = 2021 THEN forecast_accuracy_pct END) AS forecast_accuracy_2021
    FROM yearly_accuracy
    GROUP BY customer_code
)
SELECT
    c.customer,
    c.market,
    ROUND(ac.forecast_accuracy_2020, 2) AS forecast_accuracy_2020,
    ROUND(ac.forecast_accuracy_2021, 2) AS forecast_accuracy_2021,
    ROUND(ac.forecast_accuracy_2020 - ac.forecast_accuracy_2021, 2) AS accuracy_decrease_pct
FROM accuracy_comparison AS ac
JOIN dim_customer AS c
    ON c.customer_code = ac.customer_code
WHERE ac.forecast_accuracy_2021 < ac.forecast_accuracy_2020
ORDER BY accuracy_decrease_pct DESC, c.customer;
```

**Business Value:**  
Highlights customers with deteriorating forecast performance so the forecasting process can be reviewed.

---

# 🧠 SQL Techniques Demonstrated

## 🔗 JOINs

### Why?

Business data is often distributed across multiple related tables. JOINs allow these datasets to be combined for analysis.

### Used For

- Connecting customers with sales
- Connecting products with sales
- Connecting products with fiscal-year pricing
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

---

## 🧩 Common Table Expressions (CTEs)

### Why?

CTEs divide complex SQL logic into clear, logical steps.

### Used For

- Preparing customer-level sales
- Preparing product-level sales before ranking
- Calculating forecast accuracy
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

The project contains **16 curated SQL queries**, including **10 AtliQ business-analysis queries** documented above.

---

# 👨‍💻 Author

**Amol Ashok Idhate**

Aspiring Data Analyst

**GitHub:** [Amol-Idhate](https://github.com/Amol-Idhate)

**LinkedIn:** [Amol Ashok Idhate](https://www.linkedin.com/in/amol-ashok-idhate-691b753b2/)

---

## ⭐ Skills Demonstrated

**MySQL 8+** · **SQL** · **JOINs** · **CTEs** · **Subqueries** · **Window Functions** · **Aggregations** · **CASE Statements** · **Data Analysis** · **Business Intelligence**
