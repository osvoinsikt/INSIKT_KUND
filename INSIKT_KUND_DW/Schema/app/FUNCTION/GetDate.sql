SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [app].[GetDate]
(
	@dateID int
) returns datetime 
with schemabinding
as
begin
	return
	(
		convert(datetime,convert(char(8),nullif(@dateID, 0)), 112)
		--cast(nullif(@dateID, 0) as char(8))
		--datefromparts(@dateID / 10000, @dateID / 100 % 100, @dateID % 100)
	)
end
GO
