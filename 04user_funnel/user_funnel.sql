/*
Воронка пользователей (Funnel / Conversion)

Цель:
Построить воронку действий пользователей и посчитать конверсию между этапами.

Этапы воронки:
1. Пользователь зашёл в сервис (любое действие)
2. Создал заказ
3. Отменил заказ
*/

WITH user_events AS (
    -- Все действия пользователей
    SELECT
        user_id,
        action
    FROM user_actions
),

funnel_flags AS (
    -- Флаги прохождения этапов воронки
    SELECT
        user_id,
        MAX(CASE WHEN action IS NOT NULL THEN 1 ELSE 0 END) AS step_visit,
        MAX(CASE WHEN action = 'create_order' THEN 1 ELSE 0 END) AS step_create_order,
        MAX(CASE WHEN action = 'cancel_order' THEN 1 ELSE 0 END) AS step_cancel_order
    FROM user_events
    GROUP BY user_id
)

SELECT
    COUNT(*) FILTER (WHERE step_visit = 1) AS visited_users,
    COUNT(*) FILTER (WHERE step_create_order = 1) AS created_order_users,
    COUNT(*) FILTER (WHERE step_cancel_order = 1) AS canceled_order_users,

    -- Конверсии
    ROUND(
        COUNT(*) FILTER (WHERE step_create_order = 1)::numeric
        / COUNT(*) FILTER (WHERE step_visit = 1),
        3
    ) AS visit_to_create_conversion,

    ROUND(
        COUNT(*) FILTER (WHERE step_cancel_order = 1)::numeric
        / COUNT(*) FILTER (WHERE step_create_order = 1),
        3
    ) AS create_to_cancel_conversion

FROM funnel_flags;
