SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [insikt].[FCVersion_Deleting] 
	@FCVersionID int
AS
BEGIN
	-- TODO: Lägg till validering här, t ex att versionen inte är påbörjad
	SELECT -1 as Status, 'Åtgärd ej tillåten' as Message
END

GO
