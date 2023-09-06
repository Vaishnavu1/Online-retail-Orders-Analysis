-- 1. Write a query to display customer full name with their title (Mr/Ms), both first name and last name are in upper case, customer email id,
   -- customer creation date and display customer’s category after applying below categorization rules:  
   use orders;
   show tables;
   -- ----------------------------------------------------------------------------------
   -- ANSWER
   select * from online_customer;
select upper(concat(
case
WHEN OC.CUSTOMER_GENDER = 'M' THEN 'Mr. ' ELSE 'Ms. ' END,
CUSTOMER_FNAME,' ',CUSTOMER_LNAME)) as FULL_NAME ,customer_email as EMAIL,customer_creation_date as CREATION_DATE,
case
   when year(oc.CUSTOMER_CREATION_DATE) < 2005 Then 'A'
   when year(oc.CUSTOMER_CREATION_DATE) >= 2005 and year(oc.CUSTOMER_CREATION_DATE) < 2011 Then 'B'
   when year(oc.CUSTOMER_CREATION_DATE) >= 2011 Then 'C'
  end as CUSTOMER_CATEGORY
  from online_customer as oc;
  
  -- ----------------------------------------------------------------------------------
   -- 2. Write a query to display the following information for the products, which have not been sold: product_id, product_desc, product_quantity_avail, product_price, inventory 
-- values (product_quantity_avail*product_price), New_Price after applying discount as per below criteria. Sort the output with respect to decreasing value of Inventory_Value.   

select * from order_items;
select * from product;
-- ----------------------------------------------------------------------------------
-- ANSWER

select pro.product_id as PRODUCT_ID ,pro.product_desc as PRODUCT_DESC ,product_quantity_avail as QUANTITY_AVAILABLE, pro.product_price as PRODUCT_PRICE ,pro.product_quantity_avail * pro.product_price AS INVENTORY_VALUE,
CASE
    WHEN pro.product_price > 20000 THEN pro.product_price * 0.80
    WHEN pro.product_price <= 20000 AND pro.product_price > 10000 THEN pro.product_price * 0.85
    WHEN pro.product_price <= 10000 THEN pro.product_price * 0.90
  END AS DISCOUNTED_PRICE
FROM PRODUCT pro
left JOIN order_items ord ON ord.product_id = pro.product_id
where ord.product_id is null
ORDER BY inventory_value DESC;


-- 3.Write a query to display Product_class_code, Product_class_description, Count of Product type in each productclass, Inventory Value (product_quantity_avail*product_price).
-- Information should be displayed for only those product_class_code which have more than 1,00,000. Inventory Value. Sort the output with respect to decreasing value of Inventory_Value. 
-- NOTE: TABLES to be used - PRODUCT, PRODUCT_CLASS]
-- ------------------------------------------------------------------------ 
select * from product_class;

select * from product;

SELECT product_class_code, COUNT(DISTINCT product_desc)
FROM product
GROUP BY product_class_code
order by 1 desc;
-- ------------------------------------------------------------------------ 
-- ANSWER
 
select pro_c.product_class_code as PRODUCT_CLASS_CODE,
       pro_c.PRODUCT_CLASS_DESC,
       COUNT(DISTINCT pro.product_desc) as PRODUCT_TYPE_COUNT,
       SUM(pro.product_quantity_avail * pro.product_price) as INVENTORY_VALUE
from product_class pro_c
inner join product pro
ON pro_c.product_class_code = pro.product_class_code
GROUP BY pro_c.PRODUCT_CLASS_CODE, pro_c.PRODUCT_CLASS_DESC
HAVING inventory_value > 100000
ORDER BY inventory_value DESC;

-- ------------------------------------------------------------------------

-- 4.Write a query to display customer_id, full name, customer_email, customer_phone and country of customers who have cancelled all the orders
-- placed by them (USE SUB-QUERY)[NOTE: TABLES to be used - ONLINE_CUSTOMER, ADDRESSS, ORDER_HEADER]

--
select * from online_customer; 
select * from ADDRESS; 
select * from ORDER_HEADER; 

