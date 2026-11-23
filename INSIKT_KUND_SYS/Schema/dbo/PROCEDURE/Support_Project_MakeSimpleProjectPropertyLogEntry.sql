SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Skapar ett log entry för en projektegenskapsvärdeändring, redo att sättas in i FCActionLog.
----------------------------------------------------------------------------------------------
-- OBS! Det är viktigt att fälten i XML som skapas nedan läggs till i alfabetisk ordning.
-- Annars kommer inte vår XMLDictionaryReader i FCActionLogManager att deserialisera alla fälten till DTOn.
--
-- <ActionLogContent>
--  <NewValue></NewValue>
--  <OldValue></OldValue>
--  <PropertyId></PropertyId>
--  <PropertyName></PropertyName>
--  <ÖrjanForsmark></ÖrjanForsmark> // <-- Viktigt med placeringen av fälten när vi skapar XML i denna procedur!
-- </ActionLogContent>
--
-- Detta gäller alla nivåer i XMLdatat.
----------------------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[Support_Project_MakeSimpleProjectPropertyLogEntry]
	-- Aktuellt projekt.
	@projectID int,

	-- Aktuell projektegenskap.
	@projectPropertyID int,
	
	-- Gamla egenskapsvärdena. Om det saknas gammalt värde går det bra att lämna denna som NULL.
	@oldValueNumeric float,
	@oldValueString nvarchar(3000),
	@oldPredefinedValueID int,

	-- Nya egenskapsvärdena. Om det saknas nytt värde går det bra att lämna denna som NULL.
	@newValueNumeric float,
	@newValueString nvarchar(3000),
	@newPredefinedValueID int,

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

	declare @projectPropertyName nvarchar(255)
	select @projectPropertyName = Name
	from FCProjectProperty
	where ID = @projectPropertyID

	declare @oldDisplayValue nvarchar(max)
	exec Support_Project_MakeProjectPropertyDisplayValue
		@projectPropertyID,
		@oldValueNumeric, @oldValueString, @oldPredefinedValueID,
		@selectResult = 0,
		@outputVariable = @oldDisplayValue output

	declare @newDisplayValue nvarchar(max)
	exec Support_Project_MakeProjectPropertyDisplayValue
		@projectPropertyID,
		@newValueNumeric, @newValueString, @newPredefinedValueID,
		@selectResult = 0,
		@outputVariable = @newDisplayValue output

	declare @result nvarchar(max)

	set @result = '<ActionLogContent xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://schemas.datacontract.org/2004/07/Insikt.DataTransferObjects.Prognosis.Log" i:type="ProjectPropertyChangedActionLogContent">' + @NewLine

	if @newDisplayValue is null begin
		set @result = @result + '	<NewValue />' + @NewLine
	end else begin
		set @result = @result + '	<NewValue>' + dbo.fn_EscapeXML(@newDisplayValue) + '</NewValue>' + @NewLine
	end
	
	if @oldDisplayValue is null begin
		set @result = @result + '	<OldValue />' + @NewLine
	end else begin
		set @result = @result + '	<OldValue>' + dbo.fn_EscapeXML(@oldDisplayValue) + '</OldValue>' + @NewLine
	end

	set @result = @result + '	<PropertyId>' + CAST(@projectPropertyID as nvarchar(10)) + '</PropertyId>' + @NewLine
	set @result = @result + '	<PropertyName>' + dbo.fn_EscapeXML(@projectPropertyName) + '</PropertyName>' + @NewLine

	set @result = @result + '</ActionLogContent>' + @NewLine

	set @outputVariable = @result		
	if @selectResult = 1 begin
		select @result as LogEntry
	end
	
END

GO
