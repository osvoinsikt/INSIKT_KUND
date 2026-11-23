SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[getProjectOverviewForMyPages]
	@UserId int = null
AS
BEGIN

	--create table #projectIds (ProjectID int)
	--insert into #projectIds values (3242) -- kaka
	--insert into #projectIds values (3328) -- wabba


	create table #timers (ID int, Caption nvarchar(255),  [Start] datetime, [Stop] datetime)

	-- ############# Before project process
	insert into #timers (ID, Caption, [Start])
	select 1, 'Project processs', GETUTCDATE()

	-- Project process
	select
		rel.FCProjectID,
		i.ID,
		aRev.Name,
		i.IsFinished,
		a.ID as MainActivityID,
		a.EndDate
	-- select *
	from process.ProcessInstancePhase i
		join FCProjectProcessInstanceRelation rel
			on rel.ProcessInstanceID = i.ProcessInstanceID and rel.IsActive = 1
		join #projectIds p
			on p.ProjectID = rel.FCProjectID
		join process.ProcessTemplatePhaseRevision pRev
			on pRev.ID = i.ProcessTemplatePhaseRevisionID and pRev.IsDeleted = 0
		join process.ProcessTemplateActivityRevision aRev
			on aRev.ID = pRev.MainDecisionPointActivityID
		join process.ProcessInstanceActivity a
			on a.ProcessInstancePhaseID = i.ID and a.ProcessTemplateActivityRevisionID = aRev.ID
	order by rel.FCProjectID, i.[Order]

	-- ############# After project process
	update #timers set [Stop] = GETUTCDATE() where ID = 1

	-- ############# Before Process activities
	insert into #timers (ID, Caption, [Start])
	select 2, 'Process activities', GETUTCDATE()

	create table #currentPhaseForEachProject (ProjectID int, PhaseID int)

	;with projectsOrderPhases as (
		select p.ProjectID, pip.ID, ROW_NUMBER() over (partition by p.ProjectID order by pip.[Order]) as rowNr
		from #projectIds p
			join FCProjectProcessInstanceRelation rel
				on rel.FCProjectID = p.ProjectID and rel.IsActive = 1
			join process.ProcessInstancePhase pip
				on pip.ProcessInstanceID = rel.ProcessInstanceID
			join process.ProcessTemplatePhaseRevision pRev
				on pRev.ID = pip.ProcessTemplatePhaseRevisionID and pRev.IsDeleted = 0
			where pip.IsFinished = 0
	)
	insert into #currentPhaseForEachProject (ProjectID, PhaseID)
	select ProjectID, ID from projectsOrderPhases
	where rowNr = 1

	-- Process activities
	create table #activitiesForAllProjects (FCProjectID int, ActivityID int, ActivityName nvarchar(255), EndDate datetime, IsPhase bit)
	insert into #activitiesForAllProjects (FCProjectID, ActivityID, ActivityName, EndDate, IsPhase)
	select
		rel.ProjectID as FCProjectID,
		a.ID,
		ISNULL(rev.Name, a.Name) as Name,
		a.EndDate,
		(case when rev.ProcessTemplateActivityTypeID = 4 then 1 else 0 end) as IsPhase
	-- select *
	from process.ProcessInstanceActivity a
		left join process.ProcessTemplateActivityRevision rev
			on rev.ID = a.ProcessTemplateActivityRevisionID
		join #currentPhaseForEachProject rel
			on rel.PhaseID = a.ProcessInstancePhaseID
	where
		a.IsFinished = 0 and
		a.IsHidden = 0 and
		(rev.ID is null or rev.IsDeleted = 0) and (
		@UserId is null or
		exists (
			select 1
			from process.ProcessInstanceActivityResponsibleRelation usersFilter
			where usersFilter.UserID = @UserId and usersFilter.ProcessInstanceActivityID = a.ID) or
		exists (
			select 1
			from process.ProcessInstanceActivityResponsibleRelation usersFilter
				join #projectToRoleToUser temp on
					temp.ProjectID = rel.ProjectID and
					temp.RoleID = usersFilter.RoleID
			where
				temp.UserID = @UserId and
				usersFilter.ProcessInstanceActivityID = a.ID))

	select
		p.FCProjectID,
		p.ActivityID as ID,
		p.ActivityName as Name,
		p.EndDate,
		p.IsPhase,
		case when users.ProcessInstanceActivityStepID is null then users.UserID else null end as ResponsibleID,
		case when users.ProcessInstanceActivityStepID is not null then users.UserID else null end as ApproverID
	from #activitiesForAllProjects p
		left join process.ProcessInstanceActivityResponsibleRelation users
		on users.ProcessInstanceActivityID = p.ActivityID
	union
	select
		p.FCProjectID,
		p.ActivityID as ID,
		p.ActivityName as Name,
		p.EndDate,
		p.IsPhase,
		case when users.ProcessInstanceActivityStepID is null then temp.UserID else null end as ResponsibleID,
		case when users.ProcessInstanceActivityStepID is not null then temp.UserID else null end as ApproverID
	from #activitiesForAllProjects p
		join process.ProcessInstanceActivityResponsibleRelation users on
			users.ProcessInstanceActivityID = p.ActivityID
		join #projectToRoleToUser temp on
			temp.ProjectID = p.FCProjectID and
			temp.RoleID = users.RoleID

	-- ############# After Process activities
	update #timers set [Stop] = GETUTCDATE() where ID = 2

	-- ############# Before Project CALC
	insert into #timers (ID, Caption, [Start])
	select 3, 'Project CALC', GETUTCDATE()

	-- Project CALC
	select
		rel.ProjectID  as FCProjectID,
		p.ID,
		v.Name,
		users.UserID
	-- select *
	from FCProjectCalcProcess p
		join FCVersion v
			on v.ID = p.FCVersionID
		join FCProjectCalcStepUserRelation users
			on users.FCProjectCalcStepID = p.CurrentStepID
		join #projectIds rel
			on rel.ProjectID = p.FCProjectID
	where
		@UserId is null or
		exists (
			select 1 from FCProjectCalcStepUserRelation rel
				where rel.FCProjectCalcStepID = p.CurrentStepID and rel.UserID = @UserId
		)


	-- ############# After Project CALC
	update #timers set [Stop] = GETUTCDATE() where ID = 3

	-- timers
	select
		ID,
		Caption,
		[Start] as StartDate,
		[Stop] as StopDate
	 from #timers

	drop table #timers
	drop table #projectIds
	drop table #currentPhaseForEachProject
	drop table #projectToRoleToUser
	drop table #activitiesForAllProjects
END

GO
