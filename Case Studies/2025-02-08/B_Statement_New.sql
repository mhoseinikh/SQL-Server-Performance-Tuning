DBCC DROPCLEANBUFFERS;
DBCC FREEPROCCACHE;
GO
DROP TABLE IF EXISTS [Dembiz_DW].dbo.tmpidArea;
CREATE TABLE [Dembiz_DW].[dbo].[tmpidArea](
	[TType] [INT] NOT NULL,
	[idDossier] [BIGINT] NOT NULL,
	[AreaTypeID] [INT] NULL
	CONSTRAINT tmpidArea_PK PRIMARY KEY(TType,idDossier)
) ON [PRIMARY]
WITH(DATA_COMPRESSION=PAGE)
GO

INSERT INTO [Dembiz_DW].dbo.tmpidArea(TType,idDossier,AreaTypeID)
SELECT 2 AS TType,
	   ISNULL(D.Dossier1, D.idDossier) AS idDossier,
       MAX(D.AreaTypeID) AS AreaTypeID
	FROM Dembiz.dbo.Dossier D WITH (NOLOCK)
	WHERE D.AreaTypeID <= 2
	GROUP BY ISNULL(D.Dossier1, D.idDossier)
UNION
SELECT 3 AS TType,ISNULL(D.Dossier1, D.idDossier) AS idDossier,MAX(D.AreaTypeID) AS AreaTypeID
	FROM Dembiz.dbo.Dossier D WITH (NOLOCK)
	WHERE D.AreaTypeID <= 3
	GROUP BY ISNULL(D.Dossier1, D.idDossier)
UNION
SELECT 4 AS TType,ISNULL(D.Dossier1, D.idDossier) AS idDossier,MAX(D.AreaTypeID) AS AreaTypeID
	FROM Dembiz.dbo.Dossier D WITH (NOLOCK)
	WHERE D.AreaTypeID <= 4
	GROUP BY ISNULL(D.Dossier1, D.idDossier)
UNION
SELECT 5 AS TType,ISNULL(D.Dossier1, D.idDossier) AS idDossier,MAX(D.AreaTypeID) AS AreaTypeID
	FROM Dembiz.dbo.Dossier D WITH (NOLOCK)
	WHERE D.AreaTypeID <= 5
	GROUP BY ISNULL(D.Dossier1, D.idDossier)
UNION
SELECT 6 AS TType,ISNULL(D.Dossier1, D.idDossier) AS idDossier,MAX(D.AreaTypeID) AS AreaTypeID
	FROM Dembiz.dbo.Dossier D WITH (NOLOCK)
	WHERE D.AreaTypeID <= 6
	GROUP BY ISNULL(D.Dossier1, D.idDossier)
UNION
SELECT 7 AS TType,ISNULL(D.Dossier1, D.idDossier) AS idDossier,MAX(D.AreaTypeID) AS AreaTypeID
	FROM Dembiz.dbo.Dossier D WITH (NOLOCK)
	WHERE D.AreaTypeID <= 7
	GROUP BY ISNULL(D.Dossier1, D.idDossier)
UNION
SELECT 8 AS TType,ISNULL(D.Dossier1, D.idDossier) AS idDossier,MAX(D.AreaTypeID) AS AreaTypeID
	FROM Dembiz.dbo.Dossier D WITH (NOLOCK)
	WHERE D.AreaTypeID <= 8
	GROUP BY ISNULL(D.Dossier1, D.idDossier)


--INSERT INTO [Dembiz_DW].dbo._DossierCopyofOrginalDossier_tmp
SELECT t.idDossier AS tidDossier,
       t.idArea AS tidArea,
       Dos2.idDossier,
       Dos2.TrackingCode,
       Dos2.IsDeleted,
       Dos2.EblaghShode
FROM
(
    SELECT DISTINCT
           vUserRecordID.idDossier,
           WFU2.idArea
    FROM Dembiz_DW.dbo.VuserRecordDenormal vUserRecordID
        INNER JOIN Dembiz.dbo.WFUSER WFU2 WITH (NOLOCK)
            ON vUserRecordID.idUser = WFU2.idUser
		INNER JOIN Dembiz.dbo.Dossier Dos2 WITH (NOLOCK)
			ON ISNULL(Dos2.Dossier1, Dos2.idDossier) = vUserRecordID.idDossier
    WHERE vUserRecordID.DossierStatus NOT IN ( 5085, 3634, 3635, 5827, 9932259 )
          AND WFU2.enabled = 1
          AND ISNULL(vUserRecordID.IsDeleted, 0) = 0
			AND (Dos2.IsDeleted = 0 OR Dos2.Is_Canceled = 1)
			AND Dos2.AreaTypeID IS NOT NULL
) AS t
    OUTER APPLY
(
    SELECT TOP 1
           Dos2.idDossier,
           Dos2.TrackingCode,
           Dos2.IsDeleted,
           EblaghShode
    FROM Dembiz.dbo.Dossier Dos2 WITH (NOLOCK)
    WHERE ISNULL(Dos2.Dossier1, Dos2.idDossier) = t.idDossier
          AND (Dos2.IsDeleted = 0 OR Dos2.Is_Canceled = 1)
          AND Dos2.AreaTypeID IS NOT NULL
          AND (Dos2.AreaTypeID = CASE
                                     WHEN t.idArea = 1 THEN
                                     (
                                         SELECT D3.AreaTypeID
											 FROM Dembiz.dbo.Dossier D3 WITH (NOLOCK)
											 WHERE D3.idDossier = t.idDossier
                                     )
                                     WHEN t.idArea IN (2,3,4,5,6,7,8) THEN
                                     (
                                         SELECT t2.AreaTypeID
											 FROM Dembiz_DW.dbo.tmpidArea AS t2 WITH (NOLOCK)
											 WHERE t2.Ttype=t.idArea AND t2.idDossier = t.idDossier
                                     )
                                 END
              )
    ORDER BY Dos2.idDossier DESC
) Dos2
WHERE Dos2.idDossier IS NOT NULL
ORDER BY 1,2,3;
