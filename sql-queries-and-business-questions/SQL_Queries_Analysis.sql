--SQL Queries for Analysis the data and get the business insights:-

--Select Statement for every table in our DB.Schema - ECOMMERCE_ANALYTICS_DB.PROFITABILITY_ANALYSIS
SELECT * FROM ECOMMERCE_ANALYTICS_DB.PROFITABILITY_ANALYSIS.DIM_DATE;
SELECT * FROM ECOMMERCE_ANALYTICS_DB.PROFITABILITY_ANALYSIS.DIM_CUSTOMER;
SELECT * FROM ECOMMERCE_ANALYTICS_DB.PROFITABILITY_ANALYSIS.DIM_PRODUCT;
SELECT * FROM ECOMMERCE_ANALYTICS_DB.PROFITABILITY_ANALYSIS.DIM_ORDER;
SELECT * FROM ECOMMERCE_ANALYTICS_DB.PROFITABILITY_ANALYSIS.FACT_ORDER_ITEMS;

--1. Data Quality and Validation

--1. Verify the row count of each table and compare it with the expected record count.

SELECT 'DIM_DATE' AS TABLE_NAME, 
        COUNT(*) AS ROWS_COUNT FROM DIM_DATE
UNION ALL
SELECT 'DIM_CUSTOMER', 
        COUNT(*) FROM DIM_CUSTOMER
UNION ALL 
SELECT 'DIM_PRODUCT',
        COUNT(*) FROM DIM_PRODUCT
UNION ALL 
SELECT 'DIM_ORDER',
        COUNT(*) FROM DIM_ORDER
UNION ALL
SELECT 'FACT_ORDER_ITEMS',
        COUNT(*) FROM FACT_ORDER_ITEMS;

--2. Review column names and data types across all tables.

DESC TABLE DIM_DATE;
DESC TABLE DIM_CUSTOMER;
DESC TABLE DIM_PRODUCT;
DESC TABLE DIM_ORDER;
DESC TABLE FACT_ORDER_ITEMS;

--3. Identify missing or NULL values in important columns.

SELECT * FROM DIM_CUSTOMER
WHERE CUSTOMER_ID IS NULL;

--One new method with COUNT IF:-

SELECT COUNT_IF (DOB IS NULL) AS NULL_DOB_VALUE,
       COUNT_IF (CUSTOMER_ID IS NULL) AS NULL_CUSTOMER_ID,
       COUNT_IF (SIGNUP_DATE IS NULL) AS NULL_SIGNUP_DATE
       FROM DIM_CUSTOMER;

SELECT COUNT_IF (ORDER_ID IS NULL) AS NULL_DOB_VALUE,
       COUNT_IF (ORDER_DATE_KEY IS NULL) AS NULL_CUSTOMER_ID
       FROM DIM_ORDER;
       
--4. Check for duplicate Customer IDs in Dim_Customer.

SELECT CUSTOMER_ID, 
       COUNT (CUSTOMER_ID) AS Total_Customers
       FROM DIM_CUSTOMER
       GROUP BY CUSTOMER_ID
       HAVING Total_Customers>1;

--5. Check for duplicate Product IDs in Dim_Product.

SELECT PRODUCT_ID, 
       COUNT (PRODUCT_ID) AS Total_Products
       FROM DIM_PRODUCT
       GROUP BY PRODUCT_ID
       HAVING Total_Products>1;

--6. Identify duplicate order-item records using the combination of Order_ID and Line_ID.

SELECT ORDER_ID, LINE_ID,
       COUNT(ORDER_ID) AS TOTAL_ORDERS,
       COUNT(LINE_ID) AS TOTAL_LINE_IDS
FROM FACT_ORDER_ITEMS
       GROUP BY ORDER_ID, LINE_ID
       HAVING TOTAL_ORDERS>1 AND LINE_ID>1;

--7. Identify order items with Order IDs that do not exist in Dim_Order.

SELECT ORDER_ID 
       FROM FACT_ORDER_ITEMS
       WHERE ORDER_ID NOT IN (SELECT ORDER_ID FROM DIM_ORDER);

--One another method
SELECT f.* 
FROM FACT_ORDER_ITEMS AS f
LEFT JOIN DIM_ORDER AS o ON f.order_id = o.order_id
WHERE o.order_id IS NULL;

