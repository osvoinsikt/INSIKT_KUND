SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [insikt].[FCProject_Versions] as
with Versions as (
select 
	[FCProjectID] = f.FCProjectID
	,[FCVersionID] = f.FCVersionID
	,[VersionSelector] = ROW_NUMBER() over (partition by f.fcprojectid order by f.Createddate desc)
	,[FCProjectCalcStepTypeID] = stype.ID
	,[StatusName] = isnull(stype.StatusName,'Klar')
	,[FCProjectCalcProcessID] = f.ID
    ,[ProcessIsWriteEnabled] = isnull(stype.ProcessIsWriteEnabled, 0)
	,[CalcStepUserID] = min(stepUser.UserID)
	,[CalcStepUserID_CSV] = string_agg(stepUser.UserID, ',')
from INSIKT_KUND_SYS.dbo.FCProjectCalcProcess f
	left join INSIKT_KUND_SYS.dbo.FCProjectCalcStep s on
		f.CurrentStepID = s.ID
	left join INSIKT_KUND_SYS.dbo.FCProjectCalcStepType stype on
		s.FCProjectCalcStepTypeID = stype.ID
	left join INSIKT_KUND_SYS.dbo.FCProjectCalcStepUserRelation stepUser on
		s.ID = stepUser.FCProjectCalcStepID
group by
	f.FCProjectID
	,f.FCVersionID
	,stype.ID
	,stype.StatusName
    ,stype.ProcessIsWriteEnabled
	,f.Createddate
	,f.ID
),
VersionSelector as(
select 
	[FCProjectID] = v.FCProjectID
	,[FCVersionID] = v.FCVersionID
	,[FCProjectCalcStepTypeID] = v.FCProjectCalcStepTypeID
	,[FCProjectCalcProcessID] = v.FCProjectCalcProcessID
    ,[ProcessIsWriteEnabled] = v.ProcessIsWriteEnabled
	,[StatusName] = v.StatusName
	,[CalcStepUserID] = v.CalcStepUserID
	,[CalcStepUserID_CSV] = v.CalcStepUserID_CSV
from Versions v
where
	v.VersionSelector = 1
),
PreviousVersionSelector as(
select 
	[FCProjectID] = v.FCProjectID
	,[FCVersionID] = v.FCVersionID
	,[StatusName] = v.StatusName
from Versions v
where
	v.VersionSelector = 2
),
PrevPreviousVersionSelector as(
select 
	[FCProjectID] = v.FCProjectID
	,[FCVersionID] = v.FCVersionID
	,[StatusName] = v.StatusName
from Versions v
where
	v.VersionSelector = 3
),
FirstLastVersionSelector as (
select 
	[FCProjectID] = v.FCProjectID
	,[MaxSelector] = max(v.VersionSelector)
	,[MinSelector] = min(v.VersionSelector)
from Versions v
group by
	v.FCProjectID
),
FirstVersionSelector as (
select 
	[FCProjectID] = v.FCProjectID
	,[FCVersionID] = v.FCVersionID
	,[StatusName] = v.StatusName
from Versions v
	inner join FirstLastVersionSelector f on
		v.FCProjectID = f.FCProjectID
		and v.VersionSelector = f.MaxSelector
)
select
	[FCProjectID] = p.ID
	,[FCTypeID] = 2
	,[FCVersionID] = v.FCVersionID
	,[PrevFCVersionID] = prevV.FCVersionID
	,[PrevPrevFCVersionID] = prevprevV.FCVersionID
	,[FirstVersionID] = firstV.FCVersionID
	,[FCProjectCalcStepTypeID] = v.FCProjectCalcStepTypeID
	,[StatusName] = v.StatusName
	,[FCProjectCalcProcessID] = v.FCProjectCalcProcessID
    ,[ProcessIsWriteEnabled] = v.ProcessIsWriteEnabled
	,[CalcStepUserID] =  v.CalcStepUserID
	,[CalcStepUserID_Csv] = v.CalcStepUserID_Csv
	,[IsDeleted] = isnull(p.isDeleted, 0)
from INSIKT_KUND_SYS.dbo.FCProject p
	inner join VersionSelector v on
		p.ID = v.FCProjectID
	left join PreviousVersionSelector prevV on
		p.ID = prevV.FCProjectID
	left join PrevPreviousVersionSelector prevprevV on
		p.ID = prevprevV.FCProjectID
	left join FirstVersionSelector firstV on
		p.ID = firstV.FCProjectID


GO
