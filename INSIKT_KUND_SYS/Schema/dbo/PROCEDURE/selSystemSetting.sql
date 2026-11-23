SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************
 #Desc: 		Selects a System Setting
 #Used By:		-
 #InParam:		-
 #ResultSet:		-
 #
 #Returns:		-
 #Owner:		DBO
 #Creator:		Daniel Hellström
 #CreateDate:		061213
 #Modified by:		Daniel Hellström
 #ModifiedDate:		080703
 
 #Log:
	080703	DAHE	Bytt namn till SystemPropertyID

********************************************************************/
CREATE        Procedure [dbo].[selSystemSetting]
		@sPropertyName varchar(50)
AS

set nocount on

SELECT * 
FROM SystemSetting ss
INNER JOIN SystemProperty sp ON ss.SystemPropertyID = sp.ID
WHERE sp.[Name] = @sPropertyName

GO
