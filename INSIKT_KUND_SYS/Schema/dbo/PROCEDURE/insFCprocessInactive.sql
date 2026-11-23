SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************
 #Desc: 		Inserts a new inactive FCProcess needed for key references
 #Used By:		-
 #InParam:		-
 #ResultSet:		-
 #
 #Returns:		-
 #Owner:		DBO
 #Creator:		Johan Kultti
 #CreateDate:		100121
 #Modified by:		-
 #ModifiedDate:		-
 
 #Log:

********************************************************************/
CREATE	Procedure [dbo].[insFCprocessInactive]
	@vsFCVersion varchar(10)
	,@iFCTypeID int
	,@iCompanyID int
	,@vsFCLevel1 varchar(20)
	,@vsFCLevel2 varchar(20) = NULL
	,@vsFCLevel3 varchar(20) = NULL
	,@vsFCLevel4 varchar(20) = NULL
	,@vsFCLevel5 varchar(20) = NULL
	,@userID int = NULL
	,@nID int output
AS

-- insFCprocessInactive

	declare @errmsg varchar(100)
	
	Begin
		INSERT INTO [dbo].[FCProcess]
			(
			[FCVersion]
			,[FCTypeID]
			,[FCLevel01]
			,[FCLevel02]
			,[FCLevel03]
			,[FCLevel04]
			,[FCLevel05]
			,[CreatedBy]
			,[CompanyID]
			)
		VALUES
			(
			@vsFCVersion
			,@iFCTypeID
			,@vsFCLevel1
			,@vsFCLevel2
			,@vsFCLevel3
			,@vsFCLevel4
			,@vsFCLevel5
			,@userID
			,@iCompanyID
			)

		set @errmsg = 'Kunde inte skapa ny inaktiv prognosprocess.'
		if @@error <> 0 goto err
	
		set @nID = @@identity	
	end

	return

err:
	set @errmsg = @errmsg + ' Misslyckades vid skapande av inaktiv process'
	raiserror (@errmsg,16,1)
	return (-100)
GO
