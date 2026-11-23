SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************
 #Desc: 		Removes mark for an FCProcess as finished
 #Used By:		-
 #InParam:		-
 #ResultSet:		-
 #
 #Returns:		-
 #Owner:		DBO
 #Creator:		Daniel Hellström
 #CreateDate:		031024
 #Modified by:		-
 #ModifiedDate:		-
 
 #Log:

********************************************************************/
CREATE	Procedure [dbo].[unFinishFCprocess]
	@iProcessID int
	
AS

declare @errmsg varchar(100)

-- unFinsishFCProcess

		update [dbo].[FCProcess]
		set	[FinishedDate] = null
			,[FinishedBy] = null
		where [ID] = @iProcessID

		set @errmsg = 'Kunde inte uppdatera prognosprocess.'
		if @@error <> 0 goto err



return

err:
	rollback transaction
	set @errmsg = @errmsg + ' Misslyckades vid borttagning av klarmarkering'
	raiserror (@errmsg,16,1)
	return (-100)
GO
