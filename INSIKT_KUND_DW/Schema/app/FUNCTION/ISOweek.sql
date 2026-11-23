SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [app].[ISOweek] (@DATE datetime)
RETURNS int
with schemabinding
AS
BEGIN
	RETURN
		--((DATEPART(dy,DATEADD(dd,DATEDIFF(dd,convert(datetime,'17530101', 112),@DATE)/7*7,convert(datetime, '17530104', 112)))+6)/7)
		(datepart(ISO_WEEK,@DATE))

END
GO
