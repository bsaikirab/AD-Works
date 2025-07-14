------------------------------- #0. Union of Fact Internet sales and Fact internet sales new  ---

use workadventure;

select * from sales1;
select * from sales;
select * from sales1 union select * from sales;
select * from sales1 union all select * from sales;
desc sales;

 ------------- #1.Lookup the productname from the Product sheet to Sales sheet.----------------
 
 select * from product;
 select * from sales;

---- Method 1 -----------------------
 
select s.*,p.englishproductname 
from (select * from sales1 union select * from sales) as s join product as p on s.productkey = p.productkey group by englishproductname limit 10;


---- Metho 2 ---------------
alter table sales1 drop column productname;
ALTER TABLE Sales ADD COLUMN ProductName VARCHAR(255);
alter table sales1 add column productname varchar(255);

UPDATE Sales1 s
JOIN Product p ON s.Productkey= p.Productkey
SET s.ProductName = p.englishproductname;

select * from sales union all select * from sales1;

----- Metho 3-----------------

create view product_name as select  p.englishproductname as product,concat(round(sum(salesamount/1000),2),"K") as Total_sales 
from (select * from sales1 union select * from sales) as s join product as p on s.productkey = p.productkey group by englishproductname 
order by total_sales desc limit 10;

select * from product_name;

-------- Method 4 --------------------------

with product_namselect p.englishproductname as product,round(sum(s.salesamount),2) as Total_sales 
from (select * from sales1 union select * from sales) as s join product as p on s.productkey = p.productkey group by englishproductname 
order by total_sales desc limit 10)
select product,total_sales from product_name;


select * from product_name;
drop view product_name;

----- 2.Lookup the Customerfullname from the Customer and Unit Price from Product sheet to Sales sheet -----------------------------------

--- Method 1 ------------
use workadventure;
select * from customer1;
select * from product;
alter table product rename column `unit price` to Unitprice;
select * from sales1 union all select * from sales;
select s.*,concat(c.firstname," ",c.middlename," ",c.lastname) as fullname,p.unitprice  from (product as p join (select * from sales1 union select * from sales) as s on s.productkey = p.productkey)
join customer1 as c on c.customerkey = s.customerkey group by productkey order by salesamount desc limit 10;

--------- Method 2 -------------

with customername as (select concat(c.firstname," ",c.middlename," ",c.lastname) as fullname,p.unitprice,s.salesamount  as Total_sales from product as p join 
(select * from sales1 union select * from sales) as s on s.productkey = p.productkey
join customer1 as c on c.customerkey = s.customerkey 
group by fullname,p.unitprice order by total_sales desc limit 10)
select fullname,unitprice,total_sales from customername;

--- Method 3 ------------

create view customername as select concat(c.firstname," ",c.middlename," ",c.lastname) as fullname,p.unitprice,s.salesamount  as Total_sales from product as p join 
(select * from sales1 union select * from sales) as s on s.productkey = p.productkey
join customer1 as c on c.customerkey = s.customerkey 
group by fullname,p.unitprice order by total_sales desc limit 10;

select * from customername;

-------------- 3.calcuate the following fields from the Orderdatekey field ( First Create a Date Field from Orderdatekey) ----------------------------------------------------------------

select * from sales;

create view date1 as select date(orderdatekey) as date1 from sales union all
select date(orderdatekey) as date1 from sales1;

select * from date1;
select date1,year(date1) as year1,
			month(date1) as monthno,
            monthname(date1) as monthfullname,
            quarter(date1) as quarter1,
            concat(Year(date1),"-",monthname(date1)) as year_monthname,
            weekday(date1) as weeekno,
            dayname(date1) as dayname1,
