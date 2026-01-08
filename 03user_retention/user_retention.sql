
--Retention и повторные заказы пользователей

--Цель:
--Понять, как часто пользователи возвращаются и через какое время совершают повторные заказы.
--Используются оконные функции LAG и работа с датами.

WITH created_orders AS (
    -- Берём только события создания заказов
    SELECT
        user_id,
        order_id,
        time::date AS order_date
    FROM user_actions
    WHERE action = 'create_order'
),

orders_with_lag AS (
    -- Добавляем дату предыдущего заказа пользователя
    SELECT
        user_id,
        order_id,
        order_date,
        LAG(order_date) OVER (
            PARTITION BY user_id
            ORDER BY order_date
        ) AS previous_order_date
    FROM created_orders
)

SELECT
    user_id,
    order_id,
    order_date,
    previous_order_date,
    -- Разница между заказами в днях
    order_date - previous_order_date AS days_between_orders
FROM orders_with_lag
ORDER BY user_id, order_date;
