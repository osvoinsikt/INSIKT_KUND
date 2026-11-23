SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/******************************************************************* 
 #Desc: 		Create a FCVersion 
 #Used By:		- 
 #InParam:		- 
 #ResultSet:		- 
 # 
 #Returns:		- 
 #Owner:		DBO 
 #Creator:		Anders Holm 
 #CreateDate:		110511 
 #Modified by:		- 
 #ModifiedDate:		- 
  
 #Log: 
		110511	ANHO	Created 
 
********************************************************************/ 
CREATE Procedure [dbo].[insFCVersion]	 
	@Name varchar(50), 
	@Description varchar(100), 
	@FiscalYear int, 
	@CompanyID int, 
	@Type int, 
	@IsAnalysisReady bit, 
	@isWritable bit, 
	@openForSuperUsers bit, 
	@availableOnlyToSuperUsers bit, 
	@CreatedBy int, 
	@CreatedDate datetime 
	 
AS 
--[insFCVersion] 'Test2','', 2015,1,2,true, 5,'2011-05-09' 
declare @errmsg varchar(100) 
declare @newID int 
 
declare @PreviousBudgetID int 
declare @PrevPreviousBudgetID int 
declare	@PreviousPrognosID int 
 
select top(1) @PreviousBudgetID = v.ID 
from FCVersion v 
where [Type] = 1 
and CompanyCode = @CompanyID 
order by FiscalYear desc, ID desc 
 
 
select @PrevPreviousBudgetID = v.PreviousBudgetID 
from FCVersion v 
where ID = @PreviousBudgetID 
 
select top(1) @PreviousPrognosID = v.ID 
from FCVersion v 
where [Type] = 2 
and CompanyCode = @CompanyID 
order by FiscalYear desc, ID desc 
 
 
	SET @newID = (SELECT max(ID)+1 from FCVersion) 
 
	INSERT INTO FCVersion 
	SELECT  
		ID = @newID, 
		Name = @Name, 
		[Description] = @Description, 
		FiscalYear = @FiscalYear,		 
		IsBudget = @isWritable, 
		IsActiveBudget = @IsAnalysisReady, 
		IsActivePrognos = @IsAnalysisReady, 
		PreviousBudgetID = @PreviousBudgetID, 
		PreviousPrognosID =  @PreviousPrognosID, 
		PrevPreviousBudgetID = @PrevPreviousBudgetID, 
		PreviousYear = @FiscalYear-1, 
		PrevPreviousYear = @FiscalYear-2, 
		[Month] = 0, 
		PeriodMonth = 0, 
		CompanyCode = @CompanyID, 
		[Type] = @Type, 
		IDWithinType = null, 
		CreatedBy = @CreatedBy, 
		CreatedDate = cast(@CreatedDate as smalldatetime), 
		Attribute1 = null, 
		Attribute2 = null,	 
		Attribute3 = null,	 
		NrOfLockedPeriods = null,			 
		ModifiedBy = null, 
		ModifiedDate = null, 
		FCVersionCategoryID = null, 
		SortOrder = null, 
		IsDeleted = 0, 
		OpenForSuperUsers = @openForSuperUsers, 
		AvailableOnlyToSuperUsers = @availableOnlyToSuperUsers, 
		OriginVersionID = null 
		 
select @newID 
GO
