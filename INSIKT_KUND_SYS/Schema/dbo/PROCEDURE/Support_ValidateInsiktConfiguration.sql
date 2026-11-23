SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ============================================= 
-- This procedure is used to validate the configuration of INSIKT.  
-- Run it to get a report of invalid configurations and configurations not according to best practice. 
-- Levels: 
-- 1 - Info 
-- 2 - Warning 
-- 3 - Fatal 
-- ============================================= 
CREATE PROCEDURE [dbo].[Support_ValidateInsiktConfiguration] 
AS 
BEGIN 
	-- SET NOCOUNT ON added to prevent extra result sets from 
	-- interfering with SELECT statements. 
	SET NOCOUNT ON; 
 
	DECLARE @ValidationError table  
	(   
		ValidationTitle nvarchar(255) not null,  
		ValidationDescription nvarchar(MAX) not null,   
		ValidationLevel int not null 
	) 
 
 
 
---------------------------------------------------------------------------------- 
-- Test:		Blocked months not used 
-- Validation:	Check that the UseBlockedMonth FCProperty is set when the timedimension is assign to the column axis in a project budget. 
-- Level:		Warning (2) 
---------------------------------------------------------------------------------- 
BEGIN  
 
	IF EXISTS( 
		SELECT *  
		FROM FCElementProperty ep_247 
		INNER JOIN FCElementProperty ep_6 on ep_247.FCTypeID = ep_6.FCTypeID AND ep_247.CompanyID = ep_6.CompanyID AND ep_6.PropertyID = 6 AND (ep_6.ValueString LIKE '%tid%' OR ep_6.ValueString LIKE '%period%') 
		LEFT OUTER JOIN FCElementProperty ep_318 on ep_247.FCTypeID = ep_318.FCTypeID AND ep_247.CompanyID = ep_318.CompanyID AND ep_318.PropertyID = 318  
		WHERE ep_247.PropertyID = 247 
			AND (ep_318.ValueNumeric = 0 OR ep_318.ValueNumeric IS NULL) 
	) 
	BEGIN 
		INSERT INTO  @ValidationError 
		SELECT 'Blocked months not used', 'FCProperty 318 Use blocked month is not activated on a project budget FCType with time on the column axis. This is not a recommended configuration', 2 
	END 
 
 
END 
---------------------------------------------------------------------------------------- 
 
 
 
---------------------------------------------------------------------------------- 
-- Test:		User settings for INSIKT Service not configured 
-- Validation:	Check if any of these settings are missing 
-- Level:		Fatal (3) 
---------------------------------------------------------------------------------- 
BEGIN 
DECLARE @asAdminUser nvarchar(max) = (SELECT TOP 1 ValueString FROM CurrentConfiguration where Name = 'ASAdminUser') 
	IF @asAdminUser IS NULL 
	BEGIN 
		INSERT INTO @ValidationError 
		SELECT 'ASAdminUser not set', 'SystemProperty ASAdminUser (1077) and ASAdminUserPassword (1078) must be configured', 3 
	END 
	ELSE IF NOT EXISTS (SELECT * FROM UserSecurityGroup WHERE lower(UserName) = lower(@asAdminUser) AND IsDeleted = 0) 
	BEGIN 
		INSERT INTO @ValidationError 
		SELECT 'ASAdminUser is not an INSIKT user', 'The user configured in SystemProperty ASAdminUser (1077) must be a user in INSIKT', 3 
	END 
