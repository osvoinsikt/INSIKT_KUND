SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Skapar ett log entry för projektegenskapsvärdeändringar i en projektegenskapsgrupp, redo att
-- sättas in i FCActionLog.
--
-- Anroparen måste skapa och fylla tabellen #projectPropertyGroupLogValues med gamla och nya
-- egenskapsvärden innan den här proceduren anropas.
--
-- create table #projectPropertyGroupLogValues(
--     ProjectPropertyID int,
--     OldValueNumeric float, OldValueString nvarchar(3000), OldFCProjectPropertyPredefinedValueID int,
--     NewValueNumeric float, NewValueString nvarchar(3000), NewFCProjectPropertyPredefinedValueID int)
--
-- Med grupperade egenskaper måste alla egenskaper i gruppen loggas, även oförändrade värden. Den
-- här proceduren tar hand om att läsa upp även egenskaperna som inte finns representerade i
-- #projectPropertyGroupLogValues. De oförändrade värdena läses från FCProjectPropertyValue.
--
----------------------------------------------------------------------------------------------
-- OBS! Det är viktigt att fälten i XML som skapas nedan läggs till i alfabetisk ordning.
-- Annars kommer inte vår XMLDictionaryReader i FCActionLogManager att deserialisera alla fälten till DTOn.
--
-- <ActionLogContent>
--  <NewValues></NewValues>
--  <OldValues></OldValues>
--  <PropertyGroupId></PropertyGroupId>
--  <PropertyGroupName></PropertyGroupName>
--  <ÖrjanForsmark></ÖrjanForsmark> // <-- Viktigt med placeringen av fälten när vi skapar XML i denna procedur!
-- </ActionLogContent>
--
-- Detta gäller alla nivåer i XMLdatat.
----------------------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[Support_Project_MakeProjectPropertyGroupLogEntry]
	-- Aktuellt projekt.
	@projectID int,

	-- Aktuell projektegenskapsgrupp.
	@projectPropertyGroupID int,

	-- Instansen vars värden har ändrats.
	@projectPropertyGroupInstanceID int,
	
	-- Om resultat ska returneras via SELECT. Om resultatet ska returneras via en variabel kan det
	-- vara bra att sätta @selectResult = 0.
	@selectResult bit = 1,

	-- Vilken LangID som ska användas när PropertyCaption hämtas.
	@langID int = 2,

	-- Sätts om resultatet ska returneras via en variabel.
	@outputVariable nvarchar(max) = null out
