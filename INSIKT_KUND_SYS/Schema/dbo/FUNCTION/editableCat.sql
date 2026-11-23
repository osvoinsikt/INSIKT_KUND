SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/*******************************************************************
 #Desc: 		Function that returns editable categories for the given user
 #Used By:		-
 #InParam:		Username
 #ResultSet:		-
 #
 #Returns:		-
 #Owner:		DBO
 #Creator:		Daniel Hellström
 #CreateDate:		051006
 #Modified by:		-
 #ModifiedDate:		-
 
 #Log:

********************************************************************/
CREATE    FUNCTION [dbo].[editableCat] (
	@vsUser Int,
	@fullCommonAccess bit
)

RETURNS @categories TABLE
(
	[ID] int
	,[Name] varchar(50)
	,[ParentID] int

)
AS

-- select * from dbo.editableCat('TRIMMA\dahe')

BEGIN

insert into @categories 
select 	[ID]
	,[Name]
	,[ParentID] 

from 	Category as c
	
where (isOpenSave = 1 and [ParentID] is not NULL and [User] = @vsUser)			-- En katalog som är min
or (@fullCommonAccess = 1 and isCommon = 1 and [ParentID] is not NULL)				-- Operatörer kan ändra på gemensamma

RETURN
END
GO
