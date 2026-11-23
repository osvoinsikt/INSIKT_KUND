SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[insUserSecurityGroup]
(
	 @UserName varchar(255)
	,@domainName varchar(255)
	,@SID varchar(50)
	,@FullName varchar(255)
	,@isAdmin bit
	,@isAnalysisUser bit
	,@isAnalysisManager bit
	,@isAnalysisPrivileged bit
	,@isBudget bit
	,@isBudgetPrivileged bit
	,@isProject bit
	,@isProjectManager bit
	,@EmailAdress varchar(50)
	,@LangID int
	,@StartReportID int
	,@DefaultDatasourceID int
	,@UserTypeID int           
	,@DefaultSecGroupID int
	,@SuperAdmin varchar(max)

	,@UserID int output
)
AS
BEGIN

	set @UserID = null
	select
		@UserID = UserID
	from
		[dbo].[UserSecurityGroup]
	where
		UserName = @UserName

	-- Insert domain entry if it does not exist already
	declare @domainID int = null
	select @domainID = ID from dbo.Domain where lower(DomainName) = lower(@domainName)
	if @domainID is null and @domainName is not null
	begin
		insert into dbo.Domain (DomainName, FullyQualifiedDomainName, ProtocolTypeID, UserName, [Password], TenantID, ClientID, 
				ClientSecret, DomainServer, SearchRoot, IsConfigurable, SyncEnabled, SearchEnabled, IsDeleted)
			values (@domainName, null, 2, null, null, null, null, null, null, null, 0, 1, 0, 0)
		set @domainID = SCOPE_IDENTITY()
	end

	if @UserID is null
	begin

		insert into [dbo].[UserSecurityGroup]
		(
			 [UserName]
			,[DomainID]
			,[SID]
			,[FullName]
			,[EmailAdress]
			,[LangID]
			,[StartReportID]
			,[DefaultDatasourceID]
			,[UserTypeID]
			,[DefaultSecGroupID]
			,[SuperAdmin]
			,[AuthenticationType]
		)
		values
		(
			@UserName
			,@domainID
			,@SID
			,@FullName
			,@EmailAdress
			,@LangID
			,@StartReportID
			,@DefaultDatasourceID
			,@UserTypeID
			,@DefaultSecGroupID
			,@SuperAdmin
			,1
		)

		if (@@RowCount <> 1)
			raiserror ('Unable to add row to UserSecurityGroup', 16, 1)

		select @UserID = ident_current('UserSecurityGroup')

		-- Log user granted access
		insert into dbo.UserSecurityGroupLog (InitiatedBy, EventDate, TypeID, UserID)
			values (-1, GETUTCDATE(), 1, @UserID)

	end
	else
	begin
		update [dbo].[UserSecurityGroup] set
			 [UserName] = @UserName
			,[DomainID] = @domainID
			,[SID] = @SID
			,[FullName] = @FullName
			,[EmailAdress] = @EmailAdress
			,[LangID] = @LangID
			,[StartReportID] = @StartReportID
			,[DefaultDatasourceID] = @DefaultDatasourceID
			,[UserTypeID] = @UserTypeID
			,[DefaultSecGroupID] = @DefaultSecGroupID
			,[SuperAdmin] = @SuperAdmin
			,[IsDeleted] = 0
		where
			UserID = @UserID
	end

	-- Vilka roller användaren ska tilldelas
	DECLARE @roles TABLE (
		Caption varchar(250)
	)
	
	IF (@isAdmin = 1) 
	BEGIN
		INSERT INTO @roles VALUES ('Admin')
		INSERT INTO @roles VALUES ('AdminAll')
	END

	if @isAnalysisUser = 1
	begin
		insert into @roles values ('AnalysisUser')
	end
	if @isAnalysisManager = 1
	begin
		insert into @roles values ('AnalysisManager')
	end
	if @isAnalysisPrivileged = 1
	begin
		insert into @roles values ('AnalysisPrivileged')
	end

	IF (@isProject = 1)
	BEGIN
		INSERT INTO @roles VALUES ('ProjectUser')
	END

	IF (@isProjectManager = 1)
	BEGIN
		INSERT INTO @roles VALUES ('ProjectManager')
		INSERT INTO @roles VALUES ('ProjectLeader')
	END

	IF (@isBudget = 1)
	BEGIN
		INSERT INTO @roles VALUES ('BudgetUser')
	END
	
	IF (@isBudgetPrivileged = 1)
	BEGIN
		INSERT INTO @roles VALUES ('BudgetPrivileged')
	END

	-- Skapa nya kopplingar om de inte redan finns.
	INSERT INTO UserSecurityGroupRoleRelation(UserID,RoleID) 
	SELECT DISTINCT @UserID, r.ID
	FROM [Role] r
		INNER JOIN @roles roles ON r.Caption = roles.Caption
		LEFT JOIN UserSecurityGroupRoleRelation existing ON @userID = existing.UserID AND r.ID = existing.RoleID
	WHERE existing.RoleID IS NULL
END

GO
