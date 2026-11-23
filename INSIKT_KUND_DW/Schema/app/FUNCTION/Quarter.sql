SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [app].[Quarter]
(
	@DateID int
) returns int 
with schemabinding
as
begin
	return
	(
		(@DateID / 100 % 100 - 1) / 3 + 1
	)
end
GO
