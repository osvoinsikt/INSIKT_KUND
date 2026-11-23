SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************
 #Desc: 		Selectes prenumerations with a specific ID
 #Used By:		-
 #InParam:		-
 #ResultSet:		-
 #
 #Returns:		-
 #Owner:		DBO
 #Creator:		Daniel Hellström
 #CreateDate:		060226
 #Modified by:		-
 #ModifiedDate:		-
 
 #Log:

********************************************************************/
CREATE               Procedure [dbo].[selReportsForSubscription]
			@iSubscriptionID int
	  	
	  
AS


set nocount on

select 	*

from Report r
inner join SubscriptionReportRelation srr on srr.ReportID = r.[ID]

where srr.SubscriptionID = @iSubscriptionID
GO