AS
BEGIN
	set nocount on;

	declare @NewLine char(2)
	set @NewLine = CHAR(13) + CHAR(10)

	if OBJECT_ID(N'tempdb..#projectPropertyGroupLogValues') is null begin
		-- Anroparen ska egentligen skapa och fylla den här tabellen.
		create table #projectPropertyGroupLogValues(
			ProjectPropertyID int,
			OldValueNumeric float, OldValueString nvarchar(3000), OldFCProjectPropertyPredefinedValueID int,
			NewValueNumeric float, NewValueString nvarchar(3000), NewFCProjectPropertyPredefinedValueID int)
	end

	-- För komplett grupploggning måste även oförändrade värden loggas.
	insert into #projectPropertyGroupLogValues(
		ProjectPropertyID,
		OldValueNumeric, OldValueString, OldFCProjectPropertyPredefinedValueID,
		NewValueNumeric, NewValueString, NewFCProjectPropertyPredefinedValueID)
	select
		ppv.ProjectPropertyID,
		ppv.ValueNumeric, ppv.ValueString, ppv.FCProjectPropertyPredefinedValueID,
		ppv.ValueNumeric, ppv.ValueString, ppv.FCProjectPropertyPredefinedValueID
	from FCProjectPropertyValue ppv
		left outer join #projectPropertyGroupLogValues v on v.ProjectPropertyID = ppv.ProjectPropertyID
	where ppv.ProjectID = @projectID
		and ppv.ProjectPropertyGroupInstanceID = @projectPropertyGroupInstanceID
		and v.ProjectPropertyID is null
	
	declare @propertyGroupName nvarchar(255)
	declare @propertyID int
	declare @propertyName nvarchar(3000)
	declare @propertyCaption nvarchar(3000)
	declare @isRTEProperty nvarchar(10)

	declare @valueNumeric float
	declare @valueString nvarchar(3000)
	declare @predefinedValueID int
	
	declare @displayValue nvarchar(255)
	
	select @propertyGroupName = Name
	from FCProjectPropertyGroup
	where ID = @projectPropertyGroupID

	-- Skapa ny temptabell för gamla värdena.
	select
		ProjectPropertyID,
		OldValueNumeric as ValueNumeric,
		OldValueString as ValueString,
		OldFCProjectPropertyPredefinedValueID as FCProjectPropertyPredefinedValueID
	into #oldProjectPropertyGroupLogValues
	from #projectPropertyGroupLogValues v
		inner join FCProjectProperty pp on pp.ID = v.ProjectPropertyID
	where OldValueNumeric is not null or OldValueString is not null or OldFCProjectPropertyPredefinedValueID is not null

	-- Skapa ny temptabell för nya värdena.
	select
		ProjectPropertyID,
		NewValueNumeric as ValueNumeric,
		NewValueString as ValueString,
		NewFCProjectPropertyPredefinedValueID as FCProjectPropertyPredefinedValueID
	into #newProjectPropertyGroupLogValues
	from #projectPropertyGroupLogValues v
		inner join FCProjectProperty pp on pp.ID = v.ProjectPropertyID
	where NewValueNumeric is not null or NewValueString is not null or NewFCProjectPropertyPredefinedValueID is not null

	declare @result nvarchar(max)

	set @result = '<ActionLogContent xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://schemas.datacontract.org/2004/07/Insikt.DataTransferObjects.Prognosis.Log" i:type="ProjectPropertyGroupChangedActionLogContent">' + @NewLine

	if (select count(*) from #newProjectPropertyGroupLogValues) = 0 begin
		set @result = @result + '	<NewValues i:nil="true" />' + @NewLine
	end else begin
		set @result = @result + '	<NewValues>' + @NewLine

		while (select count(*) from #newProjectPropertyGroupLogValues) > 0 begin
			select top 1
				@propertyID = pp.ID,
				@propertyName = pp.Name,
				@propertyCaption = ISNULL(
					(SELECT TOP 1 
						VisibleName 
					FROM dbo.LangDictionary 
					WHERE ControlName = 'FCProjectProperty_' + CAST(pp.ID AS varchar(10)) + '_Name' AND LangID = @langID)
					, pp.Name),
				@isRTEProperty = case when pp.ControlID = 8 then 'true' else 'false' end,
				@valueNumeric = v.ValueNumeric,
				@valueString = v.ValueString,
				@predefinedValueID = v.FCProjectPropertyPredefinedValueID
			from #newProjectPropertyGroupLogValues v
				inner join FCProjectProperty pp on pp.ID = v.ProjectPropertyID
			order by isnull(pp.SortOrder, 2147483647)

			exec Support_Project_MakeProjectPropertyDisplayValue
				@propertyID,
				@valueNumeric, @valueString, @predefinedValueID,
				@selectResult = 0,
				@outputVariable = @displayValue output

			set @result = @result + '		<ProjectPropertyGroupPropertyValue>' + @NewLine
			set @result = @result + '			<PropertyId>' + cast(@propertyID as nvarchar(8)) + '</PropertyId>' + @NewLine
			set @result = @result + '			<PropertyName>' + dbo.fn_EscapeXML(@propertyName) + '</PropertyName>' + @NewLine
			set @result = @result + '			<PropertyCaption>' + dbo.fn_EscapeXML(@propertyCaption) + '</PropertyCaption>' + @NewLine
			set @result = @result + '			<Value>' + dbo.fn_EscapeXML(@displayValue) + '</Value>' + @NewLine
			set @result = @result + '			<RTE>' + @isRTEProperty + '</RTE>' + @NewLine
			set @result = @result + '		</ProjectPropertyGroupPropertyValue>' + @NewLine

			-- Ta bort raden som hanterades.
			delete from #newProjectPropertyGroupLogValues
			where ProjectPropertyID = @propertyID
		end

		set @result = @result + '	</NewValues>' + @NewLine
	end

	
	if (select count(*) from #oldProjectPropertyGroupLogValues) = 0 begin
		set @result = @result + '	<OldValues i:nil="true" />' + @NewLine
	end else begin
		set @result = @result + '	<OldValues>' + @NewLine

		while (select count(*) from #oldProjectPropertyGroupLogValues) > 0 begin
			select top 1
				@propertyID = pp.ID,
				@propertyName = pp.Name,
				@propertyCaption = ISNULL(
					(SELECT TOP 1 
						VisibleName 
					FROM dbo.LangDictionary 
					WHERE ControlName = 'FCProjectProperty_' + CAST(pp.ID AS varchar(10)) + '_Name' AND LangID = @langID)
					, pp.Name),
				@isRTEProperty = case when pp.ControlID = 8 then 'true' else 'false' end,
				@valueNumeric = v.ValueNumeric,
				@valueString = v.ValueString,
				@predefinedValueID = v.FCProjectPropertyPredefinedValueID
			from #oldProjectPropertyGroupLogValues v
				inner join FCProjectProperty pp on pp.ID = v.ProjectPropertyID
			order by isnull(pp.SortOrder, 2147483647)

			exec Support_Project_MakeProjectPropertyDisplayValue
				@propertyID,
				@valueNumeric, @valueString, @predefinedValueID,
				@selectResult = 0,
				@outputVariable = @displayValue output

			set @result = @result + '		<ProjectPropertyGroupPropertyValue>' + @NewLine
			set @result = @result + '			<PropertyId>' + cast(@propertyID as nvarchar(8)) + '</PropertyId>' + @NewLine
			set @result = @result + '			<PropertyName>' + dbo.fn_EscapeXML(@propertyName) + '</PropertyName>' + @NewLine
			set @result = @result + '			<PropertyCaption>' + dbo.fn_EscapeXML(@propertyCaption) + '</PropertyCaption>' + @NewLine
			set @result = @result + '			<Value>' + dbo.fn_EscapeXML(@displayValue) + '</Value>' + @NewLine
			set @result = @result + '			<RTE>' + @isRTEProperty + '</RTE>' + @NewLine
			set @result = @result + '		</ProjectPropertyGroupPropertyValue>' + @NewLine

			-- Ta bort raden som hanterades.
			delete from #oldProjectPropertyGroupLogValues
			where ProjectPropertyID = @propertyID
		end

		set @result = @result + '	</OldValues>' + @NewLine
	end

	set @result = @result + '	<PropertyGroupId>' + cast(@projectPropertyGroupID as nvarchar(8)) + '</PropertyGroupId>' + @NewLine
	set @result = @result + '	<PropertyGroupName>' + dbo.fn_EscapeXML(@propertyGroupName) + '</PropertyGroupName>' + @NewLine

	set @result = @result + '</ActionLogContent>' + @NewLine

	set @outputVariable = @result		
	if @selectResult = 1 begin
		select @result as LogEntry
	end
END

GO
