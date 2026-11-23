SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		DAHE
-- Create date: 2016-06-18
-- Description:	Displays a list of users that hasn't
--				used INSIKT in the last year.
-- =============================================
CREATE PROCEDURE [dbo].[support_ShowInactiveUsers]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    WITH LastLogin AS
	(
		SELECT usg.UserName AS Username, Max(sl.dtLoginTime) AS LastLogin
		FROM sessionlog AS sl LEFT OUTER JOIN [dbo].[UserSecurityGroup] AS usg ON sl.UserID = usg.UserID
		GROUP BY usg.UserName
	)

	SELECT u.Username as Username
			,u.FullName
			,ll.LastLogin
			,CASE WHEN UserTypeID = 3 THEN 'Manually added' WHEN UserTypeID = 5 THEN 'Synced from AD' WHEN UserTypeID = 7 THEN 'Synced from AD, but with manual settings' END as UserType
	FROM [User] u
	INNER JOIN LastLogin ll on ll.Username = u.UserName
	WHERE LastLogin < DATEADD(yyyy,-1, GETUTCDATE())
	ORDER BY LastLogin
END
GO
