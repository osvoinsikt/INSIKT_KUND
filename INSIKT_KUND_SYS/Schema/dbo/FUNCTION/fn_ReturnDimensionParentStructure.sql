SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*******************************************************************
 #Desc: 		Returnerar tabell med överliggande dimensionsmedlemmar i struktur
 #Used By:		-
 
#ResultSet:		Tabell @list	
			Idnr int identity(1,1),
			ElementKey varchar(50),
			ParentElementKey varchar(50),
			[Level] int
			
 
 #Returns:		-
 #Owner:		DBO
 #Creator:		Anders Holm
 #CreateDate:		090309
 #Modified by:		-
 #ModifiedDate:		-
 
 #Log:
	

********************************************************************/
--select * from fcdimension
--Select * from fn_ReturnDimensionParentStructure ('30',0,1) where level > 1

CREATE FUNCTION [dbo].[fn_ReturnDimensionParentStructure] (@FCElementKey varchar(50), @FCTypeID int, @CompanyID int)
RETURNS @list TABLE (
			Idnr int identity(1,1),
			ElementKey varchar(50),
			ParentElementKey varchar(50),
			[Level] int
			)
			
AS
BEGIN

; with cte as (
	select ElementKey, ParentKey, Level = 1
	from FCDimension
	where FCTypeID = @FCTypeID and CompanyID = @CompanyID
		and ElementKey = @FCElementKey
	union all
	select parent.ElementKey, parent.ParentKey, Level = child.Level + 1
	from FCDimension parent
		join cte child on child.ParentKey = parent.ElementKey
	where parent.FCTypeID = @FCTypeID and parent.CompanyID = @CompanyID
)
insert into @list(ElementKey, ParentElementKey, Level)
select ElementKey, ParentKey, Level
from cte

return

END
GO
