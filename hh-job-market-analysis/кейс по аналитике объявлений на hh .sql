---Определите диапазон заработных плат:
select 
---средние значения:
AVG(ROUND(salary_from,2)) as avg_salary_from,
AVG(ROUND(salary_to,2)) as avg_salary_to,
--минимумы и максимумы нижних и верхних порогов зарплаты:
MIN(ROUND(salary_from,2)) as min_salary_from,
MAX(ROUND(salary_from,2)) as max_salary_from,
MIN(ROUND(salary_to,2)) as min_salary_to,
MAX(ROUND(salary_to,2)) as max_salary_to

FROM public.parcing_table;

avg_salary_from    |avg_salary_to      |min_salary_from|max_salary_from|min_salary_to|max_salary_to|
-------------------+-------------------+---------------+---------------+-------------+-------------+
109525.086206896552|153846.714912280702|          50.00|      398000.00|     25000.00|    497500.00|



--регионы, в которых сосредоточено наибольшее количество вакансий:
select 
area,
COUNT(*) as num_vacancies
FROM public.parcing_table
group by area
ORDER by num_vacancies desc;

--компании, в которых сосредоточено наибольшее количество вакансий:
select 
employer,
COUNT(*) AS num_vacancies 
FROM public.parcing_table
group by employer
order by num_vacancies desc;



--какие преобладают типы занятости:
select 
employment,
COUNT(*) as num_vacancies 
from public.parcing_table
group by employment
order by num_vacancies desc  

--какие преобладают графики работы:
select 
schedule,
COUNT(*) as num_vacancies
from public.parcing_table
group by schedule
order by num_vacancies desc 

-- распределение грейдов (Junior, Middle, Senior):
select 
experience,
COUNT(*) as num_vacancies
FROM public.parcing_table
group by experience
order by  num_vacancies desc

--распределение грейдов среди аналитиков данных и системных аналитиков:
select 
COUNT(*)
from public.parcing_table
where name like '%Аналитик данных%' 
   OR name LIKE '%аналитик данных%'
   OR name LIKE '%Системный аналитик%'
   OR name LIKE '%системный аналитик%'
   
  -- результат 1326 
   
  select 
experience,
COUNT(*) as num_vacancies,
ROUND(COUNT(*) * 100.0 / 1326, 2) AS percent_vacancies
from public.parcing_table
where name like '%Аналитик данных%' 
   OR name LIKE '%аналитик данных%'
   OR name LIKE '%Системный аналитик%'
   OR name LIKE '%системный аналитик%'
group by experience
ORDER BY percent_vacancies desc;

experience           |num_vacancies|percent_vacancies|
---------------------+-------------+-----------------+
Junior+ (1-3 years)  |          854|            64.40|
Middle (3-6 years)   |          345|            26.02|
Junior (no experince)|          121|             9.13|
Senior (6+ years)    |            6|             0.45|

---основных работодателей, предлагаемые зарплаты и условия труда для аналитиков:
select 
employer,
COUNT(*) as num_vacancies,
AVG(ROUND(salary_from,2)) as avg_salary_from,
AVG(ROUND(salary_to,2)) as avg_salary_to,
schedule,
employment
from public.parcing_table
where name like '%Аналитик данных%' 
   OR name LIKE '%аналитик данных%'
   OR name LIKE '%Системный аналитик%'
   OR name LIKE '%системный аналитик%'
group by employer, schedule, employment
order by num_vacancies desc;


-- наиболее востребованные навыки (как жёсткие, так и мягкие) для различных грейдов и позиций:
select
key_skills_1,
COUNT(*) as num_mention
from public.parcing_table
group by key_skills_1
order by num_mention desc ;

key_skills_1                                                    |num_mention|
----------------------------------------------------------------+-----------+
                                                                |        383|
Анализ данных                                                   |        312|
SQL                                                             |        161|
Документация                                                    |         89|
MS SQL                                                          |         87|
Pandas                                                          |         86|
Аналитическое мышление                                          |         80|
Коммуникация                                                    |         69|
Python                                                          |         67|
confluence                                                      |         47|
Английский язык                                                 |         38|

(для основных навыков аналогично)