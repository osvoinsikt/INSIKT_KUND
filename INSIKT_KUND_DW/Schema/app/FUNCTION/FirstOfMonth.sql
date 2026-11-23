SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [app].[FirstOfMonth]
(
	@DateID int	
) returns int 
with schemabinding
as
begin
	return
	(
		(@DateID / 100) * 100 + 1		
	)
end
GO
