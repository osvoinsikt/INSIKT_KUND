SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:              THRO
-- Create date:  2016-07-01
-- Description: Collects all process activities with EndDate < @DueDateInDays
-- =============================================
CREATE PROCEDURE [process].[selAllActivitiesEndingInDays]
	@DueDateInDays int
AS
BEGIN

	-- Create a temp table containing the step ids of all steps that are:
	-- Directly after a finished step,
	-- Or only have one step.
	create table #validSteps (StepId int, ProcessInstanceActivityID int)
	insert into #validSteps (StepId, ProcessInstanceActivityID)
	select
		distinct s2.ID, s2.ProcessInstanceActivityID
	from process.ProcessInstanceActivityStep s1
		join process.ProcessInstanceActivityStep s2
			on s1.ProcessInstanceActivityID = s2.ProcessInstanceActivityID
		join process.ProcessInstanceActivityResponsibleRelation rel
			on s1.ProcessInstanceActivityID = rel.ProcessInstanceActivityID
	where
		(s1.FinishedBy is not null and (s2.[Order] - s1.[Order] = 1)) or
		(s1.FinishedBy is null and s1.[Order] = 1)


	select
		fcp.ProjectID, fcp.ProjectName, isnull(t.Name, a.Name) as ActivityName, a.ID as ActivityID, a.EndDate, usg.EmailAdress as EmailAddress, usg.LangID, fcp.Code, fcp.FCTypeID
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
				fcp.ID as ProjectID, fcp.Name as ProjectName, p.ID as PhaseID, fcp.isDeleted, fcp.Code, fcp.isLocked, fcp.FCTypeID
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
				inner join #validSteps valid on r.ProcessInstanceActivityStepID is null or valid.StepId = r.ProcessInstanceActivityStepID
		) ufr
			on r.RoleID IS NOT NULL and ufr.ProcessInstanceActivityID = a.ID and ufr.ProjectID = fcp.ProjectID
		inner join UserSecurityGroup usg on usg.UserID = coalesce(ufr.UserID, r.UserID)
		inner join #validSteps valid on a.ID = valid.ProcessInstanceActivityID and (r.ProcessInstanceActivityStepID is null or valid.StepId = r.ProcessInstanceActivityStepID)
	where
		a.EndDate IS NOT NULL
		and datediff(day, GETDATE(), cast(a.EndDate as DateTime)) <= @DueDateInDays
		--and datediff(day, GETDATE(), cast(a.EndDate as DateTime)) >= 0
		and not usg.EmailAdress = ''
		and coalesce(a.IsFinished, 0) = 0
		and coalesce(a.IsHidden, 0) = 0
		and coalesce(fcp.isDeleted, 0) = 0
		and coalesce(fcp.isLocked, 0) = 0
		and coalesce(s.FinishedBy, 0) = 0
		and coalesce(s.IsHidden, 0) = 0
	group by
		fcp.ProjectID, fcp.ProjectName, isnull(t.Name, a.Name), a.ID, a.EndDate, usg.EmailAdress, usg.LangID, fcp.Code, fcp.FCTypeID
	order by
		a.EndDate

	drop table #validSteps
END

GO
