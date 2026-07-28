* Проект «Секреты Тёмнолесья»
 * Цель проекта: изучить влияние характеристик игроков и их игровых персонажей 
 * на покупку внутриигровой валюты «райские лепестки», а также оценить 
 * активность игроков при совершении внутриигровых покупок
 * 
 * Автор: Новикова Елизавета Дмитриевна 
 * Дата: 17.01.2026
*/

-- Часть 1. Исследовательский анализ данных
-- Задача 1. Исследование доли платящих игроков

-- 1.1. Доля платящих пользователей по всем данным:
WITH payers AS (
  SELECT id
  FROM fantasy.users
  WHERE payer = '1'
)
SELECT
  COUNT(DISTINCT p.id) * 1.0 / NULLIF(COUNT(DISTINCT u.id), 0) AS paying_share,
  COUNT(DISTINCT p.id) AS paying_users,
  COUNT(DISTINCT u.id) AS all_users
FROM fantasy.users u
LEFT JOIN payers p
  ON p.id = u.id;

paying_share          |paying_users|all_users|
----------------------+------------+---------+
0.17687044206356351850|        3929|    22214|


-- 1.2. Доля платящих пользователей в разрезе расы персонажа:
WITH payers AS (
    SELECT DISTINCT id
    FROM fantasy.users
    WHERE payer = '1'
)
SELECT
    u.race_id,
    COUNT(DISTINCT p.id) AS paying_users,
    COUNT(DISTINCT u.id) AS all_users,
    COUNT(DISTINCT p.id) * 1.0 / NULLIF(COUNT(DISTINCT u.id), 0) AS paying_share
FROM fantasy.users u
LEFT JOIN payers p ON p.id = u.id
GROUP BY u.race_id
ORDER BY u.race_id;

race_id|paying_users|all_users|paying_share          |
-------+------------+---------+----------------------+
B1     |         427|     2501|0.17073170731707317073|
C5     |         626|     3562|0.17574396406513194834|
I6     |         229|     1327|0.17256970610399397136|
K3     |         636|     3619|0.17573915446255871788|
K4     |         659|     3648|0.18064692982456140351|
R2     |        1114|     6328|0.17604298356510745891|
T7     |         238|     1229|0.19365337672904800651|

-- Задача 2. Исследование внутриигровых покупок
-- 2.1. Статистические показатели по полю amount:
SELECT COUNT(amount) AS count_amount,-- общее число покупок
       SUM(amount) AS sum_amount, -- общая сумма
       MAX(amount) AS max_amount, -- максимальная 
       MIN(amount) AS min_amount,
       AVG(amount) AS avg_amount,
       PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY amount) AS median_amount,  -- медиана
       STDDEV_SAMP(amount) AS stddev_sample -- выборочное стандартное отклонение
FROM fantasy.events

count_amount|sum_amount|max_amount|min_amount|avg_amount       |median_amount    |stddev_sample    |
------------+----------+----------+----------+-----------------+-----------------+-----------------+
     1307678| 686615040|  486615.1|       0.0|525.6919663589833|74.86000061035156|2517.345444427788|
     
-- 2.2: Аномальные нулевые покупки:
SELECT COUNT(amount) AS count_zero_amount,-- количество покупок с нулевой стоимостью
             CASE WHEN COUNT(*) = 0 THEN NULL
       ELSE (COUNT(*) FILTER (WHERE amount = 0))::numeric / COUNT(*) END AS zero_amount_share
FROM fantasy.events

count_zero_amount|zero_amount_share     |
-----------------+----------------------+
          1307678|0.00069359582404842782|

