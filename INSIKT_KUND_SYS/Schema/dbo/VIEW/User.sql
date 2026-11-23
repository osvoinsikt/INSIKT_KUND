SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[User]
AS
SELECT
	usr.UserID
	,usr.UserName
	,d.DomainName
	,usr.SID
	,usr.FullName
	,usrAccess.isAdmin
	,usrAccess.isAnalysis
	,usrAccess.isAnalysisManager
	,usrAccess.isAnalysisPrivileged
	,usrAccess.isBudget
	,usrAccess.isBudgetPrivileged
	,usrAccess.isProject
	,usrAccess.isProjectManager
	,usr.EmailAdress
	,usr.LangID
	,usr.FirstDayOfWeek

	,CASE WHEN defaultGroup.UserID IS NULL
		THEN usr.StartReportID
		ELSE defaultGroup.StartReportID END AS StartReportID

	,CASE WHEN defaultGroup.UserID IS NULL
		THEN usr.DefaultDatasourceID
		ELSE defaultGroup.DefaultDatasourceID END AS DefaultDatasourceID

	,CASE WHEN defaultGroup.UserID IS NULL
		THEN usr.DefaultDataSourcePerspectiveID
		ELSE defaultGroup.DefaultDataSourcePerspectiveID END AS DefaultDataSourcePerspectiveID

	,usr.UserTypeID
	,usr.DefaultSecGroupID
	,usrAccess.SecurityGroupCount
	,usr.TimeZone
	,usr.SuperAdmin
	,usr.FirstLoginDate
	,usr.IsDeleted
FROM
	dbo.UserSecurityGroup AS usr LEFT JOIN dbo.Domain d on usr.DomainID = d.ID
		INNER JOIN
		(
			SELECT
				usrA.UserID
				,CAST(COALESCE (roles.AdminUser,0 ) AS bit) AS isAdmin
				,CAST(COALESCE (roles.AnalysisUser,0 ) AS bit) AS isAnalysis
				,CAST(COALESCE (roles.AnalysisManager,0 ) AS bit) AS isAnalysisManager
				,CAST(COALESCE (roles.AnalysisPrivileged,0 ) AS bit) AS isAnalysisPrivileged
				,CAST(COALESCE (roles.BudgetUser,0 ) AS bit) AS isBudget
				,CAST(COALESCE (roles.BudgetPrivileged,0 ) AS bit) AS isBudgetPrivileged
				,CAST(COALESCE (roles.ProjectUser,0 ) AS bit) AS isProject
				,CAST(COALESCE (roles.ProjectManager,0 ) AS bit) AS isProjectManager
				,COUNT(DISTINCT grpRelCountGrp.UserID) AS SecurityGroupCount
			FROM
				dbo.UserSecurityGroup AS usrA 

					LEFT OUTER JOIN dbo.UserSecurityGroupRelation AS grpRelCount ON 
						grpRelCount.UserID = usrA.UserID
					LEFT OUTER JOIN dbo.UserSecurityGroup As grpRelCountGrp ON
						grpRelCountGrp.UserID = grpRelCount.SecurityGroupID and grpRelCountGrp.IsDeleted = 0

					LEFT OUTER JOIN dbo.UserEffectiveRoles AS roles ON
						usrA.UserID = roles.UserID

			WHERE
				(usrA.UserTypeID < 64) AND usrA.IsDeleted = 0
			GROUP BY 
				usrA.UserID,
				roles.AdminUser,
				roles.AnalysisUser,
				roles.AnalysisManager,
				roles.AnalysisPrivileged,
				roles.BudgetUser,
				roles.BudgetPrivileged,
				roles.ProjectUser,
				roles.ProjectManager
		) AS usrAccess ON 
			usrAccess.UserID = usr.UserID 
		LEFT OUTER JOIN dbo.UserSecurityGroup AS defaultGroup ON 
			defaultGroup.UserID = usr.DefaultSecGroupID
WHERE
	usr.IsDeleted = 0 and
	(usr.UserTypeID = 3 OR
		(usr.UserTypeID = 5 OR usr.UserTypeID = 7)
		AND 
		(usrAccess.SecurityGroupCount > 0 OR usr.DomainID is null)
	)
GO
