
-- Total revenue
select sum(UnitPrice*Quantity) Total_revenue from e_commerce
where quantity > 0;

-- 2. Total Orders

select COUNT(DISTINCT InvoiceNo) Total_Orders from e_commerce;

-- Total Unique Customers
select count(distinct(CustomerID)) from e_commerce
;


-- Average Order Value (AOV)

SELECT 
    ROUND(SUM(Quantity * UnitPrice) / COUNT(DISTINCT InvoiceNo), 2) AS avg_order_value
FROM e_commerce
WHERE Quantity > 0;


-- Total Returns (Negative Quantities) 

select count(*) Total_returns ,  sum(quantity*unitprice) return_value from e_commerce
where quantity < 0;




