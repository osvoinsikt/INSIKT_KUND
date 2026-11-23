SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [dw].[dim_INSIKTPlaneringsProjekt] as
select
	[FCProjectID] = p.ID
	,[Name] = p.Name
	,[Code] = p.Code
from INSIKT_KUND_SYS.dbo.FCProject p
where
	p.FCTypeID = 2


------- Arbetsfiler\INSIKT-Projekt-Grund-0.3.0\INSIKT Projekt Grund\INSIKT_DW\dw\VIEW\dim_INSIKTPlaneringsProjekt.sql -----END


GO
