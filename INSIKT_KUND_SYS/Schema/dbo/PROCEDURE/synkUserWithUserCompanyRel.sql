SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************
 #Desc: 		Will synkronize the tables [UserOrganisationRelation], [FCProjectUserRelation] and [UserCompanyRel]
				All users that only exists in the table [UserCompanyRel] will be removed from the table [UserCompanyRel].
				If users exists in the table [UserOrganisationRelation] or [FCProjectUserRelation] but do not exists in the table [UserCompanyRel],
				they will be added to the table [UserCompanyRel].
				Instead of creating one complex sql, serveral tempoary tables are used to perform the task in steps.
				This is performed to make it easier to understand
 #Used By:		-
 #InParam:		-
 #ResultSet:		-
 #
 #Returns:		-
 #Owner:		DBO
 #Creator:		Hans Hörberg
 #CreateDate:		2012-10-08
 #Modified by:		-
 #ModifiedDate:		-
 
 #Log:

********************************************************************/
CREATE procedure [dbo].[synkUserWithUserCompanyRel]
AS
--The amount of companies in this INSIKT configuration.
DECLARE @COMPANIES INT
SELECT
	@COMPANIES=count(*)
FROM
	Company

--There is no point to add users to the [UserCompanyRel] table if the configuration only have one company.
IF(@COMPANIES > 1) BEGIN
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--Will be filled with all user that are in SYNK between [UserOrganisationRelation] and [UserCompanyRel]
	DECLARE @OKUSERCOMPANY TABLE
	(
		UserID INT NOT NULL,
		CompanyID INT NOT NULL
	)
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--Will be filled with all user that are in SYNK between [FCProjectUserRelation] and [UserCompanyRel]
	DECLARE @OKUSERCOMPANY_PROJECT TABLE
	(
		UserID INT NOT NULL,
		CompanyID INT NOT NULL
	)
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--The UNION of @OKUSERCOMPANY and @OKUSERCOMPANY_PROJECT
	DECLARE @OKUSERCOMPANY_ALL TABLE
	(
		UserID INT NOT NULL,
		CompanyID INT NOT NULL
	)
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	---Will be filled with the users to be added to [UserCompanyRel] FROM the table [UserOrganisationRelation]
	DECLARE @ADUSERCOMPANY TABLE
	(
		UserID INT NOT NULL,
		CompanyID INT NOT NULL
	)
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	---Will be filled with the users to be added to [UserCompanyRel] FROM the table [FCProjectUserRelation]
	DECLARE @ADUSERCOMPANY_PROJECT TABLE
	(
		UserID INT NOT NULL,
		CompanyID INT NOT NULL
	)
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	---Will be filled with the all users to be added to [UserCompanyRel]
	DECLARE @ADUSERCOMPANY_ALL TABLE
	(
		UserID INT NOT NULL,
		CompanyID INT NOT NULL
	)
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	---Will be filled with the all the new users to be added to [UserCompanyRel]. 
	DECLARE @ADUSERCOMPANY_NEW TABLE
	(
		UserID INT NOT NULL,
		CompanyID INT NOT NULL
	)
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--Will be filled with the users to be removed FROM [UserCompanyRel]
	DECLARE @REMOVECOMPANY TABLE
	(
		UserID INT NOT NULL,
		CompanyID INT NOT NULL
	)
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	/************************************************************************************************************************************************************************************/
	--Get all users that exists in both [FCProjectUserRelation] and [UserCompanyRel] and save in temp table @OKUSERCOMPANY_PROJECT
	INSERT INTO @OKUSERCOMPANY_PROJECT 
	SELECT DISTINCT
		  projUserRel.[UserID] As UserID
		  ,projUserRel.[CompanyID] As CompanyID
	FROM [FCProjectUserRelation] projUserRel
		   JOIN [UserCompanyRel] company On projUserRel.[UserID] = company.[UserID] And projUserRel.[CompanyID] = company.[CompanyID]
	/************************************************************************************************************************************************************************************/
	--Get all users that exists in both [UserOrganisationRelation] and [UserCompanyRel] and save in temp table @OKUSERCOMPANY
	INSERT INTO @OKUSERCOMPANY 
	SELECT DISTINCT
		  orgrel.[UserID] As UserID
		  ,orgrel.[CompanyID] As CompanyID
	FROM [UserOrganisationRelation] orgrel
		   JOIN [UserCompanyRel] company On orgrel.[UserID] = company.[UserID] And orgrel.[CompanyID] = company.[CompanyID]
	/************************************************************************************************************************************************************************************/
	--Get all users that are in SYNK for both [UserOrganisationRelation] and [FCProjectUserRelation] with the table [UserCompanyRel]
	INSERT INTO @OKUSERCOMPANY_ALL
	SELECT DISTINCT * FROM (SELECT * FROM @OKUSERCOMPANY UNION SELECT * FROM @OKUSERCOMPANY_PROJECT) s1
	/************************************************************************************************************************************************************************************/
	--Get all users that only exists in [UserCompanyRel] and save in temp table @REMOVECOMPANY. These should be removed to the table [UserCompanyRel]
	INSERT INTO @REMOVECOMPANY 
	SELECT DISTINCT
	  company.[UserID],
	  company.[CompanyID]
	FROM
		[UserCompanyRel] company
	  LEFT JOIN
		@OKUSERCOMPANY_ALL okuc
	  ON 
		company.[UserID] = okuc.[UserID] And company.[CompanyID] = okuc.[CompanyID]
	WHERE 
	  okuc.[UserID] IS NULL

	/************************************************************************************************************************************************************************************/
	--Get all users that only exists in [FCProjectUserRelation] and save in temp table @ADUSERCOMPANY. These should be added to the table [UserCompanyRel]
	INSERT INTO @ADUSERCOMPANY_PROJECT 
	SELECT DISTINCT
	  projUserRel.[UserID],
	  projUserRel.[CompanyID]
	FROM
		[FCProjectUserRelation] projUserRel
	  LEFT JOIN
		@OKUSERCOMPANY okuc
	  ON 
		projUserRel.[UserID] = okuc.[UserID] And projUserRel.[CompanyID] = okuc.[CompanyID]
	WHERE 
	  okuc.[UserID] IS NULL
	/************************************************************************************************************************************************************************************/
	--Get all users that only exists in [UserOrganisationRelation] and save in temp table @ADUSERCOMPANY. These should be added to the table [UserCompanyRel]
	INSERT INTO @ADUSERCOMPANY 
	SELECT DISTINCT
	  orgrel.[UserID],
	  orgrel.[CompanyID]
	FROM
		[UserOrganisationRelation] orgrel
	  LEFT JOIN
		@OKUSERCOMPANY okuc
	  ON 
		orgrel.[UserID] = okuc.[UserID] And orgrel.[CompanyID] = okuc.[CompanyID]
	WHERE 
	  okuc.[UserID] IS NULL
	/************************************************************************************************************************************************************************************/
	--Get all users to be inserted into the table [UserCompanyRel].
	INSERT INTO @ADUSERCOMPANY_ALL
	SELECT DISTINCT * FROM (SELECT * FROM @ADUSERCOMPANY UNION SELECT * FROM @ADUSERCOMPANY_PROJECT) s1
	/************************************************************************************************************************************************************************************/
	--Get all new users/company combinations to be insterted in the table [UserCompanyRel] set to default.
	INSERT INTO @ADUSERCOMPANY_NEW
	SELECT DISTINCT
	  allUsers.[UserID],
	  MIN(allUsers.CompanyID)
	FROM
		@ADUSERCOMPANY_ALL allUsers
	  LEFT JOIN
		[UserCompanyRel] company
	  ON 
		allUsers.[UserID] = company.[UserID] AND company.isDefault=1
	WHERE 
	  company.[UserID] IS NULL
	GROUP BY
		allUsers.UserID
	/************************************************************************************************************************************************************************************/
	/*##################################################################################################################################################################################*/
	--Delete users from [UserCompanyRel] that do not have any permissions in the organisation.
	DELETE FROM [UserCompanyRel]
	WHERE 
		ID IN (
			SELECT 
				company.ID
			FROM
				@REMOVECOMPANY rc
			LEFT JOIN
				[UserCompanyRel] company
			  ON 
				company.[UserID] = rc.[UserID] And company.[CompanyID] = rc.[CompanyID]
		)
	/*##################################################################################################################################################################################*/
	--Insert new users to the table [UserCompanyRel] with this default company
	INSERT INTO [UserCompanyRel]
	select [UserID]
			,[CompanyID]
			,1 As [isDefault] from @ADUSERCOMPANY_NEW
	/*##################################################################################################################################################################################*/	
	--Inser users with default not set for the company
	INSERT INTO [UserCompanyRel]
	SELECT DISTINCT
		   allUsers.[UserID]
		  ,allUsers.[CompanyID]
		  ,0 As [isDefault]
	FROM
		@ADUSERCOMPANY_ALL allUsers
	  LEFT JOIN
		@ADUSERCOMPANY_NEW new
	  ON 
		allUsers.[UserID] = new.[UserID] And allUsers.CompanyID = new.CompanyID
	WHERE 
	  new.[UserID] IS NULL
	/*##################################################################################################################################################################################*/
	--All users that lacks a default company will get the company with the lowest identification as default company.
	UPDATE [UserCompanyRel]  
	SET isDefault = 1
	FROM
		(SELECT
		  company_2.[UserID],
		  MIN(company_2.[CompanyID]) AS [CompanyID]
		FROM
			[UserCompanyRel] company_2
		LEFT JOIN		
			(SELECT DISTINCT
			  company_1.[UserID]
			FROM
				[UserCompanyRel] company_1
			WHERE 
			  company_1.isDefault=1) s1
		ON
			s1.[UserID] = company_2.[UserID]
		WHERE
			s1.UserID IS NULL
		GROUP BY
			company_2.[UserID]) AS s2
	WHERE
		[UserCompanyRel].[UserID] = s2.UserID AND
		[UserCompanyRel].[CompanyID] = s2.[CompanyID]
	/*##################################################################################################################################################################################*/
END





GO
