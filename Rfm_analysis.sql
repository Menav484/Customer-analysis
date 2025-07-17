--  Monthly Sales Trends

select 
monthname(InvoiceDate) AS month, 
round(sum(unitprice * quantity)) revenue from e_commerce 
where quantity > 0
group by month;


--  top 10 products by revenue

select Description,round(sum(unitprice*quantity)) as Revenue from e_commerce
where quantity > 0
group by Description
order by revenue desc
limit 10  ;

-- Return Rate by Product & Country

SELECT 
  country,
  Description,
  COUNT(*) AS total_transactions,
  SUM(CASE WHEN quantity < 0 THEN 1 ELSE 0 END) AS return_count,
  ROUND(
    SUM(CASE WHEN quantity < 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 
    2
  ) AS return_rate_percent
FROM e_commerce
GROUP BY country, Description
HAVING COUNT(*) > 10
ORDER BY return_rate_percent DESC
LIMIT 10;


--  RFM (Recency, Frequency, Monetary) — Customer Segmentation

select customerid,
datediff('2011-12-10' , MAX(InvoiceDate)) AS Recency,
count(distinct(InvoiceNo)) as frequency ,
sum(UnitPrice*Quantity) as monetary 
from e_commerce
where Quantity > 0 
group by CustomerID
order by recency  , frequency desc , monetary desc
;


create view rfm_analysis as 
SELECT 
    CustomerID,

    -- Recency (Lower is better)
    DATEDIFF("2011-12-10", MAX(InvoiceDate)) AS Recency,
    CASE
        WHEN DATEDIFF("2011-12-10", MAX(InvoiceDate)) <= 30 THEN 5
        WHEN DATEDIFF("2011-12-10", MAX(InvoiceDate)) <= 60 THEN 4
        WHEN DATEDIFF("2011-12-10", MAX(InvoiceDate)) <= 90 THEN 3
        WHEN DATEDIFF("2011-12-10", MAX(InvoiceDate)) <= 120 THEN 2
        ELSE 1
    END AS R_score,

    -- Frequency (Higher is better)
    COUNT(DISTINCT InvoiceNo) AS Frequency,
    CASE
        WHEN COUNT(DISTINCT InvoiceNo) >= 50 THEN 5
        WHEN COUNT(DISTINCT InvoiceNo) >= 30 THEN 4
        WHEN COUNT(DISTINCT InvoiceNo) >= 20 THEN 3
        WHEN COUNT(DISTINCT InvoiceNo) >= 10 THEN 2
        ELSE 1
    END AS F_score,

    -- Monetary (Higher is better)
    ROUND(SUM(Quantity * UnitPrice), 2) AS Monetary,
    CASE
        WHEN SUM(Quantity * UnitPrice) >= 10000 THEN 5
        WHEN SUM(Quantity * UnitPrice) >= 5000 THEN 4
        WHEN SUM(Quantity * UnitPrice) >= 1000 THEN 3
        WHEN SUM(Quantity * UnitPrice) >= 500 THEN 2
        ELSE 1
    END AS M_score

FROM e_commerce
WHERE Quantity > 0 AND CustomerID IS NOT NULL
GROUP BY CustomerID;



create view avg_rfm as
select customerid, r_score , f_score ,m_score, round((r_score +  f_score + m_score )/3,2) as RFM_score from rfm_analysis
group by customerid;


create view c_type as 
select * , case 
when R_score >=4 and F_score >=4 and M_score >=4 then "Golden"
when F_score >=4  and F_score >= 4 then "Loyal"
when R_score <=1 and F_score <=1 then "Lost"
when R_score <=3 and F_score <=2 then "at risk"
when R_score = 5 then "New"
when R_score >=4 and M_score >=4 then "Spenders"
else "others"
end as customer_type 
from avg_rfm;


select customer_type,count(*) from c_type
group by customer_type

