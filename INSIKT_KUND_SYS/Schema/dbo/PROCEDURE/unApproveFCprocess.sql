SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************
 #Desc: 		Removes the approval of an FCProcess
 #Used By:		-
 #InParam:		-
 #ResultSet:		-
 #
 #Returns:		-
 #Owner:		DBO
 #Creator:		Daniel Hellström
 #CreateDate:		040915
 #Modified by:		-
 #ModifiedDate:		-
 
 #Log:

********************************************************************/
CREATE	Procedure [dbo].[unApproveFCprocess]
	@iProcessID int
AS

declare @errmsg varchar(100)
declare @secondapprover int

-- approveFCProcess

	-- Get the status for the given FCprocess
	SELECT @secondapprover = SecondaryApprovedBy FROM FCProcess WHERE [ID] = @iProcessID

	if @secondapprover is null	--Clear the first approval
		begin
			update [dbo].[FCProcess]
			set	[ApprovedDate] = null
				,[ApprovedBy] = null
			where [ID] = @iProcessID
	
		end
	else
		begin
			update [dbo].[FCProcess]
			set	[SecondaryApprovedDate] = null
				,[SecondaryApprovedBy] = null
			where [ID] = @iProcessID

		end
	
	set @errmsg = 'Kunde inte uppdatera prognosprocess.'
	if @@error <> 0 goto err



return

err:
	rollback transaction
	set @errmsg = @errmsg + ' Misslyckades vid godkännande'
	raiserror (@errmsg,16,1)
	return (-100)
GO
