use retail_data

--Data Preparation and understanding
--question 1
Select
Select(count()From Customer) as a, Select Count() From prod_cat_info) as b 
(select count(*) from Transactions) as c

select count(*) from Customer as a union
select  count(*) from prod_cat_info as b union
select count(*)  from Transactions as c

--question 2
select count(distinct(transaction_id)) as return_count from Transactions
where qty < 0

--question 3
Alter table customer
alter column DOB date

Alter table transactions
alter column tran_date date

--also we can do this by convert function without affecting base table  convert(date,tran_date,105)

--question 4
select *,day(tran_date) as day ,MONTH(tran_date) as month,YEAR(tran_date) as year from Transactions

select DATEDIFF(year,min(tran_date) , max(tran_date)) , DATEDIFF(month,min(tran_date) , max(tran_date)),DATEDIFF(day,min(tran_date) , max(tran_date)) from Transactions

--question 5
	select prod_cat from prod_cat_info
	where prod_subcat = 'DIY'


	--Data Analysis
--question 1
select distinct store_type,count(Store_type) over(partition by store_type) as count_tran_mode , rank() over(partition by store_type order by count(Store_type))  from Transactions
group by Store_type

select top 1 store_type, count(store_type)as count_tran_mode from Transactions
group by Store_type
order by count(store_type) desc

--question 2

select gender , count(gender) from Customer
group by Gender

select gender , count(gender) as count_gender from Customer
where gender is not null
group by Gender


--question 3
select top 1 city_code ,count(Customer_id) as cx_count from Customer group by city_code
order by count(Customer_id) desc

--question 4
select prod_cat , prod_subcat from prod_cat_info
where prod_cat = 'books'

select  count(prod_subcat) from prod_cat_info
where prod_cat = 'books'

--question 5
select  prod_cat_code ,max(qty) from Transactions
group by prod_cat_code

--question 6

select sum(cast(total_amt as float)) as total_revenue from prod_cat_info c join Transactions t 
on c.prod_cat_code = t.prod_cat_code and c.prod_sub_cat_code = t.prod_subcat_code		
where prod_cat = 'electronics' or prod_cat = 'books'


--question 7
--Doubt in question 7

select count(*) as total_cst from(
select cust_id, count(distinct(transaction_id))as count_of_transaction from Transactions
where total_amt>0
group by cust_id
having count(distinct(transaction_id)) >10 ) as t5


--question 8

select SUM(CAST(t.total_amt as float)) as combined_revenue
from Transactions t join prod_cat_info p
on t.prod_cat_code = p.prod_cat_code and t.prod_subcat_code = p.prod_sub_cat_code
where t.Store_type = 'Flagship store' and p.prod_cat in ('electronics' , 'clothing') and qty>0

--question 9

select prod_subcat , sum(cast(t.total_amt as float)) as net_revenue from Transactions t join customer c
on t.cust_id = c.customer_Id
join prod_cat_info p on 
t.prod_cat_code = p.prod_cat_code and t.prod_subcat_code = p.prod_sub_cat_code
where c.Gender = 'M'and p.prod_cat = 'electronics'
group by prod_subcat

--question 10
--percentage of sales
select  t5.prod_subcat , percentage_sales , percentage_return from(
select top 5 p.prod_subcat,sum(CAST(t.total_amt as float))/(select sum(cast(t.total_amt as float)) from transactions t
 where qty>0) as percentage_sales from Transactions t join prod_cat_info p
on t.prod_cat_code = p.prod_cat_code and t.prod_subcat_code = p.prod_sub_cat_code
where qty > 0
group by prod_subcat
order by percentage_sales desc ) as t5
join 

--percentage of return
(
select  p.prod_subcat,sum(CAST(t.total_amt as float))/(select sum(cast(t.total_amt as float)) from transactions t
 where qty<0) as percentage_return from Transactions t join prod_cat_info p
on t.prod_cat_code = p.prod_cat_code and t.prod_subcat_code = p.prod_sub_cat_code
where qty < 0
group by prod_subcat) as t6
on t5.prod_subcat = t6.prod_subcat


--question 11

--age of customer
select * from (
select * from (
select cust_id , DATEDIFF(year ,dob,max_date)as age , revenue from (
select t.cust_id, c.DOB , MAX(convert(date , tran_date)) as max_date , sum(cast(t.total_amt as float)) as revenue from Customer c join Transactions t
on c.customer_Id = t.cust_id
where qty> 0
group by cust_id , DOB
) as a
) as b
where age between 25 and 35 
) as c
join (
--get last 30 days of transations
+-
select cust_id , tran_date from Transactions
group by cust_id ,tran_date
having tran_date> = (
select dateadd(day , -30 ,max(convert(date , tran_date))) as cutoff_date from Transactions
 )
) as d on c.cust_id =d.cust_id

--question 12

-

select top 2 prod_cat_code , SUM(returns) as qty_of_return from (
select  prod_cat_code , tran_date , sum(qty) as returns from Transactions where Qty<0
group by prod_cat_code ,tran_date
having tran_date> = (
select dateadd(MONTH , -3 ,max(convert(date , tran_date))) as cutoff_date from Transactions
)) as a 
group by prod_cat_code
order by qty_of_return 

--question 13

select sum(total_amt) as sales_amt , sum(Qty) as qty_sold , Store_type from Transactions
where qty>0
group by Store_type
order by sales_amt desc , qty_sold

--question 14
select prod_cat_code , avg(total_amt) as avg_revenue from Transactions
where qty>0
group by prod_cat_code
having avg(total_amt) >=(select  avg(total_amt) from Transactions where qty>0)

--question 15

select top 5 prod_subcat_code , sum(total_amt) as revenue, avg(total_amt) as avg_revenue from Transactions
where qty>0 and prod_cat_code in (select top 5 prod_cat_code  from Transactions
where qty > 0 
group  by prod_cat_code
order by sum(qty) desc)
group by prod_subcat_code


select top 1 * from Transactions
select top 1 * from prod_cat_info
select top 1 * from customer
