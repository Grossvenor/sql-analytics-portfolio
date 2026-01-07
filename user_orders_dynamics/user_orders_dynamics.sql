
Кейс: User Orders Dynamics & Cancellation Rate
SELECT
    user_id,
    order_id,
    action,
    time,

  -- Накопительное количество созданных заказов 
    COUNT(*) FILTER (WHERE action = 'create_order')
        OVER (
            PARTITION BY user_id
            ORDER BY time
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS created_orders,

  ==Накопительное количество отменённых заказов 
    COUNT(*) FILTER (WHERE action = 'cancel_order')
        OVER (
            PARTITION BY user_id
            ORDER BY time
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS canceled_orders

FROM user_actions
ORDER BY user_id, time;
