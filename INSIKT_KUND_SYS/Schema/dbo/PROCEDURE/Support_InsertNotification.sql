SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************
	#Desc: 		Adds a notification for an INSIKT user.
				This procedure will add rows in the Notification table.
	#Used By:
	#Creator:
	#CreateDate:
	#Modified by:	Gustav Bolén
	#ModifiedDate: 260316
					
	#Log:			260316 - GUBO - Changed the procedure from using ReferenceID = 0 (ScoreCardGoal) to -1 and 
								added the ReferenceType = NULL to represent a generic notification.

********************************************************************/

CREATE procedure [dbo].[Support_InsertNotification]
	@UserID int,
	@Header nvarchar(max),
	@Body nvarchar(max),
	@Footer nvarchar(max),
	@UrlLink nvarchar(max) = null,
	@CreatedBy int = null
as
begin
	if @CreatedBy is null
		set @CreatedBy = -1

	insert into Notification (ReferenceID, ReferenceType, UserID, Header, Body, Footer, UrlLink, CreatedDate, CreatedBy, IsRead)
	values (-1, NULL, @UserID, @Header, @Body, @Footer, @UrlLink, GETUTCDATE(), @CreatedBy, 0)
end
GO
