select count(customer_id) as customers_count from customers c;-- Считаем количество записей в таблице customers

select
    concat(e.first_name,' ',e.last_name) as seller,--Объединяем имя фамилию с таблицы employees
    count(s.sales_id) as operation,--Считаем количество сделок в sales
    floor(sum(s.quantity * p.price)) as income -- Считаем доход умножая количество на цену
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
    to_char(s.sale_date, 'day') as day_of_week, --Вытягиваем день недели из даты в виде строки
    floor(sum(s.quantity * p.price)) as income -- считаем доход за дни недели с округлением
from sales s -- Берем за основу sales
inner join employees e on s.sales_person_id = e.employee_id -- Подключаем employees узнать продавца
left join products p on s.product_id = p.product_id -- Подключаем products узнать цену продукта
group by concat(e.first_name,' ',e.last_name),TO_CHAR(s.sale_date, 'day'),extract (isodow from s.sale_date) -- Группируем имена и даты
order by extract (isodow from s.sale_date), concat(e.first_name,' ',e.last_name); --Сортируем по дням и имени

select 
    case 
        when age between 16 and 25 then '16-25' -- категория 16-25
        when age between 26 and 40 then '26-40' -- категория 26-40
        else '40+'   --  40+
    end as age_category, -- обозначили название столбца
    count(customer_id) as age_count -- посчитали количество id в категориях
from customers c -- подключили таблицу
where age is not null -- исключили нулевые строки
group by age_category  -- сгруппировали по категории
order by age_category; -- отсортировали


select to_char(s.sale_date , 'YYYY-MM') AS selling_month, --преобразуем дату в YY-MM
       count(distinct s.customer_id) AS total_customers, --Считаем уникальных покупателей
       floor(sum(s.quantity * p.price )) as income -- считаем income 
from sales s -- подключили таблицу
join products p ON s.product_id = p.product_id -- соеденили чтобы достать цену продукта
group by to_char(s.sale_date , 'YYYY-MM') -- сгруппировали по месяцам продаж
order by selling_month; -- отсортировали 

with tab as (
	select s.customer_id,
	row_number() over (partition by s.customer_id order by sale_date) as rn,
	s.sales_person_id,
	s.sale_date,
	s.product_id
	from sales s) -- табличка для того чтобы убрать дубли при выводе в ней выводим все столбцы что нам понадобятся 
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
	