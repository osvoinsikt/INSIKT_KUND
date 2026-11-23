SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*******************************************************************
 #Desc: 		Insert logout entry
 #Used By:		-
 #InParam:		-
 #ResultSet:		-
 #
 #Returns:		-
 #Owner:		DBO
 #Creator:		Daniel Hellström
 #CreateDate:		040203
 #Modified by:		Jonas Markström
 #ModifiedDate:		260407
 
 #Log:
- Register timeout of all connected session tabs (that are still open and have not yet timed out) to the session.
- Added an optional logoutDate parameter

********************************************************************/
CREATE Procedure [dbo].[registerLogout]
		@nID int,
		@logoutDate datetime null = null
AS

set nocount on

if @logoutDate is null
	set @logoutDate = GETUTCDATE()

update SessionLog set dtLogoutTime = @logoutDate
where [ID] = @nID

-- Register all tabs connected to the session as timed-out (which are not already timed-out)
update SessionTabLog set TimeoutTime = @logoutDate
where [SessionLogID] = @nID and TimeoutTime is null
GO
