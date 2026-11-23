SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************
 #Desc:                                Selects FCProcess macthing FCVersionID, FCTypeID, CompanyID, ElementKey
 #Used By:                           -
 #InParam:                            -
 #ResultSet:                          -
 #

 #Returns:                             -
 #Owner:                               DBO
 #Creator:                             Daniel Hellström, modified from Andreas selOpenFCProcesses
 #CreateDate:                        031022
 #Modified by:                       JOKU
 #ModifiedDate:                      100215

 #Log:
                      040915           DH                 Added support for Full names
                      040917           DH                 Added column for nrOfApprovers
                      060818           AÅ                 Changed to table ApprovalFCElementRelation for approvalrelations
					  090205	ANHO		Total remake to match new forecast (5.0)
					  100215	JOKU		remaining commented reference to deleted table ApprovalFCElementRelation removed
					  120103	ADHO		Company filter
********************************************************************/
CREATE            Procedure [dbo].[selFCProcess]
              @vsFCVersion varchar(10)
		      ,@iFCTypeID int
		      ,@iCompanyID int
              ,@vsFCLevel1 varchar(20)= NULL
              ,@vsFCLevel2 varchar(20)= NULL
              ,@vsFCLevel3 varchar(20)= NULL
              ,@vsFCLevel4 varchar(20)= NULL
              ,@vsFCLevel5 varchar(20)= NULL
AS

set nocount on

select		   [ID]
              ,FCVersion
              ,FCLevel01
              ,FCLevel02
              ,FCLevel03
              ,FCLevel04
              ,FCLevel05
              ,CreatedDate
              ,user1.UserName as CreatedBy
              ,user1.FullName as CreatedByFullname
              ,ModifiedDate
              ,user2.UserName as ModifiedBy
              ,user2.FullName as ModifiedByFullname
              ,FinishedDate
              ,user3.UserName as FinishedBy
              ,user3.FullName as FinishedByFullname
              ,ApprovedDate
              ,user4.UserName as ApprovedBy
              ,user4.FullName as ApprovedByFullname
              ,SecondaryApprovedDate
              ,user5.UserName as SecondaryApprovedBy
              ,user5.FullName as SecondaryApprovedByFullname
		      ,FCTypeID
		      ,CompanyID

from                FCProcess
                      left outer join [UserSecurityGroup] as user1 on FCProcess.CreatedBy = user1.UserID
                      left outer join [UserSecurityGroup] as user2 on FCProcess.ModifiedBy = user2.UserID
                      left outer join [UserSecurityGroup] as user3 on FCProcess.FinishedBy = user3.UserID
                      left outer join [UserSecurityGroup] as user4 on FCProcess.ApprovedBy = user4.UserID
                      left outer join [UserSecurityGroup] as user5 on FCProcess.SecondaryApprovedBy = user5.UserID

where FCVersion = @vsFCVersion
and FCTypeID = @iFCTypeID
and CompanyID = @iCompanyID
and FCLevel01 = @vsFCLevel1
and (FCLevel02 = @vsFCLevel2 or (@vsFCLevel2 is null and @vsFCLevel3 is null and @vsFCLevel4 is null and @vsFCLevel5 is null))
and (FCLevel03 = @vsFCLevel3 or (@vsFCLevel3 is null and @vsFCLevel4 is null and @vsFCLevel5 is null))
and (FCLevel04 = @vsFCLevel4 or (@vsFCLevel4 is null and @vsFCLevel5 is null))
and (FCLevel05 = @vsFCLevel5 or @vsFCLevel5 is null)
GO
