SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Uppdaterar alla beräknade projektegenskaper för ett eller alla projekt.
--
-- När "alla" projekt uppdateras så uppdateras inte projekt som är låsta (isLocked = 1).
-- Om ett visst projekt specificeras i @projectID så uppdateras det dock även om det är låst.
CREATE PROCEDURE [dbo].[Support_Project_ComputeProjectProperties]
	@userID int,

	-- Alla projekt i den här budgettypen får sina beräknade projektegenskaper uppdaterade.
	@fcTypeID int = null,

	-- Om ett specifikt projekt ska uppdateras istället för alla projekt i budgettypen.
	@projectID int = null
AS
BEGIN
	set nocount on;

	-- Proceduren sköter transaktionen om det inte redan finns en transaktion.
	declare @tranCount int = @@trancount

	if @tranCount = 0 begin
		begin tran
	end

	begin try

		declare @NewLine char(2)
		set @NewLine = CHAR(13) + CHAR(10)

		if @fcTypeID is null and @projectID is null begin
			-- Använd första projektbudgeten.
			select top 1 @fcTypeID = FCTypeID
			from FCProjectProperty
		end else if @projectID is not null begin
			-- Hitta projektbudgeten som projektet tillhör.
			select @fcTypeID = FCTypeID
			from FCProject
			where ID = @projectID
		end

		if @fcTypeID is null and @projectID is null begin
			raiserror ('No project or budget type specified', 16, 10)
		end

		create table #propertyValuesToUpdate(
			ProjectID int,
			ProjectPropertyID int,
			QueryToComputeValue nvarchar(max),
			ProjectPropertyGroupInstanceID int,
			ProjectPropertyGroupID int,

			OldValueNumeric float,
			OldValueString nvarchar(3000),
			OldFCProjectPropertyPredefinedValueID int,

			NewValueNumeric float,
			NewValueString nvarchar(3000),
			NewFCProjectPropertyPredefinedValueID int
		)

		-- Hitta existerande egenskapsvärden som ska uppdateras.
		insert into #propertyValuesToUpdate(
			ProjectID,
			ProjectPropertyID,
			QueryToComputeValue,
			ProjectPropertyGroupInstanceID,
			ProjectPropertyGroupID,
			OldValueNumeric,
			OldValueString,
			OldFCProjectPropertyPredefinedValueID
		)
		select
			p.ID as ProjectID,
			pp.ID as ProjectPropertyID,
			pp.QueryToComputeValue,
			ppv.ProjectPropertyGroupInstanceID as InstanceID,
			rel.ProjectPropertyGroupID as GroupID,
			ppv.ValueNumeric,
			ppv.ValueString,
			ppv.FCProjectPropertyPredefinedValueID
		from FCProject p
			inner join FCProjectProperty pp on pp.FCTypeID = p.FCTypeID and pp.IsDeleted = 0
			inner join FCProjectPropertyValue ppv on ppv.ProjectPropertyID = pp.ID and ppv.ProjectID = p.ID
			left outer join FCProjectPropertyGroupRelation rel on rel.ProjectPropertyID = pp.ID
		where
			-- Projektet ligger i rätt budgettyp och/eller är ett specifikt projekt.
			(p.FCTypeID = @fcTypeID and (@projectID is null or p.ID = @projectID))
			-- Projektet är inte låst (eller man har specat att det specifika projektet ska beräknas ändå).
			and (isnull(p.isLocked, 0) = 0 or @projectID is not null)
			-- Egenskapen är beräknad.
			and (pp.QueryToComputeValue is not null and pp.QueryToComputeValue <> '')

		-- Ogrupperade beräknade egenskaper som saknar värde.
		insert into #propertyValuesToUpdate(
			ProjectID,
			ProjectPropertyID,
			QueryToComputeValue,
			ProjectPropertyGroupInstanceID,
			ProjectPropertyGroupID
		)
		select
			p.ID,
			pp.ID,
			pp.QueryToComputeValue,
			null,
			null
		from
			FCProject p
			inner join FCProjectProperty pp on pp.FCTypeID = p.FCTypeID and pp.IsDeleted = 0
			left outer join FCProjectPropertyValue ppv on ppv.ProjectPropertyID = pp.ID and ppv.ProjectID = p.ID
			left outer join FCProjectPropertyGroupRelation rel on rel.ProjectPropertyID = pp.ID
		where
			-- Projektet ligger i rätt budgettyp och/eller är ett specifikt projekt.
			(p.FCTypeID = @fcTypeID and (@projectID is null or p.ID = @projectID))
			-- Projektet är inte låst (eller man har specat att det specifika projektet ska beräknas ändå).
			and (isnull(p.isLocked, 0) = 0 or @projectID is not null)
			-- Värde saknas
			and ppv.ID is null
			-- Egenskapen är beräknad.
			and (pp.QueryToComputeValue is not null and pp.QueryToComputeValue <> '')
			-- Egenskapen ligger inte i grupp.
			and rel.ProjectPropertyID is null

		-- Gruppinstanser som saknar värde för en beräknad egenskap.
		insert into #propertyValuesToUpdate(
			ProjectID,
			ProjectPropertyID,
			QueryToComputeValue,
			ProjectPropertyGroupInstanceID,
			ProjectPropertyGroupID
		)
		select distinct
			p.ID,
			pp_missing.ID,
			pp_missing.QueryToComputeValue,
			ppv_existing.ProjectPropertyGroupInstanceID,
			rel_existing.ProjectPropertyGroupID
		from
			FCProject p
			inner join FCProjectProperty pp_existing
				on pp_existing.FCTypeID = p.FCTypeID and pp_existing.IsDeleted = 0
			inner join FCProjectPropertyGroupRelation rel_existing
				on rel_existing.ProjectPropertyID = pp_existing.ID
			inner join FCProjectPropertyValue ppv_existing
				on ppv_existing.ProjectPropertyID = pp_existing.ID
				and ppv_existing.ProjectID = p.ID
				and ppv_existing.ProjectPropertyGroupInstanceID is not null
			inner join FCProjectProperty pp_missing
				on pp_missing.FCTypeID = p.FCTypeID
				and pp_missing.ID <> pp_existing.ID
				and pp_missing.IsDeleted = 0
			inner join FCProjectPropertyGroupRelation rel_missing
				on rel_missing.ProjectPropertyID = pp_missing.ID
				and rel_missing.ProjectPropertyGroupID = rel_existing.ProjectPropertyGroupID
			left outer join FCProjectPropertyValue ppv_missing
				on ppv_missing.ProjectPropertyID = pp_missing.ID
				and ppv_missing.ProjectID = p.ID
				and ppv_missing.ProjectPropertyGroupInstanceID = ppv_existing.ProjectPropertyGroupInstanceID
		where
			-- Projektet ligger i rätt budgettyp och/eller är ett specifikt projekt.
			(p.FCTypeID = @fcTypeID and (@projectID is null or p.ID = @projectID))
			-- Projektet är inte låst (eller man har specat att det specifika projektet ska beräknas ändå).
			and (isnull(p.isLocked, 0) = 0 or @projectID is not null)
			-- Värde saknas
			and ppv_missing.ID is null
			-- Den saknade egenskapen är beräknad.
			and (pp_missing.QueryToComputeValue is not null and pp_missing.QueryToComputeValue <> '')


		declare updateCursor cursor for
			select
				ProjectId,
				ProjectPropertyID,
				QueryToComputeValue,
				ProjectPropertyGroupInstanceID,
				ProjectPropertyGroupID,
				OldValueNumeric,
				OldValueString,
				OldFCProjectPropertyPredefinedValueID
			from #propertyValuesToUpdate

		open updateCursor

		-- Kommer att innehålla det beräknade egenskapsvärdet.
		create table #computed (ValueNumeric float, ValueString nvarchar(3000), FCProjectPropertyPredefinedValueID int)

		-- Parameter till loggprocedur.
		create table #projectPropertyLogValues (
			ProjectID int, ProjectPropertyID int, ProjectPropertyGroupID int, ProjectPropertyGroupInstanceID int,
			OldValueNumeric float, OldValueString nvarchar(3000), OldFCProjectPropertyPredefinedValueID int,
			NewValueNumeric float, NewValueString nvarchar(3000), NewFCProjectPropertyPredefinedValueID int
		)

		declare @curProjectID int
		declare @curPropertyID int
		declare @curQueryToComputeValue nvarchar(max)
		declare @curInstanceID int
		declare @curGroupID int
		declare @curOldValueNumeric float
		declare @curOldValueString nvarchar(3000)
		declare @curOldPredefinedValueID int

		fetch next from updateCursor into
			@curProjectID,
			@curPropertyID,
			@curQueryToComputeValue,
			@curInstanceID,
			@curGroupID,
			@curOldValueNumeric,
			@curOldValueString,
			@curOldPredefinedValueID

		while @@FETCH_STATUS = 0 begin
			-- TODO: Istället för att generera om temptabellen för varje egenskapsvärde som ska uppdateras kanske vi kan generera en temptabell per projekt och sedan uppdatera IsCurrentGroupInstance för varje värde. Men det behövs bara om det blir ett prestandaproblem.
			declare @projectValuesSQL nvarchar(max)
			exec Support_Project_CreateProjectPropertiesTempTable
				@projectID = @curProjectID,
				@projectPropertyGroupID = @curGroupID,
				@projectPropertyGroupInstanceID = @curInstanceID,
				@selectSQLQuery = 0,
				@SQLQueryOutputVariable = @projectValuesSQL output

			declare @fullSQL nvarchar(max)
			set @fullSQL = @projectValuesSQL + @newLine + ';' + @curQueryToComputeValue

			-- För att få ut värdet från SQL-frågan körs en insert into temptabell. Det ska bara
			-- producera en rad, vilken vi kan hämta ut värdena från efteråt.
			truncate table #computed
			insert into #computed
			exec(@fullSQL)

			if (select count(*) from #computed) <> 1 begin
				declare @errmsg nvarchar(max)
				set @errmsg = 'QueryToComputeValue returnerade inte exakt en rad för '
					+ 'FCProjectID: ' + cast(@curProjectID as nvarchar(10))
					+ ', FCProjectPropertyID: ' + cast(@curPropertyID as nvarchar(10))
					+ ', FCProjectPropertyGroupID: ' + isnull(cast(@curGroupID as nvarchar(10)), 'NULL')
					+ ', FCProjectPropertyGroupInstanceID: ' + isnull(cast(@curInstanceID as nvarchar(10)), 'NULL')
				raiserror (@errmsg, 16, 10)
			end

			declare @newValueNumeric float
			declare @newValueString nvarchar(3000)
			declare @newPredefinedValueID int

			select
				@newValueNumeric = ValueNumeric,
				@newValueString = ValueString,
				@newPredefinedValueID = FCProjectPropertyPredefinedValueID
			from #computed

			-- Kom ihåg det nya värdet så att det kan loggas senare.
			update #propertyValuesToUpdate
			set NewValueNumeric = @newValueNumeric,
				NewValueString = @newValueString,
				NewFCProjectPropertyPredefinedValueID = @newPredefinedValueID
			where
				ProjectID = @curProjectID
				and ProjectPropertyID = @curPropertyID
				and (ProjectPropertyGroupInstanceID is null or ProjectPropertyGroupInstanceID = @curInstanceID)

			-- Uppdatera värdet i databasen.
			exec Support_Project_SetProjectPropertyValue
				@projectID = @curProjectID,
				@projectPropertyID = @curPropertyID,
				@userID = @userID,
				@groupInstanceID = @curInstanceID,
				@valueNumeric = @newValueNumeric,
				@valueString = @newValueString,
				@predefinedValueID = @newPredefinedValueID,
				@logChange = 0

			-- TODO: Borde egentligen kolla enligt datatyp/kontrolltyp.
			declare @valueChanged bit
			set @valueChanged = 0
			if (@curOldValueNumeric is null and @newValueNumeric is not null) or (@curOldValueNumeric is not null and @newValueNumeric is null) or (@curOldValueNumeric <> @newValueNumeric) begin
				set @valueChanged = 1
			end
			if (@curOldValueString is null and @newValueString is not null) or (@curOldValueString is not null and @newValueString is null) or (@curOldValueString <> @newValueString) begin
				set @valueChanged = 1
			end
			if (@curOldPredefinedValueID is null and @newPredefinedValueID is not null) or (@curOldPredefinedValueID is not null and @newPredefinedValueID is null) or (@curOldPredefinedValueID <> @newPredefinedValueID)		begin
				set @valueChanged = 1
			end

			if @valueChanged = 1 begin
				insert into #projectPropertyLogValues(
					ProjectID, ProjectPropertyID, ProjectPropertyGroupID, ProjectPropertyGroupInstanceID,
					OldValueNumeric, OldValueString, OldFCProjectPropertyPredefinedValueID,
					NewValueNumeric, NewValueString, NewFCProjectPropertyPredefinedValueID
				) values (
					@curProjectID, @curPropertyID, @curGroupID, @curInstanceID,
					@curOldValueNumeric, @curOldValueString, @curOldPredefinedValueID,
					@newValueNumeric, @newValueString, @newPredefinedValueID
				)
			end

			fetch next from updateCursor into
				@curProjectID,
				@curPropertyID,
				@curQueryToComputeValue,
				@curInstanceID,
				@curGroupID,
				@curOldValueNumeric,
				@curOldValueString,
				@curOldPredefinedValueID
		end

		-- Logga ändringarna.
		exec Support_Project_LogProjectPropertyChanges @userID = @userID

		if @tranCount = 0 begin
			commit tran
		end
	end try
	begin catch
		if @tranCount = 0 and @@trancount > 0 begin
			rollback tran
		end;

		throw;
	end catch
END


GO
