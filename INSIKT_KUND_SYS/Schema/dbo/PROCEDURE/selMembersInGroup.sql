SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[selMembersInGroup]
(
  @groupID int
)
AS

set nocount on
if @groupID = 1
   begin
	   select
		 ug.UserID
		,ug.UserName
		,d.DomainName
		,ug.FullName
		,ug.EmailAdress
		,ug.SID
		,ug.UserTypeID
	   from
		UserSecurityGroup ug left join dbo.Domain d on ug.DomainID = d.ID
	   where
		ug.UserTypeID in (3,5,7) and ug.IsDeleted = 0
	   order by
		 ug.FullName
		,ug.UserName

   end
else
   begin
	   select
		 ug.UserID
		,ug.UserName
		,d.DomainName
		,ug.FullName
		,ug.EmailAdress
		,ug.SID
		,ug.UserTypeID
	   from
		UserSecurityGroup ug
		 inner join UserGroupRelation ugr on
		  ugr.UserID = ug.UserID
		 left join dbo.Domain d on ug.DomainID = d.ID
	   where
		ugr.GroupID = @groupID
		and ug.UserTypeID in (3,5,7, 64) and ug.IsDeleted = 0
	   order by
		 ug.FullName
		,ug.UserName
   end
GO
