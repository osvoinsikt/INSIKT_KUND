SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Based on https://stackoverflow.com/a/1012802
CREATE FUNCTION [dbo].[fn_RemoveCharacters]
(
	@string nvarchar(max),

	-- Characters matching this pattern will be removed.
	--
	-- Examples:
	-- * '0-9' will remove all digits.
	-- * '^a-z' will remove everything except a-z.
	-- * '^a-z0-9' will remove everything except a-z and 0-9.
	--
	-- The pattern is case insensitive, so a-z matches both a-z and A-Z.
	@pattern varchar(255)
)
returns nvarchar(max)
as
begin
	set @pattern =  '%['+@pattern+']%'

	while PatIndex(@pattern, @string) > 0
		set @String = Stuff(@string, PatIndex(@pattern, @string), 1, '')

	return @String
end
GO