END 
---------------------------------------------------------------------------------------- 
 
 
---------------------------------------------------------------------------------- 
-- Test:		FCElementProperty duplicates 
-- Validation:	Check if there are any FCElementProperty duplicates that aren't IsMultiValue. 
-- Level:		Warning (2) 
---------------------------------------------------------------------------------- 
BEGIN  
 
	-- Get the FCElementProperty attributes that has deuplicates. 
	SELECT ep.PropertyID, ep.FCTypeID, ep.CompanyID, ep.FCElementID, ep.ElementKey, ep.OptionalCode, ep.AdditionalFilter, ep.UserID 
	INTO #DuplicateCheck_DuplicateValues 
	FROM FCElementProperty ep 
	JOIN FCProperty p ON (ep.PropertyID = p.ID) 
	WHERE p.IsMultiValue = 0 
	GROUP BY ep.PropertyID, ep.FCTypeID, ep.CompanyID, ep.FCElementID, ep.ElementKey, ep.OptionalCode, ep.AdditionalFilter, ep.UserID 
	HAVING COUNT(*) > 1 
 
	-- Get all the FCElementProperty IDs that has the duplicate attributes. 
	SELECT p.ID AS PropertyID, ep.ID AS ElementPropertyID 
	INTO #DuplicateCheck_PropertyIDAndElementPropertyID 
	FROM FCElementProperty ep  
	JOIN #DuplicateCheck_DuplicateValues dp 
	ON ( 
		ep.PropertyID = dp.PropertyID  
		AND ep.FCTypeID = dp.FCTypeID  
		AND ep.CompanyID = dp.CompanyID  
		AND ep.FCElementID = dp.FCElementID  
		AND ep.ElementKey = dp.ElementKey  
		AND (ep.OptionalCode = dp.OptionalCode OR (ep.OptionalCode IS NULL AND dp.OptionalCode IS NULL) ) 
		AND (ep.AdditionalFilter = dp.AdditionalFilter OR (ep.AdditionalFilter IS NULL AND dp.AdditionalFilter IS NULL) ) 
		AND (ep.UserID = dp.UserID OR (ep.UserID IS NULL AND dp.UserID IS NULL) ) 
	) 
	JOIN FCProperty p ON (ep.PropertyID = p.ID) 
 
	-- Merge the FCElementProperty IDS to a long string. 
	SELECT  
	  PropertyID, 
	  STUFF(( 
		SELECT ', ' + CAST([ElementPropertyID] AS VARCHAR(MAX))  
		FROM #DuplicateCheck_PropertyIDAndElementPropertyID  
		WHERE (PropertyID = Results.PropertyID)  
		FOR XML PATH(''),TYPE).value('(./text())[1]','VARCHAR(MAX)') 
	  ,1,2,'') AS IDS 
	INTO #DuplicateCheck_PropertyIDAndElementPropertyIDs 
	FROM #DuplicateCheck_PropertyIDAndElementPropertyID Results 
	GROUP BY PropertyID 
 
	-- Construct Warning messages. 
	INSERT INTO @ValidationError 
	SELECT 
		'Duplicate FCElementProperties on ' + p.Name, 
		'The FCProperty ' + p.Name + ' has duplicate FCElementProperty values. See IDs ' + ids.IDS, 
		2 
	FROM #DuplicateCheck_PropertyIDAndElementPropertyIDs ids 
	JOIN FCProperty p on (ids.PropertyID = p.ID) 
 
	-- Drop temp tables. 
	DROP TABLE #DuplicateCheck_DuplicateValues 
	DROP TABLE #DuplicateCheck_PropertyIDAndElementPropertyID 
	DROP TABLE #DuplicateCheck_PropertyIDAndElementPropertyIDs 
END 
---------------------------------------------------------------------------------------- 
 
 
 
---------------------------------------------------------------------------------- 
-- Test:		FCProperties that provide functionality but are no longer implemented in the application 
-- Validation:	Check if any of these settings are set 
-- Level:		Fatal (3) 
---------------------------------------------------------------------------------- 
BEGIN 
 
	insert into @ValidationError 
	select distinct 
		'Unsupported setting ' + p.[Name], 
		'The FCProperty ' + p.[Name] + ' is configured, but it is no longer implemented in the application. You should remove the setting from FCElementProperty if it is no longer required in this installation. Otherwise, contact a developer about re-implementing the functionality.', 
		3 
	from FCProperty p 
	join FCElementProperty ep on (p.ID = ep.PropertyID) 
	where p.Deprecated = 1 
 
