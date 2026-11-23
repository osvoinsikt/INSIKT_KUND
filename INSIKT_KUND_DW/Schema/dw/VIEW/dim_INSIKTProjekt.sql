SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--
-- Används för att skapa dimensionen INSIKT Projekt som används i projektanalys. 
--
CREATE view [dw].[dim_INSIKTProjekt] as
select
      [FCProjectID] = p.FCProjectID
      ,[Code] = p.Code
      ,[Name] = p.Name
      ,[DisplayName] = iif(p.IsDeleted = 1, '', p.DisplayName)
      ,[ProjektID] = p.ProjektID
      ,[Projektledare] = p.Projektledare
      ,[Projektstatus] = p.Projektstatus
      ,[Projekttyp] = p.Projekttyp
      ,[Projektfas] = p.Projektfas
from dw.base_FCProject p

GO
