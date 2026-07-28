/* Проект первого модуля: анализ данных для агентства недвижимости
 * Часть 2. Решаем ad hoc задачи
 *
 * Автор:Новикова Елизавета Дмитриевна 
 * Дата:16.03.2026
*/

-- Задача 1: Время активности объявлений
-- Определим аномальные значения (выбросы) по значению перцентилей:
 
WITH limits AS (
    SELECT  
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY total_area) AS total_area_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY rooms) AS rooms_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY balcony) AS balcony_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY ceiling_height) AS ceiling_height_limit_h,
        PERCENTILE_DISC(0.01) WITHIN GROUP (ORDER BY ceiling_height) AS ceiling_height_limit_l
    FROM real_estate.flats     
),
-- Найдём id объявлений, которые не содержат выбросы:
filtered_id AS(
    SELECT id
    FROM real_estate.flats  
    WHERE 
        total_area < (SELECT total_area_limit FROM limits)
        AND (rooms < (SELECT rooms_limit FROM limits) OR rooms IS NULL)
        AND (balcony < (SELECT balcony_limit FROM limits) OR balcony IS NULL)
        AND ((ceiling_height < (SELECT ceiling_height_limit_h FROM limits)
            AND ceiling_height > (SELECT ceiling_height_limit_l FROM limits)) OR ceiling_height IS NULL)
    )
-- Выведем объявления без выбросов:
SELECT 
CASE
    WHEN c.city = 'Санкт-Петербург' THEN 'Санкт-Петербург'
    ELSE 'Ленинградская область'
  END AS region,
COUNT(f.id) AS count_flats,-- количество квартир 
ROUND(AVG(a.last_price/f.total_area)::numeric,2) AS avg_price_form2,
ROUND(AVG(f.total_area)::numeric,2) AS avg_area,
AVG(f.rooms) AS avg_rooms,-- количество комнат в квартире 
AVG(f.balcony) AS avg_balcony, -- количество балконов 
CASE WHEN a.days_exposition IS NULL THEN 'non category'
WHEN a.days_exposition BETWEEN 1 AND 30 THEN '1-30 days'
WHEN a.days_exposition BETWEEN 31 AND 90 THEN '31-90 days'
WHEN a.days_exposition BETWEEN 91 AND 180 THEN '91-180 days'
WHEN a.days_exposition>=181 THEN '181+ days'
END AS duration_category
FROM real_estate.flats AS f
JOIN real_estate.advertisement AS a ON a.id=f.id
JOIN real_estate.city AS c ON c.city_id = f.city_id
WHERE EXTRACT (YEAR FROM a.first_day_exposition) BETWEEN 2017 AND 2018
AND f.id IN (SELECT * FROM filtered_id)
GROUP BY region,duration_category 
ORDER BY
  count_flats DESC,
  region;

region               |count_flats|avg_price_form2|avg_area|avg_rooms         |avg_balcony       |duration_category|
---------------------+-----------+---------------+--------+------------------+------------------+-----------------+
Санкт-Петербург      |       2769|      110458.68|   56.47|1.9115204044781510|1.0754448398576513|31-90 days       |
Санкт-Петербург      |       1893|      113477.58|   61.14|2.0264131008980454| 1.149522799575822|91-180 days      |
Санкт-Петербург      |       1885|      116893.01|   65.06|2.1172413793103448|1.4635658914728682|181+ days        |
Санкт-Петербург      |       1737|      108703.68|   54.60|1.8750719631548647|1.0263653483992468|1-30 days        |
Ленинградская область|       1644|       70477.99|   49.46|1.7427007299270073|1.1367088607594937|31-90 days       |
Ленинградская область|        993|       68858.23|   52.67|1.8751258811681772|1.3932038834951457|181+ days        |
Ленинградская область|        947|       70678.04|   50.22|1.7560718057022175|1.1862955032119915|91-180 days      |
Ленинградская область|        729|       75518.71|   47.96|1.6131687242798354|1.0874704491725768|1-30 days        |
Санкт-Петербург      |        580|      133195.48|   79.70|2.4655172413793103|1.5827814569536425|non category     |
Ленинградская область|        306|       65716.53|   59.35|2.1732026143790850|1.4845360824742269|non category     |