END 
---------------------------------------------------------------------------------------- 
 
 
 
---------------------------------------------------------------------------------- 
-- Test:		Domains have a valid FQDN
-- Validation:	Check if FQDN is set for all LDAP domains
-- Level:		Warning (2) 
---------------------------------------------------------------------------------- 
BEGIN 
	insert into @ValidationError 
	select 
		'Fully Qualified Domain Name is not set', 
		'FQDN for domain ID ' + convert(varchar(10), d.ID) + ' is not set. All domains using LDAP protocol should have FQDN set.', 
		2 
	from dbo.Domain d 
		where d.ProtocolTypeID = 1 and (d.FullyQualifiedDomainName is null or ltrim(rtrim(d.FullyQualifiedDomainName)) = '') 
END 
---------------------------------------------------------------------------------------- 


----------------------------------------------------------------------------------
-- Test:		Domains are successfully synced
-- Validation:	Check that all sync-enabled domains have been successfully synced recently
-- Level:		Fatal (3)
----------------------------------------------------------------------------------
BEGIN
	declare @syncEnabled int = (select top 1 ValueNumeric from SystemSetting where SystemPropertyID = 9104)
	if @syncEnabled = 1
	begin
		insert into @ValidationError
		select
			'Domain fails to synchronize',
			'The domain with ID ' + convert(varchar(10), d.ID) + ' has not been successfully synchronized in the last day. Ensure that the domain settings are accurate.',
			3
		from dbo.Domain d
		where
			-- LDAP, WinNT, Azure
			d.ProtocolTypeID in (1, 2, 3) and d.IsDeleted = 0 and d.SyncEnabled = 1 and
			(LastSuccessfulSync is null or LastSuccessfulSync < dateadd(day, -1, getutcdate())) and
			-- At least one group to sync
			exists (select * from UserSecurityGroup g where g.DomainID = d.ID and g.UserTypeID = 64 and g.IsDeleted = 0)
	end
END
----------------------------------------------------------------------------------------


