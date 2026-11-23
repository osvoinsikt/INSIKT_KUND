SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [dbo].[selGroupSuperAdmin]
	@iUserID int
AS
SELECT TOP(1) 
	securityGroup.UserName as GroupSuperAdminName,
	securityGroup.SuperAdmin as GroupSuperAdmin

	FROM
		dbo.UserSecurityGroup AS usg
			INNER JOIN dbo.UserSecurityGroupRelation AS userGroupRelation ON 
				userGroupRelation.UserID = usg.UserID
			INNER JOIN dbo.UserSecurityGroup As securityGroup ON
				securityGroup.UserID = userGroupRelation.SecurityGroupID and securityGroup.IsDeleted = 0

	WHERE usg.[UserID] = @iUserID and securityGroup.SuperAdmin is not null

GO