case when monthname(date1)='January' then 'FM10' 
when monthname(date1)='February' then 'FM11'
when monthname(date1)='March' then 'FM12'
when monthname(date1)='April'then'FM1'
when monthname(date1)='May' then 'FM2'
when monthname(date1)='June' then 'FM3'
when monthname(date1)='July' then 'FM4'
when monthname(date1)='August' then 'FM5'
when monthname(date1)='September' then 'FM6'
when monthname(date1)='October' then 'FM7'
when monthname(date1)='November' then 'FM8'
when monthname(date1)='December'then 'FM9'
end Financial_months,
case when monthname(date1) in ('January' ,'February' ,'March' )then 'Q4'
when monthname(date1) in ('April' ,'May' ,'June' )then 'Q1'
when monthname(date1) in ('July' ,'August' ,'September' )then 'Q2'
else  'Q3' end as financial_quarters from date1;


----- 4.Calculate the Sales amount uning the columns(unit price,order quantity,unit discount)--------------------------------------------------------------------------------
use workadventure;
 ------- Method 1 ------
 
select *,round(sum(unitprice*orderquantity * (1 - discountamount)),2) AS sales_amount from sales1 union all 
select *,round(sum(unitprice*orderquantity * (1 - discountamount)),2) from sales group by 1 order by sales_amount desc limit 10;

---- Method 2 -------

with pro as (select *,
concat(round(sum(unitprice*orderquantity * (1 - discountamount)/1000),2),"K") AS sales_amount 
from (select * from sales1 union all select * from sales) as k group by productkey order by sales_amount desc limit 10)
select unitprice,orderquantity,discountamount,Sales_amount from pro;

 
 --------  5.Calculate the Productioncost uning the columns(unit cost ,order quantity) ---------------------------
 
 select * from sales;
 
 ----- Method 1
 
 select *,round(sum(productstandardcost*orderquantity),2) as Productioncost from 
 (select * from sales1 union all select * from sales) as k group by productkey order by productioncost desc limit 10;

 ---- Method 2 ---------
 
select productstandardcost,orderquantity,productstandardcost*orderquantity as Productioncost from sales1 union all 
select productstandardcost,orderquantity,productstandardcost*orderquantity as productioncost  from sales;



------- 6.Calculate the profit ---------------------------------------------------------------------------------------------------------
use workadventure;

select * from sales;

----- Method 1 ---------

