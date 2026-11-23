SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--
-- Vy på relation mellan Projektegenskaper och ProjektEvent
-- Konfiguration kan ske direkt i denna vy, och då ändrar man endast på FCProjectEventID och FCProjectPropertyID
-- 
--
create view [insikt].[FCProjectEventCurrentConfiguration] as
select
	[FCProjectEventID] = rel.FCProjectEventID
	,[FCProjectPropertyID] = rel.FCProjectPropertyID
	,[EventName] = e.Name
	,[FCProjectPropertyName] = isnull(property.Name, 'Felaktig konfiguration - Projektegenskap finns ej')
	,[FCProjectPropertyDisplayName] = coalesce(property.DisplayName, property.Name,'Felaktig konfiguration - Projektegenskap finns ej')
	,[FCTypeID] = 2
	--select *
from insikt.FCProjectPropertyEventRelation rel
	inner join insikt.FCProjectEvent e on
		e.FCProjectEventID = rel.FCProjectEventID
	left join INSIKT_KUND_SYS.dbo.FCProjectProperty property on
		property.ID = rel.FCProjectPropertyID

GO
