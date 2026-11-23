SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:              THRO
-- Create date: 2016-06-30
-- Description: Collects all process activities with a startDate = today
-- =============================================
CREATE PROCEDURE [process].[selAllActivitiesStartingToday]
AS
BEGIN

	select
		fcp.ProjectID, fcp.ProjectName,  isnull(t.Name, a.Name) as ActivityName, a.ID as ActivityID, a.StartDate, usg.EmailAdress as EmailAddress, usg.LangID, fcp.Code, fcp.FCTypeID
	from
		[process].[ProcessInstanceActivity] as a
		inner join [process].ProcessInstanceActivityResponsibleRelation r
			on r.ProcessInstanceActivityID = a.ID
		left join [process].ProcessInstanceActivityStep s
			on r.ProcessInstanceActivityID = s.ProcessInstanceActivityID and r.ProcessInstanceActivityStepID = s.ID
		left join [process].ProcessTemplateActivityRevision t
			on t.ID = a.ProcessTemplateActivityRevisionID
		inner join (
			select
				fcp.ID as ProjectID, fcp.Name as ProjectName, p.ID as PhaseID, fcp.isDeleted, fcp.Code, fcp.FCTypeID
			from
				[process].ProcessInstancePhase p
				inner join [process].ProcessInstance i on i.ID = p.ProcessInstanceID
				inner join FCProjectProcessInstanceRelation fcr on fcr.ProcessInstanceID = i.ID
				inner join FCProject fcp on fcp.ID = fcr.FCProjectID
		) fcp
			on fcp.PhaseID = a.ProcessInstancePhaseID
		left outer join (
			select
				usg.UserID, r.ProcessInstanceActivityID, fppv.ProjectID
			from
				[process].ProcessInstanceActivityResponsibleRelation r
				inner join FCRole fr on fr.ID = r.RoleID
				inner join FCProjectPropertyFCRoleRelation fprr on fprr.FCRoleID = fr.ID
				inner join FCProjectPropertyValue fppv on fppv.ProjectPropertyID = fprr.FCProjectPropertyID
				inner join FCProjectProperty fpp on fpp.ID = fppv.ProjectPropertyID
				inner join UserSecurityGroup usg on
					 ((fpp.Datatype = 'string' and fppv.ValueString = usg.UserName)
						or (fpp.Datatype = 'numeric' and fppv.ValueNumeric = usg.UserID))
		) ufr
			on r.RoleID IS NOT NULL and ufr.ProcessInstanceActivityID = a.ID and ufr.ProjectID = fcp.ProjectID
		inner join UserSecurityGroup usg on usg.UserID = coalesce(ufr.UserID, r.UserID)
	where
		a.StartDate IS NOT NULL
		and datediff(day, GETDATE(), cast(a.StartDate as DateTime)) = 0
		and not usg.EmailAdress = ''
		and coalesce(a.IsFinished, 0) = 0
		and coalesce(a.IsHidden, 0) = 0
		and coalesce(fcp.isDeleted, 0) = 0
		and coalesce(s.FinishedBy, 0) = 0
		and coalesce(s.IsHidden, 0) = 0
	group by
		fcp.ProjectID, fcp.ProjectName, isnull(t.Name, a.Name), a.ID, a.StartDate, usg.EmailAdress, usg.LangID, fcp.Code, fcp.FCTypeID

END

GO
