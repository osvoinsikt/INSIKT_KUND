SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--declare @String nvarchar(max), @Delimiter nchar(1)
--set @String = 'col1\, coalesce(col2, ''*,*''),col3, ''kalle, pelle, olle'' as col4, col5'
--set @Delimiter = ','
--select @String

--declare @result TABLE (ListPos int IDENTITY(1,1) NOT NULL PRIMARY KEY, Item nvarchar(max))        

CREATE FUNCTION [app].[SplitEscape](@String nvarchar(max), @Delimiter nchar(1))        
returns @result TABLE (ListPos int IDENTITY(1,1) NOT NULL PRIMARY KEY, Item nvarchar(max))
with schemabinding
as        
begin        
    declare @idx int        
    declare @slice nvarchar(4000)
    declare @idChar char
    declare @escapeFrom int
    declare @escapeToChar char
    
       
	select @idx = 1        
	if len(@String)<=0 or @String is null  return        
       
    while @idx!= 0        
    begin        
        set @idx = patindex('%[^\][' + @Delimiter + '('']%','.' + @String)
           
        if @idx!=0 set @idChar = substring(@String, @idx, 1)
		while @idx != 0 and @idChar != @Delimiter
			begin						
				set @escapeFrom = @idx
				set @escapeToChar = 
					case @idChar
						when '(' then ')'
						when '''' then ''''
					end
					
				set @idx = patindex('%[^\][' + @escapeToChar + ']%', '.' + right(@String, datalength(@String)/2 - @escapeFrom))
					
				if @idx != 0
					begin						
						set @idx = @escapeFrom + @idx + patindex('%[^\][' + @Delimiter + '('']%', '.' + right(@String, datalength(@String)/2 - @escapeFrom - @idx))
						if @idx!=0 set @idChar = substring(@String, @idx, 1)
					end
			end

		if @idx != 0				
			set @slice = left(@String,@idx - 1)
        else        
            set @slice = @String
        
                   
		insert into @result(item) 
		select
			replace
			(
				replace
				(
					replace
					(
						replace
						(
							ltrim(rtrim(@slice))
							,
							'\' + @Delimiter, @Delimiter
						)
						,
						'\(', '('
					)
					,
					'\)', ')'
				)
				,
				'\''', ''''
			)
  
        set @String = right(@String,datalength(@String)/2 - @idx)        
        if len(@String) = 0 break        
    end    
return        
end
--select * from @result
GO
