SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [insikt].[FCVersion_Deleted] 
	@FCVersionID int
AS
BEGIN
	-- TODO: Radera data och annan relaterad information
	SELECT 1 as Status, 'Version borttagen' as Message
END

GO
