select count(customer_id) as customers_count from customers;

select
    concat(e.first_name, ' ', e.last_name) as seller,
    --объединяем имя фамилию
    count(s.sales_id) as operation,
    --считаем количество сделок в sales
    floor(sum(s.quantity * p.price)) as income
    -- считаем доход
from sales as s
inner join employees as e
    on
        s.sales_person_id = e.employee_id
-- подключаем employees
left join products as p
    on
        s.product_id = p.product_id
-- подключаем products узнать
group by
    concat(e.first_name, ' ', e.last_name)
-- группируем по продавцу
order by income desc
-- сортируем по убыванию суммы дохода
limit 10;

with tab as (
    select
        concat(e.first_name, ' ', e.last_name) as seller,
        --объединяем имя фамилию
        floor(avg(s.quantity * p.price)) as average_income
    --считаем средний доход
    from sales as s
    -- берем за основу sales
    inner join employees as e on s.sales_person_id = e.employee_id
    -- подключаем employees
    left join products as p on s.product_id = p.product_id
    -- подключаем products
    group by concat(e.first_name, ' ', e.last_name)
    -- группируем по продавцу
    order by average_income
)

select
    seller,
    average_income
from tab
where average_income < (select avg(average_income) from tab);

select
    concat(e.first_name, ' ', e.last_name) as seller,
    --объединяем имя фамилию с таблицы employees
    to_char(s.sale_date, 'day') as day_of_week,
    --вытягиваем день недели из даты в виде строки
    floor(sum(s.quantity * p.price)) as income
-- считаем доход за дни недели с округлением
from sales as s
-- берем за основу sales
inner join employees as e on s.sales_person_id = e.employee_id
-- подключаем employees узнать продавца
left join products as p on s.product_id = p.product_id
-- подключаем products узнать цену продукта
group by
    concat(e.first_name, ' ', e.last_name),
    to_char(s.sale_date, 'day'),
    extract(isodow from s.sale_date)
-- группируем имена и даты
order by
    extract(isodow from s.sale_date),
    concat(e.first_name, ' ', e.last_name);
--сортируем по дням и имени

select
    case
        when age between 16 and 25 then '16-25'
        -- категория 16-25
        when age between 26 and 40 then '26-40'
        -- категория 26-40
        else '40+'
    --  40+
    end as age_category,
    -- обозначили название столбца
    count(customer_id) as age_count
-- посчитали количество id в категориях
from customers
-- подключили таблицу
where age is not null
-- исключили нулевые строки
group by age_category
-- сгруппировали по категории
order by age_category;
-- отсортировали

select
    to_char(s.sale_date, 'yyyy-mm') as selling_month,
    --преобразуем дату в yy-mm
    count(distinct s.customer_id) as total_customers,
    --считаем уникальных покупателей
    floor(sum(s.quantity * p.price)) as income
-- считаем income
from sales as s
-- подключили таблицу
inner join products as p on s.product_id = p.product_id
-- соеденили чтобы достать цену продукта
group by to_char(s.sale_date, 'yyyy-mm')
-- сгруппировали по месяцам продаж
order by selling_month;
-- отсортировали

with tab as (
    select
        s.customer_id,
        s.sales_person_id,
        s.sale_date,
        s.product_id,
        row_number() over (partition by s.customer_id 
        order by s.sale_date) as rn
    from sales as s
)-- табличка для того чтобы убрать дубли

select
    concat(c.first_name, ' ', c.last_name) as customer,
    -- объединяем имя фамилию для одной ячейки у покупателя
    first_value(t.sale_date)
        over (partition by t.customer_id order by t.sale_date)
    as sale_date,
    -- находим дату первой продажи
    concat(e.first_name, ' ', e.last_name) as seller
-- объединяем имя фамилию для одной ячейки у продавца
from tab as t
-- наша временная табличка
inner join customers as c on t.customer_id = c.customer_id
-- отсюда возьмем имя фамилию покупателя
inner join employees as e on t.sales_person_id = e.employee_id
-- отсюда возьмем имя фамилию продавца
inner join products as p on t.product_id = p.product_id
-- здесь возьмем цену акционного продукта
where p.price = 0 and t.rn = 1
-- условия на акционный продукт , условие на первую запись в списке продаж
order by t.customer_id;
--сортирвока по customer id
