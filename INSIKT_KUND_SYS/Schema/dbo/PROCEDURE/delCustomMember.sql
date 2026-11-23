SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************
 #Desc: 		Deletes a custom member
 #Used By:		-
 #InParam:		-
 #ResultSet:		-
 #
 #Returns:		-
 #Owner:		DBO
 #Creator:		Daniel Hellström
 #CreateDate:		041206
 #Modified by:		Daniel Hellström
 #ModifiedDate:		050516
 
 #Log:
	050516	DH	Added transaction management and delete statement for CustomMemberMembers
********************************************************************/
CREATE PROCEDURE [dbo].[delCustomMember]
	@iCustomMemberID int
AS

-- delCustomMember 1

set nocount on

update CustomMembers
set IsDeleted = 1
where ID = @iCustomMemberID
GO
