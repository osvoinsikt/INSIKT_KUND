SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Tar bort ett projekt och dess tillhörande data, inklusive delprojekt, ELLER
-- all data för ett projekt gällande en viss version.
CREATE PROCEDURE [dbo].[Support_DeleteProject]
	@fcProjectID int,
	@fcVersionID int = NULL
AS
	BEGIN
		set nocount on;

		-- Ta först rekursivt bort delprojekt
		if @fcVersionID is null
			begin
				declare @childProjectID int;
				declare @childProjectCursor cursor;
				set @childProjectCursor = cursor for select ID from dbo.FCProject where ParentProjectID = @fcProjectID;
				open @childProjectCursor;

				fetch next from @childProjectCursor into @childProjectID;
				while @@FETCH_STATUS = 0
					begin
						exec dbo.Support_DeleteProject @childProjectID
						fetch next from @childProjectCursor into @childProjectID;
					end
			end

		-- Hjälpvariabler med info om projektet och versionen
		declare @fcProjectKey varchar(max);
		declare @fcVersionKey varchar(max);
		declare @fcTypeID int;
		declare @companyID int;
		declare @fcProjectDimension varchar(max);
		declare @fcVersionDimension varchar(max);
		declare @processInstanceID int;

		set @fcProjectKey = cast(@fcProjectID as varchar(max));
		set @fcVersionKey = cast(@fcVersionID as varchar(max));
		select @fcTypeID = FCTypeID, @companyID = CompanyID from dbo.FCProject where ID = @fcProjectID;
		select @fcProjectDimension = ValueString from FCCurrentConfiguration where FCTypeID = @fcTypeID and CompanyID = @companyID and Name = 'FCProcessDimension';
		select @fcVersionDimension = ValueString from FCCurrentConfiguration where FCTypeID = @fcTypeID and CompanyID = @companyID and Name = 'VersionDimension';
		select @processInstanceID = ProcessInstanceID from dbo.FCProjectProcessInstanceRelation where FCProjectID = @fcProjectID;

		-- Hämta id:n för projektets (och ev. versionens) budgetkommentarer
		declare @commentIDs table (ID int not null);
		insert into @commentIDs
		select ID from dbo.CellComment where FCTypeID = @fcTypeID and CompanyID = @companyID
		intersect
		select CellCommentID from dbo.CellCommentDimension
		where DimensionName = @fcProjectDimension and ElementKey = @fcProjectKey
		intersect
		select CellCommentID from dbo.CellCommentDimension
		where DimensionName = @fcVersionDimension and (@fcVersionKey is null or ElementKey = @fcVersionKey);


		-- Ta bort periodiseringar
		select distinct dist.ID
		into #periodicDistributions
		from FCElementPeriodicDistribution dist
			join FCElementPeriodicDistributionDimension dim_org
				on dim_org.PeriodicDistributionID = dist.ID
					and dim_org.DimensionName = @fcProjectDimension
					and dim_org.ElementKey = @fcProjectKey
			left join FCElementPeriodicDistributionDimension dim_version
				on dim_version.PeriodicDistributionID = dist.ID
					and dim_version.DimensionName = @fcVersionDimension
					and dim_version.ElementKey = @fcVersionKey
		where dist.FCTypeID = @FCTypeID and dist.CompanyID = @CompanyID
			and (@FCVersionID is null or dim_version.ID is not null)

		delete from FCElementPeriodicDistributionDimension
		where PeriodicDistributionID in (select ID from #periodicDistributions)

		delete from FCElementPeriodicDistribution
		where ID in (select ID from #periodicDistributions)

		drop table #periodicDistributions


		-- Ta bort kopplingar till cellkommentarsdokument
		create table #documentsToBeRemoved (ID int)

		insert into #documentsToBeRemoved
		select ccd.DocumentID
		from dbo.CellCommentEntry e
				 inner join dbo.CellCommentDocument ccd on e.ID = ccd.CellCommentEntryID
		where e.CellCommentID in (select ID from @commentIDs)

		delete ccd
		from dbo.CellCommentEntry e
				 inner join dbo.CellCommentDocument ccd on e.ID = ccd.CellCommentEntryID
		where e.CellCommentID in (select ID from @commentIDs);

		-- Ta bort cellkommentarsdokument
		declare documentCursor cursor fast_forward for
			select ID from #documentsToBeRemoved

		declare @documentId int
		open documentCursor
		fetch next from documentCursor into @documentId

		while @@FETCH_STATUS = 0 begin
			exec dbo.delDocument @documentId
			fetch next from documentCursor into @documentId
		end

		close documentCursor
		deallocate documentCursor

		drop table #documentsToBeRemoved

		-- Ta bort kommentarer
		delete from dbo.CellCommentEntry where CellCommentID in (select ID from @commentIDs);

        delete from dbo.CellCommentValue where CellCommentID in (select ID from @commentIDs);

		delete from dbo.CellCommentDetail where CellCommentID in (select ID from @commentIDs);

		delete from dbo.CellCommentDimension where CellCommentID in (select ID from @commentIDs);

		delete from dbo.CellComment where ID in (select ID from @commentIDs);

		delete pcr
		from dbo.FCProcessFCColumnRelation pcr
				 inner join dbo.FCProcess p on p.ID = pcr.FCProcessID
		where p.FCTypeID = @fcTypeID
			and p.CompanyID = @companyID
			and p.FCLevel01 = @fcProjectKey
			and (@fcVersionID is null or p.FCVersion = @fcVersionID)

		delete pcr
		from dbo.FCProcessFCColumnRelation pcr
				 inner join dbo.FCProjectCalcProcess cp on cp.ID = pcr.FCProjectCalcProcessID
		where cp.FCProjectID = @fcProjectID and (@fcVersionID is null or cp.FCVersionID = @fcVersionID);

		-- Ta bort projektstegs kopplingar till användare
		delete sur
		from dbo.FCProjectCalcStepUserRelation sur
				 inner join dbo.FCProjectCalcStep cs on sur.FCProjectCalcStepID = cs.ID
				 inner join dbo.FCProjectCalcProcess cp on cs.FCProjectCalcProcessID = cp.ID
		where cp.FCProjectID = @fcProjectID and (@fcVersionID is null or cp.FCVersionID = @fcVersionID);

		-- Sätt nuvarande steg för varje kalkylprocess till null för att sedan kunna ta bort stegen
		update dbo.FCProjectCalcProcess set CurrentStepID = NULL
		where FCProjectID = @fcProjectID and (@fcVersionID is null or FCVersionID = @fcVersionID);

		-- Ta bort kalkylprocesstegen
		delete cs
		from FCProjectCalcStep cs
				 inner join FCProjectCalcProcess cp on cs.FCProjectCalcProcessID = cp.ID
		where cp.FCProjectID = @fcProjectID and (@fcVersionID is null or cp.FCVersionID = @fcVersionID);

		--Ta bort processkommentarer
		delete urr
		from dbo.FCProjectCommentUserReadRelation urr
				 inner join dbo.FCProjectComment c on urr.FCProjectCommentID = c.ID
				 inner join dbo.FCProjectCalcProcess cp on c.FCProjectCalcProcessID = cp.ID
		where c.FCProjectID = @fcProjectID and (@fcVersionID is null or cp.FCVersionID = @fcVersionID);

		delete c
		from dbo.FCProjectComment c
				 inner join dbo.FCProjectCalcProcess cp on c.FCProjectCalcProcessID = cp.ID
		where c.FCProjectID = @fcProjectID and (@fcVersionID is null or cp.FCVersionID = @fcVersionID);

		-- Ta bort processer
		delete from dbo.FCProcess
		where FCTypeID = @fcTypeID
			and CompanyID = @companyID
			and FCLevel01 = @fcProjectKey
			and (@fcVersionID is null or FCVersion = @fcVersionID)

		-- Ta bort kalkylprocesser
		delete from dbo.FCProjectCalcProcess
		where FCProjectID = @fcProjectID and (@fcVersionID is null or FCVersionID = @fcVersionID);

		-- Om ingen specifik version är given ska data som inte är kopplad till version tas bort.
		if @fcVersionID is null
			begin
				-- Ta bort projektets processinstans.
				if @processInstanceID is not null
					begin
						exec process.Support_delete_instance @processInstanceID;
					end

				-- Ta bort projektets indikatorer.
				delete from dbo.FCProjectIndicatorStateRelation
				where FCProjectID = @fcProjectID

				-- Ta bort fcdimension
				declare @fcProjectTypeGroupID int
				create table #fcProjectTypes (ID int)
				create table #fcDimsToBeRemoved (ID int)

				select @fcProjectTypeGroupID = GroupID from FCTypeGroupRelation where FCTypeID = @fcTypeID

				insert into #fcProjectTypes
				select FCTypeID
				from FCTypeGroupRelation
				where GroupID = @fcProjectTypeGroupID

				if not exists (select 1 from #fcProjectTypes)
					begin
						insert into #fcProjectTypes
						select @fcTypeID
					end

				insert into #fcDimsToBeRemoved
				select ID
				from FCDimension
				where
					DimensionName = @fcProjectDimension and
					ElementKey = @fcProjectKey and
					FCTypeID in (select ID from #fcProjectTypes)

				delete from FCDimensionAncestorRelation
				where
					AncestorID in (select ID from #fcDimsToBeRemoved) or
					DecendantID in (select ID from #fcDimsToBeRemoved)

				delete dimTrans
				from FCDimensionMemberTranslation dimTrans
						 inner join #fcDimsToBeRemoved dimToBeRemoved on dimTrans.FCDimensionID = dimToBeRemoved.ID

				delete dim
				from FCDimension dim
						 inner join #fcDimsToBeRemoved dimToBeRemoved on dim.ID = dimToBeRemoved.ID

				drop table #fcProjectTypes
				drop table #fcDimsToBeRemoved

				-- Ta bort dokument kopplade till projektet
				delete from dbo.FCProjectDocument where FCProjectID = @fcProjectID;

				-- Ta bort projektegenskapsvärden
				delete from dbo.FCProjectPropertyValue where ProjectID = @fcProjectID;

				--Ta bort projektkommentarer
				delete urr
				from dbo.FCProjectCommentUserReadRelation urr
						 inner join dbo.FCProjectComment c on urr.FCProjectCommentID = c.ID
				where c.FCProjectID = @fcProjectID and c.FCProjectCalcProcessID is null;

				delete c
				from dbo.FCProjectComment c
				where c.FCProjectID = @fcProjectID and c.FCProjectCalcProcessID is null;

				-- Ta bort Senaste
				delete from dbo.FCRecentSelection
				where FCTypeID = @fcTypeID and CompanyID = @companyID and ElementKey = @fcProjectKey

				-- Ta bort Favoriter
				delete from dbo.FCFavoriteSelection
				where FCTypeID = @fcTypeID and CompanyID = @companyID and ElementKey = @fcProjectKey

				-- Ta bort användar/organisation-kopplingar
				delete from FCProjectUserRelationLog where FCProjectID = @fcProjectID
				delete from FCProjectUserRelation where FCProjectID = @fcProjectID

				-- Ta bort projektet
				delete from dbo.FCProject where ID = @fcProjectID;

				-- Sänk räknaren för ID så långt det går.
				declare @nextFCProjectID int;
				select @nextFCProjectID = isnull(max(ID) + 1, 0) from dbo.FCProject;
				dbcc CHECKIDENT('FCProject', RESEED, @nextFCProjectID);
			end

		-- Töm loggen
		delete from dbo.FCActionLog
		where FCProjectID = @fcProjectID
		  and (@fcVersionID is null or VersionID = @fcVersionID);

		exec dbo.delDocumentDataNotReferenced;

	END
GO