select on_c.CUSTOMER_ID, concat(on_c.CUSTOMER_FNAME,' ',on_c.CUSTOMER_LNAME) as CUSTOMER_NAME, on_c.CUSTOMER_EMAIL,on_c.CUSTOMER_PHONE,ad.COUNTRY
from online_customer on_c
inner join address ad
on on_c.address_id = ad.address_id
where on_c.CUSTOMER_ID in (
select or_h.customer_id
from order_header or_h
where order_status = 'Cancelled');

-- ------------------------------------------------------------------------
-- 5.Write a query to display Shipper name, City to which it is catering, number of customer 
-- catered by the shipper in the city and number of consignments delivered to that city for  Shipper DHL 

select * from shipper;
select * from order_header;


SELECT s.shipper_name as SHIPPER_NAME,
       a.city as CITY,
       COUNT(DISTINCT oc.customer_id) AS NUM_OF_CUSTOMERS,
       COUNT(DISTINCT oh.order_id) AS NUM_OF_ORDERS
FROM shipper s
JOIN order_header oh ON s.shipper_id = oh.shipper_id
JOIN online_customer oc ON oh.customer_id = oc.customer_id
JOIN address a ON oc.address_id = a.address_id
WHERE s.shipper_name = 'DHL'
GROUP BY s.shipper_name, a.city;

-- Question-6



-- -----------------------------------------------------------------------
select * from product;
select * from product_class;
select * from order_items;


select pro.PRODUCT_ID,
       pro.PRODUCT_DESC,
       SUM(pro.PRODUCT_QUANTITY_AVAIL) AS PRODUCT_QUANTITY_AVAIL,
       ord.PRODUCT_QUANTITY AS QUANTITY_SOLD,
	case
           when pro_c.product_class_desc IN ('Electronics', 'Computer') then
               case
                   when ord.PRODUCT_QUANTITY = 0 OR ord.PRODUCT_QUANTITY IS NULL then 'No Sales in past, give discount to reduce inventory'
                   when pro.PRODUCT_QUANTITY_AVAIL < 0.1 * ord.PRODUCT_QUANTITY then 'Low inventory, need to add inventory'
                   when pro.PRODUCT_QUANTITY_AVAIL < 0.5 * ord.PRODUCT_QUANTITY then 'Medium inventory, need to add some inventory'
                   else 'Sufficient inventory'
               end
           when pro_c.product_class_desc IN ('Mobiles', 'Watches') then
               case
                   when ord.PRODUCT_QUANTITY = 0 OR ord.PRODUCT_QUANTITY IS NULL then 'No Sales in past, give discount to reduce inventory'
                   when pro.PRODUCT_QUANTITY_AVAIL < 0.2 * ord.PRODUCT_QUANTITY then 'Low inventory, need to add inventory'
                   when pro.PRODUCT_QUANTITY_AVAIL < 0.6 * ord.PRODUCT_QUANTITY then 'Medium inventory, need to add some inventory'
                   else 'Sufficient inventory'
               end
           else
               case
                   when ord.PRODUCT_QUANTITY = 0 OR ord.PRODUCT_QUANTITY IS NULL then 'No Sales in past, give discount to reduce inventory'
                   when pro.PRODUCT_QUANTITY_AVAIL < 0.3 * ord.PRODUCT_QUANTITY then 'Low inventory, need to add inventory'
                   when pro.PRODUCT_QUANTITY_AVAIL < 0.7 * ord.PRODUCT_QUANTITY then 'Medium inventory, need to add some inventory'
                   else 'Sufficient inventory'
               end
       end AS INVENTORY_STATUS
from product pro
inner join product_class pro_c on pro.product_class_code = pro_c.product_class_code
inner join order_items ord on pro.PRODUCT_ID = ord.PRODUCT_ID
group by pro.PRODUCT_ID, pro.PRODUCT_DESC, ord.PRODUCT_QUANTITY;

-- 7. Write a query to display order_id and volume of the biggest order (in terms of volume) that can fit in carton id 10 -- [NOTE: TABLES to be used - CARTON, ORDER_ITEMS, PRODUCT]

