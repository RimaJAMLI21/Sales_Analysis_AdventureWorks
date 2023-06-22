--Promotion Analysis Customer
---All internet Promotions

select fis.ProductKey, 
       DP.EnglishPromotionName, 
	   sum(fis.SalesAmount) as Promo_Sales_Revenue

from FactInternetSales fis
inner join DimPromotion DP on DP.PromotionKey=fis.PromotionKey

where fis.PromotionKey!=1

group by ProductKey,
         DP.EnglishPromotionName;