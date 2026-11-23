SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Genererar SQL-kod för att skapa tabellen #projectPropertyValues och de SQL-variabler som finns
-- tillgängliga vid EventValidation, QueryToFillPredefinedValues och liknande. Det kan användas som
-- konfigurationsstöd.
--
-- Tabellen och variablerna kan fyllas med riktiga värden för ett givet projekt, alternativt kan
-- alla värden och variabler lämnas NULL; båda fallen måste hanteras av QueryToFillPredefinedValues.
CREATE PROCEDURE [dbo].[Support_Project_CreateProjectPropertiesTempTable]
	-- Sätt den här för att generera temptabellen och variablerna utan värden. Varje
	-- projektegenskap får dock en rad i tabellen, men med NULL som värden.
	-- Om varken @fcTypeID eller @projectID är satt sätts @fcTypeID till första projektbudgeten.
	@fcTypeID as int = null,

	-- Sätt den här för att generera temptabellen med värden för ett visst projekt.
	@projectID as int = null,

	-- Om tabellen genereras med värden kan den här sättas om en viss projektegenskapsgrupp ska
	-- vara "aktiv". En instans av gruppen sätts då som aktiv, alltså
	-- IsCurrentGroupInstance = 1 i tabellen. Om @projectPropertyGroupInstanceID är satt
	-- sätts den som aktiv; annars slumpväljs en instans i gruppen.
	@projectPropertyGroupID int = null,

	-- Om en specifik instans ska vara aktiv i den aktiva egenskapsgruppen.
	@projectPropertyGroupInstanceID int = null,

	-- Säger om den genererade SQL-frågan ska returneras genom SELECT.
	@selectSQLQuery bit = 1,

	-- Kan användas för att få ut SQL-frågan som variabel. Kan kombineras med @selectSQLQuery = 0.
	@SQLQueryOutputVariable nvarchar(max) = null output
AS
BEGIN
	set nocount on;

	if @fcTypeID is null and @projectID is null begin
		-- Använd första projektbudgeten.
		select top 1 @fcTypeID = FCTypeID
		from FCProjectProperty
	end else if @projectID is not null begin
		-- Hitta projektbudgeten som projektet tillhör.
		select @fcTypeID = FCTypeID
		from FCProject
		where ID = @projectID
	end

	if @fcTypeID is null and @projectID is null begin
		raiserror ('No project or budget type specified', 16, 10)
	end

	if @projectID is not null and @projectPropertyGroupID is not null and @projectPropertyGroupInstanceID is null begin
		-- Hitta åt en valfri instans i gruppen.
		select top 1 @projectPropertyGroupInstanceID = ppv.ProjectPropertyGroupInstanceID
		from FCProjectPropertyValue ppv
			inner join FCProjectProperty pp on pp.ID = ppv.ProjectPropertyID and pp.IsDeleted = 0
			inner join FCProjectPropertyGroupRelation rel on rel.ProjectPropertyID = pp.ID and rel.ProjectPropertyGroupID = @projectPropertyGroupID
		where ppv.ProjectID = @projectID
		order by NEWID()
	end

	declare @projectIDString varchar(8)
	set @projectIDString = cast(@projectID as nvarchar(max))

	declare @sql varchar(max)

	-- SQL: Deklarera generella variabler.
	set @sql =
'-- Tillgängliga variabler.
declare @FilterValuesForSelection bit = ' + iif(@projectID is null, '0', '1') + '
declare @projectID int
declare @FCProjectID int
declare @parentProjectID int
declare @projectNotes nvarchar(3000)
declare @projectPropertyGroupID int
declare @userID int = -1
declare @langID int = 1'

	-- Deklarera variabler för projektegenskaper som inte är grupperade.
	declare propertyVariableCursor scroll cursor for
		select
			p.ID,
			EscapedName = dbo.fn_RemoveCharacters(replace(Name, ' ', '_'), '^a-zå-ö0-9_'),
			Datatype,
			HasPredefinedValueID = case when ControlID = 2 and QueryToFillPredefinedValues is null and RoleID is null then 1 else 0 end
		from FCProjectProperty p
			left join FCProjectPropertyGroupRelation groupRel on groupRel.ProjectPropertyID = p.ID
		where p.FCTypeID = @fcTypeID
			and isnull(p.isMultiselect, 0) = 0
			and p.IsDeleted = 0
			and groupRel.ID is null
	open propertyVariableCursor

	declare @propertyID int
	declare @escapedPropertyName nvarchar(max)
	declare @propertyDataType varchar(15)
	declare @propertyHasPredefinedValueID bit

	fetch next from propertyVariableCursor into
		@propertyID,
		@escapedPropertyName,
		@propertyDataType,
		@propertyHasPredefinedValueID
	while @@fetch_status = 0 begin
		declare @propertyVariableType varchar(15)
		if @propertyHasPredefinedValueID = 1 begin
			set @propertyVariableType = 'int';
		end else if @propertyDataType = 'string' begin
			set @propertyVariableType = 'nvarchar(max)';
		end else begin
			set @propertyVariableType = 'float';
		end

		-- SQL: Deklarera variabel för projektegenskap.
		set @sql += '
