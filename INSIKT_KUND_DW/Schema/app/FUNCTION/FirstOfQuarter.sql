SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [app].[FirstOfQuarter]
(
	@DateID int	
) returns int 
with schemabinding
as
begin
	return
	(
		(@DateID / 10000) * 10000
		+ (((@DateID / 100 % 100 - 1) / 3) * 3 + 1) * 100
		+ 1
	)
end
GO
