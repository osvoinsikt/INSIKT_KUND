SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [app].[DateIDFromParts]
(
	@Year int
	,@Month int
	,@Day int
) returns int 
with schemabinding
as
begin
	return
	(
		@Year * 10000
		+
		@Month * 100
		+
		@Day
	)
end
GO