--8. Identify order items with Product IDs that do not exist in Dim_Product.

SELECT f.* 
FROM FACT_ORDER_ITEMS AS f
LEFT JOIN DIM_PRODUCT AS o ON f.PRODUCT_ID = o.PRODUCT_ID
WHERE o.PRODUCT_ID IS NULL;

--2. Overall Business Performance

--9. Calculate annual Gross Sales, Net Sales, Total Cost, and Profit.
--For the 'ANNUAL' Sales, Profit, Cost etc we can do the JOINS and mention the 'YEAR':-

SELECT * FROM FACT_ORDER_ITEMS;
SELECT * FROM DIM_ORDER;
SELECT * FROM DIM_DATE;

SELECT d.YEAR,
       SUM(f.Gross_Sales) AS Annual_Gross_Sales,
       SUM(f.Net_Sales) AS Annual_Net_Sales,
       SUM(f.Total_Cost) AS Annual_Cost,
       SUM(f.Profit) AS Annual_Profit
       FROM FACT_ORDER_ITEMS AS f
       LEFT JOIN DIM_ORDER AS o ON f.order_id = o.order_id
       LEFT JOIN DIM_DATE AS d ON o.ORDER_DATE_KEY = d.date_key
       GROUP BY d.YEAR
       ORDER BY d.YEAR;
       
--10. Calculate the annual Profit Margin percentage.

SELECT d.year, 
       SUM(PROFIT) AS Annual_Profit,
       SUM(NET_SALES) AS Annual_Net_Sales,
       (SUM(f.Profit)/(SUM(f.Net_Sales))*100) AS Annual_Profit_Percetage
      FROM FACT_ORDER_ITEMS AS f 
      LEFT JOIN DIM_ORDER AS o ON f.order_id = o.order_id
      LEFT JOIN DIM_DATE AS d ON o.order_date_key = d.date_key
      GROUP BY d.Year
      ORDER BY d.Year;
      
-- 11. Calculate Year-over-Year (YoY) Sales and Profit Growth

WITH Yearly_Data AS (
SELECT d.YEAR,
       SUM(f.Net_Sales) AS Total_Net_Sales,
       SUM(f.Profit) AS Total_Profit
       FROM FACT_ORDER_ITEMS AS f
       LEFT JOIN DIM_ORDER AS o ON f.order_id = o.order_id
       LEFT JOIN DIM_DATE AS d ON o.order_date_key = d.date_key
       GROUP BY d.YEAR
),
  Previous_Data AS ( 
  SELECT *,
         LAG(Total_Net_Sales) OVER (ORDER BY YEAR) AS Prev_Sales,
         LAG(Total_Profit) OVER(ORDER BY YEAR) AS Prev_Profit
         FROM Yearly_Data
)
  SELECT YEAR, 
         Total_Net_Sales,
         ((Total_Net_Sales-Prev_Sales)/Prev_Sales*100) AS YOY_SALES_GROWTH,
         Total_Profit,
         ((Total_Profit-Prev_Profit)/Prev_Profit*100) AS YOY_PROFIT_GROWTH
  FROM Previous_Data
  ORDER BY YEAR;

--12. Analyze monthly sales and profit trends to identify seasonality.

SELECT d.YEAR, 
       d.MONTH_NUMBER,
       d.MONTH_NAME,
       SUM(f.NET_SALES) AS Total_Sales,
       SUM(f.PROFIT) AS Total_Profit
       FROM FACT_ORDER_ITEMS AS f 
       LEFT JOIN DIM_ORDER AS o ON f.order_id = o.order_id
       LEFT JOIN DIM_DATE AS d ON o.order_date_key = d.date_key
       GROUP BY d.YEAR, d.MONTH_NUMBER, d.MONTH_NAME
       ORDER BY d.YEAR, d.MONTH_NUMBER, d.MONTH_NAME

--13. Identify the best- and worst-performing quarters based on sales and profit.
--There are 2-3 diff ways to solve this ques:-

