DBCC DROPCLEANBUFFERS;
DBCC FREEPROCCACHE;
GO
DROP TABLE IF EXISTS [Dembiz_DW].dbo.tmpidArea2;
DROP TABLE IF EXISTS [Dembiz_DW].dbo.tmpidArea3;
DROP TABLE IF EXISTS [Dembiz_DW].dbo.tmpidArea4;
DROP TABLE IF EXISTS [Dembiz_DW].dbo.tmpidArea5;
DROP TABLE IF EXISTS [Dembiz_DW].dbo.tmpidArea6;
DROP TABLE IF EXISTS [Dembiz_DW].dbo.tmpidArea7;
DROP TABLE IF EXISTS [Dembiz_DW].dbo.tmpidArea8;
SELECT ISNULL(Dos3.Dossier1, Dos3.idDossier) AS idDossier,
       Dos3.AreaTypeID
INTO [Dembiz_DW].dbo.tmpidArea2
FROM Dembiz.dbo.Dossier Dos3 WITH (NOLOCK)
WHERE Dos3.AreaTypeID <= 2;
SELECT ISNULL(Dos3.Dossier1, Dos3.idDossier) AS idDossier,
       Dos3.AreaTypeID
INTO [Dembiz_DW].dbo.tmpidArea3
FROM Dembiz.dbo.Dossier Dos3 WITH (NOLOCK)
WHERE Dos3.AreaTypeID <= 3;
SELECT ISNULL(Dos3.Dossier1, Dos3.idDossier) AS idDossier,
       Dos3.AreaTypeID
INTO [Dembiz_DW].dbo.tmpidArea4
FROM Dembiz.dbo.Dossier Dos3 WITH (NOLOCK)
WHERE Dos3.AreaTypeID <= 4;
SELECT ISNULL(Dos3.Dossier1, Dos3.idDossier) AS idDossier,
       Dos3.AreaTypeID
INTO [Dembiz_DW].dbo.tmpidArea5
FROM Dembiz.dbo.Dossier Dos3 WITH (NOLOCK)
WHERE Dos3.AreaTypeID <= 5;
SELECT ISNULL(Dos3.Dossier1, Dos3.idDossier) AS idDossier,
       Dos3.AreaTypeID
INTO [Dembiz_DW].dbo.tmpidArea6
FROM Dembiz.dbo.Dossier Dos3 WITH (NOLOCK)
WHERE Dos3.AreaTypeID <= 6;
SELECT ISNULL(Dos3.Dossier1, Dos3.idDossier) AS idDossier,
       Dos3.AreaTypeID
INTO [Dembiz_DW].dbo.tmpidArea7
FROM Dembiz.dbo.Dossier Dos3 WITH (NOLOCK)
WHERE Dos3.AreaTypeID <= 7;
SELECT ISNULL(Dos3.Dossier1, Dos3.idDossier) AS idDossier,
       Dos3.AreaTypeID
INTO [Dembiz_DW].dbo.tmpidArea8
FROM Dembiz.dbo.Dossier Dos3 WITH (NOLOCK)
WHERE Dos3.AreaTypeID <= 8;
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
    WHERE DossierStatus NOT IN ( 5085, 3634, 3635, 5827, 9932259 )
          AND WFU2.enabled = 1
          AND ISNULL(vUserRecordID.IsDeleted, 0) = 0
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
          AND AreaTypeID IS NOT NULL
          AND
          (
              ISNULL(Dos2.IsDeleted, 100) = 0
              OR Dos2.Is_Canceled = 1
          )
          AND (Dos2.AreaTypeID = CASE
                                     WHEN t.idArea = 3 THEN
                                     (
                                         SELECT MAX(AreaTypeID)
                                         FROM Dembiz_DW.dbo.tmpidArea3 WITH (NOLOCK)
                                         WHERE idDossier = t.idDossier
                                     )
                                     WHEN t.idArea = 4 THEN
                                     (
                                         SELECT MAX(AreaTypeID)
                                         FROM Dembiz_DW.dbo.tmpidArea4 WITH (NOLOCK)
                                         WHERE idDossier = t.idDossier
                                     )
                                     WHEN t.idArea = 1 THEN
                                     (
                                         SELECT AreaTypeID
                                         FROM Dembiz.dbo.Dossier Dos3 WITH (NOLOCK)
                                         WHERE Dos3.idDossier = t.idDossier
                                     )
                                     WHEN t.idArea = 2 THEN
                                     (
                                         SELECT MAX(AreaTypeID)
                                         FROM Dembiz_DW.dbo.tmpidArea2 WITH (NOLOCK)
                                         WHERE idDossier = t.idDossier
                                     )
                                     WHEN t.idArea = 5 THEN
                                     (
                                         SELECT MAX(AreaTypeID)
                                         FROM Dembiz_DW.dbo.tmpidArea5 WITH (NOLOCK)
                                         WHERE idDossier = t.idDossier
                                     )
                                     WHEN t.idArea = 6 THEN
                                     (
                                         SELECT MAX(AreaTypeID)
                                         FROM Dembiz_DW.dbo.tmpidArea6 WITH (NOLOCK)
                                         WHERE idDossier = t.idDossier
                                     )
                                     WHEN t.idArea = 7 THEN
                                     (
                                         SELECT MAX(AreaTypeID)
                                         FROM Dembiz_DW.dbo.tmpidArea7 WITH (NOLOCK)
                                         WHERE idDossier = t.idDossier
                                     )
                                     WHEN t.idArea = 8 THEN
                                     (
                                         SELECT MAX(AreaTypeID)
                                         FROM Dembiz_DW.dbo.tmpidArea8 WITH (NOLOCK)
                                         WHERE idDossier = t.idDossier
                                     )
                                 END
              )
    ORDER BY Dos2.idDossier DESC
) Dos2
WHERE Dos2.idDossier IS NOT NULL
ORDER BY 1,2,3;
