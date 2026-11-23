SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [insikt].[ProcessTemplateActivityRevision] as 
select
    ProcessTemplateActivityRevisionID = ar.ID
    ,ProcessTemplateActivityID = ar.ProcessTemplateActivityID
    ,Name = ar.Name
    ,DisplayName = ar.Name
    ,ProcessTemplateActivityTypeID = ar.ProcessTemplateActivityTypeID
    ,ProcessTemplatePhaseRevisionID = ar.ProcessTemplatePhaseRevisionID
from INSIKT_KUND_SYS.process.ProcessTemplateActivityRevision ar
where
    ar.ProcessTemplateActivityTypeID = 4 -- TypeID 4 = Fas
union
select
    ProcessTemplateActivityRevisionID = -199 -- ProcessInstance saknas
    ,ProcessTemplateActivityID = null
    ,Name = 'Inactive'
    ,DisplayName = 'Ingen process startad'
    ,ProcessTemplateActivityTypeID = null
    ,ProcessTemplatePhaseRevisionID = null
union
select
    ProcessTemplateActivityRevisionID = -99 -- Avslutad fas när alla faser är klara
    ,ProcessTemplateActivityID = null
    ,Name = 'Finished'
    ,DisplayName = 'Avslutad'
    ,ProcessTemplateActivityTypeID = null
    ,ProcessTemplatePhaseRevisionID = null

GO