--By CTE:-
WITH Total_Sales_Profit AS (
SELECT d.YEAR, d.QUARTER, 
       SUM(f.NET_SALES) AS Total_Sales,
       SUM(f.PROFIT) AS Total_Profit
       FROM FACT_ORDER_ITEMS AS f 
       LEFT JOIN DIM_ORDER AS o ON f.order_id = o.order_id
       LEFT JOIN DIM_DATE AS d ON o.order_date_key = d.date_key
       GROUP BY d.YEAR, d.QUARTER
)
SELECT *,
       MAX(Total_Sales) OVER() AS Max_Sales,
       MIN(Total_Sales) OVER() AS Min_Sales,
       MAX(Total_Profit) OVER() AS Max_Profit,
       MIN(Total_Profit) OVER() AS Min_Profit
FROM Total_Sales_Profit
ORDER BY YEAR, QUARTER;

--By SubQuery:-
SELECT *,
       MAX(Total_Sales) OVER() AS Max_Sales,
       MIN(Total_Sales) OVER() AS Min_Sales,
       MAX(Total_Profit) OVER() AS Max_Profit,
       MIN(Total_Profit) OVER() AS Min_Profit
FROM (
SELECT d.YEAR, d.QUARTER, 
       SUM(f.NET_SALES) AS Total_Sales,
       SUM(f.PROFIT) AS Total_Profit
       FROM FACT_ORDER_ITEMS AS f 
       LEFT JOIN DIM_ORDER AS o ON f.order_id = o.order_id
       LEFT JOIN DIM_DATE AS d ON o.order_date_key = d.date_key
       GROUP BY d.YEAR, d.QUARTER
);    
--14. Compare sales and profitability across different sales channels.

SELECT o.SALES_CHANNEL,
       SUM(f.Net_Sales) AS Total_Net_Sales,
       SUM(f.Profit) AS Total_Profit,
       (SUM(f.Profit)/NULLIF (SUM(f.Net_Sales),0)*100) AS Profit_Growth_Margin
FROM FACT_ORDER_ITEMS AS f 
LEFT JOIN DIM_ORDER AS o ON f.order_id = o.order_id 
       GROUP BY o.SALES_CHANNEL
       ORDER BY Total_Net_Sales DESC;
       
--15. Analyze sales, order volume, and profitability by payment method.

SELECT o.PAYMENT_METHOD,
       SUM(f.Net_Sales) AS Total_Net_Sales,
       SUM (f.Profit) AS Total_Profit,
       COUNT(DISTINCT f.Order_id) AS Order_Volume
FROM FACT_ORDER_ITEMS AS f 
LEFT JOIN DIM_ORDER AS o ON f.order_id = o.order_id 
       GROUP BY o.PAYMENT_METHOD
       ORDER BY Total_Net_Sales DESC;       

--3. Product and Category Performance

--16. Identify the top 10 products by Net Sales.

--By 2 Methods - 1st Directly in one single Query:-
SELECT p.PRODUCT_NAME,
       SUM(f.NET_SALES) AS Total_Net_Sales,
       RANK() OVER(ORDER BY SUM(f.NET_SALES) DESC) AS RANK_Products
       FROM fact_order_items AS f
       LEFT JOIN DIM_PRODUCT AS p ON f.product_id = p.product_id
       GROUP BY p.PRODUCT_NAME --(GROUP_BY IMP)
       QUALIFY RANK_Products <= '10';

--By CTE:-
WITH PRODUCTS_SALES AS (
SELECT p.PRODUCT_NAME,
       SUM(f.NET_SALES) AS Total_Net_Sales
       FROM fact_order_items AS f
       LEFT JOIN DIM_PRODUCT AS p ON f.product_id = p.product_id
       GROUP BY p.product_name
) 
SELECT *,
       RANK() OVER(ORDER BY Total_Net_Sales DESC) AS Product_Rank
       FROM PRODUCTS_SALES
       QUALIFY Product_Rank <= '10';
       
--17. Identify the top 10 products by Profit.

--By CTE:-
WITH PRODUCTS_PROFIT AS (
SELECT p.PRODUCT_NAME,
       SUM(f.PROFIT) AS Total_Profit
FROM FACT_ORDER_ITEMS AS f
LEFT JOIN DIM_PRODUCT AS p ON f.product_id = p.product_id
       GROUP BY p.PRODUCT_NAME --Here we can add a Group_By Clause
)
SELECT *, 
       RANK() OVER(ORDER BY Total_Profit DESC) AS Products_Profit_Rank --then add a desc in Order_By
       FROM PRODUCTS_PROFIT
       QUALIFY Products_Profit_Rank <= '10'; --at last add Qualift because it's a Window Function
       
