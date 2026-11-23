SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [app].[Month]
(
	@DateID int
) returns int 
with schemabinding
as
begin
	return
	(
		@DateID / 100 % 100
	)
end
GO
