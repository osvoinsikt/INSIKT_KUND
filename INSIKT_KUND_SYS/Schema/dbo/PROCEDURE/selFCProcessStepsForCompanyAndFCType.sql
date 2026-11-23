SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/*******************************************************************

 #Desc:                              Selects FCProcessSteps for Company and FCType
 #Used By:                           -
 #InParam:                           -
 #ResultSet:                         -
 #

 #Returns:                           -
 #Owner:                             DBO
 #Creator:                           Anders Holm
 #CreateDate:                        080901
 #Modified by:                       -
 #ModifiedDate:                      -

 #Log:
                      

********************************************************************/

CREATE            Procedure [dbo].[selFCProcessStepsForCompanyAndFCType]
				@CompanyID int = NULL,
				@FCTypeID int = NULL
				
AS

-- [selFCProcessStepsForCompanyAndFCType] 1, 0


set nocount on

select ps.*, pst.Name as StepType

from FCProcessStep ps
inner join FCProcessStepType pst on ps.StepTypeID = pst.[ID]                    

where (FCTypeID = @FCTypeID or (FCTypeID is null))
and (CompanyID = @CompanyID or (CompanyID is null))
order by ps.StepTypeID




GO
