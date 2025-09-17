SELECT * FROM WAS.vDocHeader WHERE DocHeaderID = 3250946


SELECT da.AccountingHeadlinesID
     , d.TotalPrice
     , g.GoodsCode
     , g.GoodsTitle
     , doc.AssetCode
     , doc.AssetCentralCode
     , did.ItemQty
     , did.ItemPrice
     , d.DocNo
     , d.DocDate
     , (did.ItemQty * did.ItemPrice) SumPrice
     , did.IsManual
     , did2.DocNo OnDocNo
     , cStatus.Title dstatus
     , dhA.DocNo docNoAcc
     , dhA.DocDate DocDateAcc
     , d.PricingDate
     , (
         SELECT *
         FROM dbo.GetTitleCatalogValue(i.IsJunk)
       ) JunkTitle
     , i.IsJunk
     , CASE i.IsJunk
         WHEN 5557122 THEN (did.ItemQty * did.ItemPrice)
         ELSE 0
       END AS marjoo
     , CASE i.IsJunk
         WHEN 5557121 THEN (did.ItemQty * did.ItemPrice)
         ELSE 0
       END AS esghat
     , CASE i.IsJunk
         WHEN 5557163 THEN (did.ItemQty * did.ItemPrice)
         ELSE 0
       END AS ersaltehran
     , dep.DepartmentName + '-' + dep.DepartmentCode AS depName
     , DocAH.Certain
FROM was.DocHeader d
  LEFT JOIN (
    SELECT dr.DocHeadTargetID
         , dha.DocNo
         , dha.DocDate
         , dha.TotalPrice
    FROM was.DocRelation dr
      INNER JOIN was.Voucher dha ON dr.VoucherID = dha.VoucherID
  ) dhA ON dhA.DocHeadTargetID = d.DocHeaderID
  INNER JOIN WAS.DocItem i ON d.DocHeaderID = i.DocHeaderID
  INNER JOIN WAS.Goods g ON g.GoodsID = i.GoodsID
  INNER JOIN was.DocItemDetail did ON i.DocItemID = did.DocItemID
  LEFT JOIN (
    SELECT DocAssetID
         , AssetCode
         , AssetCentralCode
    FROM was.DocAsset
      INNER JOIN was.Asset ON WAS.Asset.AssetID = WAS.DocAsset.AssetID
  ) doc ON doc.DocAssetID = did.DocAssetID
  INNER JOIN dbo.Department dep ON dep.DepartmentID = WAS.getSourceDepartmentID(d.DocHeaderID)
  INNER JOIN was.CatalogValue cStatus ON cStatus.CatalogValueID = d.DocStatusID
  LEFT JOIN WAS.vDocItemDetail did2 ON did.SourceDocItemDetailID = did2.DocItemDetailID
  LEFT JOIN (
    SELECT *
    FROM (
      SELECT ROW_NUMBER() OVER (PARTITION BY di.DocItemID ORDER BY dar.DocArticleRelationID) Rowid
           , dr.DocHeadTargetID
           , dha.VoucherID
           , dha.DocDate
           , dha.DocNo
           , da.DebtorType
           , da.DirectionType
           , ah.Title AS Certain
           , p.Title AS Headlines
           , dha.DocHeaderType
           , di.DocItemID
           , da.AccountingHeadlinesID
      FROM WAS.Voucher AS dha
        INNER JOIN WAS.DocRelation AS dr ON dr.VoucherID = dha.VoucherID
        INNER JOIN WAS.DocArticle AS da ON da.VoucherID = dha.VoucherID
          AND dha.ConvertStatus = 0
        INNER JOIN WAS.DocArticleRelation AS dar ON dar.DocArticleID = da.DocArticleID
        INNER JOIN WAS.DocItem AS di ON di.DocItemID = dar.DocItemTargetID
        INNER JOIN WAS.AccountingHeadlines AS ah ON ah.AccountingHeadlinesID = da.AccountingHeadlinesID
        LEFT JOIN WAS.AccountingHeadlines p ON p.AccountingHeadlinesID = ah.ParentID
      WHERE ah.ParentID IN (11)
    ) AS f
    WHERE f.Rowid = 1
  ) AS DocAH ON did.DocItemID = DocAH.DocItemID
  LEFT JOIN WAS.DocArticleTypeForDocHeaderItem('{DocHeaderID}') AS da ON did.DocItemID = da.DocItemID
    AND da.AccountingHeadlinesID IN (18, 19)
    AND da.DebtorType = 5557545
    AND da.DirectionType = 5557548
    AND da.AccountingHeadlinesID = DocAH.AccountingHeadlinesID
WHERE d.DocHeaderType = 5557057
  AND ('{OrganizationID}' = '' OR d.OrganizationID = '{OrganizationID}')
  AND ('{DocHeaderID}' = '' OR d.DocHeaderID = '{DocHeaderID}') 