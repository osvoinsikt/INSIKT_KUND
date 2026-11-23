SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_GetProjectLink]
(
	@fcProjectID INT
)
RETURNS VARCHAR(2000)
AS
BEGIN
	--SELECT dbo.fn_GetProjectLink(1)
	DECLARE
		@RootURL NVARCHAR(2000),
		@fcProjectlink NVARCHAR(2000)

	SET @RootURL = (SELECT ValueString FROM SystemSetting WHERE SystemPropertyID = 1069)
	IF NOT (@RootURL LIKE '%/')
	BEGIN
		SET @RootURL = @RootURL + '/'
	END

	DECLARE @fcTypeId AS INT = (SELECT TOP 1 FCTypeID FROM FCProject WHERE ID = @fcProjectID)

	SET @fcProjectlink = @RootURL + 'planning?ProjectId=' + CONVERT(VARCHAR, @fcProjectID) + '&FCTypeID=' + CONVERT(VARCHAR, @fcTypeId)

	RETURN @fcProjectlink

END
GO