---------------------------------------------------------------------------------- 
-- Test:		Check if any users share email 
-- Validation:	Check if any users share email 
-- Level:		Warning (2) 
---------------------------------------------------------------------------------- 
BEGIN 
 
	SELECT EmailAdress 
	INTO #Duplicates 
	FROM UserSecurityGroup 
		WHERE EmailAdress is not null AND EmailAdress <> '' and IsDeleted = 0 
	GROUP BY EmailAdress 
	HAVING COUNT(*) > 1 
 
	DECLARE @Duplicates nvarchar(max) = '' 
 
	SELECT  
		@Duplicates += FullName + ' (' + EmailAdress + '), '  
	FROM [User] 
	WHERE 
		EmailAdress in (SELECT EmailAdress FROM #Duplicates) 
 
	IF @Duplicates <> '' 
	BEGIN 
		INSERT INTO @ValidationError 
		SELECT 'Users with the same email address', 'The following users do not have a unique email address: ' + @Duplicates, 2 
	END 
	 
	DROP TABLE #Duplicates 
END 
---------------------------------------------------------------------------------------- 
 
 
---------------------------------------------------------------------------------- 
-- Test:		Checks for invalid internal users 
-- Validation:	Check if any users have different username and email 
-- Level:		Warning (2) 
---------------------------------------------------------------------------------- 
BEGIN 
 
	DECLARE @InvalidUsers nvarchar(max) = '' 
 
	SELECT  
		@InvalidUsers += FullName + ', ' 
	FROM [User] 
	WHERE 
		DomainName is null and 
		lower(UserName) <> lower(EmailAdress) 
 
	IF @InvalidUsers <> '' 
	BEGIN 
		INSERT INTO @ValidationError 
		SELECT 'Users with different usernames and email addresses', 'The following INSIKT managed users do not have the same username and email address: ' + @InvalidUsers, 2 
	END 
END 
 
---------------------------------------------------------------------------------- 
-- Test:		No duplicates in DataSourceConnection 
-- Validation:	Check if there are rows in DataSourceConnection with the same server and database 
-- Level:		Warning (2) 
---------------------------------------------------------------------------------- 
BEGIN 
	declare @duplicateConnections nvarchar(max) = '' 
 
	select @duplicateConnections += lower(Server) + ' / ' + lower([Database]) + ', ' 
	from DataSourceConnection 
	where IsDeleted = 0 
	group by lower(Server), lower([Database]) 
	having count(*) > 1 
 
	if @duplicateConnections <> '' 
	begin 
		insert into @ValidationError 
		select 'Duplicates in DataSourceConnection', 'DataSourceConnection has multiple rows with the same server / database: ' + @duplicateConnections, 2 
	end 
END 
 
---------------------------------------------------------------------------------- 
-- Test:		No duplicates in DataSources 
-- Validation:	Check if there are rows in DataSources for the same datasource connection and cube 
-- Level:		Warning (2) 
---------------------------------------------------------------------------------- 
BEGIN 
	declare @duplicateDataSources nvarchar(max) = '' 
 
	select @duplicateDataSources += lower(c.Server) + ' / ' + lower(c.[Database]) + ' / ' + lower(SourceCube) + ', ' 
	from DataSources s 
		join DataSourceConnection c on c.ID = s.DataSourceConnectionID 
	where s.IsDeleted = 0 
	group by lower(c.Server), lower(c.[Database]), lower(s.SourceCube) 
	having count(*) > 1 
 
	if @duplicateDataSources <> '' 
	begin 
		insert into @ValidationError 
		select 'Duplicates in DataSources', 'DataSources has multiple rows for the same server / database / cube: ' + @duplicateDataSources, 2 
	end 
END 
 
---------------------------------------------------------------------------------- 
-- Test:		Default datasource is set 
-- Validation:	Check if any datasource is set as system default 
-- Level:		Warning (2) 
---------------------------------------------------------------------------------- 
BEGIN 
	IF NOT EXISTS (select 1 from dbo.DataSources where IsDefault = 1) 
	BEGIN 
		INSERT INTO @ValidationError 
		SELECT 
			'No datasource is set as system default', 
			'One datasource should be set as the system default. If a user does not have an explicit default/start datasource set when entering the Analysis Module INSIKT will throw exceptions', 
			2 
	END 
END 
 
---------------------------------------------------------------------------------- 
-- Test:		Checks InsiktService version 
-- Validation:	Check if version of INSIKT and INSIKT Service matches 
-- Level:		Fatal (3) 
---------------------------------------------------------------------------------- 
BEGIN 
 
	declare @insightVersion varchar(100) = (select Version from dbo.DatabaseVersion where IsCurrent = 1)

	-- Get the version from the currently running service, based on its alive timestamp.
	declare @insightServiceVersion varchar(100)
	select top 1 @insightServiceVersion = ServiceVersion
	from InsiktServiceStatus
	order by LastAlive desc
 
	if @insightServiceVersion is not null 
	begin 
 
		-- Check if insight version contains only part of the version string. That can happen due to a bug 
		-- in the auto upgrade system where only the version number and not the build type and commit hash number 
		-- is added to DatabaseVersion. 
		declare @insightVersionThirdDotPos int = charindex('.', @insightVersion, charindex('.', @insightVersion, charindex('.', @insightVersion) + 1) + 1) 
		declare @insightServiceVersionThirdDotPos int = charindex('.', @insightServiceVersion, charindex('.', @insightServiceVersion, charindex('.', @insightServiceVersion) + 1) + 1) 
 
		declare @insightVersionTrimmed varchar(100) = iif(@insightVersionThirdDotPos = 0, @insightVersion, substring(@insightVersion, 1, @insightVersionThirdDotPos - 1)) 
		declare @insightServiceVersionTrimmed varchar(100) = iif(@insightServiceVersionThirdDotPos = 0, @insightServiceVersion, substring(@insightServiceVersion, 1, @insightServiceVersionThirdDotPos - 1)) 
 
		if @insightVersionTrimmed <> @insightServiceVersionTrimmed 
		begin 
		    insert into @ValidationError 
		    select 
		        'Wrong version of INSIKT Service installed', 
				'Version of INSIKT Service does not match that of the installation of INSIKT. INSIKT: ' + @insightVersionTrimmed + ', INSIKT Service: ' + @insightServiceVersionTrimmed, 
				3 
		end 
	end 
END 
 
---------------------------------------------------------------------------------- 
-- Test:		LicenseServerUser should be configured 
-- Validation:	Check if LicenseServerUser is missing in SystemSetting 
-- Level:		Fatal (3) 
---------------------------------------------------------------------------------- 
BEGIN 
	IF NOT EXISTS ( 
		SELECT 1 FROM dbo.SystemSetting where SystemPropertyID = 1087 
	) 
	BEGIN 
		INSERT INTO @ValidationError 
		SELECT 'LicenseServerUser not set', 'SystemProperty LicenseServerUser (1087) should be configured for INSIKT to function', 3 
	END 
END 
 
---------------------------------------------------------------------------------- 
-- Test:		LicenseServerPassword should be configured 
-- Validation:	Check if LicenseServerPassword is missing in SystemSetting 
-- Level:		Fatal (3) 
---------------------------------------------------------------------------------- 
BEGIN 
	IF NOT EXISTS ( 
		SELECT 1 FROM dbo.SystemSetting where SystemPropertyID = 1089 
	) 
	BEGIN 
		INSERT INTO @ValidationError 
		SELECT 'LicenseServerPassword not set', 'SystemProperty LicenseServerPassword (1089) should be configured for INSIKT to function', 3 
	END 
END 

---------------------------------------------------------------------------------- 
-- Test:		Checks settings for FCObjectProperty 
-- Validation:	Check if any properties have multiple values of IsObjectName, IsObjectID, IsObjectCode set
-- Level:		Fatal (3) 
---------------------------------------------------------------------------------- 
BEGIN
	INSERT INTO @ValidationError
	SELECT
		'Illegal configuration for FCObjectProperty "' + p.[Name] + '" with ID ' + CAST(p.[ID] AS VARCHAR(MAX)),
		'Property "' + p.[Name] + '" has several of the property types Object code, Object Id and Object name active.',
		3
	FROM FCObjectProperty p
	WHERE (p.isObjectName = 1 AND p.isObjectCode = 1)
	   OR (p.isObjectCode = 1 AND p.isObjectID = 1)
	   OR (p.isObjectID = 1 AND p.isObjectName = 1)
END

---------------------------------------------------------------------------------- 
-- Test:		Check empty values of static FCObject predefined values 
-- Validation:	Check there are FCObject properties that have static predefined values where many
--				have empty/null ValueString/ValueNumeric. Only one value should be empty.
-- Level:		Warning (2) 
---------------------------------------------------------------------------------- 
BEGIN
	INSERT INTO @ValidationError
	SELECT 
		'Multiple empty predefined values in for FCObjectProperty "' + p.[Name] + '" with ID ' + CAST(p.[ID] AS VARCHAR(MAX)),
		'Property "' + p.[Name] + '" has multiple predefined values that have empty/null ValueNumeric/ValueString. Only one (the default one) should be empty/null.',
		2
	FROM FCObjectProperty p
	WHERE ID IN (
		SELECT FCObjectPropertyID
		FROM FCObjectPropertyPredefinedValue
		WHERE (ValueString IS NULL OR ValueString = '') AND ValueNumeric IS NULL AND IsDeleted = 0
		GROUP BY FCObjectPropertyID
		HAVING COUNT(*) > 1
	) AND IsDeleted = 0
END
 
----------------------------------------------------------------------------------------
 
	select ValidationTitle as Title, ValidationDescription as Description, ValidationLevel as Level from @ValidationError 
END


GO
