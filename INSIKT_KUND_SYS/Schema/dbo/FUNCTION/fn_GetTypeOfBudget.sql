SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*******************************************************************
 #Desc: 			Säger om det är en vanlig budget, projektbudget eller projektkalkyl (implicit en projektbudget).
 #Used By:			-
 #Creator:			Emil Ahlqvist
 #CreateDate:		151013
 #Modified by:		EMAH
 #ModifiedDate:		2017-02-14
 
 #Log:
					Updated after FCType configuration refactor.
********************************************************************/
CREATE FUNCTION [dbo].[fn_GetTypeOfBudget]
(
	@fcTypeID int
)
RETURNS varchar(15)
AS
BEGIN
	--SELECT dbo.fn_GetTypeOfBudget(1)
	DECLARE @type varchar(15)

	SELECT @type = fctt.[Name] FROM FCType fct join FCTypeType fctt ON (fct.FCTypeTypeID = fctt.ID) WHERE fct.ID = @fcTypeID

	RETURN @type

END
GO