select *,round(sum(salesamount-(totalproductcost+taxamt+freight)) as Profit  
from (select * from sales1 union all select * from sales)  k group by productkey order by profit desc;

------- Method 2----------------

create view profit1 as (select productkey,Salesamount,totalproductcost,taxamt,freight,sum(salesamount-(totalproductcost+taxamt+freight)) as Profit 
from (select * from sales1 union all select * from sales) k group by productkey);

select sum(profit) from profit1;

drop view profit;


select sum(profit) as total_Profit from profit1;  ------------ number series ----------------
use workadventure;


SELECT 
  CASE
    WHEN SUM(profit) >= 1000000 THEN CONCAT(ROUND(SUM(profit)/1000000, 2), 'M')
  END AS Total_Profit
FROM profit1;  ------------- million series ---------------


SELECT 
  CASE
	WHEN SUM(profit) >= 1000 THEN CONCAT(ROUND(SUM(profit)/1000, 2), 'K')
    ELSE ROUND(SUM(profit), 2)
  END AS Total_Profit
FROM profit1; ------------- thousands series -------------



---------------- #7.Create a Pivot table for month and sales (provide the Year as filter to select a particular Year) --------

------------ Method 1--------------
use workadventure;

with month_sales as (select date(orderdatekey) as date1,salesamount from  (select * from sales1 union all select * from sales) as k)
select year(date1) as year1,monthname(date1) as monthfullname,round(sum(salesamount),2) as total_sales from month_sales 
where year(date1) = 2011 group by monthfullname order by total_sales desc;


with month_sales as (select date(orderdatekey) as date1,salesamount from  (select * from sales1 union all select * from sales) as k)
select year(date1) as year1,monthname(date1) as monthfullname,round(sum(salesamount),2) as total_sales from month_sales 
where year(date1) = 2011 group by monthfullname order by total_sales desc;

with month_sales as (select date(orderdatekey) as date1,salesamount from sales union all
select date(orderdatekey) as date1,salesamount from sales1)
select year(date1) as year1,monthname(date1) as monthfullname,salesamount from month_sales ;

----- Method 2-----------------

with month_sales as (select date(orderdatekey) as date1,salesamount from  (select * from sales1 union all select * from sales) as k)
select year(date1) as year1,monthname(date1) as monthfullname,
round(sum(salesamount),2) as total_sales from month_sales 
where year(date1) = 2011 group by year(date1),monthfullname ORDER BY CASE MONTHNAME(date1)
    WHEN 'January' THEN 1
    WHEN 'February' THEN 2
    WHEN 'March' THEN 3
    WHEN 'April' THEN 4
    WHEN 'May' THEN 5
    WHEN 'June' THEN 6
    WHEN 'July' THEN 7
    WHEN 'August' THEN 8
    WHEN 'September' THEN 9
    WHEN 'October' THEN 10
    WHEN 'November' THEN 11
    WHEN 'December' THEN 12
END;

---- Method 3 -----------

with month_sales as (select date(orderdatekey) as date1,salesamount from  (select * from sales1 union all select * from sales) as k)
select year(date1) as year1,monthname(date1) as monthfullname,
round(sum(salesamount),2) as total_sales from month_sales 
where year(date1) = 2011 group by year(date1),month(date1),monthfullname ORDER BY MONth(date1);

use workadventure;

--------------------- #8.Create a Bar chart to show yearwise Sales ----------------------------------------------------------------------

------ Method 1-------------

with year_sales as (select date(orderdatekey) as date1,salesamount from sales union all
select date(orderdatekey) as date1,salesamount from sales1)
select year(date1) as year1,concat(round(sum(salesamount)/1000),2,"K") as total_sales from year_sales group by 1 order by 1;

------------ Method 2--------------------------------

with year_sales as (select date(orderdatekey) as date1,salesamount from (select * from sales union all select * from sales1) as k)
select year(date1) as year1,round(sum(salesamount),2) as total_sales from year_sales group by 1 order by 1;

---------- #9.Create a Line Chart to show Monthwise sales-----------------------------------------------------------------------------------

----------- Method 1 --------

with month_sales1 as (select date(orderdatekey) as date1,salesamount from (select * from sales union all select * from sales1) as k)
select monthname(date1) as monthfullname,concat(round(sum(salesamount)/1000),2,"K") as Total_Sales from month_sales1 group by monthfullname order by total_sales desc;

------------ Method 2-------------

with month_sales1 as (select date(orderdatekey) as date1,salesamount from (select * from sales union all select * from sales1) as k)
select monthname(date1) as monthfullname,round(sum(salesamount),2) as Total_Sales from month_sales1 group by monthfullname,month(date1) order by month(date1);

with month_sales1 as (select date(orderdatekey) as date1,salesamount from sales union all
select date(orderdatekey) as date1,salesamount from sales1)
select monthname(date1) as monthfullname,round(sum(salesamount),2) as Total_Sales from month_sales1 group by monthfullname;

--------------- 10.Create a Pie chart to show Quarterwise sales -----------------------------------------------------------------------------

with quarter_sales1 as (select date(orderdatekey) as date1,salesamount from (select * from sales union all select * from sales1) as k)
select quarter(date1) as qtr,concat(round(sum(salesamount/1000),2),"K") as Total_Sales from quarter_sales1 group by qtr order by qtr;

with quarter_sales1 as (select date(orderdatekey) as date1,salesamount from sales union all
select date(orderdatekey) as date1,salesamount from sales1)
select quarter(date1) as qtr,round(sum(salesamount),2) as Total_Sales from quarter_sales1 group by qtr order by qtr;


------------ #11.Create a combinational chart (bar and Line) to show Salesamount and Productioncost together ------------------

select * from sales;

select productkey,round(sum(totalproductcost),2) as totalproductcost,round(sum(salesamount),2) as Total_Sales 
from (select * from sales union all select * from sales1) as k group by 1;


-------------- 12.Build addtional KPI /Charts for Performance by Products, Customers, Region -------------------------------------

select * from product;
select * from sales;

------------ Product wise salees --------------
select p.englishproductname,round(sum(s.salesamount),2) as total_Sales from (select * from sales1 union all select * from sales) as s
join product as p on p.productkey = s.productkey group by englishproductname;

-----  Region wise sales-------------------------
select * from sales;
select * from salesterr;

select t.salesterritoryregion,concat(round(sum(s.salesamount)/1000,2),"k") as Total_Sales from  (select * from sales1 union all select * from sales) as s
join salesterr as t on t.salesterritorykey = s.salesterritorykey group by salesterritoryregion;

-------------  category wise sales ---------------------------------------------------
use workadventure;
select * from salesterr;
select * from category;
select * from subcategory;
select * from sales;
select * from product;
select * from category;

select c.englishproductcategoryname,CONCAT(round(sum(s.salesamount)/1000,2),"K") as Total_Amount from category as c
join subcategory as sub on c.productcategorykey = sub.productcategorykey join
product as p on p.productsubcategorykey = sub.productsubcategorykey join
(select * from sales union all select * from sales1) as s on s.productkey = p.productkey group by englishproductcategoryname;

select * from subcategory;

select c.englishproductcategoryname,sub.englishproductsubcategoryname,CONCAT(round(sum(s.salesamount)/1000,2),"K") as Total_Amount from category as c
join subcategory as sub on c.productcategorykey = sub.productcategorykey join
product as p on p.productsubcategorykey = sub.productsubcategorykey join
sales as s on s.productkey = p.productkey group by englishproductsubcategoryname,englishproductcategoryname;


----------- Subcategory wise Salees -------------------------------------------

select sub.englishproductsubcategoryname,round(sum(s.salesamount)/1000,2) as Total_Amount from subcategory as sub join
product as p on p.productsubcategorykey = sub.productsubcategorykey join
(select * from sales union all select * from sales1) as s on s.productkey = p.productkey group by englishproductsubcategoryname;


--------------- Total Sales ----------------------------------------------------------------------

Select concat(round(sum(Salesamount)/1000000,2)," M") as Total_sales from (select * from sales1 union all select * from sales) as k;


--------- Total Regions ------------------------------------------------------------------------

select * from salesterr;
SELECT COUNT(DISTINCT salesterritoryregion) FROM salesterr
WHERE salesterritoryregion <> 'NA';

SELECT COUNT(DISTINCT salesterritoryregion)
FROM salesterr
WHERE salesterritoryregion NOT IN ('NA');

----------- Total Product cost --------------------------------------------------------------------
select * from sales;
Select concat(round(sum(totalproductcost)/1000000,2)," M") as Total_sales from (select * from sales1 union all select * from sales) as k;

------------ Total Unitprice -----------------

select * from sales;
Select concat(round(sum(unitprice)/1000000,2)," M") as Total_sales from (select * from sales1 union all select * from sales) as k;


------------------------- Total Product ----------------------------------
select * from product;

select count(distinct englishproductname) as Total_Count_Products from product;


---------------------------  Maximum Sales & Profit -------------------------------------
select max(salesamount) from (select * from sales union all select * from sales1) as k;
with profit as (select productkey,Salesamount,totalproductcost,taxamt,freight, round(salesamount-(totalproductcost+taxamt+freight),2) as Profit 
from (select * from sales1 union all select * from sales)  k group by productkey order by profit desc limit 10)
select max(profit) as Total_Profit from profit;


------------- Minimum Sales and Profit -----------------------------------------------------------

select min(salesamount) from (select * from sales union all select * from sales1) as k;
with profit as (select productkey,Salesamount,totalproductcost,taxamt,freight, round(salesamount-(totalproductcost+taxamt+freight),2) as Profit 
from (select * from sales1 union all select * from sales)  k group by productkey order by profit desc limit 10)
select min(profit) as Total_Profit from profit;


--------------------------------- Above avg sales ----------------------------------

select productkey,salesamount from (select * from sales union all select * from sales1) as k where salesamount > (Select avg(Salesamount) from 
(select * from sales union all select * from sales1) as ss) group by productkey order by productkey;


---------------- Below Avg Sales -----------------------------------------------------------------------------

select productkey,salesamount from (select * from sales union all select * from sales1) as k where salesamount < (Select avg(Salesamount) from 
(select * from sales union all select * from sales1) as ss) group by productkey order by productkey;

--------------------------- first 5 date wise sales values -----------------------------------------------------------
select * from sales;

with first_Five as (select date(orderdatekey) as date1,salesamount from (select * from sales union all select * from sales1) as k),
Ranked_Sales as (select salesamount,date1,ROW_NUMBER() OVER (ORDER BY date1) AS rn from first_five)
select date1,salesamount from ranked_sales where rn <5;

----------- First date and 5th date wise sales values -----------------------------------

with first_value1 as (select date(orderdatekey) as date1,salesamount from (select * from sales union all select * from sales1) as k),
first_value2 as (select salesamount,date1,first_value(date1) OVER (ORDER BY date1) AS first1 from first_value1)
select first1,salesamount from first_value2 limit 5;

use workadventure;

with fifth_Productkey as (select productkey,monthname(date(orderdatekey)) as Monthfullname,sum(Salesamount) as Total_Amount
from (Select * from sales union all select * from sales1) as k group by productkey)
select productkey,Total_Amount,nth_value(productkey,5) over (order by total_amount desc) as Fith_value from fifth_Productkey;

----------- Last date wise Sales values --------------------------------------------------------------------------------------

with last_value1 as (select date(orderdatekey) as date1,salesamount from (select * from sales union all select * from sales1) as k),
last_value2 as (select salesamount,date1,last_value(date1) OVER (ORDER BY date1 ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
 AS last1 from last_value1)
select last1,salesamount from last_value2 where date1 = last1 limit 5;

------------------------------------------- sum() partition ----------------------------------------------------------------------

select  productkey,sum(salesamount) over (partition by productkey order by salesamount) as Total_Sales from
(select * from sales union all select * from sales1) as k group by productkey order by Total_Sales desc;

------------------------------- Difference sales on year on year-------------------------

with differ as (select year(date(orderdatekey)) as year1,round(sum(Salesamount),2) as Total_Sales from (Select * from sales union all select * from sales1) 
as k group by year(date(orderdatekey)))
select year1,Total_sales,
lead(Total_sales,1) over (order by year1) as Next_Sales from differ;


with differ as (select year(date(orderdatekey)) as year1,round(sum(Salesamount),2) as Total_Sales from (Select * from sales union all select * from sales1) 
as k group by year(date(orderdatekey)))
select year1,Total_sales,
lead(Total_sales,1) over (order by year1) as Next_Sales from differ;

SELECT YEAR(DATE(orderdatekey)) AS year,SUM(salesamount) AS total_sales,LEAD(SUM(salesamount)) OVER (ORDER BY YEAR(DATE(orderdatekey))) AS next_year_sales
FROM (SELECT * FROM sales UNION ALL SELECT * FROM sales1) AS k GROUP BY YEAR(DATE(orderdatekey)) ORDER BY year;


with differ as (select year(date(orderdatekey)) as year1,round(sum(Salesamount),2) as Total_Sales from (Select * from sales union all select * from sales1) 
as k group by year(date(orderdatekey)))
select year1,Total_sales,
lag(Total_sales,1) over (order by year1) as prev_Sales from differ;

with differ as (select year(date(orderdatekey)) as year1,round(sum(Salesamount),2) as Total_Sales from (Select * from sales union all select * from sales1) 
as k group by year(date(orderdatekey))), k as (
select year1,Total_sales,
lag(Total_sales,1) over (order by year1) as prev_Sales from differ)
select year1,Total_Sales,prev_Sales,round((Total_Sales-Prev_Sales),2) as year_Over_Year_change from k;

with differ as (select year(date(orderdatekey)) as year1,round(sum(Salesamount),2) as Total_Sales from (Select * from sales union all select * from sales1) 
as k group by year(date(orderdatekey))), k as (
select year1,Total_sales,
lead(Total_sales,1) over (order by year1) as Next_Sales from differ)
select year1,Total_Sales,next_sales,(Total_Sales-Next_Sales) as yoy,
round(((next_sales-Total_sales)/Total_sales*100),2) as yoy_percentage from k;

---------- Using Triggeer and Lead or Lag ------------------------------------------------------------------

CREATE TABLE yoy (
  year1 INT,
  total_sales DECIMAL(10,2),
  next_sales DECIMAL(10,2),
  yoy DECIMAL(10,2)
);

INSERT INTO yoy (year1, total_sales, next_sales, yoy)
SELECT year1,total_sales,next_sales,
total_sales - next_sales AS yoy
FROM (SELECT YEAR(orderdatekey) AS year1,ROUND(SUM(salesamount), 2) AS total_sales,LEAD(ROUND(SUM(salesamount), 2)) OVER (ORDER BY YEAR(orderdatekey)) AS next_sales
FROM (SELECT * FROM sales UNION ALL SELECT * FROM sales1) AS all_sales GROUP BY YEAR(orderdatekey)) AS yearly_sales;

select * from yoy;

use workadventure;
------ Rank wise Products or customers ------------------------------------
Select * from sales;

with Denise1 as (select  p.englishproductname as productname,
CASE WHEN SUM(s.SalesAmount) >= 1000000 THEN CONCAT(ROUND(SUM(s.SalesAmount) / 1000000, 2), 'M')
        WHEN SUM(s.SalesAmount) >= 1000 THEN CONCAT(ROUND(SUM(s.SalesAmount) / 1000, 2), 'K')
        ELSE ROUND(SUM(s.SalesAmount), 2) end as Total_sales
from (select * from sales1 union select * from sales) as s join product as p on s.productkey = p.productkey group by englishproductname limit 10)
select productname,Total_Sales, dense_rank () over (order by Total_Sales desc) as Ranks from denise1;


with denise1 as (select concat(c.firstname," ",c.middlename," ",c.lastname) as fullname,p.unitprice,s.salesamount  as Total_sales from (product as p join (select * from sales1 union select * from sales) as s on s.productkey = p.productkey)
join customer1 as c on c.customerkey = s.customerkey group by fullname order by total_sales desc limit 20)
select fullname,Total_Sales,rank() over (order by Total_Sales) as RN from denise1;


SET SQL_SAFE_UPDATES = 0;
Set GLOBAL log_bin_trust_function_creators = 1;

------------- TCL COMMANDS -----------------------------
----------- TCL Commands(Commit,savepoint,rollback) ------------------

select * from yoy;
start transaction;
delete from yoy_summary where year1 = 2014;
select * from yoy_summary;
rollback;

 --- savepoint and commit ------------
 select * from yoy;
 start transaction;
 delete from yoy_summary where year1 = 2014;
 savepoint sv1;
 delete from yoy_summary where year1 = 2011;
 rollback to sv1;
 rollback;
commit;
 
  --------------- Avg sales by using out parameter ----------------------------
  
  use workadventure;
  
call avg_sales(@average);
select @average;

------------ Sales amount by using in and out paramater------------------------------
select * from sales;

call sales_amount(581,@581);
select @581;

-------------- if and in paramter using salesl --------------------------------------------


call profit1(225);
call profit1(606);
call profit1(529);

select * from sales1 order by productkey;

call sal(581,@581);
select @581;

call sal(529,@529);
select @529;

---------------------- in and out paramter using sales without declare --------------------------------------------

call sal1(606,@606);

--------------- loops by using proft ---------------------------

select * from sales;

call myloops(225,5);

-------------------------------------------------------- Pending functions -------------------------------------------------------------


# ntileavg_sales
# cursor
# exception handling
# user defined functions


 ------------------- End --------------------------------------------------------------------------------------------------------------------------------------------------
















































  





















































































































































































 
 
 
 
 
 
 
 
 
