SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************
 #Desc: 		Marks an FCProcess as finished
 #Used By:		-
 #InParam:		-
 #ResultSet:		-
 #
 #Returns:		-
 #Owner:		DBO
 #Creator:		Daniel Hellström
 #CreateDate:		031022
 #Modified by:		-
 #ModifiedDate:		-
 
 #Log:

********************************************************************/
CREATE	Procedure [dbo].[finishFCprocess]
	@iProcessID int
	,@userID int
	
AS

declare @errmsg varchar(100)

-- finsishFCProcess

		update [dbo].[FCProcess]
		set	[FinishedDate] = convert(varchar,getutcdate(),120)
			,[FinishedBy] = @userID
		where [ID] = @iProcessID

		set @errmsg = 'Kunde inte uppdatera prognosprocess.'
		if @@error <> 0 goto err


return

err:
	rollback transaction
	set @errmsg = @errmsg + ' Misslyckades vid godkännande'
	raiserror (@errmsg,16,1)
	return (-100)
GO
