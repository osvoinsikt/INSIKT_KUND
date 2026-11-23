SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--
-- Tar bort alla processer, projekt, etc. och tillhörande data.
--
CREATE PROCEDURE [dbo].[Support_ClearFCTypeContent]
	--
	-- Vilken budgettyp som ska rensas. Kan sättas till NULL för att rensa alla budgettyper
	-- kopplade till @FCVersionID.
	--
	@FCTypeID int,

	--
	-- Vilket bolag som ska rensas.
	--
	@CompanyID int,

	--
	-- Om en specifik version ska rensas. I så fall tas endast data kopplad till versionen bort.
	-- Själva projekten lämnas kvar (om det är en projektbudget), eftersom de inte är kopplade
	-- till versionen. Även annan data som inte är kopplad till versionen lämnas kvar.
	--
	@FCVersionID int = null
AS
BEGIN
	set nocount on;

	--
	-- Om en planeringsversion är satt men budgettyp inte är definierad så körs en clear på alla
	-- typer som är relaterade till versionen.
	--
	if @FCTypeID is null and @FCVersionID is not null
		begin
			select FCTypeID
			into #FCTypeIds
			from FCVersionFCTypeRelation
			where FCVersionID = @FCVersionID
			union
			select secondaryGroupRel.FCTypeID
			from FCTypeGroupRelation secondaryGroupRel
				join FCTypeGroupRelation primaryGroupRel
					on primaryGroupRel.IsPrimary = 1
						and primaryGroupRel.GroupID = secondaryGroupRel.GroupID
						and primaryGroupRel.FCTypeID != secondaryGroupRel.FCTypeID
				join FCVersionFCTypeRelation primaryVersionRel
					on primaryVersionRel.FCTypeID = primaryGroupRel.FCTypeID
			where primaryVersionRel.FCVersionID = @FCVersionID

			-- Om det inte finns nån version/budgettyp-koppling är versionen tillgänglig i alla budgettyper.
			if not exists(select * from #FCTypeIds)
				begin
					insert into #FCTypeIds select ID from FCType
				end

			select @FCTypeID = min(FCTypeID) from #FCTypeIds
			while @FCTypeID is not null
				begin
					exec [dbo].[Support_ClearFCTypeContent]
						@FCTypeID = @FCTypeID,
						@CompanyID = @CompanyID,
						@FCVersionID = @FCVersionID

					select @FCTypeID = min(FCTypeID) from #FCTypeIds where FCTypeID > @FCTypeID
				end

			drop table #FCTypeIds
			return;
		end


	declare @VersionDimensionName nvarchar(50) = (
		select top 1 ValueString
		from FCElementProperty
		where PropertyID = 9
			and FCTypeID = @FCTypeID
			and CompanyID = @CompanyID
	)

	-- Ta bort periodiseringar
	select distinct dist.ID
	into #periodicDistributions
	from FCElementPeriodicDistribution dist
		left join FCElementPeriodicDistributionDimension dim_version
			on dim_version.PeriodicDistributionID = dist.ID
				and dim_version.DimensionName = @VersionDimensionName
				and dim_version.ElementKey = cast(@FCVersionID as nvarchar)
	where dist.FCTypeID = @FCTypeID and dist.CompanyID = @CompanyID
		and (@FCVersionID is null or dim_version.ID is not null)

	delete from FCElementPeriodicDistributionDimension
	where PeriodicDistributionID in (select ID from #periodicDistributions)

	delete from FCElementPeriodicDistribution
	where ID in (select ID from #periodicDistributions)

	drop table #periodicDistributions


	select
		c.*
	into
		#CommentsToDelete
	from
		CellComment c
			left join FCElementProperty epPlanningVersion on
				epPlanningVersion.PropertyID = 9
				and epPlanningVersion.CompanyID = c.CompanyID
				and epPlanningVersion.FCTypeID = c.FCTypeID
			left join CellCommentDimension cDimVer on
				cDimVer.CellCommentID = c.ID
				and cDimVer.DimensionName = epPlanningVersion.ValueString
	where
		c.FCTypeID = @FCTypeID
		and c.CompanyID = @CompanyID
		and
		(
			cDimVer.ElementKey = cast(@FCVersionID as varchar(12))
			or @FCVersionID is null
		)

	select bcd.DocumentID
	into #DocumentsToDelete
	from dbo.CellCommentDocument bcd
		inner join dbo.CellCommentEntry bce on bcd.CellCommentEntryID = bce.ID
		inner join #CommentsToDelete c on bce.CellCommentID = c.ID

	-- Ta bort kommentarsdokument
	delete r
	from #CommentsToDelete c
		inner join dbo.CellCommentEntry e on c.ID = e.CellCommentID
		inner join dbo.CellCommentDocument bcd on e.ID = bcd.CellCommentEntryID
		inner join dbo.Document d on bcd.DocumentID = d.ID
		inner join dbo.DocumentRevision r on d.ID = r.DocumentID

	delete bcd
	from #CommentsToDelete c
		inner join dbo.CellCommentEntry e on c.ID = e.CellCommentID
		inner join dbo.CellCommentDocument bcd on e.ID = bcd.CellCommentEntryID

	delete dl
	from dbo.DocumentLock dl
		inner join #DocumentsToDelete dd on dl.DocumentID = dd.DocumentID

	delete d
	from dbo.Document d
		inner join #DocumentsToDelete dd on d.ID = dd.DocumentID

	exec dbo.delDocumentDataNotReferenced

	-- Ta bort kommentarer
	delete from dbo.CellCommentEntry
	where CellCommentID in(select ID from #CommentsToDelete)

    -- Ta bort kommentarvärden
    delete from dbo.CellCommentValue
    where CellCommentID in (select ID from #CommentsToDelete)

	-- Ta bort kommentardetaljer
	delete from CellCommentDetail
	where CellCommentID in (select ID from #CommentsToDelete)

	-- Ta bort kommentardimensionskopplingar
	delete from dbo.CellCommentDimension
	where CellCommentID in (select ID from #CommentsToDelete)

	-- Ta bort kommentarcontainers
	delete from dbo.CellComment where ID in (select ID from #CommentsToDelete)

	drop table #CommentsToDelete
	drop table #DocumentsToDelete


	-- Ta bort processkommentarer.
	delete pc
	from dbo.FCProcessComment pc
		inner join dbo.FCProcess p on pc.ProcessID = p.ID
	where p.FCTypeID = @FCTypeID and p.CompanyID = @CompanyID
		and (p.FCVersion = @FCVersionID or @FCVersionID is null)

	-- Ta bort processmeddelanden.
	delete rel
	from dbo.UserReadMessageRelation rel
		inner join dbo.FCMessage m on rel.messageID = m.ID
		inner join dbo.FCProcess p on m.FCProcessID = p.ID
	where p.FCTypeID = @FCTypeID and p.CompanyID = @CompanyID
		and (p.FCVersion = @FCVersionID or @FCVersionID is null)

	delete m
	from dbo.FCMessage m
		inner join  dbo.FCProcess p on m.FCProcessID = p.ID
	where p.FCTypeID = @FCTypeID and p.CompanyID = @CompanyID
		and (p.FCVersion = @FCVersionID or @FCVersionID is null)


	-- Ta bort dynamiska kolumner kopplade till planeringsprocess
	delete pcr
	from dbo.FCProcessFCColumnRelation pcr
		inner join dbo.FCProcess p on p.ID = pcr.FCProcessID
	where p.FCTypeID = @FCTypeID and p.CompanyID = @CompanyID
		and (p.FCVersion = @FCVersionID or @FCVersionID is null)

	-- Ta bort dynamiska kolumner kopplade till kalkylprocess
	delete pcr
	from dbo.FCProcessFCColumnRelation pcr
		inner join dbo.FCProjectCalcProcess cp on cp.ID = pcr.FCProjectCalcProcessID
		inner join dbo.FCProject p on cp.FCProjectID = p.ID
	where p.FCTypeID = @FCTypeID and p.CompanyID = @CompanyID
		and (cp.FCVersionID = @FCVersionID or @FCVersionID is null)

	-- Ta bort projektstegs kopplingar till användare
	delete from dbo.FCProjectCalcStepUserRelation
	where FCProjectCalcStepID in (
		select s.ID
		from dbo.FCProjectCalcStep s
			inner join dbo.FCProjectCalcStepType st on s.FCProjectCalcStepTypeID = st.ID
			inner join dbo.FCProjectCalcProcess cp on s.FCProjectCalcProcessID = cp.ID
		where st.FCTypeID = @FCTypeID and st.CompanyID = @CompanyID
			and (cp.FCVersionID = @FCVersionID or @FCVersionID is null))

	-- Sätt nuvarande steg för varje kalkylprocess till null för att sedan kunna ta bort stegen
	update dbo.FCProjectCalcProcess
	set CurrentStepID = NULL
	where (FCVersionID = @FCVersionID or @FCVersionID is null)
		and FCProjectID in (
			select ID
			from dbo.FCProject
			where FCTypeID = @FCTypeID and CompanyID = @CompanyID)

	-- Ta bort kalkylprocesstegen
	delete s
	from dbo.FCProjectCalcStep s
		inner join dbo.FCProjectCalcProcess cp on s.FCProjectCalcProcessID = cp.ID
	where (cp.FCVersionID = @FCVersionID or @FCVersionID is null)
		and s.FCProjectCalcStepTypeID in (
			select ID
			from dbo.FCProjectCalcStepType
			where FCTypeID = @FCTypeID and CompanyID = @CompanyID)

	-- Ta bort user-read-kopplingar till projektkommentarer
	delete urr
	from dbo.FCProjectCommentUserReadRelation urr
		inner join dbo.FCProjectComment c on urr.FCProjectCommentID = c.ID
		inner join dbo.FCProject p on c.FCProjectID = p.ID
		left join dbo.FCProjectCalcProcess cp on c.FCProjectCalcProcessID = cp.ID
	where p.FCTypeID = @FCTypeID and p.CompanyID = @CompanyID and
		(@FCVersionID is null or cp.FCVersionID = @FCVersionID)

	-- Ta bort projektkommentarer
	delete c
	from dbo.FCProjectComment c
		inner join dbo.FCProject p on c.FCProjectID = p.ID
		left join dbo.FCProjectCalcProcess cp on c.FCProjectCalcProcessID = cp.ID
	where p.FCTypeID = @FCTypeID and p.CompanyID = @CompanyID and
		(@FCVersionID is null or cp.FCVersionID = @FCVersionID)

	-- Ta bort processer
	delete from dbo.FCProcess
	where FCTypeID = @FCTypeID and CompanyID = @CompanyID
		and (FCVersion = @FCVersionID or @FCVersionID is null)


	-- Ta bort kalkylprocesser
	delete from dbo.FCProjectCalcProcess
	where (FCVersionID = @FCVersionID or @FCVersionID is null)
		and FCProjectID in (
			select ID
			from dbo.FCProject
			where FCTypeID = @FCTypeID and CompanyID = @CompanyID)


	-- Om ingen specifik version är given ska data som inte är kopplad till version tas bort.
	if @FCVersionID is null
		begin

			-- Ta bort indikator state
			delete from dbo.FCProjectIndicatorStateRelation
			where FCProjectID in (
					select ID
					from dbo.FCProject
					where FCTypeID = @FCTypeID and CompanyID = @CompanyID)

			-- Ta bort process instance state
			declare @execSql nvarchar(max)
			set @execSql = ''

			select @execSql = @execSql + ' exec process.Support_delete_instance ' + LTRIM(STR(ProcessInstanceID)) + ';' from dbo.FCProjectProcessInstanceRelation
				where FCProjectID in (
					select ID
					from dbo.FCProject
					where FCTypeID = @FCTypeID and CompanyID = @CompanyID)

			exec sp_executesql @execSql;

			-- Ta bort dokument kopplade till projekt
			delete from dbo.FCProjectDocument
			where FCProjectID in (
				select ID
				from dbo.FCProject
				where FCTypeID = @FCTypeID and CompanyID = @CompanyID)

			-- Ta bort projektegenskapsvärden
			delete from dbo.FCProjectPropertyValue
			where ProjectID in (
				select ID
				from dbo.FCProject
				where FCTypeID = @FCTypeID and CompanyID = @CompanyID)

			-- Ta bort projekten
			delete from dbo.FCProject
			where FCTypeID = @FCTypeID and CompanyID = @CompanyID

			-- Sänk räknaren för projekt-ID så långt det går.
			declare @nextFCProjectID int;
			select @nextFCProjectID = isnull(max(ID) + 1, 0) from dbo.FCProject;
			dbcc CHECKIDENT('FCProject', RESEED, @nextFCProjectID);

		end


	-- Töm loggen
	delete from dbo.FCActionLog
	where FCTypeID = @FCTypeID and CompanyID = @CompanyID
		and (VersionID = @FCVersionID or @FCVersionID is null)
END
GO
