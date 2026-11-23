SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [app].[GetDateID]
(
	@date datetime
) returns int 
with schemabinding
as
begin
	return
	(
		year(@date) * 10000 + month(@date) * 100 + day(@date)
	)
end
GO
