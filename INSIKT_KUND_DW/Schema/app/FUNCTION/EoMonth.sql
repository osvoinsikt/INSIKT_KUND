SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [app].[EoMonth]
(
	@DateID int	
) returns int 
with schemabinding
as
begin
	return
	(
		(@DateID / 100) * 100
		+
		case @DateID / 100 % 100
			when  1 then 31
			when  2 then 28 + case when ((@DateID / 10000) % 4 = 0 AND (@DateID / 10000) % 100 <> 0) OR (@DateID / 10000) % 400 = 0 then 1 else 0 end 
			when  3 then 31
			when  4 then 30
			when  5 then 31
			when  6 then 30
			when  7 then 31
			when  8 then 31
			when  9 then 30 
			when 10 then 31
			when 11 then 30 
			when 12 then 31
			else 31
		end
	)
end
GO
