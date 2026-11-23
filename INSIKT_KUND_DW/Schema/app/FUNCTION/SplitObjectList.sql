SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [app].[SplitObjectList]
(
	@String nvarchar(max)
)
returns @result TABLE (ListPos int IDENTITY(1,1) NOT NULL PRIMARY KEY, Item nvarchar(max))        
with schemabinding
as        
begin        
    declare @len int = datalength(@String)/2
	declare @charPos int = 0
	declare @trimToData bit = 1
	declare @endQuoteAt int = 0
	declare @char nchar
	declare @sliceStartAt int = 0
	declare @sliceData nvarchar(max)
	declare @trimAtSliceDataEnd int = 0
	

	
    
    while @charPos <= @len
    begin
		set @charPos = @charPos + 1
		set @char =  substring(@String, @charPos, 1)

		if @trimToData = 1 
			begin
				if @char in (char(9), char(10), char(13), char(32))
					continue 
			
				set @trimToData = 0
				set @sliceStartAt = @charPos
			end
		

		if @char = '[' 
			begin
				set @endQuoteAt = charindex(']', @String, @charPos + 1)
				while @endQuoteAt <> 0 and @endQuoteAt < @len
				begin
					
					if substring(@String, @endQuoteAt + 1, 1) <> ']' break
						
					set @endQuoteAt = charindex(']', @String, @endQuoteAt + 2)
				end
				set @charPos = @endQuoteAt
			end
		if @char = ',' or @charPos > @len
			begin
				set @sliceData = substring(@String, @sliceStartAt, @charPos - @sliceStartAt)
				set @trimAtSliceDataEnd = patindex('%[^' + char(9) + char(10) + char(13) + ' ]%', reverse(@sliceData)) -1
				if @trimAtSliceDataEnd > 0 set @sliceData = left(@sliceData, DATALENGTH(@sliceData) / 2 - @trimAtSliceDataEnd)

				insert into @result(Item)
				select 
					Item = @sliceData

				set @sliceStartAt = 0
				set @trimToData = 1

			end
    end

return
end
GO