WITH limits AS (
    SELECT  
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY total_area) AS total_area_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY rooms) AS rooms_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY balcony) AS balcony_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY ceiling_height) AS ceiling_height_limit_h,
        PERCENTILE_DISC(0.01) WITHIN GROUP (ORDER BY ceiling_height) AS ceiling_height_limit_l
    FROM real_estate.flats     
),
-- Находим id объявлений без выбросов
filtered_id AS (
    SELECT id
    FROM real_estate.flats  
    WHERE 
        total_area < (SELECT total_area_limit FROM limits)
        AND (rooms < (SELECT rooms_limit FROM limits) OR rooms IS NULL)
        AND (balcony < (SELECT balcony_limit FROM limits) OR balcony IS NULL)
        AND ((ceiling_height < (SELECT ceiling_height_limit_h FROM limits)
            AND ceiling_height > (SELECT ceiling_height_limit_l FROM limits)) OR ceiling_height IS NULL)
),
filtred_base_data AS (
    SELECT 
        f.total_area,
        f.id AS id,
        -- Месяц публикации
        EXTRACT (MONTH FROM a.first_day_exposition) AS month_number,
        -- Месяц снятия (вычисляется только если есть days_exposition)
        EXTRACT (MONTH FROM (a.first_day_exposition + a.days_exposition * INTERVAL '1 day')) AS monthof_end_date,
        (a.last_price / f.total_area) AS price_form2
    FROM real_estate.advertisement AS a 
    JOIN real_estate.flats AS f ON f.id = a.id
    JOIN real_estate.city AS c ON c.city_id = f.city_id
    -- Оставляем только те ID, что вошли в лимиты
    JOIN filtered_id ON f.id = filtered_id.id
    WHERE EXTRACT (YEAR FROM a.first_day_exposition) BETWEEN 2015 AND 2018
      AND a.days_exposition IS NOT NULL -- Важно для расчета даты снятия
),
stats_where_pub AS (
    SELECT 
        month_number AS month,
        COUNT(id) AS count_pub,
        AVG(price_form2) AS avg_price_form2_pub,
        AVG(total_area) AS avg_total_area_pub
    FROM filtred_base_data
    GROUP BY month_number
),
stats_where_end AS (
    SELECT 
        monthof_end_date AS month,
        COUNT(id) AS count_end
    FROM filtred_base_data
    GROUP BY monthof_end_date
)
SELECT 
    p.month,
    p.count_pub,
    e.count_end,
    ROUND(p.avg_price_form2_pub::NUMERIC, 2) AS avg_price_form2,
    ROUND(p.avg_total_area_pub::NUMERIC, 2) AS avg_total_area
FROM stats_where_pub AS p
JOIN stats_where_end AS e ON p.month = e.month
ORDER BY p.month;

month|count_pub|count_end|avg_price_form2|avg_total_area|
-----+---------+---------+---------------+--------------+
    1|      858|     1513|       99464.77|         56.79|
    2|     1625|     1240|       95869.57|         57.36|
    3|     1303|     1307|       96464.36|         57.05|
    4|     1155|     1243|       97577.66|         58.05|
    5|     1002|      878|       98427.02|         57.11|
    6|     1409|      925|       98173.15|         56.44|
    7|     1285|     1317|       98430.81|         56.83|
    8|     1308|     1367|       99435.40|         55.97|
    9|     1507|     1468|      101425.88|         58.01|
   10|     1572|     1617|       98199.48|         56.70|
   11|     1726|     1565|       98647.08|         56.71|
   12|     1139|     1449|       97392.94|         55.86|



