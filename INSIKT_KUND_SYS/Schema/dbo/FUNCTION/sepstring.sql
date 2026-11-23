SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/*******************************************************************
 #Desc: 		Function that returns a table with the string parts
 #Used By:		-
 #InParam:		String and Separator Character
 #ResultSet:		-
 #
 #Returns:		-
 #Owner:		DBO
 #Creator:		Andreas Åström
 #CreateDate:		031011
 #Modified by:  Calle Alexandersson
 #ModifiedDate:	2018-10-09
 
 #Log:  Ändrade till ny standard enligt dbo.Split från DW.
		Ändrade till nvarchar(max)

********************************************************************/
CREATE    FUNCTION [dbo].[sepstring] (@toseparate nvarchar(max), @sepby nchar(1))

RETURNS @strings TABLE (sort int identity,
    strings nvarchar(max))
AS

--select * from dbo.sepstring('1000;2000;3000',';')

BEGIN
    declare @idx int
    declare @slice nvarchar(4000)

    select @idx = 1
    if len(@toseparate)<=0 or @toseparate is null  return

    while @idx!= 0        
    begin
        set @idx = charindex(@sepby,@toseparate)
        if @idx!=0        
            set @slice = left(@toseparate,@idx - 1)        
        else        
            set @slice = @toseparate

        insert into @strings
            (strings)
        values(ltrim(rtrim(@slice)))

        set @toseparate = right(@toseparate,datalength(@toseparate)/2 - @idx)
        if len(@toseparate) = 0 break
    end
    return
END
GO
