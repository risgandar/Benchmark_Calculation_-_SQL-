BULK INSERT Carrier
FROM "C:\Users\SQL Server Management Studio\Carrier.csv"
WITH ship_costs AS (  -- Common Table Expression is easier to read than subquery
  SELECT 
    DeliveryDateYYYYMM, 
    LMShipClassID,
    SUM(SFX_Ship_Cost) AS SFX_Ship_Cost, 
    ROUND(SUM(PO_fraction)) AS POs  -- rounding at 0 digit is the default
  WHERE IsCancelledFlag = 0
    AND DirtyShipping_Flag = 0
    AND IsOwnAccountFlag = 0
    AND DeliveryDate <= LAST_DAY(DATE_SUB(CURRENT_DATE(), INTERVAL 2 MONTH)) 
    AND DeliveryDate >= LAST_DAY(DATE_SUB(CURRENT_DATE(), INTERVAL 4 MONTH))
    AND (
      LMSCarrierConsolidated LIKE "LP BJ%" 
      OR LMSCarrierConsolidated LIKE "LP Panth%" 
      OR LMSCarrierConsolidated LIKE "LP XD%" 
      OR LMSCarrierConsolidated LIKE "LP Arrow%"
    ) 
  GROUP BY 1, 2  -- No need to provide column name explicitly
)
SELECT
  LMShipClassID,
  SUM(SFX_Ship_Cost) / SUM(POs) AS SFX_Ship_Cost_PO -- Sum and div in a single step
FROM ship_costs
WHERE
  LMShipClassID IN (2, 3) -- More flexible filtering here, not early
GROUP BY 1
ORDER BY 1  -- Default is ASC
;
