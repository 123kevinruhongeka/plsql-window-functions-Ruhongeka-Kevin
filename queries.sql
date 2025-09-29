--Ranking Functions

-- ROW_NUMBER(), RANK(), DENSE_RANK(), PERCENT_RANK()
SELECT 
    c.customer_id,
    c.name,
    c.region,
    SUM(t.amount) AS total_revenue,
    ROW_NUMBER() OVER (ORDER BY SUM(t.amount) DESC) AS row_num,
    RANK() OVER (ORDER BY SUM(t.amount) DESC) AS rank,
    DENSE_RANK() OVER (ORDER BY SUM(t.amount) DESC) AS dense_rank,
    PERCENT_RANK() OVER (ORDER BY SUM(t.amount) DESC) AS percent_rank
FROM customers c
JOIN transactions t ON c.customer_id = t.customer_id
GROUP BY c.customer_id, c.name, c.region
ORDER BY total_revenue DESC;
--Interpretation: This query ranks customers by total revenue using four different ranking methods, helping identify top performers and their relative positions in the customer base

--Aggregate Functions
-- SUM(), AVG() with ROWS vs RANGE frames
SELECT 
    TO_CHAR(sale_date, 'YYYY-MM') AS sales_month,
    SUM(amount) AS monthly_sales,
    SUM(SUM(amount)) OVER (
        ORDER BY TO_CHAR(sale_date, 'YYYY-MM') 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total_rows,
    SUM(SUM(amount)) OVER (
        ORDER BY TO_CHAR(sale_date, 'YYYY-MM') 
        RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total_range,
    AVG(SUM(amount)) OVER (
        ORDER BY TO_CHAR(sale_date, 'YYYY-MM')
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS moving_avg_3month
FROM transactions
GROUP BY TO_CHAR(sale_date, 'YYYY-MM')
ORDER BY sales_month;
--Interpretation: Demonstrates running totals using different frame types (ROWS vs RANGE) and calculates 3-month moving averages to identify sales trends.

-- Navigation Functions
-- LAG(), LEAD() for growth calculations
WITH monthly_sales AS (
    SELECT 
        TO_CHAR(sale_date, 'YYYY-MM') AS sales_month,
        SUM(amount) AS monthly_sales
    FROM transactions
    GROUP BY TO_CHAR(sale_date, 'YYYY-MM')
)
SELECT 
    sales_month,
    monthly_sales,
    LAG(monthly_sales, 1) OVER (ORDER BY sales_month) AS prev_month_sales,
    LEAD(monthly_sales, 1) OVER (ORDER BY sales_month) AS next_month_sales,
    ROUND(
        ((monthly_sales - LAG(monthly_sales, 1) OVER (ORDER BY sales_month)) / 
         LAG(monthly_sales, 1) OVER (ORDER BY sales_month)) * 100, 2
    ) AS growth_percent
FROM monthly_sales
ORDER BY sales_month;
--Interpretation: Provides month-over-month growth analysis by comparing current sales with previous and next months, enabling trend identification.

--Distribution Functions
sql
-- NTILE(4), CUME_DIST() for customer segmentation
WITH customer_stats AS (
    SELECT 
        c.customer_id,
        c.name,
        c.region,
        SUM(t.amount) AS total_spent,
        COUNT(t.transaction_id) AS transaction_count
    FROM customers c
    JOIN transactions t ON c.customer_id = t.customer_id
    GROUP BY c.customer_id, c.name, c.region
)
SELECT 
    customer_id,
    name,
    region,
    total_spent,
    transaction_count,
    NTILE(4) OVER (ORDER BY total_spent DESC) AS spending_quartile,
    ROUND(CUME_DIST() OVER (ORDER BY total_spent DESC), 3) AS cumulative_distribution,
    CASE 
        WHEN NTILE(4) OVER (ORDER BY total_spent DESC) = 1 THEN 'Platinum'
        WHEN NTILE(4) OVER (ORDER BY total_spent DESC) = 2 THEN 'Gold'
        WHEN NTILE(4) OVER (ORDER BY total_spent DESC) = 3 THEN 'Silver'
        ELSE 'Bronze'
    END AS customer_segment
FROM customer_stats
ORDER BY total_spent DESC;