--18. Compare sales, cost, profit, and profit margin across product categories.

SELECT p.CATEGORY,
       SUM(f.NET_SALES) AS Total_Net_Sales,
       SUM(f.TOTAL_COST) AS Total_Net_Cost,
       SUM(f.PROFIT) AS Total_Profit,
       ROUND(SUM(f.PROFIT)/NULLIF(SUM(f.NET_SALES),0)*100,2) AS Total_Profit_Margin
FROM FACT_ORDER_ITEMS AS f
LEFT JOIN DIM_PRODUCT AS p ON f.product_id = p.product_id
       GROUP BY p.CATEGORY
       ORDER BY Total_Net_Sales DESC;

--19. Identify categories with high sales but relatively low profit margins.

--By Direct MethodL:-
SELECT p.CATEGORY,
       SUM(f.NET_SALES) AS Total_Net_Sales,
       ROUND(SUM(f.PROFIT)/NULLIF(SUM(f.NET_SALES),0)*100,2) AS Total_Profit_Margin
FROM FACT_ORDER_ITEMS AS f
LEFT JOIN DIM_PRODUCT AS p ON f.product_id = p.product_id
       GROUP BY p.CATEGORY
       ORDER BY Total_Net_Sales DESC, Total_Profit_Margin;
       
--By CTE:-
WITH Product_Categories_Data AS (
SELECT p.CATEGORY,
       SUM(f.NET_SALES) AS Total_Net_Sales,
       ROUND(SUM(f.PROFIT)/NULLIF(SUM(f.NET_SALES),0)*100,2) AS Total_Profit_Margin
FROM FACT_ORDER_ITEMS AS f
LEFT JOIN DIM_PRODUCT AS p ON f.product_id = p.product_id
       GROUP BY p.CATEGORY
) 
 SELECT *,
        RANK() OVER(ORDER BY Total_Net_Sales DESC, Total_Profit_Margin) AS Categories_Rank
 FROM Product_Categories_Data;
 
--20. Identify products generating negative profit.

SELECT p.Product_ID, p.Product_Name,
       SUM(f.Profit) AS Total_Profit,
       SUM(f.net_sales) AS Total_Net_Sales
FROM DIM_PRODUCT AS p
LEFT JOIN FACT_ORDER_ITEMS AS f ON p.product_id = f.product_id
GROUP BY p.Product_ID, p.Product_Name
HAVING Total_Profit < 0;

--21. Analyze product quantity sold and average selling price across categories.

SELECT p.CATEGORY,
       SUM(f.Quantity) AS Qty_Sold,
       ROUND(SUM(f.Net_Sales)/NULLIF(SUM(f.Quantity),0),2) AS Avg_Selling_Price --Formula for Avg_Selling_Price = Sum(Net_Sales) / Sum(Quantity) 
FROM FACT_ORDER_ITEMS AS f 
LEFT JOIN DIM_PRODUCT AS p ON f.product_id = p.product_id
       GROUP BY p.CATEGORY
       ORDER BY Qty_Sold DESC;

--4. Discount and Profitability Analysis

--22. Analyze the relationship between discount rates and profit margins. 
/*First we need to create the CASE for the Discount_Rate then we calculate the total_net_sales, total_profit and profit_margin 
  and categories each of these based on case statement:-*/

SELECT
    CASE
        WHEN DISCOUNT_RATE = 0 THEN '0%'
        WHEN DISCOUNT_RATE <= 0.10 THEN '0-10%'
        WHEN DISCOUNT_RATE <= 0.20 THEN '10-20%'
        WHEN DISCOUNT_RATE <= 0.30 THEN '20-30%'
        ELSE 'Above 30%'
    END AS DISCOUNT_RANGE,
    SUM(NET_SALES) AS NET_SALES,
    SUM(PROFIT) AS PROFIT,
    ROUND(SUM(PROFIT) / NULLIF(SUM(NET_SALES), 0)*100, 2) AS PROFIT_MARGIN_PCT
FROM FACT_ORDER_ITEMS
GROUP BY 1 --in this group by & order by we can also use directly the name - DISCOUNT_RANGE / 1 for the First Column:-
ORDER BY 1;

--23. Compare profitability across different discount ranges.

