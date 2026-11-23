SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [app].[PrintMax]
(
	@str nvarchar(max)
)
as
begin
	-- nothing we can do with null data
	if (@str is null)
		return
	-- Uniform line breaks to be just one nchar(10) whatever input.
	set @str = 
		replace
		(
			replace(@str, nchar(13) + nchar(10), nchar(10))
			,nchar(13)
			, nchar(10)
		)
	-- This procedure was created to properly print
	-- nvarchar(max) since the print statement can
	-- only handle NVARCHAR(4000), we break the
	-- input down into 4000 byte blocks and print
	-- upto the last linebreak before the 4000 byte cutoff
	declare
	 	 @ReversedData nvarchar(max)
		,@LineBreakIndex int
		,@SearchLength int
	-- if the search length is less than the first occurance
	-- of a line break, the data will be printed with a line break
	-- at the SearchLength position even though there should not be
	-- a break in the data there.
	set @SearchLength = 4000

	-- only loop while the input is greater than the search length
	while len(@str) > @SearchLength
		begin
			-- obtain and reverse the input upto the search length
			set @ReversedData = reverse(left(@str, @SearchLength))			
			-- determine the position of the first line break for this piece of data
			set @LineBreakIndex = charindex(char(10), @ReversedData)
			-- print the input only showing data upto the line break
			-- the original linebreak will not be displayed
			print left(@str, @SearchLength - @LineBreakIndex)
			-- resize the input removing the data that was displayed and the line break.
			set @str = right(@str, len(@str) - @SearchLength + @LineBreakIndex-1)
		end
	-- if there is any data remaining, print it
	if len(@str) > 0
		print @str	
end
GO
