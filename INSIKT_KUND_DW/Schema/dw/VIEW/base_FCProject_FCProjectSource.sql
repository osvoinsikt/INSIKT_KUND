SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--
-- Använd proceduren [app].[Support_Generate_FCProjectSource_PropertyValues] för att uppdatera [dw].[base_FCProject_FCProjectSource_PropertyValues]
--
-- @INSIKT_SYS = 'INSIKT_SYS' -- Ersätt med korrekt SYS-databas
-- Observera att proceduren skapar ett script för create/alter som måste köras manuellt
--
CREATE view [dw].[base_FCProject_FCProjectSource] as
select
    [FCProjectID] = p.ID
    ,[Code] = p.Code
    ,[Name] = p.Name
    ,[DisplayName] = isnull(concat_ws(' ', p.Code, p.Name),'')
	,[ProjektID] = projekt.ProjektID
    ,[StartDateID] = try_cast(left(replace(ppv.Startdatum_3, '-', ''), 8) as int)
    ,[EndDateID] = try_cast(left(replace(ppv.Slutdatum_4, '-', ''), 8) as int)
    ,[StartMonthID] = app.MonthID(try_cast(left(replace(ppv.Startdatum_3, '-', ''), 8) as int))
    ,[EndMonthID] = app.MonthID(try_cast(left(replace(ppv.Slutdatum_4, '-', ''), 8) as int))
    ,[isDeleted] = isnull(p.isDeleted,0)
	,[Projektledare] = isnull(userProjektledare.FullName, '')
	,[Projektstatus] = isnull(predefinedProjektstatus.VisibleName,'')
    ,[Projekttyp] = isnull(predefinedProjekttyp.VisibleName, '')
    ,[Projektfas] = isnull(predefinedFas.VisibleName, '')
--select *
from INSIKT_KUND_SYS.dbo.FCProject p
    left join dw.base_FCProject_FCProjectSource_PropertyValues ppv on
        ppv.FCProjectID = p.ID
    left join INSIKT_KUND_SYS.dbo.FCProjectPropertyPredefinedValue predefinedFas on
        predefinedFas.FCProjectPropertyID = 9
        and predefinedFas.ID = ppv.Projektfas_9
    left join dw.base_Projekt projekt on
        projekt.ProjektID = ppv.SA_Projekt_8
    left join INSIKT_KUND_SYS.dbo.UserSecurityGroup userProjektledare on
        userProjektledare.UserID = ppv.Projektledare_7
    left join INSIKT_KUND_SYS.dbo.FCProjectPropertyPredefinedValue predefinedProjekttyp on
        predefinedProjekttyp.FCProjectPropertyID = 6
        and predefinedProjekttyp.ID = ppv.Projekttyp_6
    left join INSIKT_KUND_SYS.dbo.FCProjectPropertyPredefinedValue predefinedProjektstatus on
        predefinedProjektstatus.FCProjectPropertyID = 5
        and predefinedProjektstatus.ID = ppv.Projektstatus_5
where
    p.FCTypeID = 2


GO
