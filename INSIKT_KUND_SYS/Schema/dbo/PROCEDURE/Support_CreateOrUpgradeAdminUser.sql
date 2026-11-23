SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Support_CreateOrUpgradeAdminUser]
	@userName varchar(255) = 'trimma\yoshi',
	@domain varchar(255) = 'trimma',
	@fullName varchar(255) = 'Yoshi'
AS
BEGIN
	DECLARE	@userID int
	DECLARE @emailAddress AS VARCHAR(50) = CASE
		WHEN @userName LIKE '%@%' THEN @userName -- Use email if the username is an email address
		ELSE NULL
	END

	EXEC [dbo].[insUserSecurityGroup]
			@UserName = @userName,
			@domainName = @domain,
			@SID = N'123',
			@FullName = @fullName,
			@isAdmin = 1,
			@isAnalysisUser = 1,
			@isAnalysisManager = 1,
			@isAnalysisPrivileged = 1,
			@isBudget = 1,
			@isBudgetPrivileged = 1,
			@isProject = 1,
			@isProjectManager = 1,
			@EmailAdress = @emailAddress,
			@LangID = 2,
			@StartReportID = NULL,
			@DefaultDatasourceID = NULL,
			@UserTypeID = 3,
			@DefaultSecGroupID = NULL,
			@SuperAdmin = NULL,

			@UserID = @userID OUTPUT

	SELECT @userID as UserID
END
GO
