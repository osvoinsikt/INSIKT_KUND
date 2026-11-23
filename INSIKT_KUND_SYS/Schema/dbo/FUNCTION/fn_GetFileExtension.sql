SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*******************************************************************
 #Desc: 			Tar ut filändelsen från ett filnamn.
 #Used By:			-
 #Creator:			Adam Holmstrom
 #CreateDate:		140331
 #Modified by:		-
 #ModifiedDate:		-
 
 #Log:

********************************************************************/
CREATE FUNCTION [dbo].[fn_GetFileExtension]
(
	@fileName nvarchar(250)
)
RETURNS varchar(5)
AS
BEGIN
	--SELECT dbo.fn_GetFileExtension('fileName.txt')
	--SELECT dbo.fn_GetFileExtension('file.Name.txt')
	DECLARE @extension varchar(5)

	SELECT @extension = 
		CASE 
		WHEN @fileName LIKE '%.%' THEN 
			RIGHT(@fileName, CHARINDEX('.', REVERSE(@fileName)))
		ELSE @fileName
    END

	RETURN @extension

END
GO
