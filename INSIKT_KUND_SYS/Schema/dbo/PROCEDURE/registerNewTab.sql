SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[registerNewTab]
	@SessionLogId int,
	@TabId int,
	@SessionTabLogId int output
AS

set nocount on

insert into SessionTabLog
	(
	SessionLogID,
	TabID,
	CreationTime
	)
values
	(
	@SessionLogId
	,@TabId
	,getutcdate()
	)

set @SessionTabLogId = @@identity

return
GO
