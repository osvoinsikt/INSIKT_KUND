SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Tar bort ett projekt och dess tillhörande data för en viss version.
CREATE PROCEDURE [dbo].[Support_DeleteProjectCalcProcess]
	 @fcProjectID int,
	 @fcVersionID int
AS
BEGIN
	EXEC Support_DeleteProject @fcProjectID, @fcVersionID
END
GO
