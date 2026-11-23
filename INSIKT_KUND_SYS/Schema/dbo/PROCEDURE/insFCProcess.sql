SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************
 #Desc: 		Manage an FCprocess ALTER  or update
 #Used By:		-
 #InParam:		-
 #ResultSet:		-
 #
 #Returns:		-
 #Owner:		DBO
 #Creator:		Andreas Åström
 #CreateDate:		031012
 #Modified by:		Johan Kultti
 #ModifiedDate:		100122
 
 #Log:	100122 - Modified to update CreatedDate and CreatedBy of an inactive process

********************************************************************/
CREATE	Procedure [dbo].[insFCProcess]
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
	,@created bit output
AS

-- insFCProcess

	declare @currid int
	declare @errmsg varchar(100)

	if not exists (select [ID] 
			from FCProcess
			where FCVersion = @vsFCVersion
			and	FCTypeID = @iFCTypeID
			and	CompanyID = @iCompanyID
			and	FCLevel01 = @vsFCLevel1
			and	(FCLevel02 = @vsFCLevel2 or (@vsFCLevel2 is null and @vsFCLevel3 is null and @vsFCLevel4 is null and @vsFCLevel5 is null))
			and	(FCLevel03 = @vsFCLevel3 or (@vsFCLevel3 is null and @vsFCLevel4 is null and @vsFCLevel5 is null))
			and	(FCLevel04 = @vsFCLevel4 or (@vsFCLevel4 is null and @vsFCLevel5 is null))
			and	(FCLevel05 = @vsFCLevel5 or @vsFCLevel5 is null)) 
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
			,[CreatedDate]
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
			,getutcdate()
			,@userID
			,@iCompanyID
			)

		set @errmsg = 'Kunde inte skapa ny prognosprocess.'
		if @@error <> 0 goto err
	
		set @nID = @@identity
		set @created = 1
	end
	
	else
	begin

		declare @now datetime = getutcdate()
		
		update [dbo].[FCProcess]
		set	ModifiedDate = @now
			,ModifiedBy = @userID
			-- Set Created* if the process was previously inactive, which is signaled by CreatedDate being null.
			,CreatedBy = iif(CreatedDate is null, @userID, CreatedBy)
			,CreatedDate = iif(CreatedDate is null, @now, CreatedDate)
		where FCVersion = @vsFCVersion
			and	FCLevel01 = @vsFCLevel1
			and FCTypeID = @iFCTypeID
			and	CompanyID = @iCompanyID
			and	(FCLevel02 = @vsFCLevel2 or (@vsFCLevel2 is null and @vsFCLevel3 is null and @vsFCLevel4 is null and @vsFCLevel5 is null))
			and	(FCLevel03 = @vsFCLevel3 or (@vsFCLevel3 is null and @vsFCLevel4 is null and @vsFCLevel5 is null))
			and	(FCLevel04 = @vsFCLevel4 or (@vsFCLevel4 is null and @vsFCLevel5 is null))
			and	(FCLevel05 = @vsFCLevel5 or @vsFCLevel5 is null) 
			
		set @errmsg = 'Kunde inte uppdatera prognosprocess.'
		if @@error <> 0 goto err
	
		select @nID = [ID] from FCProcess where FCVersion = @vsFCVersion
			and	FCLevel01 = @vsFCLevel1
			and FCTypeID = @iFCTypeID
			and	CompanyID = @iCompanyID
			and	(FCLevel02 = @vsFCLevel2 or (@vsFCLevel2 is null and @vsFCLevel3 is null and @vsFCLevel4 is null and @vsFCLevel5 is null))
			and	(FCLevel03 = @vsFCLevel3 or (@vsFCLevel3 is null and @vsFCLevel4 is null and @vsFCLevel5 is null))
			and	(FCLevel04 = @vsFCLevel4 or (@vsFCLevel4 is null and @vsFCLevel5 is null))
			and	(FCLevel05 = @vsFCLevel5 or @vsFCLevel5 is null)

		set @created = 0
	end

	return

err:
	set @errmsg = @errmsg + ' Misslyckades vid processkapande'
	raiserror (@errmsg,16,1)
	return (-100)
GO
