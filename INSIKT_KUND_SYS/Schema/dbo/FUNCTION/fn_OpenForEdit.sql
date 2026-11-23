SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*******************************************************************
 #Desc: 			Returnerar 1 för öppen annars 0 
 #Used By:			-
 #InParam:			-
 #ResultSet:		-
 #
 #Returns:			-
 #Owner:			DBO
 #Creator:			Anders Holm
 #CreateDate:		090506
 #Modified by:		Daniel Hellström
 #ModifiedDate:		101026
 #Misc:				Copyright TRIMMA Affärsutveckling AB
 #Log:
		101026	DAHE	Kommenterat bort den senare delen.
********************************************************************/


--Select  dbo.fn_OpenForEdit('3303',5,0,1) 



CREATE   Function [dbo].[fn_OpenForEdit] (@FCElementKey varchar(20),@VersionID int,@FCTypeID int,@CompanyID int )  RETURNS varchar(50) 
AS  
BEGIN 

	Declare @NofApproval int,@value int

	Select @value=0

	If Exists 	(	
			Select * from dbo.FCProcess 
			Where  (FinishedDate is null or FinishedDate = '')		
			And	FCLevel01=@FCElementKey
			And	FCVersion=@VersionID
			And (FCTypeID=@FCTypeID or FCTypeID is null)
			And (CompanyID=@CompanyID or CompanyID is null)
			)
	select @value=1
	 
	--If Exists 	(	
	--		Select * from dbo.FCProcess 
	--		Where  (FinishedDate is not null or FinishedDate <> '')
	--		And (ApprovedDate is null or ApprovedDate = '')
	--		And (SecondaryApprovedDate is null or SecondaryApprovedDate = '')
	--		And	FCLevel01=@FCElementKey
	--		And	FCVersion=@VersionID
	--		And (FCTypeID=@FCTypeID or FCTypeID is null)
	--		And (CompanyID=@CompanyID or CompanyID is null)
	--		)
	--select @value=1

	Return @value
END





GO
