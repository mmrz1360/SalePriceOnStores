WITH CTE_SalePriceView AS (SELECT * FROM
    (SELECT R = ROW_NUMBER() OVER(PARTITION BY ItemID, StoreID ORDER BY EffectiveDate DESC),
	StoreID,
	ItemID,
	EffectiveDate,
	PriceAmount,
	ConsumerPrice
	FROM ItemSalePriceView) KK
    WHERE KK.R = 1),

	CTE_FINAL AS
   (SELECT RN = ROW_NUMBER() OVER(PARTITION BY ItemID, S.StoreID ORDER BY EffectiveDate DESC),
	S.StoreID,
	ItemID,
	EffectiveDate,
	PriceAmount,
	ConsumerPrice 
	FROM CTE_SalePriceView AS CW WITH(NOLOCK)

	INNER JOIN Store AS S WITH(NOLOCK)
	ON S.StoreID = CW.StoreID OR CW.StoreID IS NULL 
)

SELECT F.StoreID ,F.ItemID ,F.PriceAmount ,F.ConsumerPrice INTO #P
FROM CTE_FINAL AS F 
WHERE F.RN=1;


SELECT
SK.StockID AS [branch_id],
CASE
WHEN SK.StockID='30F7D745-A8EA-4B51-BA35-C3B7B2529671' THEN '2019010208414573116'
WHEN SK.StockID='5BC22131-FEA0-4B6F-9DC4-33EA0EE9461D' THEN '2019010208414573108'
WHEN SK.StockID='D2B24A93-4467-4925-9C09-E01D88C023E4' THEN '2019010208414573109'
WHEN SK.StockID='FAA85F0C-04EF-40BB-A143-3304C30790E3' THEN '2019010208414573110' 
WHEN SK.StockID='2796753F-E584-4D51-BF21-4F38CFC155FD' THEN '2019010208414573119' 
WHEN SK.StockID='7E427A74-4469-46BB-9822-183E9BA328BD' THEN '2019010208414573111' 
WHEN SK.StockID='A833C867-0D97-4E60-835E-34F6C54D7FBA' THEN '2019010208414573120' 
WHEN SK.StockID='0988C3EC-C135-42F5-BA02-8E4B0DE5A3AC' THEN '2019010208414573121' 
WHEN SK.StockID='688CB05E-C790-462B-96C5-AB14E1B53549' THEN '2019010208414573112' 
WHEN SK.StockID='519843A2-13C2-4751-BEC4-4013920079D1' THEN '2019010208414573113' 
WHEN SK.StockID='1227DE65-371E-4C6F-AED9-D8B352034EAE' THEN '2019010208414573114' 
WHEN SK.StockID='CC5CADF3-4ECB-4AB1-9AB8-81FC82FB7C50' THEN '2019010208414573115' 
WHEN SK.StockID='B71DB913-9194-45FE-952A-14EF9F4B3E27' THEN '2019010208414573117' 
WHEN SK.StockID='A9960C2D-DE32-4CDA-A1B4-9954EF186DB7' THEN '2019010208414573106' 
WHEN SK.StockID='4D2C5513-04A1-4DB1-9B13-893422BBA6D1' THEN '2019010208414573118'
END [branch_id],

I.ItemID AS [goods_id],
2 AS [status],
CAST(SUM(ISS.ReservedUnitCount + ISS.CurrentUnitCount) AS DECIMAL(11,3)) [count],
CAST(P.ConsumerPrice AS INT) AS [price_consumer],
CAST(P.PriceAmount AS INT) AS [price_pay],
ISS.AllowRecieve AS [allow_recieve]

FROM ItemStockState AS ISS WITH(NOLOCK)

INNER JOIN Stock AS SK WITH(NOLOCK)
ON SK.StockID = ISS.StockID

LEFT JOIN #P AS P WITH(NOLOCK)
ON P.ItemID = ISS.ItemID AND P.StoreID = SK.StoreID

INNER JOIN Item AS I WITH(NOLOCK)
ON I.ItemID=ISS.ItemID

INNER JOIN DictionaryTranslations AS DT WITH(NOLOCK)
ON DT.DictionaryID = I.UnitOfMeasureID AND DT.LanguageID=314

WHERE P.ConsumerPrice IS NOT NULL
AND P.PriceAmount IS NOT NULL
AND SK.StoreID IS NOT NULL

GROUP BY I.ItemID, SK.StockID, P.PriceAmount, P.ConsumerPrice, ISS.AllowRecieve 
HAVING SUM(ISS.CurrentUnitCount + ISS.ReservedUnitCount) IS NOT NULL

DROP TABLE #P;