-- 2.3: Популярные эпические предметы:
WITH epic_sales AS (
    SELECT
        e.item_code,
        i.game_items AS item_name,
        COUNT(e.transaction_id) AS sales_cnt          -- кол-во транзакций
    FROM fantasy.events AS e
    JOIN fantasy.items AS i
        ON e.item_code = i.item_code                  -- связываем покупки с предметами
    WHERE e.amount > 0                                 -- фильтрация покупок с нулевой стоимостью
    GROUP BY e.item_code, i.game_items
),
total_epic_sales AS (
    SELECT SUM(sales_cnt) AS total_sales
    FROM epic_sales
),
epic_item_buyers AS (
    SELECT
        e.item_code,
        COUNT(DISTINCT e.id) AS buyers_cnt            -- уникальные игроки, купившие предмет
    FROM fantasy.events AS e
    WHERE e.amount > 0
    GROUP BY e.item_code
),
total_buyers AS (
    SELECT COUNT(DISTINCT id) AS total_players        -- все внутриигровые покупатели
    FROM fantasy.events
    WHERE amount > 0
)
SELECT
    es.item_name              AS item_id,             -- эпический предмет
    es.sales_cnt              AS sales_absolute,      -- абсолютное кол-во продаж
    es.sales_cnt * 1.0 / tes.total_sales AS sales_share,      -- доля продаж предмета от всех
    eb.buyers_cnt,                                    -- число уникальных покупателей предмета
    eb.buyers_cnt * 1.0 / tb.total_players AS buyers_share    -- доля игроков, купивших предмет
FROM epic_sales AS es
JOIN epic_item_buyers eb
    ON es.item_code = eb.item_code
CROSS JOIN total_epic_sales tes
CROSS JOIN total_buyers tb
ORDER BY eb.buyers_cnt DESC, es.sales_cnt DESC;

item_id                  |sales_absolute|sales_share               |buyers_cnt|buyers_share              |
-------------------------+--------------+--------------------------+----------+--------------------------+
Book of Legends          |       1004516|    0.76870086648693611964|     12194|    0.88413573085846867749|
Bag of Holding           |        271875|    0.20805098980617108889|     11968|    0.86774941995359628770|
Necklace of Wisdom       |         13828|    0.01058180813623810140|      1627|    0.11796693735498839907|
Gems of Insight          |          3833|    0.00293318416157077254|       926|    0.06714037122969837587|
Treasure Map             |          3084|    0.00236001564160820832|       753|    0.05459686774941995360|
Silver Flask             |           795|    0.00060836979088149339|       633|    0.04589617169373549884|
Amulet of Protection     |          1078|    0.00082493413153490550|       445|    0.03226508120649651972|
Glowing Pendant          |           563|    0.00043083294624689406|       354|    0.02566705336426914153|
Strength Elixir          |           580|    0.00044384211158649832|       331|    0.02399941995359628770|
Ring of Wisdom           |           379|    0.00029002786257117735|       310|    0.02247679814385150812|
Gauntlets of Might       |           514|    0.00039333594026803472|       281|    0.02037412993039443155|
Potion of Speed          |           375|    0.00028696688249127047|       231|    0.01674883990719257541|
Ring of Invisibility     |           252|    0.00019284174503413375|       184|    0.01334106728538283063|

-- Часть 2. Решение ad hoc-задачи
-- Задача: Зависимость активности игроков от расы персонажа:

with purchases as (
-- Все игроки и их покупки (если есть), с отбором только платных покупок
select
	u.id,
	u.race_id as race,
	u.payer,
	e.amount
from
	fantasy.users as u
left join fantasy.events as e
        on
	u.id = e.id
	and e.amount > 0
	-- фильтрация покупок с нулевой стоимостью
	-- AND e.item_rarity = 'epic' -- (пример) здесь можно добавить фильтр по эпичности
),
per_race_base as (
-- Базовые агрегаты по каждой расе
select
	race,
	COUNT(distinct id) as total_players,
	-- общее количество зарегистрированных игроков
	COUNT(distinct case when amount > 0 then id end) as players_with_purchases,
	-- количество игроков, которые совершают внутриигровые покупки (любые, amount>0)
	COUNT(distinct case when payer=1 and amount > 0 then id end) as payers 
	-- количество платящих игроков (по флагу payer)
from
	purchases
group by
	race
),
per_race_player_stats as (
-- Статы по каждому игроку в разрезе расы
select
	race,
	id,
	COUNT(*) filter (
where
	amount > 0) as cnt_purchases,
	-- кол-во покупок игрока
	SUM(amount) filter (
where
	amount > 0) as total_amount,
	-- суммарная стоимость покупок игрока
         case
		when COUNT(*) filter (
	where
		amount > 0) > 0
                then SUM(amount) * 1.0 
                     / COUNT(*) filter (
	where
		amount > 0)
		-- средняя стоимость одной покупки у игрока
	end as avg_purchase_amount_for_player
from
	purchases
group by
	race,
	id
),
per_race_averages as (
-- Средние метрики по покупающим игрокам в разрезе расы
select
	race,
	AVG(cnt_purchases * 1.0) as avg_purchases_per_paying_player,	-- среднее количество покупок на одного игрока, совершившего внутриигровые покупки
	AVG(total_amount * 1.0)/ AVG(cnt_purchases * 1.0) as avg_purchase_amount_per_paying_player1,  --общеe среднee
	AVG(avg_purchase_amount_for_player) as avg_purchase_amount_per_paying_player,  --среднее для анализа поведения игроков как индивидуальных элементов в совокупности
    AVG(total_amount * 1.0) as avg_total_amount_per_paying_player
	-- средняя суммарная стоимость всех покупок на одного игрока, совершившего внутриигровые покупки
from
	per_race_player_stats
where
	cnt_purchases > 0
	-- только игроки, которые что‑то купили
group by
	race
	)
