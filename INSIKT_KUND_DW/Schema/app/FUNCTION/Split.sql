SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [app].[Split](@String nvarchar(max), @Delimiter nchar(1))        
returns @result TABLE (ListPos int IDENTITY(1,1) NOT NULL PRIMARY KEY, Item nvarchar(max))        
with schemabinding
as        
begin        
    declare @idx int        
    declare @slice nvarchar(4000)
       
    select @idx = 1        
        if len(@String)<=0 or @String is null  return        
       
    while @idx!= 0        
    begin        
        set @idx = charindex(@Delimiter,@String)        
        if @idx!=0        
            set @slice = left(@String,@idx - 1)        
        else        
            set @slice = @String        
                   
		insert into @result(item) values(ltrim(rtrim(@slice)))        
  
        set @String = right(@String,datalength(@String)/2 - @idx)        
        if len(@String) = 0 break        
    end    
return        
end
GO
