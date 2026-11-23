SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************
 #Desc: 		Deletes all members associated with a custom member
 #Used By:		-
 #InParam:		-
 #ResultSet:		-
 #
 #Returns:		-
 #Owner:		DBO
 #Creator:		Daniel Hellström
 #CreateDate:		040130
 #Modified by:		-
 #ModifiedDate:		-
 
 #Log:

********************************************************************/
CREATE       Procedure [dbo].[delMembersForCustomMember]
	  @iCustomMemberID int
AS

-- delMembersForCustomMember

set nocount on

DELETE FROM CustomMemberMembers
WHERE CustomMemberID = @iCustomMemberID
GO
