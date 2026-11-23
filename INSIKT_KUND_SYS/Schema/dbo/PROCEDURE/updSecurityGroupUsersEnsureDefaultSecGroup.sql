SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Description:	Makes sure that Automatic users have a valid default security group. Those who don't have one will be marked as deleted.
-- =============================================
CREATE PROCEDURE [dbo].[updSecurityGroupUsersEnsureDefaultSecGroup]
(
	@CalledByUserID int = -1
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Get the users who need a new default group
	SELECT usr.UserID, 
		usr.DefaultSecGroupID as OldDefaultSecurityGroupID, 
		(SELECT min(rel.SecurityGroupID)
	     FROM UserSecurityGroupRelation rel
		 WHERE rel.UserID = usr.UserID
		 GROUP BY rel.UserID) as NewDefaultSecurityGroupID
	INTO #usersToUpdateDefaultGroup
	FROM UserSecurityGroup usr
	WHERE usr.DefaultSecGroupID IS NOT NULL
	  AND NOT EXISTS(SELECT 1
	                 FROM UserSecurityGroupRelation rel
	                 WHERE rel.UserID = usr.UserID
	                   AND rel.SecurityGroupID = usr.DefaultSecGroupID)

	-- Try to find a new default security group for those who have lost their current one.
	-- Will skip those who has DefaultSecGroupID = NULL since they are using manual settings.
	UPDATE UserSecurityGroup
	SET DefaultSecGroupID = usrToUpdate.NewDefaultSecurityGroupID
	FROM UserSecurityGroup usr
		inner join #usersToUpdateDefaultGroup usrToUpdate on usr.UserID = usrToUpdate.UserID

	-- Log about the updated default group
	insert into dbo.UserSecurityGroupLog (InitiatedBy, EventDate, TypeID, UserID, 
		PropertyID, OldValue, OldDisplayValue, NewValue, NewDisplayValue)
	select @CalledByUserID, GETUTCDATE(), 5, usrToUpdate.UserID, 8, 
		usrToUpdate.OldDefaultSecurityGroupID, oldDefGrp.FullName,
		usrToUpdate.NewDefaultSecurityGroupID, newDefGrp.FullName
	from #usersToUpdateDefaultGroup usrToUpdate
		inner join UserSecurityGroup oldDefGrp on oldDefGrp.UserID = usrToUpdate.OldDefaultSecurityGroupID
		left join UserSecurityGroup newDefGrp on newDefGrp.UserID = usrToUpdate.NewDefaultSecurityGroupID

	-- Get users who are synchronized users but are not part of any group.
	SELECT usr.UserID
	INTO #UsersToBeRemoved
	FROM UserSecurityGroup usr
	WHERE (usr.UserTypeID = 5 OR usr.UserTypeID = 7)
	  AND usr.IsDeleted = 0
	  AND usr.DomainID is not null
	  AND (SELECT TOP 1 rel.SecurityGroupID
	      FROM UserSecurityGroupRelation rel
	      WHERE rel.UserID = usr.UserID) IS NULL

	-- Mark users as removed
	UPDATE UserSecurityGroup
	SET IsDeleted = 1
	FROM UserSecurityGroup usr
		INNER JOIN #UsersToBeRemoved userToBeRemoved on userToBeRemoved.UserID = usr.UserID

	-- Log access removed
	insert into dbo.UserSecurityGroupLog (InitiatedBy, EventDate, TypeID, UserID)
	select @CalledByUserID, GETUTCDATE(), 2, userToBeRemoved.UserID
	from #UsersToBeRemoved userToBeRemoved

	-- Remove property values for removed users
	DELETE pv
	FROM UserSecurityGroupPropertyValue pv
		INNER JOIN #UsersToBeRemoved userToBeRemoved on userToBeRemoved.UserID = pv.UserID

	DROP TABLE #usersToUpdateDefaultGroup
	DROP TABLE #UsersToBeRemoved
END
GO
