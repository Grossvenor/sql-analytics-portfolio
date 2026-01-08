
--Кейс: User Order Intervals
--Цель: рассчитать временные интервалы между заказами пользователя
--Уровень агрегации: 1 строка = 1 заказ


WITH orders AS (
    SELECT
        user_id,
        order_id,
        time AS order_time
    FROM user_actions
    WHERE action = 'create_order'
),

orders_with_lag AS (
    SELECT
        user_id,
        order_id,
        order_time,
        LAG(order_time) OVER (
            PARTITION BY user_id
            ORDER BY order_time
        ) AS prev_order_time
    FROM orders
)

SELECT
    user_id,
    order_id,
    order_time,
    prev_order_time,

  -- Интервал между заказами в минутах
    EXTRACT(EPOCH FROM (order_time - prev_order_time)) / 60
        AS minutes_since_prev_order

FROM orders_with_lag
ORDER BY user_id, order_time;
