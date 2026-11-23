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
 #Modified by:		Johan Kultti
 #ModifiedDate:		100226
 
 #Log:
100226	JOKU	Modified to support longer browser properties data (type and version can be very long)
********************************************************************/
CREATE	Procedure [dbo].[registerBrowser]
	@nID int
	,@vsBrowser nvarchar(350)

AS

-- registerLogin

set nocount on

declare @errmsg varchar(100)

update SessionLog set vsBrowser = @vsBrowser	
Where [ID] =  @nID
		
set @errmsg = '¤dbError_GeneralUpdateError'		
		
if @@error <> 0 goto err

return

err:
	set @errmsg = @errmsg + '¤dbError_FailedToLogOut'
	raiserror (@errmsg,16,1)
	return (-100)

GO
