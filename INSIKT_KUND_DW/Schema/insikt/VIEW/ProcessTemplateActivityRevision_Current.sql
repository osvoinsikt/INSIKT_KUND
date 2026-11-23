SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view insikt.ProcessTemplateActivityRevision_Current as 
with ProcessInstanceWithCurrentPhaseOrder as
(
select
    f.FCProjectID
    ,f.ProcessInstanceID
    ,ProcessTemplatePhaseRevisionID = pi.ProcessTemplatePhaseRevisionID
    ,PhaseOrder = pi.[Order]
    ,CurrentPhaseOrder = min(pi.[Order]) over (partition by f.FCProjectID)
from INSIKT_KUND_SYS.dbo.FCProjectProcessInstanceRelation f
        inner join INSIKT_KUND_SYS.process.ProcessInstancePhase pi on
            pi.ProcessInstanceID = f.ProcessInstanceID
                        
where
    pi.IsFinished = 0
    and f.IsActive = 1
),
FCProjectInActivePhase as
(
    select
        FCProjectID = f.FCProjectID
        ,ProcessTemplateActivityRevisionID = activityRevision.ID
        ,Name = activityRevision.Name
    from ProcessInstanceWithCurrentPhaseOrder f
        inner join INSIKT_KUND_SYS.process.ProcessTemplateActivityRevision activityRevision on
            activityRevision.ProcessTemplatePhaseRevisionID  = f.ProcessTemplatePhaseRevisionID
    where
        f.CurrentPhaseOrder = f.PhaseOrder
        and activityRevision.ProcessTemplateActivityTypeID = 4 -- TypeID 4 = Fas

),
FinishedPhase as
(
    select 
        ProcessTemplateActivityRevisionID = f.ProcessTemplateActivityRevisionID
        ,ProcessTemplateActivityID = f.ProcessTemplateActivityID
        ,Name = f.Name
        ,DisplayName = f.DisplayName
        ,ProcessTemplateActivityTypeID = f.ProcessTemplateActivityTypeID
        ,ProcessTemplatePhaseRevisionID = f.ProcessTemplatePhaseRevisionID
    from insikt.ProcessTemplateActivityRevision f
    where
        f.ProcessTemplateActivityID is null
        and f.Name = 'Finished'
),
InactivePhase as
(
    select 
        ProcessTemplateActivityRevisionID = f.ProcessTemplateActivityRevisionID
        ,ProcessTemplateActivityID = f.ProcessTemplateActivityID
        ,Name = f.Name
        ,DisplayName = f.DisplayName
        ,ProcessTemplateActivityTypeID = f.ProcessTemplateActivityTypeID
        ,ProcessTemplatePhaseRevisionID = f.ProcessTemplatePhaseRevisionID
    from insikt.ProcessTemplateActivityRevision f
    where
        f.ProcessTemplateActivityID is null
        and f.Name = 'Inactive'
    
)
-- Om projektet saknas process (ProcessInstance) så sätts fasen till DisplayName för 'Inactive'
-- Om projektets samtliga faser är avslutade så sätts fasen till DisplayName för 'Finished'
select
    FCProjectID = p.ID
    ,ProcessTemplateActivityRevisionID = iif(
        processInstance.ProcessInstanceID is null,
        inactivePhase.ProcessTemplateActivityRevisionID,  
        isnull(activePhase.ProcessTemplateActivityRevisionID, finishedPhase.ProcessTemplateActivityRevisionID)
    )
    ,ActivePhaseName = iif(
        processInstance.ProcessInstanceID is null,
        inactivePhase.Name,  
        isnull(activePhase.Name, finishedPhase.Name)
    )
    ,FCTypeID = 2
from INSIKT_KUND_SYS.dbo.FCProject p
    left join INSIKT_KUND_SYS.dbo.FCProjectProcessInstanceRelation processInstance on 
        processInstance.FCProjectID = p.ID
    left join FCProjectInActivePhase activePhase on
        activePhase.FCProjectID = p.ID
    cross join InactivePhase inactivePhase
    cross join FinishedPhase finishedPhase
------- Arbetsfiler\INSIKT-Projekt-Grund-0.3.0\INSIKT Projekt Grund\INSIKT_DW\insikt\VIEW\ProcessTemplateActivityRevision_Current.sql -----END


GO
