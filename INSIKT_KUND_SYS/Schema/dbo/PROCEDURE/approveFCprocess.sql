SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*******************************************************************

 #Desc:                                Approves an FCProcess
 #Used By:                           -
 #InParam:                            -
 #ResultSet:                          -
 #

 #Returns:                             -
 #Owner:						DBO
 #Creator:						Daniel Hellström
 #CreateDate:					031022
 #Modified by:					DH
 #ModifiedDate:					040914

 

 #Log:

	040914	DH	Added support for secondary approval

 

********************************************************************/
CREATE Procedure [dbo].[approveFCprocess]
    @iProcessID int
    ,@userID int

AS
	declare @errmsg varchar(100)
	declare @firstapprover int

    -- Get the status for the given FCprocess
    SELECT @firstapprover = ApprovedBy FROM FCProcess WHERE [ID] = @iProcessID

    if @firstapprover is null           --This is the first approval
    begin
        update [dbo].[FCProcess]
        set [ApprovedDate] = convert(varchar,getutcdate(),120)
			,[ApprovedBy] = @userID
        where [ID] = @iProcessID
    end

    else

	begin
		update [dbo].[FCProcess]
		set [SecondaryApprovedDate] = convert(varchar,getutcdate(),120)
			,[SecondaryApprovedBy] = @userID
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
