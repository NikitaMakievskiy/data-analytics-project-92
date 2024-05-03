select count(customer_id) as customers_count from customers c;-- Считаем общее количество созданных записей в таблице customers --

select 
	concat(e.first_name,' ',e.last_name) as seller, --Объединяем имя фамилию с таблицы employees
	count(s.sales_id) as operation, -- Считаем количество сделок в sales
	floor(sum(s.quantity * p.price)) as income -- Считаем доход умножая количество проданного продукта и его цену 
from sales s -- Берем за основу sales
inner join employees e on s.sales_person_id = e.employee_id -- Подключаем employees узнать продавца
left join products p on s.product_id = p.product_id -- Подключаем products узнать цену продукта
group by concat(e.first_name,' ',e.last_name) -- Группируем по продавцу
order by income desc -- Сортируем по убыванию суммы дохода от большего к меньшему
limit 10; 

with tab as (
select 
	concat(e.first_name,' ',e.last_name) as seller, --Объединяем имя фамилию с таблицы employees
	floor(avg(s.quantity * p.price)) as average_income --Считаем средний доход за сделку
from sales s -- Берем за основу sales
inner join employees e on s.sales_person_id = e.employee_id -- Подключаем employees узнать продавца
left join products p on s.product_id = p.product_id-- Подключаем products узнать цену продукта
group by concat(e.first_name,' ',e.last_name) -- Группируем по продавцу
order by average_income)--Сортируем по возрастанию средний доход от меньшего к большему
select 
	seller,
	average_income
	from tab
	where average_income < (select avg(average_income) from tab);


select 
	concat(e.first_name,' ',e.last_name) as seller, --Объединяем имя фамилию с таблицы employees
	TO_CHAR(s.sale_date, 'day') as day_of_week, --Вытягиваем день недели из даты в виде строки
	floor(SUM(s.quantity * p.price)) as income -- считаем доход за дни недели с округлением
from sales s -- Берем за основу sales
inner join employees e on s.sales_person_id = e.employee_id -- Подключаем employees узнать продавца
left join products p on s.product_id = p.product_id -- Подключаем products узнать цену продукта
GROUP BY concat(e.first_name,' ',e.last_name),TO_CHAR(s.sale_date, 'day'),extract (isodow from s.sale_date) -- Группируем имена и даты
ORDER BY extract (isodow from s.sale_date), concat(e.first_name,' ',e.last_name); --Сортируем по дням и имени

SELECT
    CASE
        WHEN age BETWEEN 16 AND 25 THEN '16-25' -- категория 16-25
        WHEN age BETWEEN 26 AND 40 THEN '26-40' -- категория 26-40
        ELSE '40+'   --  40+
    END AS age_category, -- обозначили название столбца
    COUNT(customer_id) AS age_count -- посчитали количество id в категориях
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
       floor(sum(s.quantity * p.price )) as income -- считаем income 
FROM sales s -- подключили таблицу
join products p ON s.product_id = p.product_id -- соеденили чтобы достать цену продукта
GROUP BY TO_CHAR(s.sale_date , 'YYYY-MM') -- сгруппировали по месяцам продаж
order by selling_month; -- отсортировали 

with tab as (
	select s.customer_id,
	row_number() over (partition by s.customer_id order by sale_date) as rn,
	s.sales_person_id,
	s.sale_date,
	s.product_id
	from sales s
) -- табличка для того чтобы убрать дубли при выводе в ней выводим все столбцы что нам понадобятся 
select 
	concat(c.first_name,' ',c.last_name)as customer, -- объединяем имя фамилию для одной ячейки у покупателя
	first_value(t.sale_date) over (partition by t.customer_id order by t.sale_date) as sale_date, -- находим дату первой продажи
	concat(e.first_name,' ',e.last_name) as seller -- объединяем имя фамилию для одной ячейки у продавца
from tab t -- наша временная табличка
join customers c on t.customer_id = c.customer_id -- отсюда возьмем имя фамилию покупателя
join employees e on t.sales_person_id = e.employee_id -- отсюда возьмем имя фамилию продавца
join products p on t.product_id = p.product_id -- здесь возьмем цену акционного продукта 
where p.price = 0 and t.rn = 1 -- условия на акционный продукт , условие на первую запись в списке продаж 
order by t.customer_id; --сортирвока по customer ID
	