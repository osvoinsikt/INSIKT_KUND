SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Uppdaterar ett projektegenskapsvärde. Om projektet har ett gammalt värde för egenskapen ändras
-- det värdet i FCProjectPropertyValue; annars sätts en ny rad in i FCProjectPropertyValue.
CREATE PROCEDURE [dbo].[Support_Project_SetProjectPropertyValue]
	-- Projektet som ska uppdateras.
	@projectID int,

	-- Projektegenskapen som ska uppdateras.
	@projectPropertyID int,

	-- Användaren som gör ändringen.
	@userID int,

	-- Sätts om det är en numerisk eller boolsk egenskap.
	@valueNumeric float = null,

	-- Sätts om det är en strängegenskap.
	@valueString nvarchar(3000) = null,

	-- Sätts om det är egenskap med fördefinierade alternativ i FCProjectPropertyPredefinedValue.
	@predefinedValueID int = null,

	-- Om det är en grupperad projektegenskap måste aktuell gruppinstans specificeras.
	@groupInstanceID int = null,

	-- Huruvida den här proceduren ska logga ändringen i FCActionLog. Det fungerar endast med ej
	-- grupperade projektegenskaper. Om en grupperad egenskap ska ändras måste hela gruppen loggas
	-- av någon annan procedur.
	@logChange bit = 1
AS
BEGIN
	set nocount on;

	declare @fcTypeID int
	declare @companyID int
	declare @isGrouped bit
	declare @isCode bit

	declare @oldValueNumeric float
	declare @oldValueString nvarchar(3000)
	declare @oldPredefinedValueID int

	select
		@fcTypeID = FCTypeID,
		@companyID = CompanyID,
		@isGrouped = case when rel.ProjectPropertyID is null then 0 else 1 end,
		@oldValueNumeric = ppv.ValueNumeric,
		@oldValueString = ppv.ValueString,
		@oldPredefinedValueID = ppv.FCProjectPropertyPredefinedValueID,
		@isCode = pp.isProjectCode
	from FCProjectProperty pp
		left outer join FCProjectPropertyValue ppv on ppv.ProjectPropertyID = pp.ID and ppv.ProjectID = @projectID
		left outer join FCProjectPropertyGroupRelation rel on rel.ProjectPropertyID = pp.ID
	where pp.ID = @projectPropertyID

	if @isGrouped = 0 and @groupInstanceID is not null begin
		raiserror ('Group instance ID given for non-grouped project property', 16, 10)
	end else if @isGrouped = 1 and @groupInstanceID is null begin
		raiserror ('Group instance ID must be specified for a grouped project property', 16, 10)
	end

	if @logChange = 1 and @isGrouped = 1 begin
		raiserror ('This procedure cannot log changes in grouped project property values. Set @logChange = 0, and make sure to log the change elsewhere.', 16, 10)
	end

	-- TODO: Borde egentligen kolla enligt datatyp/kontrolltyp.
	declare @valueChanged bit
	set @valueChanged = 0
	if (@oldValueNumeric is null and @valueNumeric is not null) or (@oldValueNumeric is not null and @valueNumeric is null) or (@oldValueNumeric <> @valueNumeric) begin
		set @valueChanged = 1
	end
	if (@oldValueString is null and @valueString is not null) or (@oldValueString is not null and @valueString is null) or (@oldValueString <> @valueString) begin
		set @valueChanged = 1
	end
	if (@oldPredefinedValueID is null and @predefinedValueID is not null) or (@oldPredefinedValueID is not null and @predefinedValueID is null) or (@oldPredefinedValueID <> @predefinedValueID) begin
		set @valueChanged = 1
	end

	if @valueChanged = 1 begin
		declare @propertyValueID int
		select @propertyValueID = ID
		from FCProjectPropertyValue
		where ProjectID = @projectID
			and ProjectPropertyID = @projectPropertyID
			and (ProjectPropertyGroupInstanceID is null or ProjectPropertyGroupInstanceID = @groupInstanceID)

		if @isCode = 1 begin
			update FCProject
			set [Code] = @valueString
			where [ID] = @projectID
		end else if @propertyValueID is not null begin
			update FCProjectPropertyValue
			set ValueNumeric = @valueNumeric,
				ValueString = @valueString,
				FCProjectPropertyPredefinedValueID = @predefinedValueID,
				ModifiedBy = @userID,
				ModifiedDate = GETUTCDATE()
			where ID = @propertyValueID
		end else begin
			insert into FCProjectPropertyValue(
				ProjectID, ProjectPropertyID, ProjectPropertyGroupInstanceID,
				ValueNumeric, ValueString, FCProjectPropertyPredefinedValueID,
				ModifiedBy, ModifiedDate
			)
			values (
				@projectID, @projectPropertyID, @groupInstanceID,
				@valueNumeric, @valueString, @predefinedValueID,
				@userID, GETUTCDATE()
			)
		end

		if @logChange = 1 begin
			declare @logEntry nvarchar(max)
			exec Support_Project_MakeSimpleProjectPropertyLogEntry
				@projectID = @projectID,
				@projectPropertyID = @projectPropertyID,
				@oldValueNumeric = @oldValueNumeric,
				@oldValueString = @oldValueString,
				@oldPredefinedValueID = @oldPredefinedValueID,
				@newValueNumeric = @valueNumeric,
				@newValueString = @valueString,
				@newPredefinedValueID = @predefinedValueID,
				@selectResult = 0,
				@outputVariable = @logEntry out

			insert into FCActionLog(FCTypeID, CompanyID, FCProjectID, UserID, [Time], Content, TypeID)
			values (@fcTypeID, @companyID, @projectID, @userID, getutcdate(), @logEntry, 11)
		end
	end
END

GO
