SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************
 #Desc: 			Selects a datasource by server, cube and database
 #Used By:			-
 #InParam:			-
 #ResultSet:		
 #
 #Returns:			
 #Owner:			DBO
 #Creator:			Johan Kultti
 #CreateDate:		070628
 #Modified by:		-
 #ModifiedDate:		-
 
 #Log:

********************************************************************/
CREATE          Procedure [dbo].[selDatasourceForServerAndDatabaseAndCube]
				@vsServer varchar(50)
				,@vsDatabase varchar(50)
				,@vsCube nvarchar(50)
AS

-- User Information
select ds.*, c.[Database] as SourceDatabase, c.[Server] as SourceServer
from [DataSources] ds
inner join [DataSourceConnection] c
		on (ds.DataSourceConnectionID = c.ID)

where	c.[Server] = @vsServer
AND	c.[Database] = @vsDatabase
AND	SourceCube = @vsCube

GO
