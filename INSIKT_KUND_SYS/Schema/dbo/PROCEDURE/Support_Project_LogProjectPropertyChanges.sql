SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Loggar projektegenskapsändringar.
--
-- Anroparen måste skapa och fylla tabellen #projectPropertyLogValues med gamla och nya
-- egenskapsvärden innan den här proceduren anropas.
--
-- #projectPropertyLogValues ser ut som följande:
-- create table #projectPropertyLogValues(
--     ProjectID int, ProjectPropertyID int, ProjectPropertyGroupID int, ProjectPropertyGroupInstanceID int,
--     OldValueNumeric float, OldValueString nvarchar(3000), OldFCProjectPropertyPredefinedValueID int,
--     NewValueNumeric float, NewValueString nvarchar(3000), NewFCProjectPropertyPredefinedValueID int)
--
-- Om en egenskap saknar gammalt värde går det bra att lämna Old*Value som NULL. Motsvarande gäller
-- om det inte finns ett nytt värde, exempelvis om ett egenskapsvärde tas bort.
--
-- För grupperade egenskaper måste ProjectPropertyGroupID och ProjectPropertyGroupInstanceID sättas.
-- Endast de värden som förändrats i gruppen måste fyllas i temptabellen; oförändrade värden behöver
-- inte läggas in.
CREATE PROCEDURE [dbo].[Support_Project_LogProjectPropertyChanges]
	@userID int
AS
BEGIN
	set nocount on;

	declare @NewLine char(2)
	set @NewLine = CHAR(13) + CHAR(10)

	if OBJECT_ID(N'tempdb..#projectPropertyLogValues') is null begin
		-- Anroparen ska egentligen skapa och fylla den här tabellen.
		create table #projectPropertyLogValues(
			ProjectID int, ProjectPropertyID int, ProjectPropertyGroupID int, ProjectPropertyGroupInstanceID int,
			OldValueNumeric float, OldValueString nvarchar(3000), OldFCProjectPropertyPredefinedValueID int,
			NewValueNumeric float, NewValueString nvarchar(3000), NewFCProjectPropertyPredefinedValueID int)
	end
	
	declare @fcTypeID int
	declare @companyID int
	declare @projectID int
	declare @projectPropertyID int

	select *
	into #nonGroupedLogValues
	from #projectPropertyLogValues
	where ProjectPropertyGroupInstanceID is null
	
	select *
	into #groupedLogValues
	from #projectPropertyLogValues
	where ProjectPropertyGroupInstanceID is not null

	create table #projectPropertyGroupLogValues(
		ProjectPropertyID int,
		OldValueNumeric float, OldValueString nvarchar(3000), OldFCProjectPropertyPredefinedValueID int,
		NewValueNumeric float, NewValueString nvarchar(3000), NewFCProjectPropertyPredefinedValueID int)

	declare @logEntry nvarchar(max)

	-- Hantera enkla ogrupperade egenskaper.
	while (select COUNT(*) from #nonGroupedLogValues) > 0 begin
		declare @oldValueNumeric float
		declare @oldValueString nvarchar(3000)
		declare @oldPredefinedValueID int
		declare @newValueNumeric float
		declare @newValueString nvarchar(3000)
		declare @newPredefinedValueID int

		select top 1
			@projectID = v.ProjectID,
			@fcTypeID = p.FCTypeID,
			@companyID = p.CompanyID,
			@projectPropertyID = v.ProjectPropertyID,
			@oldValueNumeric = v.OldValueNumeric,
			@oldValueString = v.OldValueString,
			@oldPredefinedValueID = v.OldFCProjectPropertyPredefinedValueID,
			@newValueNumeric = v.NewValueNumeric,
			@newValueString = v.NewValueString,
			@newPredefinedValueID = v.NewFCProjectPropertyPredefinedValueID
		from #nonGroupedLogValues v
			inner join FCProject p on p.ID = v.ProjectID
		
		exec Support_Project_MakeSimpleProjectPropertyLogEntry
			@projectID = @projectID, @projectPropertyID = @projectPropertyID,
			@oldValueNumeric = @oldValueNumeric, @oldValueString = @oldValueString, @oldPredefinedValueID = @oldPredefinedValueID,
			@newValueNumeric = @newValueNumeric, @newValueString = @newValueString, @newPredefinedValueID = @newPredefinedValueID,
			@selectResult = 0,
			@outputVariable = @logEntry out

		insert into FCActionLog(FCTypeID, CompanyID, FCProjectID, UserID, [Time], Content, TypeID)
		values (@fcTypeID, @companyID, @projectID, @userID, GETUTCDATE(), @logEntry, 11)
		
		delete from #nonGroupedLogValues
		where ProjectID = @projectID and ProjectPropertyID = @projectPropertyID
	end

	-- Hantera egenskapsgrupper.
	while (select COUNT(*) from #groupedLogValues) > 0 begin
		-- Välj ut en gruppinstans att hantera.
		declare @groupID int
		declare @instanceID int
		select top 1
			@projectID = v.ProjectID,
			@fcTypeID = p.FCTypeID,
			@companyID = p.CompanyID,
			@groupID = v.ProjectPropertyGroupID,
			@instanceID = v.ProjectPropertyGroupInstanceID
		from #groupedLogValues v
			inner join FCProject p on p.ID = v.ProjectID

		-- Hitta alla värden som hör till valda gruppinstansen.
		truncate table #projectPropertyGroupLogValues
		insert into #projectPropertyGroupLogValues(
			ProjectPropertyID,
			OldValueNumeric, OldValueString, OldFCProjectPropertyPredefinedValueID,
			NewValueNumeric, NewValueString, NewFCProjectPropertyPredefinedValueID)
		select
			ProjectPropertyID,
			OldValueNumeric, OldValueString, OldFCProjectPropertyPredefinedValueID,
			NewValueNumeric, NewValueString, NewFCProjectPropertyPredefinedValueID
		from #groupedLogValues
		where ProjectPropertyGroupInstanceID = @instanceID

		-- Logga gruppen.
		exec Support_Project_MakeProjectPropertyGroupLogEntry
			@projectID = @projectID,
			@projectPropertyGroupID = @groupID,
			@projectPropertyGroupInstanceID = @instanceID,
			@selectResult = 0,
			@outputVariable = @logEntry out

		insert into FCActionLog(FCTypeID, CompanyID, FCProjectID, UserID, [Time], Content, TypeID)
		values (@fcTypeID, @companyID, @projectID, @userID, GETUTCDATE(), @logEntry, 12)
		
		-- Ta bort instansen som hanterats.
		delete from #groupedLogValues
		where ProjectPropertyGroupInstanceID = @instanceID
	end

END

GO
