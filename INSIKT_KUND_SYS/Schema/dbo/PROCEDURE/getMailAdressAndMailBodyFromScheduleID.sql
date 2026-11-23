SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/*******************************************************************
 #Desc: 		Selects mailadresses to users/groups that belong to this subscription.
 #Used By:		-
 #InParam:		ScheduleID
 #ResultSet:		
 #
 #Returns:		Mailadress and mailbody to send.
 #Owner:		DBO
 #Creator:		Robert Jonsson
 #CreateDate:		060309
 #Modified by:		Johan Kultti
 #ModifiedDate:		100128
 
 #Log:			070319 - ANHO -	Changed ReportID to SubscriptionID
				100128 - JOKU - Extended the fetching of mail info to groups connected to a subscription
				151130 - EMAH - Renamed the procedure so that it's clear that schedule ID is used and created another procedure that takes subscription ID as a parameter.

********************************************************************/
CREATE Procedure [dbo].[getMailAdressAndMailBodyFromScheduleID]
	@scheduleID int
	
AS

-- DECLARE @scheduleID INTEGER;
-- SET @scheduleID = 12;


-- Get E-mails for all users in any way associated with a schedule event to a subscription
	
-- All normal users included in subscriptions in the schedule
select [User].[EmailAdress], [Subscription].MailBody
from [User]
inner join [SubscriptionUserRelation] on [SubscriptionUserRelation].[UserID] = [User].[UserID]
inner join [Subscription] on [Subscription].[ID] = [SubscriptionUserRelation].[SubscriptionID]
inner join [SubscriptionScheduleRelation] on [SubscriptionScheduleRelation].[ScheduleID] = @scheduleID AND [SubscriptionScheduleRelation].[SubscriptionID]= [Subscription].[ID]
where ([User].[EmailAdress] Is Not NULL) AND ([User].[EmailAdress] <> '')

UNION

-- All normal users belonging to groups included in subscriptions in the schedule
select normalUser.[EmailAdress], [Subscription].[MailBody]
from [User] normalUser
inner join [UserGroupRelation] ON [UserGroupRelation].[UserID] = normalUser.[UserID]							-- only with regular users belonging to groups
inner join [Group] ON [Group].ID = [UserGroupRelation].[GroupID]												-- join group data
inner join [SubscriptionGroupRelation] ON [SubscriptionGroupRelation].[GroupID] = [Group].[ID]					-- only with group belonging to a subscription
inner join [Subscription] ON [Subscription].[ID] = [SubscriptionGroupRelation].[SubscriptionID]					-- only subscriptions with group subscribers
inner join [SubscriptionScheduleRelation] on [SubscriptionScheduleRelation].[ScheduleID] = @scheduleID AND [SubscriptionScheduleRelation].[SubscriptionID]= [Subscription].[ID] -- only subscriptions belonging to the given schedule
where (normalUser.[EmailAdress] Is Not NULL) AND (normalUser.[EmailAdress] <> '')

UNION

-- All normal users belonging to a securitygroup belonging to a group included in subscriptions in the schedule
select normalUser.[EmailAdress], [Subscription].[MailBody]
from [User] normalUser
inner join [UserSecurityGroupRelation] ON [UserSecurityGroupRelation].[UserID] = normalUser.[UserID]			-- only belonging to a group
inner join [UserSecurityGroup] secGroup ON secGroup.[UserID] = [UserSecurityGroupRelation].[SecurityGroupID]	-- securitygroup data
inner join [UserGroupRelation] ON [UserGroupRelation].[UserID] = secGroup.[UserID]								-- only with securitygroups belonging to groups
inner join [Group] ON [Group].ID = [UserGroupRelation].[GroupID]												-- join group data
inner join [SubscriptionGroupRelation] ON [SubscriptionGroupRelation].[GroupID] = [Group].[ID]					-- only with group belonging to a subscription
inner join [Subscription] ON [Subscription].[ID] = [SubscriptionGroupRelation].[SubscriptionID]					-- only subscriptions with group subscribers
inner join [SubscriptionScheduleRelation] on [SubscriptionScheduleRelation].[ScheduleID] = @scheduleID AND [SubscriptionScheduleRelation].[SubscriptionID]= [Subscription].[ID] -- only subscriptions belonging to the given schedule
where (normalUser.[EmailAdress] Is Not NULL) AND (normalUser.[EmailAdress] <> '')


-- Second result set, from Robert's old proc. Don't know if it's even used
	select [SubscriptionReportRelation].SubscriptionID
	from SubscriptionReportRelation
	inner join [SubscriptionScheduleRelation] on [SubscriptionScheduleRelation].ScheduleID = @scheduleID
	where [SubscriptionReportRelation].SubscriptionID = [SubscriptionScheduleRelation].SubscriptionID

GO
