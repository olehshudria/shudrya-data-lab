-- Завдання 1. Покупці за країнами
SELECT country,
       COUNT(id) AS users_count
  FROM `bigquery-public-data.thelook_ecommerce.users` 
 GROUP BY country
 ORDER BY COUNT(id) DESC
 LIMIT 10
 ;

 -- Завдання 2. Виторг за категоріями товарів
SELECT products.category,
       COUNT(order_items.product_id) AS items_sold,
       ROUND(SUM(order_items.sale_price), 2) AS revenue
 FROM `bigquery-public-data.thelook_ecommerce.order_items` AS order_items
 JOIN `bigquery-public-data.thelook_ecommerce.products` AS products
 ON order_items.product_id = products.id
GROUP BY products.category
ORDER BY revenue DESC
;

-- Завдання 3. Замовлення за окремими статусами
SELECT status, 
       COUNT (order_id) AS orders_count
  FROM `bigquery-public-data.thelook_ecommerce.orders`
  WHERE status IN ("Complete", "Shipped")
  GROUP BY status
  ORDER BY status
  ;

-- Завдання 4. Продажі по місяцях
SELECT FORMAT_DATE('%Y-%m', DATE(created_at)) AS month,
       COUNT(product_id) AS items_sold, 
       ROUND(AVG(sale_price), 2) AS avg_price
  FROM `bigquery-public-data.thelook_ecommerce.order_items`
  WHERE EXTRACT(YEAR FROM created_at) = 2024
  OR EXTRACT(YEAR FROM created_at) = 2025
  GROUP BY FORMAT_DATE('%Y-%m', DATE(created_at))
  ORDER BY month
;

-- Завдання 5. Тільки великі категорії
SELECT products.category,
       ROUND(SUM(order_items.sale_price), 2) AS revenue
  FROM `bigquery-public-data.thelook_ecommerce.order_items` AS order_items
  LEFT JOIN `bigquery-public-data.thelook_ecommerce.products` AS products
    ON order_items.product_id = products.id
 GROUP BY products.category
HAVING SUM(order_items.sale_price) > 100000
ORDER BY revenue DESC
;

-- Завдання 6. Топ-10 товарів за виторгом
SELECT products.name AS product_name, 
       products.brand, 
       COUNT(order_items.product_id) AS times_sold, 
       ROUND(SUM(order_items.sale_price), 2) AS revenue
  FROM `bigquery-public-data.thelook_ecommerce.order_items` AS order_items
  LEFT JOIN `bigquery-public-data.thelook_ecommerce.products` AS products
    ON order_items.product_id = products.id

 GROUP BY products.name,
          products.brand
ORDER BY revenue DESC
LIMIT 10
;

-- Завдання 7. Відсоток повернень за категоріями
SELECT products.category AS category,
       COUNT(order_items.product_id) AS total_items, 
       COUNTIF(returned_at IS NOT NULL) AS returned_items,
       ROUND(COUNTIF(returned_at IS NOT NULL) / COUNT(order_items.product_id) * 100, 1) return_rate_pct
  FROM `bigquery-public-data.thelook_ecommerce.order_items` AS order_items
  LEFT JOIN `bigquery-public-data.thelook_ecommerce.products` AS products
    ON order_items.product_id = products.id

 GROUP BY products.category
 ORDER BY return_rate_pct DESC
 ;

 -- Завдання 8. Середній вік покупця за категорією
 WITH cte AS (
 SELECT DISTINCT products.category AS category,
        users.id AS user_id, 
        users.age AS user_age
  FROM `bigquery-public-data.thelook_ecommerce.order_items` AS order_items
  LEFT JOIN `bigquery-public-data.thelook_ecommerce.products` AS products
    ON order_items.product_id = products.id
  LEFT JOIN `bigquery-public-data.thelook_ecommerce.users` AS users
    ON order_items.user_id = users.id  )
SELECT category,
       COUNT(DISTINCT user_id) AS buyers,
       ROUND(AVG(user_age), 1) AS avg_age
  FROM cte 
  GROUP BY category
  ORDER BY avg_age DESC
;

-- Завдання 9. Рейтинг місяців за виторгом
SELECT FORMAT_DATE('%Y-%m', DATE(created_at)) AS month,
       ROUND(SUM(sale_price), 2) AS revenue, 
       RANK() OVER (ORDER BY SUM(sale_price) DESC) AS revenue_rank
  FROM `bigquery-public-data.thelook_ecommerce.order_items`
  WHERE EXTRACT(YEAR FROM created_at) = 2025
  GROUP BY FORMAT_DATE('%Y-%m', DATE(created_at))
  ORDER BY revenue_rank
;

-- Завдання 10. Приріст виторгу до попереднього місяця
WITH cte AS (
SELECT FORMAT_DATE('%Y-%m', DATE(created_at)) AS month,
       ROUND(SUM(sale_price), 2) AS revenue
  FROM `bigquery-public-data.thelook_ecommerce.order_items`
  WHERE EXTRACT(YEAR FROM created_at) = 2025
  GROUP BY FORMAT_DATE('%Y-%m', DATE(created_at))
)
SELECT month,
       revenue, 
       LAG(revenue) OVER (ORDER BY month) AS prev_month_revenue,
       ROUND((revenue - LAG(revenue) OVER (ORDER BY month)) / LAG(revenue) OVER (ORDER BY month) * 100, 1) AS growth_pct 
  FROM cte
ORDER BY month
;

-- Завдання 11. Топ-3 товари в кожній категорії
SELECT products.category,
       products.name AS product_name, 
       ROUND(SUM(order_items.sale_price), 2) AS revenue,
       ROW_NUMBER() OVER (PARTITION BY products.category ORDER BY SUM(order_items.sale_price) DESC) AS rank_in_category
  FROM `bigquery-public-data.thelook_ecommerce.order_items` AS order_items
  LEFT JOIN `bigquery-public-data.thelook_ecommerce.products` AS products
    ON order_items.product_id = products.id

 GROUP BY products.name,
          products.category
QUALIFY rank_in_category <= 3
ORDER BY products.category, rank_in_category
;

