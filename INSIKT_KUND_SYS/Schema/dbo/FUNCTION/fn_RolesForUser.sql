SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/*******************************************************************
 #Desc: 		-
 #Used By:		-
 #InParam:		-
 #ResultSet:		-
 #
 #Returns:		-
 #Owner:		DBO
 #Creator:		Daniel Hellström
 #CreateDate:		130624
 #Modified by:		-
 #ModifiedDate:		-
 
 #Log:

********************************************************************/
CREATE    FUNCTION [dbo].[fn_RolesForUser] (@iUserID int) 
RETURNS @roles TABLE (RoleID int)
AS

BEGIN

	DECLARE @isGroupUser bit
	
	-- Har användaren manuella behörigheter eller fått behörigheter via grupp --
	SELECT @isGroupUser = CASE WHEN UserTypeID = 5 THEN 1 ELSE 0 END   
	FROM UserSecurityGroup
	WHERE UserID = @iUserID
	-----------------------------------------------------------------------------

	
	IF @isGroupUser = 1 
	BEGIN
		-- Användaren får sina behörigheter via grupper

		WITH GroupsForUser (GroupID)
		AS
		(
			SELECT usg.UserID
			FROM UserSecurityGroupRelation usgRel
				INNER JOIN UserSecurityGroup usg ON usgRel.SecurityGroupID = usg.UserID and usg.IsDeleted = 0
			WHERE usgRel.UserID = @iUserID
		)
		
	
		INSERT INTO @roles(RoleID)
		SELECT DISTINCT RoleID
		FROM UserSecurityGroupRoleRelation
		INNER JOIN GroupsForUser ON GroupsForUser.GroupID = UserSecurityGroupRoleRelation.UserID
			
	
	END
	ELSE
	BEGIN
		-- Användaren är inte en gruppanvändare. Vi går direkt mot UserSecurityRoleRelation
	
		INSERT INTO @roles(RoleID)
		SELECT RoleID
		FROM UserSecurityGroupRoleRelation
		WHERE UserID = @iUserID
	
	END


	RETURN
END
GO