SELECT 
      CASE 
          WHEN DISCOUNT_RATE = 0 THEN '0% Discount'
          WHEN DISCOUNT_RATE <= 0.1 THEN '0-10% Discount'
          WHEN DISCOUNT_RATE <= 0.2 THEN '10-20% Discount'
          WHEN DISCOUNT_RATE <= 0.3 THEN '20-30% Discount'
          ELSE 'Above 30% Discount'
          END AS Discount_Range,
          SUM(NET_SALES) AS Total_Net_Sales,
          SUM(PROFIT) AS Total_Profit,
          ROUND(SUM(PROFIT) / NULLIF(SUM(NET_SALES),0)*100,2) AS Profit_Margin
FROM FACT_ORDER_ITEMS
     GROUP BY Discount_Range
     ORDER BY Discount_Range;

--24. Identify products that remain profitable despite higher discounts.

SELECT p.PRODUCT_ID, p.PRODUCT_NAME,
       AVG(f.DISCOUNT_RATE) AS AVG_DISCOUNT,
       SUM(f.NET_SALES) AS NET_SALES,
       SUM(f.PROFIT) AS PROFIT
FROM FACT_ORDER_ITEMS f
JOIN DIM_PRODUCT p ON f.PRODUCT_ID = p.PRODUCT_ID
       GROUP BY p.PRODUCT_ID, p.PRODUCT_NAME
       HAVING AVG(f.DISCOUNT_RATE) > 0.1 AND SUM(f.PROFIT) > 0
       ORDER BY PROFIT DESC;

--25. Quantify the financial impact of returned and cancelled orders. - (Order_Status ko Group_By karke unpar check krna Net_Sales, Profit and Count of DISTINCT Orders):-

SELECT o.ORDER_STATUS,
       COUNT(DISTINCT o.ORDER_ID) AS Order_Numbers,
       SUM(NET_SALES) AS Total_Net_Sales,
       SUM(PROFIT) AS Total_Profit
FROM FACT_ORDER_ITEMS AS f
LEFT JOIN DIM_ORDER AS o ON f.order_id = o.order_id
       WHERE o.ORDER_STATUS IN ('Cancelled', 'Returned')
       GROUP BY o.ORDER_STATUS;

--26. Identify products or categories experiencing declining profitability over time.

WITH monthly AS (
    SELECT d.YEAR, d.MONTH_NUMBER, p.CATEGORY,
           SUM(f.PROFIT) AS PROFIT
    FROM FACT_ORDER_ITEMS f
    JOIN DIM_ORDER o ON f.ORDER_ID = o.ORDER_ID
    JOIN DIM_DATE d ON o.ORDER_DATE_KEY = d.DATE_KEY
    JOIN DIM_PRODUCT p ON f.PRODUCT_ID = p.PRODUCT_ID
    GROUP BY d.YEAR, d.MONTH_NUMBER, p.CATEGORY
),
trends AS (
    SELECT *,
           LAG(PROFIT) OVER (PARTITION BY CATEGORY ORDER BY YEAR, MONTH_NUMBER) AS PREVIOUS_MONTH_PROFIT
    FROM monthly
)
SELECT *
FROM trends
WHERE PROFIT < PREVIOUS_MONTH_PROFIT
ORDER BY CATEGORY, YEAR, MONTH_NUMBER;

--5. Customer Demographics and Segmentation

/*27. Calculate customer age using DOB and classify customers into these age groups:
•	Under 25
•	25–34
•	35–44
•	45–54
•	55 and above*/

WITH CUSTOMER_AGE AS (
SELECT CUSTOMER_ID, GENDER, DOB, 
       DATEDIFF(YEAR, DOB, CURRENT_DATE()) AS AGE
FROM DIM_CUSTOMER
) 
SELECT *,
       CASE 
           WHEN DOB IS NULL THEN 'UNKNOWN'
           WHEN AGE <= 24 THEN 'BELOW 25'
           WHEN AGE <= 34 THEN '25-34'
           WHEN AGE <= 44 THEN '34-44'
           WHEN AGE <= 54 THEN '44-54'
           ELSE '55 AND ABOVE'
           END AS AGE_GROUP
FROM CUSTOMER_AGE;

--28.	Compare Net Sales and Profit across customer age groups.

