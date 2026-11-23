SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Support_Project_MakeProjectPropertyDisplayValue]
	-- Aktuell projektegenskap.
	@projectPropertyID int,

	-- Aktuellt värde som ska visas.
	@valueNumeric float,
	@valueString nvarchar(max),
	@predefinedValueID int,
	
	-- Om resultat ska returneras via SELECT. Om resultatet ska returneras via en variabel kan det
	-- vara bra att sätta @selectResult = 0.
	@selectResult bit = 1,

	-- Sätts om resultatet ska returneras via en variabel.
	@outputVariable nvarchar(max) = null out
AS
BEGIN
	set nocount on;
	
	declare @NewLine char(2)
	set @NewLine = CHAR(13) + CHAR(10)

	declare @fcTypeID int
	declare @controlID int
	declare @dataType nvarchar(10)
	declare @queryToFill nvarchar(max)
	declare @roleId int

	select
		@fcTypeID = FCTypeID,
		@controlID = ControlID,
		@dataType = Datatype,
		@queryToFill = QueryToFillPredefinedValues,
		@roleID = RoleID
	from FCProjectProperty
	where ID = @projectPropertyID

	declare @displayValue nvarchar(max) = null
	
	if @controlID = 2 begin
		-- Dropdown

		-- if a roleId is set. Generate a queryToFill for that role
		if @roleID is not null begin
			select @queryToFill = dbo.fn_BuildQueryToFillForUserRole (@roleID, 1)
		end

		if @queryToFill is null begin
			select @displayValue = VisibleName
			from FCProjectPropertyPredefinedValue
			where ID = @predefinedValueID
		end else begin
			declare @projectValuesSQL nvarchar(max)
			exec Support_Project_CreateProjectPropertiesTempTable
				@fcTypeID = @fcTypeID,
				@selectSQLQuery = 0,
				@SQLQueryOutputVariable = @projectValuesSQL output

			declare @fullQueryToFillSQL nvarchar(max)
			set @fullQueryToFillSQL = @projectValuesSQL + @NewLine + ';' + @queryToFill

			create table #queryToFillResult (
				VisibleName nvarchar(255),
				ValueNumeric float, ValueString nvarchar(3000),
				isDefault bit, SortOrder int, AllowSelection bit)

			insert into #queryToFillResult(VisibleName, ValueNumeric, ValueString, isDefault, SortOrder, AllowSelection)
			exec(@fullQueryToFillSQL)

			if @dataType = 'string' begin
				select @displayValue = VisibleName
				from #queryToFillResult
				where ValueString = @valueString

				if @displayValue is null
					begin
						set @displayValue = @valueString
					end
			end else begin
				select @displayValue = VisibleName
				from #queryToFillResult
				where ValueNumeric = @valueNumeric

				if @displayValue is null
					begin
						set @displayValue = cast(@valueNumeric as nvarchar(255))
					end
			end

			drop table #queryToFillResult
		end
	end else if @dataType = 'string' begin
		set @displayValue = @valueString
	end else if @dataType = 'bit' begin
		if @valueNumeric is not null begin
			if @valueNumeric = 1 begin
				set @displayValue = 'Ja'
			end else begin
				set @displayValue = 'Nej'
			end
		end
	end else begin
		set @displayValue = cast(@valueNumeric as nvarchar(255))
	end

	set @outputVariable = @displayValue		
	if @selectResult = 1 begin
		select @displayValue as DisplayValue
	end
END
GO
