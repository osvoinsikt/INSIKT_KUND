SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[registerTabTimeout]
		@SessionTabLogId int
AS

set nocount on

update SessionTabLog set TimeoutTime = GETUTCDATE()
where [ID] = @SessionTabLogId
GO