WITH CUSTOMER_AGE AS (
SELECT c.CUSTOMER_ID,
       c.DOB, 
       DATEDIFF(YEAR, DOB, CURRENT_DATE()) AS AGE,
       f.net_sales,
       f.profit
FROM DIM_CUSTOMER AS c 
LEFT JOIN DIM_ORDER AS o ON c.customer_id = o.customer_id
LEFT JOIN FACT_ORDER_ITEMS AS f ON o.order_id = f.order_id
),
CUSTOMER_AGE_GROUP AS(
SELECT *,
       CASE 
           WHEN DOB IS NULL THEN 'UNKNOWN'
           WHEN AGE <= 24 THEN 'Below 25'
           WHEN AGE <= 34 THEN '25-34'
           WHEN AGE <= 44 THEN '34-44'
           WHEN AGE <= 54 THEN '44-54'
           ELSE '55 and Above'
           END AS AGE_GROUP
FROM CUSTOMER_AGE
) 
SELECT AGE_GROUP, 
       SUM(NET_SALES) AS Total_Net_Sales,
       SUM(PROFIT) AS Total_Profit
FROM CUSTOMER_AGE_GROUP
       GROUP BY AGE_GROUP
       ORDER BY Total_Net_Sales DESC;
       
--29.	Compare the number of unique customers, orders, Net Sales, and Profit by Gender.

SELECT c.GENDER, 
       COUNT(DISTINCT c.CUSTOMER_ID) AS Num_of_Custm,
       COUNT(DISTINCT o.ORDER_ID) AS Num_of_Ords,
       SUM(f.NET_SALES) AS Total_Net_Sales,
       SUM(f.PROFIT) AS Total_Profit
FROM FACT_ORDER_ITEMS AS f 
LEFT JOIN DIM_ORDER AS o ON f.order_id = o.order_id
LEFT JOIN DIM_CUSTOMER AS c ON o.customer_id = c.customer_id
       GROUP BY c.GENDER;

--30.	Calculate Average Order Value (AOV) for each age group.
WITH CUSTOMER_AGE AS(
SELECT c.CUSTOMER_ID,
       c.DOB, 
       DATEDIFF(YEAR, DOB, CURRENT_DATE()) AS AGE,
       f.net_sales,
       o.order_id
FROM DIM_CUSTOMER AS c 
LEFT JOIN DIM_ORDER AS o ON c.customer_id = o.customer_id
LEFT JOIN FACT_ORDER_ITEMS AS f ON o.order_id = f.order_id
),
CUSTOMER_AGE_GROUP AS(
SELECT *,
       CASE 
           WHEN DOB IS NULL THEN 'UNKNOWN'
           WHEN AGE <= 24 THEN 'Below 25'
           WHEN AGE <= 34 THEN '25-34'
           WHEN AGE <= 44 THEN '34-44'
           WHEN AGE <= 54 THEN '44-54'
           ELSE '55 and Above'
           END AS AGE_GROUP
FROM CUSTOMER_AGE
),
CUSTOMER_AGE_ORDER_VALUE AS(
SELECT AGE_GROUP, 
       SUM(NET_SALES) AS Order_Value,
FROM CUSTOMER_AGE_GROUP
       GROUP BY AGE_GROUP
)
SELECT AGE_GROUP,
       AVG(Order_Value) AS Avg_Ord_Value
FROM CUSTOMER_AGE_ORDER_VALUE
       GROUP BY AGE_GROUP
       ORDER BY Avg_Ord_Value DESC;

--31.	Identify the most profitable customer segments using age and gender.

SELECT c.CUSTOMER_SEGMENT, c.GENDER,
       SUM(f.NET_SALES) AS NET_SALES,
       SUM(f.PROFIT) AS PROFIT
FROM FACT_ORDER_ITEMS f
JOIN DIM_ORDER o ON f.ORDER_ID = o.ORDER_ID
JOIN DIM_CUSTOMER c ON o.CUSTOMER_ID = c.CUSTOMER_ID
GROUP BY c.CUSTOMER_SEGMENT, c.GENDER
ORDER BY PROFIT DESC;

--32.	Compare customer segments, such as Consumer, Corporate, and other available categories.

SELECT c.CUSTOMER_SEGMENT,
       COUNT(DISTINCT c.CUSTOMER_ID) AS CUSTOMERS,
       COUNT(DISTINCT o.ORDER_ID) AS TOTAL_ORDERS,
       SUM(f.NET_SALES) AS NET_SALES,
       SUM(f.PROFIT) AS PROFIT
