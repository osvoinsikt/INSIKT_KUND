SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************
 #Desc: 		Selects mailadresses to users/groups that belong to this subscription.
 #Used By:		-
 #InParam:		SubscriptionID
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
				151130 - EMAH - Changed the procedure to use subscriptionID and don't care about schedules. (INSIKTService uses another procedure that takes advantage of schedule IDs: getMailAdressAndMailBodyFromScheduleID
				180105 - CAAL - Also return LangIDs for the users
				201005 - ANGU - Returns usernames as well 
********************************************************************/
CREATE Procedure [dbo].[getMailAdressAndMailBodyFromID]
	@subscriptionID int
	
AS

 --DECLARE @subscriptionID INTEGER;
 --SET @subscriptionID = 1024;


-- Get E-mails for all users in any way associated with a schedule event to a subscription
	
-- All normal users included in subscriptions in the schedule
select [User].[EmailAdress], [Subscription].MailBody, [User].[LangID], [User].UserName
from [User]
inner join [SubscriptionUserRelation] on [SubscriptionUserRelation].[UserID] = [User].[UserID]
inner join [Subscription] on [Subscription].[ID] = [SubscriptionUserRelation].[SubscriptionID]
where ([User].[EmailAdress] Is Not NULL) AND ([User].[EmailAdress] <> '') AND subscription.ID = @subscriptionID

UNION

-- All normal users belonging to groups included in subscriptions in the schedule
select normalUser.[EmailAdress], [Subscription].[MailBody], normalUser.[LangID], normalUser.[UserName]
from [User] normalUser
inner join [UserGroupRelation] ON [UserGroupRelation].[UserID] = normalUser.[UserID]							-- only with regular users belonging to groups
inner join [Group] ON [Group].ID = [UserGroupRelation].[GroupID]												-- join group data
inner join [SubscriptionGroupRelation] ON [SubscriptionGroupRelation].[GroupID] = [Group].[ID]					-- only with group belonging to a subscription
inner join [Subscription] ON [Subscription].[ID] = [SubscriptionGroupRelation].[SubscriptionID]					-- only subscriptions with group subscribers
where (normalUser.[EmailAdress] Is Not NULL) AND (normalUser.[EmailAdress] <> '') AND subscription.ID = @subscriptionID

UNION

-- All normal users belonging to a securitygroup belonging to a group included in subscriptions in the schedule
select normalUser.[EmailAdress], [Subscription].[MailBody], normalUser.[LangID], normalUser.[UserName]
from [User] normalUser
inner join [UserSecurityGroupRelation] ON [UserSecurityGroupRelation].[UserID] = normalUser.[UserID]			-- only belonging to a group
inner join [UserSecurityGroup] secGroup ON secGroup.[UserID] = [UserSecurityGroupRelation].[SecurityGroupID]	-- securitygroup data
inner join [UserGroupRelation] ON [UserGroupRelation].[UserID] = secGroup.[UserID]								-- only with securitygroups belonging to groups
inner join [Group] ON [Group].ID = [UserGroupRelation].[GroupID]												-- join group data
inner join [SubscriptionGroupRelation] ON [SubscriptionGroupRelation].[GroupID] = [Group].[ID]					-- only with group belonging to a subscription
inner join [Subscription] ON [Subscription].[ID] = [SubscriptionGroupRelation].[SubscriptionID]					-- only subscriptions with group subscribers
where (normalUser.[EmailAdress] Is Not NULL) AND (normalUser.[EmailAdress] <> '') AND subscription.ID = @subscriptionID


-- Second result set, from Robert's old proc. Don't know if it's even used
	select [SubscriptionReportRelation].SubscriptionID
	from SubscriptionReportRelation
	where [SubscriptionReportRelation].SubscriptionID = @subscriptionID
GO
