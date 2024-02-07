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
	concat(e.first_name,' ',e.last_name) as name,
	TO_CHAR(s.sale_date, 'Day') as weekday,
	ROUND(SUM(s.quantity * p.price)) as income
from sales s
inner join employees e on s.sales_person_id = e.employee_id -- Подключаем employees узнать продавца
left join products p on s.product_id = p.product_id
GROUP BY concat(e.first_name,' ',e.last_name),TO_CHAR(s.sale_date, 'Day'),extract (isodow from s.sale_date)
ORDER BY extract (isodow from s.sale_date), concat(e.first_name,' ',e.last_name);


