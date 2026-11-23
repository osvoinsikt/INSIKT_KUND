SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [app].[EndOfQuarter]
(
	@DateID int	
) returns int 
with schemabinding
as
begin
	return
	(
		(@DateID / 10000) * 10000
		+ (((@DateID / 100 % 100 - 1) / 3) * 3 + 3) * 100
	
		+
		case (((@DateID / 100 % 100 - 1) / 3) * 3 + 3)		
			when  3 then 31			
			when  6 then 30
			when  9 then 30 			
			when 12 then 31
			else 31
		end
	)
end
GO