SELECT
    b.race,
    b.total_players,  -- 1) общее количество зарегистрированных игроков
    b.players_with_purchases,  -- 2) количество игроков, которые совершают внутриигровые покупки
    b.players_with_purchases * 1.0 / NULLIF(b.total_players, 0) -- 2) их доля от общего количества зарегистрированных игроков
        AS share_players_with_purchases,
    b.payers * 1.0 / NULLIF(b.players_with_purchases, 0) -- 3) доля платящих игроков среди игроков, которые совершают внутриигровые покупки
        AS share_payers_among_players_with_purchases,
    a.avg_purchases_per_paying_player,    -- 4) среднее количество покупок на одного игрока, совершившего внутриигровые покупки
    a.avg_purchase_amount_per_paying_player,-- 5) средняя стоимость одной покупки на одного игрока, совершившего внутриигровые покупки
    a.avg_purchase_amount_per_paying_player1,
    a.avg_total_amount_per_paying_player  -- 6) средняя суммарная стоимость всех покупок на одного игрока, совершившего внутриигровые покупки
FROM per_race_base AS b
LEFT JOIN per_race_averages AS a
    ON b.race = a.race
ORDER BY b.race;

race|total_players|players_with_purchases|share_players_with_purchases|share_payers_among_players_with_purchases|avg_purchases_per_paying_player|avg_purchase_amount_per_paying_player|avg_purchase_amount_per_paying_player1|avg_total_amount_per_paying_player|
----+-------------+----------------------+----------------------------+-----------------------------------------+-------------------------------+-------------------------------------+--------------------------------------+----------------------------------+
B1  |         2501|                  1543|      0.61695321871251499400|                   0.16267012313674659754|            78.7906675307841866|                     791.837803632386|                     682.3352670368272|                  53761.6511696275|
C5  |         3562|                  2229|      0.62577203818079730488|                   0.18214445939883355765|            82.1018393898609242|                    781.0536407915329|                     761.5015204646742|                 62520.67552832558|
I6  |         1327|                   820|      0.61793519216277317257|                   0.16707317073170731707|           106.8048780487804878|                    775.5473875688749|                     455.6781464837871|                 48668.64886469521|
K3  |         3619|                  2276|      0.62890301188173528599|                   0.17398945518453427065|            81.7381370826010545|                     709.443919996442|                     510.9003221660996|                 41760.04056875769|
K4  |         3648|                  2266|      0.62116228070175438596|                   0.17696381288614298323|            86.1288614298323036|                    699.8950929524863|                     552.9032343628076|                47620.926056540346|
R2  |         6328|                  3921|      0.61962705436156763590|                   0.18005610813567967355|           121.4021933180311145|                    733.6179975306599|                    403.13103540314637|                 48940.99189251082|
T7  |         1229|                   737|      0.59967453213995117982|                   0.19945725915875169607|            77.8697421981004071|                    735.4793610031825|                     529.0550594739536|                 41197.38108983745|