FROM FACT_ORDER_ITEMS f
JOIN DIM_ORDER o ON f.ORDER_ID = o.ORDER_ID
JOIN DIM_CUSTOMER c ON o.CUSTOMER_ID = c.CUSTOMER_ID
GROUP BY c.CUSTOMER_SEGMENT
ORDER BY PROFIT DESC;

--33.	Analyze customer acquisition channels to identify which channels attract the most valuable customers.

SELECT c.ACQUISITION_CHANNEL,
       COUNT(c.CUSTOMER_ID) AS Total_Customers,
       SUM(f.NET_SALES) AS Total_Net_Sales,
       SUM(f.PROFIT) AS Total_Profit
FROM FACT_ORDER_ITEMS AS f 
LEFT JOIN DIM_ORDER AS o ON f.order_id = o.order_id
LEFT JOIN DIM_CUSTOMER AS c ON o.customer_id = c.customer_id
       GROUP BY c.ACQUISITION_CHANNEL
       ORDER BY Total_Customers DESC;
       
--34.	Segment customers into one-time and repeat purchasers.

WITH customer_orders AS (
    SELECT o.CUSTOMER_ID,
           COUNT(DISTINCT o.ORDER_ID) AS TOTAL_ORDERS
    FROM DIM_ORDER o
    GROUP BY o.CUSTOMER_ID
)
SELECT CUSTOMER_ID, TOTAL_ORDERS,
       CASE
           WHEN TOTAL_ORDERS = 1 THEN 'One-Time'
           WHEN TOTAL_ORDERS > 1 THEN 'Repeat'
           ELSE 'No Orders'
       END AS CUSTOMER_TYPE
FROM customer_orders;

--35.	Calculate each customer's first purchase date, most recent purchase date, and total number of orders.

SELECT c.CUSTOMER_ID,
       MIN(d.FULL_DATE) AS First_Purchase_Date,
       MAX(d.FULL_DATE) AS Last_Purchase_Date,
       COUNT(o.ORDER_ID) AS Num_of_Total_Orders
FROM DIM_CUSTOMER AS c
LEFT JOIN DIM_ORDER AS o ON c.customer_id = o.Customer_id 
LEFT JOIN DIM_DATE AS d ON o.order_date_key = d.date_key
       GROUP BY c.CUSTOMER_ID; 

--36.	Perform RFM analysis using Recency, Frequency, and Monetary Value.

WITH rfm AS (
    SELECT o.CUSTOMER_ID,
           DATEDIFF(DAY, MAX(d.FULL_DATE), CURRENT_DATE()) AS RECENCY,
           COUNT(DISTINCT o.ORDER_ID) AS FREQUENCY,
           SUM(f.NET_SALES) AS MONETARY
    FROM DIM_ORDER o
    JOIN DIM_DATE d ON o.ORDER_DATE_KEY = d.DATE_KEY
    JOIN FACT_ORDER_ITEMS f ON o.ORDER_ID = f.ORDER_ID
    GROUP BY o.CUSTOMER_ID
)
SELECT *,
       NTILE(5) OVER (ORDER BY RECENCY DESC) AS RECENCY_SCORE,
       NTILE(5) OVER (ORDER BY FREQUENCY) AS FREQUENCY_SCORE,
       NTILE(5) OVER (ORDER BY MONETARY) AS MONETARY_SCORE
FROM rfm;

--6. Advanced Business Analysis

--38.	Identify the products and categories contributing the most to annual sales and profit.

SELECT d.YEAR, 
       p.CATEGORY,
       p.PRODUCT_NAME, 
       SUM(f.NET_SALES) AS Total_Sales,
       SUM(f.PROFIT) AS Total_Profit
FROM FACT_ORDER_ITEMS AS f 
LEFT JOIN DIM_ORDER AS o ON f.ORDER_ID = o.ORDER_ID
LEFT JOIN DIM_PRODUCT AS p ON f.PRODUCT_ID = p.PRODUCT_ID
LEFT JOIN DIM_DATE AS d ON o.ORDER_DATE_KEY = d.DATE_KEY
       GROUP BY d.YEAR, p.CATEGORY, p.PRODUCT_NAME;   

