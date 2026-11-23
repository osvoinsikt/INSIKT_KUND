SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [app].[DateDiffMonth]
(
	@StartDateID int
	,@EndDateID int
) returns int 
with schemabinding
as
begin
	return
	(
		(@EndDateID / 10000 * 12) - (@StartDateID / 10000 * 12)
		+
		(@EndDateID / 100 % 100) - (@StartDateID / 100 % 100)
	)
end
GO
