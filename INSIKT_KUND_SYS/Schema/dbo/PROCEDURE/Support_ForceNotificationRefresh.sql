SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************
 #Desc: 		Force a reload of notifications for currently logged in users
 #Used By:
 #Creator:
 #CreateDate:	2025-07-21
 #Modified by
 #ModifiedDate:
 #Change history:
 #Log:

********************************************************************/
create procedure [dbo].Support_ForceNotificationRefresh
	@CreatedBy int = null
as
begin
	if @CreatedBy is null
		set @CreatedBy = -1

	-- Only insert the force notification refresh job if there is none already
	if not exists (select 1 from ServiceJob where ServiceJobTypeID = 8 and FinishedDate is null)
	begin
		insert into ServiceJob (ServiceJobTypeID, Body, CreatedBy, CreatedDate, NotifyUserTypeID)
		values (8, '', @CreatedBy, GETUTCDATE(), 1)	-- 8 = Force Notification Refresh
	end
end
GO
