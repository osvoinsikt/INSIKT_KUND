SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_GetElementKeyFromUniqueName]
(
	@uniqueName nvarchar(150)
)
RETURNS nvarchar(20)
AS
BEGIN

	IF @uniqueName IS NULL RETURN NULL

	DECLARE @lastStartBracketPos int	
	SELECT @lastStartBracketPos = LEN(@uniqueName) - CHARINDEX(REVERSE('&['), REVERSE(@uniqueName))
	If @lastStartBracketPos = LEN(@uniqueName) RETURN NULL  -- Return NULL if a key ("&[") is not found.
	ELSE SET @lastStartBracketPos = @lastStartBracketPos + 2 -- +2 to start on the key's startindex (jump over "&[")

	DECLARE @elementKey nvarchar(20) = NULL
	SELECT @elementKey = SUBSTRING(@uniqueName, @lastStartBracketPos, LEN(@uniqueName) - (@lastStartBracketPos))

	RETURN @elementKey

END
GO