--39.	Find the top three most profitable products within each category.

WITH product_profit AS (
    SELECT p.CATEGORY, p.PRODUCT_ID, p.PRODUCT_NAME,
           SUM(f.PROFIT) AS PROFIT
    FROM FACT_ORDER_ITEMS f
    JOIN DIM_PRODUCT p ON f.PRODUCT_ID = p.PRODUCT_ID
    GROUP BY p.CATEGORY, p.PRODUCT_ID, p.PRODUCT_NAME
),
ranked AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY CATEGORY
               ORDER BY PROFIT DESC
           ) AS PRODUCT_RANK
    FROM product_profit
)
SELECT *
FROM ranked
WHERE PRODUCT_RANK <= 3
ORDER BY CATEGORY, PRODUCT_RANK;

--40.	Calculate month-over-month (MoM) sales and profit growth.

WITH monthly AS (
    SELECT d.YEAR, d.MONTH_NUMBER,
           SUM(f.NET_SALES) AS SALES,
           SUM(f.PROFIT) AS PROFIT
    FROM FACT_ORDER_ITEMS f
    JOIN DIM_ORDER o ON f.ORDER_ID = o.ORDER_ID
    JOIN DIM_DATE d ON o.ORDER_DATE_KEY = d.DATE_KEY
    GROUP BY d.YEAR, d.MONTH_NUMBER
),
previous_values AS (
    SELECT *,
           LAG(SALES) OVER (ORDER BY YEAR, MONTH_NUMBER) AS PREV_SALES,
           LAG(PROFIT) OVER (ORDER BY YEAR, MONTH_NUMBER) AS PREV_PROFIT
    FROM monthly
)
SELECT *,
       ROUND(100.0 * (SALES - PREV_SALES) /
             NULLIF(PREV_SALES, 0), 2) AS SALES_MOM_PCT,
       ROUND(100.0 * (PROFIT - PREV_PROFIT) /
             NULLIF(PREV_PROFIT, 0), 2) AS PROFIT_MOM_PCT
FROM previous_values
ORDER BY YEAR, MONTH_NUMBER;

--41.	Calculate customer revenue contribution and identify high-value customers.

WITH customer_sales AS (
    SELECT o.CUSTOMER_ID,
           SUM(f.NET_SALES) AS NET_SALES,
           SUM(f.PROFIT) AS PROFIT
    FROM FACT_ORDER_ITEMS f
    JOIN DIM_ORDER o ON f.ORDER_ID = o.ORDER_ID
    GROUP BY o.CUSTOMER_ID
)
SELECT *,
       ROUND(100.0 * NET_SALES / NULLIF(SUM(NET_SALES) OVER (), 0), 2)
             AS REVENUE_CONTRIBUTION_PCT
FROM customer_sales
ORDER BY NET_SALES DESC;

--42.	Identify inactive or lapsed customers based on their most recent purchase date.

WITH last_purchase AS (
    SELECT o.CUSTOMER_ID,
           MAX(d.FULL_DATE) AS LAST_PURCHASE_DATE
    FROM DIM_ORDER o
    JOIN DIM_DATE d ON o.ORDER_DATE_KEY = d.DATE_KEY
    GROUP BY o.CUSTOMER_ID
)
SELECT c.CUSTOMER_ID, c.FIRST_NAME, c.LAST_NAME,
       lp.LAST_PURCHASE_DATE
FROM DIM_CUSTOMER c
LEFT JOIN last_purchase lp ON c.CUSTOMER_ID = lp.CUSTOMER_ID
WHERE lp.LAST_PURCHASE_DATE IS NULL
   OR lp.LAST_PURCHASE_DATE < DATEADD(DAY, -90, CURRENT_DATE())
ORDER BY lp.LAST_PURCHASE_DATE;

--43.	Compare sales and profit margins across shipping states and cities.

SELECT o.SHIPPING_STATE, o.SHIPPING_CITY,
       SUM(f.NET_SALES) AS Total_Sales, 
       SUM(f.PROFIT) AS Total_Profit
FROM FACT_ORDER_ITEMS AS f
LEFT JOIN DIM_ORDER AS o ON f.order_id = o.ORDER_ID
       GROUP BY o.SHIPPING_STATE, o.SHIPPING_CITY
       ORDER BY Total_Profit DESC;