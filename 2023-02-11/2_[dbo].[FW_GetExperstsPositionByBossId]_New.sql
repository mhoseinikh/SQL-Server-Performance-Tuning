
EXECUTE [dbo].[usp_GetExperstsPositionByBossId] @UserID=956
GO
SELECT *
	FROM [dbo].[FW_GetExperstsPositionByBossId](956)
	ORDER BY 1
