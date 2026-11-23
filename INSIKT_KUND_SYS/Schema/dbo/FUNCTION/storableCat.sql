SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/*******************************************************************
 #Desc: 		Function that returns storable categories for the given user
 #Used By:		-
 #InParam:		Username
 #ResultSet:		-
 #
 #Returns:		-
 #Owner:		DBO
 #Creator:		Daniel Hellström
 #CreateDate:		040129
 #Modified by:		-
 #ModifiedDate:		-
 
 #Log:

********************************************************************/
CREATE   FUNCTION [dbo].[storableCat] (
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

-- select * from dbo.storableCat(12, 0)

BEGIN

insert into @categories 
select 	[ID]
	,[Name]
	,[ParentID] 

from 	Category as c
	
where (isOpenSave = 1 and [ParentID] is not NULL and [User] = @vsUser)
or ([ParentID] is not NULL and isOpenSave = 1 and ([User] is null or [User] = ''))
or (@fullCommonAccess = 1 and isCommon = 1 and [ParentID] is not NULL)
or [Name] = 'reportsPrivateFolder'

RETURN
END
GO
