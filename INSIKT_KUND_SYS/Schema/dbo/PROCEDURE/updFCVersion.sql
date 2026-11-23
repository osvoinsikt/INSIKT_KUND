SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************
 #Desc: 		Updates a FCVersion
 #Used By:		-
 #InParam:		-
 #ResultSet:		-
 #
 #Returns:		-
 #Owner:		DBO
 #Creator:		Anders Holm
 #CreateDate:		110509
 #Modified by:		-
 #ModifiedDate:		-
 
 #Log:
		110509	ANHO	Created

********************************************************************/
CREATE	Procedure [dbo].[updFCVersion]
	@ID int,
	@Name varchar(50),
	@Description varchar(100),
	@FiscalYear int,
	@Type int,
	@IsAnalysisReady bit,
	@isWritable bit,
	@openForSuperUsers bit,
	@availableOnlyToSuperUsers bit,
	@ModifiedBy int,
	@ModifiedDate smalldatetime
AS
--[updFCVersion] 5, 'Test','', 2012,6,2,true,true,5,'2011-05-09'

	UPDATE FCVersion
	SET 
		Name = @Name,
		[Description] = @Description,
		[Type] = @Type,
		IsActiveBudget = @IsAnalysisReady,
		IsActivePrognos = @IsAnalysisReady,
		IsBudget = @isWritable,	
		PreviousYear = @FiscalYear-1,
		PrevPreviousYear = @FiscalYear-2,
		FiscalYear = @FiscalYear,
		ModifiedBy = @ModifiedBy,
		ModifiedDate = @ModifiedDate,
		OpenForSuperUsers = @openForSuperUsers,
		OnlyAvailableToSuperUsers = @availableOnlyToSuperUsers
	WHERE ID = @ID

	select @ID
GO
