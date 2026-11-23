SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [app].[Year]
(
	@DateID int
) returns int 
with schemabinding
as
begin
	return
	(
		@DateID / 10000
	)
end
GO
