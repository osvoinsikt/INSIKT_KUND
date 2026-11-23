SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [insikt].[FCProject_Versions_CalcProcess] as
with CalcProcess as
(
    select
        [FCProjectID] = fcp.FCProjectID
        ,[FCVersionID] = fcp.FCVersionID
        ,[FCVersionTypeID] = fcv.Type
        ,[FCVersionCategoryID] = fcv.FCVersionCategoryID
        ,[ProcessIsWriteEnabled] = isnull(fcst.ProcessIsWriteEnabled, 0)
        ,[CreatedDate] = fcp.CreatedDate
        ,[ModifiedDate] = fcp.ModifiedDate
        -- Senaste versionen har ALLTID 1 för FCVersionOrder och FCVersionCategoryOrder
        -- För att ta ut prev eller prevprev kan man då alltid använda + 1 eller + 2 på dessa fält
        ,[FCVersionOrder] = row_number() over (partition by fcp.FCProjectID order by fcp.CreatedDate desc)
        ,[FCVersionCategoryOrder] = row_number() over (partition by fcp.FCProjectID, fcv.FCVersionCategoryID order by fcp.CreatedDate desc)
    from INSIKT_KUND_SYS.dbo.FCProjectCalcProcess fcp
        inner join INSIKT_KUND_SYS.dbo.FCVersion fcv on
            fcv.ID = fcp.FCVersionID
        left join INSIKT_KUND_SYS.dbo.fcprojectcalcstep fcs on 
            fcp.currentstepid = fcs.id
        left join INSIKT_KUND_SYS.dbo.FCProjectCalcStepType fcst on 
            fcs.FCProjectCalcStepTypeID = fcst.id
)
select
    [FCProjectID] = f.FCProjectID
    ,[FCVersionID] = f.FCVersionID
    ,[PrevFCVersionID] = prev.FCVersionID
    ,[FCVersionTypeID] = f.FCVersionTypeID
    ,[FCVersionCategoryID] = f.FCVersionCategoryID
    ,[ProcessIsWriteEnabled] = f.ProcessIsWriteEnabled
    ,[CreatedDate] = f.CreatedDate
    ,[ModifiedDate] = f.ModifiedDate
    ,[FCVersionOrder] = f.FCVersionOrder
    ,[FCVersionCategoryOrder] = f.FCVersionCategoryOrder
from CalcProcess f
    left join CalcProcess prev on
        f.FCProjectID = prev.FCProjectID
        and f.FCVersionOrder + 1 = prev.FCVersionOrder

GO