declare @' + @escapedPropertyName + ' ' + @propertyVariableType

		fetch next from propertyVariableCursor into
			@propertyID,
			@escapedPropertyName,
			@propertyDataType,
			@propertyHasPredefinedValueID
	end

	-- SQL: Skapa temptabell.
	set @sql = @sql + '

-- Tabell med projektegenskapsvärden.
if OBJECT_ID(N''tempdb..#projectPropertyValues'') is not null drop table #projectPropertyValues
create table #projectPropertyValues(
	FCProjectPropertyID int,
	FCProjectPropertyGroupInstanceID int,
	IsCurrentGroupInstance bit,
	ValueNumeric float,
	ValueString nvarchar(max),
	FCProjectPropertyPredefinedValueID int,
	OldValueNumeric float,
	OldValueString nvarchar(max),
	OldFCProjectPropertyPredefinedValueID int,
	HasChanged bit
)
'

	if @projectID is not null begin
		-- Filtrerad data.

		fetch first from propertyVariableCursor into
			@propertyID,
			@escapedPropertyName,
			@propertyDataType,
			@propertyHasPredefinedValueID
		while @@fetch_status = 0 begin
			declare @propertyValueAsString nvarchar(max) = null;
			if @propertyHasPredefinedValueID = 1 begin
				declare @propertyPredefinedValueID int =
					(select top 1 FCProjectPropertyPredefinedValueID
					 from FCProjectPropertyValue
					 where ProjectID = @projectID and ProjectPropertyID = @propertyID)
				set @propertyValueAsString = cast(@propertyPredefinedValueID as nvarchar(max))
			end else if @propertyDataType = 'string' begin
				declare @propertyValueString nvarchar(max) =
					(select top 1 ValueString
					 from FCProjectPropertyValue
					 where ProjectID = @projectID and ProjectPropertyID = @propertyID)
				set @propertyValueAsString = '''' + replace(@propertyValueString, '''', '''''') + ''''
			end else begin
				declare @propertyValueNumeric float =
					(select top 1 ValueNumeric
					 from FCProjectPropertyValue
					 where ProjectID = @projectID and ProjectPropertyID = @propertyID)
				set @propertyValueAsString = cast(@propertyValueNumeric as nvarchar(max))
			end

			if @propertyValueAsString is not null begin
				-- SQL: Värde för projektegenskapsvariabel
				set @sql += '
set @' + @escapedPropertyName + ' = ' + @propertyValueAsString
			end

			fetch next from propertyVariableCursor into
				@propertyID,
				@escapedPropertyName,
				@propertyDataType,
				@propertyHasPredefinedValueID
		end

		-- SQL: Sätt några variabler.
		set @sql = @sql + '
select
	@projectID = ID,
	@FCProjectID = ID,
	@projectNotes = Notes,
	@parentProjectID = ParentProjectID
from FCProject
where ID = ' + @projectIDString

		declare @instanceIDString nvarchar(100)
		set @instanceIDString = 'NULL'

		if @projectPropertyGroupID is not null begin
			if @projectPropertyGroupInstanceID is not null begin
				set @instanceIDString = cast(@projectPropertyGroupInstanceID as nvarchar(10))
			end

			-- SQL: Sätt variabel för aktiv grupp.
			set @sql = @sql + '
set @projectPropertyGroupID = ' + CAST(@projectPropertyGroupID as nvarchar(8))
		end

		-- SQL: Fyll temptabellen.
		set @sql = @sql + '
insert into #projectPropertyValues(
	FCProjectPropertyID,
	FCProjectPropertyGroupInstanceID,
	IsCurrentGroupInstance,
	ValueNumeric, ValueString, FCProjectPropertyPredefinedValueID,
	HasChanged)
select
	pp.ID,
	ppv.ProjectPropertyGroupInstanceID,
	case
		when ppv.ProjectPropertyGroupInstanceID is not null and ppv.ProjectPropertyGroupInstanceID = ' + @instanceIDString + ' then 1
		else 0
	end as IsCurrentGroupInstance,
	ppv.ValueNumeric, ppv.ValueString, ppv.FCProjectPropertyPredefinedValueID,
	0
from FCProject p
	inner join FCProjectProperty pp on pp.FCTypeID = p.FCTypeID and p.IsDeleted = 0
	left outer join FCProjectPropertyValue ppv on ppv.ProjectID = p.ID and ppv.ProjectPropertyID = pp.ID
	left outer join FCProjectPropertyGroupRelation rel on rel.ProjectPropertyID = pp.ID
where p.ID = ' + @projectIDString
	-- Grupperade egenskaper ska bara med om det faktiskt finns en instans.
	-- Ogrupperade egenskaper ska med oavsett.
	+ '
	and (ppv.ID is not null or rel.ID is null)'

	end

	-- SQL: Avsluta med en SELECT. Det är här användaren kan skriva sin konfigurationskod.
	set @sql = @sql + '

-- select * from #projectPropertyValues'

	close propertyVariableCursor
	deallocate propertyVariableCursor

	set @SQLQueryOutputVariable = @sql

	if @selectSQLQuery = 1 begin
		select @sql as SQLQuery
	end
END

GO
