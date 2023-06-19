use AdventureWorksDW2012;

						-- Customer Analysis


-- Age Segmentation Analysis

select DC.CustomerKey,
(case 
    when cast((datediff(DD,DC.BirthDate, GETDATE())/ 365.25) - 12 as int ) > 29
	     and
		 cast((datediff(DD, DC.BirthDate, GETDATE())/ 365.25) - 12 as int) < 40
	then 'Thirties'

	when cast((datediff(DD,DC.BirthDate, GETDATE())/ 365.25) - 12 as int ) >= 40
	     and
		 cast((datediff(DD, DC.BirthDate, GETDATE())/ 365.25) - 12 as int) < 50
	then 'Fourties'

	when cast((datediff(DD,DC.BirthDate, GETDATE())/ 365.25) - 12 as int ) < 60
	then 'Fifties'

    when cast((datediff(DD,DC.BirthDate, GETDATE())/ 365.25) - 12 as int ) >= 60
	then 'Senior'

	else 'Twenties'
end)as AgeGroup
from DimCustomer DC
order by AgeGroup;




---Customer Commute Distance Analysis 
--Provides insights into customer behavior and revenue patterns based on their commute distance

select DC.CommuteDistance,
       AVG(DC.YearlyIncome) as Avg_Income,
	   COUNT(distinct fis.CustomerKey) as Number_Customers,
	   COUNT(fis.SalesOrderNumber) as Number_Of_Orders,
	   SUM(fis.SalesAmount)/COUNT(DISTINCT fis.CustomerKey) as Avg_Revenue_Customer
       
from FactInternetSales fis
inner join DimCustomer DC on fis.CustomerKey = DC.CustomerKey

group by DC.CommuteDistance
order by Number_Customers desc, DC.CommuteDistance;

--- Customer Education Gender
--Provide insights into the relationship between customer eduction, gender, and various metrics...

select DC.EnglishEducation,
       DC.Gender,
	   AVG(DC.YearlyIncome) as AvgIncome,
	   count(distinct fis.CustomerKey) as NumberCustomers,
	   count(fis.SalesOrderNumber) as NumberOfOrders,
	   AVG(cast(DC.NumberCarsOwned as decimal(10,2))) as AvgCarsPerCustomer,
	   AVG(cast(DC.TotalChildren as decimal(10,2)))as AvgChildrenPerCustomer,
	   count(fis.SalesOrderNumber) / count(distinct fis.CustomerKey) as OrdersPerCustomer,
	   sum(fis.SalesAmount) / count(distinct fis.CustomerKey) as AvgRevenuePerCustomer
       
from FactInternetSales fis
inner join DimCustomer DC on fis.CustomerKey = DC.CustomerKey

group by DC.EnglishEducation, DC.Gender

order by EnglishEducation, NumberCustomers desc;

----Customer Family Demography 

select DC.NumberChildrenAtHome,
       DC.NumberCarsOwned,
	   DC.CommuteDistance,

	   count(distinct fis.CustomerKey) as Number_Customers,
	   count(fis.SalesOrderNumber) as Number_Of_Orders,
	   sum(fis.SalesAmount)/count(distinct fis.CustomerKey) as Avg_Revenue_Per_Customer

from FactInternetSales as fis
inner join DimCustomer DC on fis.CustomerKey = DC.CustomerKey
left outer join FactInternetSalesReason fisr on fis.SalesOrderNumber = fisr.SalesOrderNumber
left outer join DimSalesReason DSR on fisr.SalesReasonKey = DSR.SalesReasonKey
inner join DimGeography as DG on DG.GeographyKey = DC.GeographyKey

where fis.CustomerKey in
						(select fis1.CustomerKey
						from FactInternetSales fis1
						inner join DimCustomer DC on fis1.CustomerKey = DC.CustomerKey
						inner join DimGeography DG on DC.GeographyKey = DG.GeographyKey

						where DG.StateProvinceName in ('California', 'British Columbia', 'Washington', 'England', 'New South Wales'))

group by DC.NumberChildrenAtHome,DC.NumberCarsOwned, DC.CommuteDistance

order by Number_Customers desc

-- Analysis customers and revenue by state:

/*Analyze customers and revenue on a regional level by state and country 
  highlighting regions with the hights number of customers, orders and average revenue per customer.
*/

select DG.StateProvinceName,
       DG.EnglishCountryRegionName,
	   AVG(DC.YearlyIncome) as Avg_Icome,
	   count(distinct fis.CustomerKey) as Number_Customers,
	   count(fis.SalesOrderNumber) as Number_Of_Orders,
	   sum(fis.SalesAmount)/count(distinct fis.CustomerKey) as Avg_Revenue_Per_Customer

from FactInternetSales as fis
inner join DimCustomer as DC on fis.CustomerKey = DC.CustomerKey
inner join DimGeography as DG on DC.GeographyKey = DG.GeographyKey

Group by DG.StateProvinceName, DG.EnglishCountryRegionName

order by Number_Customers DESC, Number_Of_Orders DESC, Avg_Revenue_Per_Customer DESC


---- Sales Reason by Customer

select 
      concat(DC.FirstName, ' ',DC.LastName)	CustomerName,
	  DSR.SalesReasonName

from FactInternetSales fis
inner join DimCustomer DC on fis.CustomerKey = DC.CustomerKey
left outer join FactInternetSalesReason fisr on fisr.SalesOrderNumber = fis.SalesOrderNumber
left outer join DimSalesReason DSR on DSR.SalesReasonKey = fisr.SalesReasonKey

where DSR.SalesReasonName is not null

---Top 5 States Demographics:

/*Customers in top 5 states for orders and account for over 5000 orders
--(CA, WA, England, BC, Wales)
*/
select DC.EnglishEducation,
      DC.NumberChildrenAtHome,
	  DSR.SalesReasonName,

	  CAST(AVG(DC.YearlyIncome) AS decimal(10,2)) AS AvgIncome,
	  count(distinct fis.CustomerKey) as Number_Customers,
	  count(fis.SalesOrderNumber) as Number_Of_Orders,
	  sum(fis.SalesAmount)/count(distinct fis.CustomerKey) as Avg_Revenue_Per_Customer

from FactInternetSales fis
inner join DimCustomer DC on fis.CustomerKey = Dc.CustomerKey
left outer join FactInternetSalesReason fisr on fisr.SalesOrderNumber = fis.SalesOrderNumber
left outer join DimSalesReason DSR on  fisr.SalesReasonKey = DSR.SalesReasonKey
inner join DimGeography as DG on DG.GeographyKey = DC.GeographyKey

where fis.CustomerKey in (select fis1.CustomerKey
							from FactInternetSales as fis1
							inner join DimCustomer DC1 on fis1.CustomerKey = DC.CustomerKey
							where DC1.GeographyKey in (
														select DG1.GeographyKey
														from DimGeography DG1
														where DG1.StateProvinceName in ('California', 'British Columbia', 'Washington', 'England', 'New South Wales')))

group by DC.EnglishEducation, DC.NumberCarsOwned, DC.NumberChildrenAtHome, SalesReasonName

order by Number_Customers desc;







































