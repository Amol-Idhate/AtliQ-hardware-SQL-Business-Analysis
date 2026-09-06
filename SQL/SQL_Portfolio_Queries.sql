/*
  SQL Portfolio Queries
  Dialect: MySQL 8+
  Focus: business analysis, joins, CTEs, aggregations, CASE logic, and window functions.
  Each section presents a business question followed by one curated solution.
*/

-- ============================================================================
-- 1. Question: List every movie with its financial information, including
--    movies that do not yet have a matching financial record.
-- ============================================================================
-- Note: LEFT JOIN retains every row from movies; unmatched financial columns
--       are returned as NULL.
SELECT
    m.movie_id,
    m.title,
    f.budget,
    f.revenue,
    f.currency,
    f.unit
FROM movies AS m
LEFT JOIN financials AS f
    ON m.movie_id = f.movie_id;


-- ============================================================================
-- 2. Question: Count movies by language, including languages with no movies.
-- ============================================================================
-- Note: COUNT(m.movie_id), rather than COUNT(*), correctly returns 0 for a
--       language that has no matching movie.
SELECT
    l.name AS language,
    COUNT(m.movie_id) AS movie_count
FROM languages AS l
LEFT JOIN movies AS m
    ON l.language_id = m.language_id
GROUP BY l.language_id, l.name
ORDER BY movie_count DESC, language;


-- ============================================================================
-- 3. Question: Show each movie and its cast as one pipe-separated list.
-- ============================================================================
-- Note: GROUP_CONCAT converts each movie's multiple actor rows into one
--       readable string. The bridge table movie_actor resolves the many-to-many relationship.
SELECT
    m.movie_id,
    m.title,
    GROUP_CONCAT(a.name ORDER BY a.name SEPARATOR ' | ') AS actors
FROM moviesdb.movies AS m
JOIN moviesdb.movie_actor AS ma
    ON m.movie_id = ma.movie_id
JOIN moviesdb.actors AS a
    ON ma.actor_id = a.actor_id
GROUP BY m.movie_id, m.title;


-- ============================================================================
-- 4. Question: Find Bollywood movies with profit normalised to millions and
--    rank them from most to least profitable.
-- ============================================================================
-- Note: CASE standardises values stored in thousands, millions, and billions
--       so that every profit result is comparable in millions.
SELECT
    m.title,
    ROUND(
        CASE f.unit
            WHEN 'thousands' THEN (f.revenue - f.budget) / 1000
            WHEN 'billions'  THEN (f.revenue - f.budget) * 1000
            WHEN 'millions'  THEN  f.revenue - f.budget
        END,
        2
    ) AS profit_mln
FROM moviesdb.movies AS m
JOIN moviesdb.financials AS f
    ON m.movie_id = f.movie_id
WHERE m.industry = 'bollywood'
ORDER BY profit_mln DESC;


-- ============================================================================
-- 5. Question: Identify low-rated movies that still achieved at least 500%
--    profit, compared with the average movie rating.
-- ============================================================================
-- Note: The CTE calculates profit once. The scalar subquery supplies the
--       benchmark average rating used to identify under-rated successes.
WITH movie_profit AS (
    SELECT
        m.movie_id,
        m.title,
        m.imdb_rating,
        (f.revenue - f.budget) * 100.0 / f.budget AS profit_pct
    FROM movies AS m
    JOIN financials AS f
        ON m.movie_id = f.movie_id
    WHERE f.budget > 0
)
SELECT
    title,
    imdb_rating,
    ROUND(profit_pct, 1) AS profit_pct
FROM movie_profit
WHERE imdb_rating < (SELECT AVG(imdb_rating) FROM movies)
  AND profit_pct >= 500
ORDER BY profit_pct DESC;


-- ============================================================================
-- 6. Question: Find actors aged between 71 and 84 using a CTE.
-- ============================================================================
-- Note: The CTE gives the calculated age a reusable name before the outer
--       query filters it; this makes the logic easier to read and maintain.
WITH actor_age AS (
    SELECT
        name,
        YEAR(CURDATE()) - birth_year AS age
    FROM actors
)
SELECT name, age
FROM actor_age
WHERE age BETWEEN 71 AND 84
ORDER BY age DESC, name;


-- ============================================================================
-- 7. Question: Calculate monthly gross sales for customer 90002002, using the
--    price applicable to each fiscal year.
-- ============================================================================
-- Note: Both product_code and fiscal_year are needed in the join because a
--       product can have a different gross price in a different fiscal year.
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


-- ============================================================================
-- 8. Question: Assign a market badge based on FY2021 sales volume.
-- ============================================================================
-- Note: CASE evaluates the aggregated sales quantity after GROUP BY and
--       turns the numeric threshold into a business-friendly label.
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


-- ============================================================================
-- 9. Question: Return the top three customers by net sales in FY2020.
-- ============================================================================
-- Note: Sales are aggregated per customer before sorting; LIMIT then keeps
--       only the highest three results.
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


-- ============================================================================
-- 10. Question: Show each expense's percentage contribution to its category
--     and the cumulative category expense over time.
-- ============================================================================
-- Note: PARTITION BY restarts each calculation for every category. The ROWS
--       frame creates a running total from the first date through the current row.
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


-- ============================================================================
-- 11. Question: Calculate each FY2021 customer's net-sales contribution to
--     the overall total.
-- ============================================================================
-- Note: The CTE first creates one row per customer. SUM(...) OVER () then
--       calculates the grand total without collapsing those customer rows.
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


-- ============================================================================
-- 12. Question: Find the three highest-selling products in each division in
--     FY2021, retaining ties.
-- ============================================================================
-- Note: The first CTE aggregates product sales; the second assigns a rank
--       within each division. DENSE_RANK keeps products tied at the same rank.
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


-- ============================================================================
-- 13. Question: Find the top two markets by gross sales within every region
--     for FY2021, retaining ties.
-- ============================================================================
-- Note: The query follows a two-stage pattern: aggregate market sales first,
--       then rank markets only against other markets in the same region.
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


-- ============================================================================
-- 14. Question: Build an actual-versus-forecast table that preserves records
--     existing in either source, then replaces missing quantities with zero.
-- ============================================================================
-- Note: MySQL has no FULL OUTER JOIN, so the two LEFT JOIN results are combined
--       with UNION. COALESCE converts missing sales or forecast values to zero.
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


-- ============================================================================
-- 15. Question: Calculate FY2021 forecast accuracy by customer using absolute
--     error, and rank customers from most to least accurate.
-- ============================================================================
-- Note: ABS prevents positive and negative forecast errors from cancelling out.
--       NULLIF avoids a division-by-zero error; GREATEST ensures accuracy is never negative.
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


-- ============================================================================
-- 16. Question: Identify customers whose forecast accuracy fell from FY2020
--     to FY2021 and quantify the decrease.
-- ============================================================================
-- Note: The first CTE calculates accuracy for each customer-year. Conditional
--       aggregation pivots FY2020 and FY2021 into columns for direct comparison.
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
