SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************
 #Desc:                                Selects all FCProcess by Compan and FCType
 #Used By:                           -
 #InParam:                            -
 #ResultSet:                          -
 #

 #Returns:                             -
 #Owner:                               DBO
 #Creator:                          Anders Holm
 #CreateDate:						090224
 #Modified by:                     
 #ModifiedDate:                         

 #Log:								
********************************************************************/
CREATE            Procedure [dbo].[selFCProcessesByCompanyAndFCType]
(
              @CompanyID int,
              @FCTypeID int,
              @FCVersionID int
 )
AS

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

WHERE (FCProcess.FCTypeID = @FCTypeID or FCProcess.FCTypeID is null)
AND (FCProcess.CompanyID = @CompanyID or FCProcess.CompanyID is null)
AND FCProcess.FCVersion = @FCVersionID
GO
