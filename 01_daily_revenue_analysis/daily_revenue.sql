-- Кейс: Дневная выручка и её прирост
-- Цель: посчитать дневную выручку по неотменённым заказам
--       и рассчитать абсолютный и процентный прирост по дням

WITH uncanceled_orders AS (
    -- отбираем заказы, которые не были отменены
    SELECT DISTINCT order_id
    FROM user_actions
    WHERE order_id NOT IN (
        SELECT order_id
        FROM user_actions
        WHERE action = 'cancel_order'
    )
),

orders_expanded AS (
    -- разворачиваем массив товаров в заказах
    
    SELECT
        o.order_id,
        o.creation_time::date AS date,
        UNNEST(o.product_ids) AS product_id
    FROM orders o
    WHERE o.order_id IN (SELECT order_id FROM uncanceled_orders)
),

prices AS (
    -- добавляем цену каждого товара
    SELECT
        e.order_id,
        e.date,
        p.price
    FROM orders_expanded e
    JOIN products p
        ON e.product_id = p.product_id
),

revenue_by_day AS (
    -- считаем дневную выручку
    SELECT
        date,
        SUM(price) AS daily_revenue
    FROM prices
    GROUP BY date
),

final AS (
  -- считаем прирост выручки с помощью LAG
    SELECT
        date,
        daily_revenue,
        COALESCE(
            daily_revenue - LAG(daily_revenue) OVER (ORDER BY date),
            0
        ) AS revenue_growth_abs,
        COALESCE(
            ROUND(
                (daily_revenue - LAG(daily_revenue) OVER (ORDER BY date))
                / LAG(daily_revenue) OVER (ORDER BY date) * 100,
                1
            ),
            0
        ) AS revenue_growth_percentage
    FROM revenue_by_day
)

-- Финальный результат
SELECT *
FROM final
ORDER BY date;
