SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO



/*******************************************************************
 #Desc: 		Mark a message as read by the given user
 #Used By:		-
 #InParam:		-
 #ResultSet:		-
 #
 #Returns:		-
 #Owner:		DBO
 #Creator:		Daniel Hellström
 #CreateDate:		040223
 #Modified by:		Daniel Hellström
 #ModifiedDate:		100829
 
 #Log:
		100829 Added check to avoid multiple rows

********************************************************************/
CREATE       Procedure [dbo].[insSetMessageAsRead]
	@iUserID int
	,@nFCMessageID int
	,@nID int output

AS

-- insFCMessage

set nocount on

declare @errmsg varchar(100)

begin transaction

		IF NOT EXISTS(SELECT ID FROM UserReadMessageRelation WHERE messageID = @nFCMessageID AND userid = @iUserID)
		BEGIN

			insert into UserReadMessageRelation
				(
				messageID
				,userid
				)
			Values
				(
				@nFCMessageID
				,@iUserID
				)
		END
		
		set @errmsg = 'Allmänt fel vid insert. '		
		
		if @@error <> 0 goto err
	
		set @nID = @@identity
	
commit transaction

return

err:
	rollback transaction
	set @errmsg = @errmsg + 'Misslyckades att sätta meddelande som läst.'
	raiserror (@errmsg,16,1)
	return (-100)




GO
