SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Ersätter tecken i en sträng så att strängen kan sättas in i XML.
-- Strängen blir giltig både som attribut och data.
CREATE FUNCTION [dbo].[fn_EscapeXML]
(
	@value nvarchar(max)
)
RETURNS nvarchar(max)
AS
BEGIN
	return
		replace(
			replace(
				replace(
					replace(
						replace(@value, '&', '&amp;')
					,'<', '&lt;')
				,'>', '&gt;')
			,'"', '&quot;')
		,'''', '&#39;')
END
GO
