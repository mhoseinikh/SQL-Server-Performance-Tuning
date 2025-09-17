SELECT	da.AccountingHeadlinesID, dh.TotalPrice, g.GoodsCode, g.GoodsTitle, doc.AssetCode, doc.AssetCentralCode, did.ItemQty
		, did.ItemPrice, dh.DocNo, dh.DocDate, (did.ItemQty * did.ItemPrice) AS SumPrice, did.IsManual, did2.DocNo OnDocNo
		, dh.Title AS dstatus, drV.DocNo docNoAcc, drV.DocDate DocDateAcc, dh.PricingDate, cv.Title AS JunkTitle, di.IsJunk
		, CASE di.IsJunk WHEN 5557122 THEN (did.ItemQty * did.ItemPrice) ELSE 0 END AS marjoo
		, CASE di.IsJunk WHEN 5557121 THEN (did.ItemQty * did.ItemPrice) ELSE 0 END AS esghat
		, CASE di.IsJunk WHEN 5557163 THEN (did.ItemQty * did.ItemPrice) ELSE 0 END AS ersaltehran
		, dh.DepartmentName + '-' + dh.DepartmentCode AS depName, DocAH.Certain
	FROM (SELECT dh2.DocHeaderID
					, dh2.DocStatusID
					, dh2.TotalPrice
					, dh2.DocNo
					, dh2.DocDate
					, dh2.PricingDate
					, dep.DepartmentCode
					, dep.DepartmentName
					, cStatus.Title
			FROM was.DocHeader as dh2 WITH(NOLOCK)
				INNER JOIN dbo.Department AS dep WITH(NOLOCK)
					ON dep.DepartmentID = (SELECT TOP 1 dh3.SourceDepartmentID 
												FROM WAS.DocRelation AS dr3
													INNER JOIN WAS.DocHeader AS dh3 ON 
														dh3.DocHeaderID = dr3.DocHeadTargetID 
												WHERE dh3.DocHeaderType = 5556993 
													AND dr3.DocHeadSourceID = dh2.DocHeaderID)
				INNER JOIN was.CatalogValue AS cStatus WITH(NOLOCK)
					ON cStatus.CatalogValueID = dh2.DocStatusID
			WHERE dh2.DocHeaderType = 5557057
				AND ('{OrganizationID}' = '' OR dh2.OrganizationID = '{OrganizationID}')
				AND ('{DocHeaderID}' = '' OR dh2.DocHeaderID = '{DocHeaderID}')) AS dh
		INNER JOIN WAS.DocItem AS di WITH(NOLOCK)
			ON di.DocHeaderID = dh.DocHeaderID
		INNER JOIN was.DocItemDetail AS did WITH(NOLOCK)
			ON did.DocItemID = di.DocItemID
		INNER JOIN WAS.Goods AS g WITH(NOLOCK)
			ON g.GoodsID = di.GoodsID
		INNER JOIN WAS.CatalogValue AS cv WITH(NOLOCK)
			ON cv.CatalogValueID = di.IsJunk
		LEFT JOIN (SELECT did.DocItemDetailID, dh.DocNo
					FROM WAS.DocItemDetail AS did WITH(NOLOCK)
						INNER JOIN WAS.DocItem AS di WITH(NOLOCK)
							ON di.DocItemID = did.DocItemID AND di.Quantity<>0
						INNER JOIN WAS.DocHeader AS dh WITH(NOLOCK)
							ON dh.DocHeaderID = di.DocHeaderID
						INNER JOIN WAS.Goods AS g WITH(NOLOCK)
							ON g.GoodsID = di.GoodsID
						INNER JOIN WAS.UnitType AS ut WITH(NOLOCK)
							ON ut.UnitTypeCode = g.UnitTypeCode) As did2
			ON did2.DocItemDetailID = did.SourceDocItemDetailID
		LEFT JOIN (
			SELECT dr.DocHeadTargetID, v.DocNo, v.DocDate
				FROM WAS.DocRelation AS dr WITH(NOLOCK)
					INNER JOIN WAS.Voucher AS v WITH(NOLOCK) 
						ON v.VoucherID = dr.VoucherID
		) AS drV 
			ON drV.DocHeadTargetID = dh.DocHeaderID
		LEFT JOIN (
			SELECT	DocAssetID, AssetCode, AssetCentralCode
				FROM was.DocAsset AS da2 WITH(NOLOCK)
					INNER JOIN was.Asset AS a2 WITH(NOLOCK) 
						ON a2.AssetID = da2.AssetID
		) AS doc 
			ON doc.DocAssetID = did.DocAssetID
		OUTER APPLY (SELECT	TOP 1
							ah2.Title AS Certain, di2.DocItemID, da2.AccountingHeadlinesID
						FROM WAS.Voucher AS v2 WITH(NOLOCK)
							INNER JOIN WAS.DocRelation AS dr2 WITH(NOLOCK) 
								ON dr2.VoucherID = v2.VoucherID
							INNER JOIN WAS.DocArticle AS da2 WITH(NOLOCK) 
								ON da2.VoucherID = v2.VoucherID 
							INNER JOIN WAS.DocArticleRelation AS dar2 WITH(NOLOCK) 
								ON dar2.DocArticleID = da2.DocArticleID
							INNER JOIN WAS.DocItem AS di2 WITH(NOLOCK)
								ON di2.DocItemID = dar2.DocItemTargetID
							INNER JOIN WAS.AccountingHeadlines AS ah2 WITH(NOLOCK) 
								ON ah2.AccountingHeadlinesID = da2.AccountingHeadlinesID
						WHERE ah2.ParentID IN (11)
							AND v2.ConvertStatus = 0
							AND di2.DocItemID = did.DocItemID
						ORDER BY dar2.DocArticleRelationID
		) AS DocAH 
		LEFT JOIN WAS.DocArticleTypeForDocHeaderItem('{DocHeaderID}') AS da 
			ON da.DocItemID = did.DocItemID
				AND da.AccountingHeadlinesID IN (18, 19)
				AND da.DebtorType = 5557545
				AND da.DirectionType = 5557548
				AND da.AccountingHeadlinesID = DocAH.AccountingHeadlinesID