select * from carton;
select * from product;
select * from order_items;

select ord.order_id, (pro.len * pro.width * pro.height * ord.product_quantity) AS ORDER_VOLUME
from product pro
inner join order_items ord ON pro.product_id = ord.product_id
where (pro.len * pro.width * pro.height * ord.product_quantity) <= (
    select (c.len * c.width * c.height) AS CARTON_VOLUME
    from carton c
    where c.carton_id = '10'
)
order by ORDER_VOLUME desc
limit 1;

--  8.Write a query to display customer id, customer full name, total quantity and total value (quantity*price) shipped where mode of payment is
-- Cash and customer last name starts with 'G' --[NOTE: TABLES to be used - ONLINE_CUSTOMER, ORDER_ITEMS, PRODUCT, ORDER_HEADER]

select * from order_header ;
select * from online_customer where customer_lname like 'G%';

select on_c.CUSTOMER_ID,concat(on_c.CUSTOMER_FNAME,' ',on_c.CUSTOMER_LNAME) as FULL_NAME,sum(ord.product_quantity) as TOTAL_QUANTITY,sum(ord.product_quantity*pro.product_price) as TOTAL_VALUE
from online_customer on_c
inner join order_header oh
on on_c.customer_id = oh.customer_id
inner join order_items ord
on oh.order_id = ord.order_id
inner join product pro
on ord.product_id = pro.product_id
where oh.payment_mode = 'Cash' and on_c.CUSTOMER_LNAME LIKE 'G%'
group by on_c.CUSTOMER_ID, FULL_NAME;

-- 9.Write a query to display product_id, product_desc and total quantity of products which are sold together with product id 201 and are not shipped to city Bangalore and New 
-- Delhi. Display the output in descending order with respect to the tot_qty.   (USE SUB-QUERY)   
-- [NOTE: TABLES to be used – ORDER_ITEMS, PRODUCT, ORDER_HEADER,  ONLINE_CUSTOMER, ADDRESS]  
select * from order_header;
select * from order_items;

select pro.PRODUCT_ID,pro.PRODUCT_DESC,sum(ord.PRODUCT_QUANTITY) AS TOTAL_QUANTITY
from product pro
inner join order_items ord on pro.PRODUCT_ID = ord.PRODUCT_ID
inner join order_header oh on ord.ORDER_ID = oh.ORDER_ID
inner join online_customer on_c on oh.CUSTOMER_ID = on_c.CUSTOMER_ID
inner join address a on on_c.ADDRESS_ID = a.ADDRESS_ID
where ord.ORDER_ID in (
	select ord.ORDER_ID
	from order_items
	where PRODUCT_ID = '201'
	and oh.ORDER_STATUS = 'shipped'
	and a.CITY NOT IN ('Bangalore', 'New Delhi'))
group by pro.PRODUCT_ID,pro.PRODUCT_DESC
order by TOTAL_QUANTITY DESC;

-- 10. Write a query to display the order_id,customer_id and customer fullname, total quantity of products shipped for order ids which are even and shipped
-- to address where pincode is not starting with "5" -- [NOTE: TABLES to be used - online_customer,Order_header, order_items,address] 

select ord.ORDER_ID,on_c.CUSTOMER_ID,concat(on_c.CUSTOMER_FNAME,' ',on_c.CUSTOMER_LNAME) as FULL_NAME,sum(ord.PRODUCT_QUANTITY) AS TOTAL_QUANTITY
from product pro
inner join order_items ord on pro.PRODUCT_ID = ord.PRODUCT_ID
inner join order_header oh on ord.ORDER_ID = oh.ORDER_ID
inner join online_customer on_c on oh.CUSTOMER_ID = on_c.CUSTOMER_ID
inner join address a on on_c.ADDRESS_ID = a.ADDRESS_ID
where ord.ORDER_ID % 2 = 0
and a.PINCODE not like '5%'
group by ord.ORDER_ID,on_c.CUSTOMER_ID;

