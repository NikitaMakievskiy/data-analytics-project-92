select count(customer_id) as customers_count from customers c;-- Считаем общее количество созданных записей в таблице customers --

select 
	concat(e.first_name,' ',e.last_name) as name, --Объединяем имя фамилию с таблицы employees
	count(s.sales_id) as operations, -- Считаем количество сделок в sales
	round(sum(s.quantity * p.price)) as income -- Считаем доход умножая количество проданного продукта и его цену 
from sales s -- Берем за основу sales
inner join employees e on s.sales_person_id = e.employee_id -- Подключаем employees узнать продавца
left join products p on s.product_id = p.product_id -- Подключаем products узнать цену продукта
group by concat(e.first_name,' ',e.last_name) -- Группируем по продавцу
order by income desc; -- Сортируем по убыванию суммы дохода от большего к меньшему

select 
	concat(e.first_name,' ',e.last_name) as name, --Объединяем имя фамилию с таблицы employees
	round(avg(s.quantity * p.price)) as average_income --Считаем средний доход за сделку
from sales s -- Берем за основу sales
inner join employees e on s.sales_person_id = e.employee_id -- Подключаем employees узнать продавца
left join products p on s.product_id = p.product_id -- Подключаем products узнать цену продукта
group by concat(e.first_name,' ',e.last_name) -- Группируем по продавцу
order by average_income; --Сортируем по возрастанию средний доход от меньшего к большему

select 
	concat(e.first_name,' ',e.last_name) as name, --Объединяем имя фамилию с таблицы employees
	TO_CHAR(s.sale_date, 'Day') as weekday, --Вытягиваем день недели из даты в виде строки
	ROUND(SUM(s.quantity * p.price)) as income -- считаем доход за дни недели с округлением
from sales s -- Берем за основу sales
inner join employees e on s.sales_person_id = e.employee_id -- Подключаем employees узнать продавца
left join products p on s.product_id = p.product_id -- Подключаем products узнать цену продукта
GROUP BY concat(e.first_name,' ',e.last_name),TO_CHAR(s.sale_date, 'Day'),extract (isodow from s.sale_date) -- Группируем имена и даты
ORDER BY extract (isodow from s.sale_date), concat(e.first_name,' ',e.last_name); --Сортируем по дням и имени

SELECT
    CASE
        WHEN age BETWEEN 16 AND 25 THEN '16-25' -- категория 16-25
        WHEN age BETWEEN 26 AND 40 THEN '26-40' -- категория 26-40
        ELSE '40+'   --  40+
    END AS age_category, -- обозначили название столбца
    COUNT(customer_id) AS count -- посчитали количество id в категориях
FROM
    customers c -- подключили таблицу
WHERE
    age IS NOT null -- исключили нулевые строки
GROUP BY
    age_category  -- сгруппировали по категории
ORDER BY
    age_category; -- отсортировали


SELECT TO_CHAR(s.sale_date , 'YYYY-MM') AS selling_month, --преобразуем дату в YY-MM
       COUNT(distinct s.customer_id) AS total_customers, --Считаем уникальных покупателей
       round(sum(s.quantity * p.price ), 0) as income -- считаем income 
FROM sales s -- подключили таблицу
join products p ON s.product_id = p.product_id -- соеденили чтобы достать цену продукта
GROUP BY TO_CHAR(s.sale_date , 'YYYY-MM') -- сгруппировали по месяцам продаж
order by selling_month; -- отсортировали 

