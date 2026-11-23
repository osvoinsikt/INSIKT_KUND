SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [insikt].[CopyCommentsFromResultatplaneringToAnalysis]
	@FCVersionID int = null,
	@ParentEventID int = null
	,@CopyAll bit = 0
AS BEGIN
	set nocount on;

	--
	-- Standardvariabler
	--
	declare @ProcName sysname, @TranCount int, @EventIDStack varbinary(max)
	set @ProcName = app.GetObjectFullName(@@procid)
	set @TranCount = @@trancount

	declare @nrOfCommentsToCopy int = 0
	declare @fromFCTypeID int = 1
	declare @budgetCommentTypeID int = 2
	declare @prognosisCommentTypeID int = 3

	declare @commentTypesToCopyTo table (ID int)	
	if @FCVersionID is null
	begin
		-- Kopiera kommentarer för både budget och prognoser.
		insert into @commentTypesToCopyTo(ID) values (@budgetCommentTypeID), (@prognosisCommentTypeID)
	end
	else
	begin
		-- Lista ut vilken typ av FCVersion som proceduren körs för och kopiera endast kommentarer till motsvarande kommentarstyp.
		declare @commentTypeToCopyTo int
		select @commentTypeToCopyTo = case when [Type] = 1 then @budgetCommentTypeID else @prognosisCommentTypeID end
		from [INSIKT_KUND_SYS].dbo.FCVersion
		where ID = @FCVersionID
		insert into @commentTypesToCopyTo(ID) values(@commentTypeToCopyTo)
	end

	begin try
	--------------------------------------------------------------------------
	-- Start
	--------------------------------------------------------------------------
	exec app.LogEventStart @ParentEventID = @ParentEventID, @EventIDStack = @EventIDStack output, @EventObject = @ProcName
		,@EventTitle = 'insikt.CopyCommentsFromResultatplaneringToAnalysis'
		,@Description = 'Kopierar kommentarer från planering till analys (kommentarstyper)'

		begin tran

		-- Skapa nya kommentarer
		DECLARE @DefaultTimestamp datetime = '2018-01-01'
		DECLARE @PreviousCopyTimeStamp datetime
		DECLARE @CurrentCommentID int, @CurrentCommentTypeID int
		DECLARE @LastInsertedCommentID int

		-- Läs ut tidsstämpel för senaste kommentar som kopierats vid tidigare körning.
		select @PreviousCopyTimeStamp = MAX(case when cce.CreatedDate > COALESCE(cce.ModifiedDate, @DefaultTimestamp) then cce.CreatedDate else cce.ModifiedDate end) 
			from [INSIKT_KUND_SYS].dbo.CellCommentEntry cce 
				inner join [INSIKT_KUND_SYS].dbo.CellComment cc on (cc.ID = cce.CellCommentID)
			where cc.CellCommentTypeID in (select ID from @commentTypesToCopyTo)

		if @PreviousCopyTimeStamp is NULL or @CopyAll = 1
		BEGIN
			SET @PreviousCopyTimeStamp = @DefaultTimestamp
		END

		select cc.ID as CellCommentID, case when fcv.[Type] = 1 then @budgetCommentTypeID else @prognosisCommentTypeID end as CommentTypeID
			into #cellCommentsToAdd
		from [INSIKT_KUND_SYS].dbo.CellComment cc
			inner join [INSIKT_KUND_SYS].dbo.CellCommentEntry cce on cce.ID = (
				select top 1 ID from [INSIKT_KUND_SYS].dbo.CellCommentEntry
				where CellCommentID = cc.ID
				order by isnull(ModifiedDate, CreatedDate) desc
			)
			inner join [INSIKT_KUND_SYS].dbo.CellCommentDimension ccd_pv on (ccd_pv.CellCommentID = cc.ID and ccd_pv.DimensionName = 'Planeringsversion')
			inner join [INSIKT_KUND_SYS].dbo.FCVersion fcv on (ccd_pv.ElementKey = cast(fcv.ID as nvarchar(50)))
		where FCTypeID = @fromFCTypeID and
			  (cce.CreatedDate > @PreviousCopyTimeStamp or cce.ModifiedDate > @PreviousCopyTimeStamp)
			  and (@FCVersionID is null or ccd_pv.ElementKey = cast(@FCVersionID as nvarchar(50)))

	
		select @nrOfCommentsToCopy = count(*) from #cellCommentsToAdd
		if @nrOfCommentsToCopy < 1
		begin
			print 'No new comments from ' + cast(@PreviousCopyTimeStamp as nvarchar(50)) + 
				case when @FCVersionID is null then '' else ' and for FCVersion ' + cast(@FCVersionID as nvarchar(50)) end +
				' found. Exiting procedure...'
				exec app.LogEventStop @EventIDStack = @EventIDStack out
				commit tran
			RETURN
		end

		-- Ta bort kommentarer som redan kopierats till analys, men förändrats.
		select cc.TargetCellCommentID AS ID
			into #cellCommentsToRemove
		from #cellCommentsToAdd temp
			inner join insikt.CopiedComments cc on (cc.SourceCellCommentID = temp.CellCommentID)
		where cc.CopyType = 'PlanningToAnalysis'

		-- Ta bort från mappningstabell (dessa läggs till igen längre ned).
		delete from insikt.CopiedComments
			where TargetCellCommentID in (select ID from #cellCommentsToRemove)

		delete ccd
		from [INSIKT_KUND_SYS].dbo.CellCommentDocument ccd
			inner join [INSIKT_KUND_SYS].dbo.CellCommentEntry cce on (cce.ID = ccd.CellCommentEntryID)
		where cce.CellCommentID IN (select ID from #cellCommentsToRemove)

		delete from [INSIKT_KUND_SYS].dbo.CellCommentEntry
		where CellCommentID IN (select ID from #cellCommentsToRemove)

		delete from [INSIKT_KUND_SYS].dbo.CellCommentDimension
		where CellCommentID IN (select ID from #cellCommentsToRemove)

		delete from [INSIKT_KUND_SYS].dbo.CellComment
		where ID IN (select ID from #cellCommentsToRemove)

		-- Kopiera alla nya kommentarer
		DECLARE comment_cursor CURSOR FOR 
			select CellCommentID, CommentTypeID from #cellCommentsToAdd

		OPEN comment_cursor

		FETCH NEXT FROM comment_cursor
		INTO @CurrentCommentID, @CurrentCommentTypeID

		WHILE @@FETCH_STATUS = 0
		BEGIN

			INSERT INTO [INSIKT_KUND_SYS].dbo.CellComment(CompanyID, CellCommentTypeID)
			SELECT CompanyID, @CurrentCommentTypeID
			FROM [INSIKT_KUND_SYS].dbo.CellComment
			WHERE [ID] = @CurrentCommentID

			SET @LastInsertedCommentID = @@identity 

			-- Lägg till kopierade kommentaren i mappningstabellen
			INSERT INTO insikt.CopiedComments(SourceCellCommentID, TargetCellCommentID, CopyType)
				values(@CurrentCommentID, @LastInsertedCommentID, 'PlanningToAnalysis')

			-- Lägg till alla dimensioner som inte ska ändras	
			INSERT INTO [INSIKT_KUND_SYS].dbo.CellCommentDimension(CellCommentID, DimensionName, HierarchyName, FullMemberName, ElementKey, CellCommentTypeID)
			SELECT @LastInsertedCommentID, DimensionName, HierarchyName, FullMemberName, ElementKey, @CurrentCommentTypeID
			FROM [INSIKT_KUND_SYS].dbo.CellCommentDimension
			WHERE CellCommentID = @CurrentCommentID
		
			-- Lägg till inläggen, ett åt gången, genom iteration.
			DECLARE entry_cursor CURSOR FOR
				SELECT ID
				FROM [INSIKT_KUND_SYS].dbo.CellCommentEntry
				WHERE CellCommentID = @CurrentCommentID;

			DECLARE @currentEntryID int;

			OPEN entry_cursor;
			FETCH NEXT FROM entry_cursor INTO @currentEntryID;
			WHILE @@FETCH_STATUS = 0
			BEGIN
				-- Kopiera inlägget.
				INSERT INTO [INSIKT_KUND_SYS].dbo.CellCommentEntry(CellCommentID, Comment, CreatedBy, CreatedDate, ModifiedDate, IsDeleted)
				SELECT @LastInsertedCommentID, Comment = replace(cast(Comment as nvarchar(max)), char(13) + char(10), '<br />'), CreatedBy, CreatedDate, ModifiedDate, IsDeleted
				FROM [INSIKT_KUND_SYS].dbo.CellCommentEntry
				WHERE ID = @currentEntryID

				-- Hämta nya inläggets ID.
				DECLARE @lastInsertedEntryID int;
				set @lastInsertedEntryID = @@IDENTITY;

				-- Kopiera dokumenten till nya inlägget.
				DECLARE @currentDocumentID int;
				DECLARE document_cursor CURSOR FOR
					SELECT DocumentID
					FROM [INSIKT_KUND_SYS].dbo.CellCommentDocument
					WHERE CellCommentEntryID = @currentEntryID;
						
				OPEN document_cursor;
				FETCH NEXT FROM document_cursor INTO @currentDocumentID;
				WHILE @@FETCH_STATUS = 0
				BEGIN
					DECLARE @newDocumentID int
					EXEC @newDocumentID = [INSIKT_KUND_SYS].dbo.copyDocument @currentDocumentID

					INSERT INTO [INSIKT_KUND_SYS].dbo.CellCommentDocument(CellCommentEntryID, DocumentID)
					VALUES(@lastInsertedEntryID, @newDocumentID)

					FETCH NEXT FROM document_cursor INTO @currentDocumentID
				END
				CLOSE document_cursor;
				DEALLOCATE document_cursor;

				FETCH NEXT FROM entry_cursor INTO @currentEntryID
			END
			CLOSE entry_cursor;
			DEALLOCATE entry_cursor;
					
			FETCH NEXT FROM comment_cursor
			INTO @CurrentCommentID, @CurrentCommentTypeID
		END
		CLOSE comment_cursor
		DEALLOCATE comment_cursor

		-- Nedan är korrigering av kommentarskopplingar och väldigt lösningsspecifikt (men kan härmas för andra lösningar)

		----
		-- Korrigera datumdimension. Ändra hierarki till 'År - Månad'.
		update ccd
		set FullMemberName = replace(replace(FullMemberName, 'Redovisningsår-Period', 'År - Månad'), 'Redovisningsår', 'År'),
			HierarchyName = 'År - Månad'
		from [INSIKT_KUND_SYS].dbo.CellCommentDimension ccd
		where ccd.CellCommentTypeID in (select ID from @commentTypesToCopyTo)
			and ccd.DimensionName = 'Datum' and ccd.HierarchyName = 'Redovisningsår-Period'
		--
		----

		----
		-- Korrigera huvuddimension. Organisation -> inblandade dimensionsdelar
		select ccd.* 
			into #orgDimensionConnections
		from [INSIKT_KUND_SYS].dbo.CellCommentDimension ccd
		where ccd.CellCommentTypeID in (select ID from @commentTypesToCopyTo)
			and ccd.DimensionName = 'Organisation'
	
		-- Ta bort kopplingar mot huvuddimension.
		delete ccd
		from [INSIKT_KUND_SYS].dbo.CellCommentDimension ccd
		where ccd.CellCommentTypeID in (select ID from @commentTypesToCopyTo)
			and ccd.DimensionName = 'Organisation'

		-- Lägg till kopplingar mot inblandade dimensionsdelar
			insert into [INSIKT_KUND_SYS].dbo.CellCommentDimension(CellCommentID, DimensionName, HierarchyName, FullMemberName, ElementKey, CellCommentTypeID)
			select 
				CellCommentID,
				'Avdelning',
				'Lista',
				'[Avdelning].[Lista].[Avdelning]' + '.&[' + + CAST(o.[AvdelningID] as varchar(10)) + ']',
				ElementKey = o.AvdelningID,
				CellCommentTypeID
			from #orgDimensionConnections temp
				inner join dw.dim_Organisation o on o.Organisation_LeafID = temp.ElementKey
			--
		----

		print 'Copied ' + cast(@nrOfCommentsToCopy as nvarchar(10)) + ' comments from ' + cast(@PreviousCopyTimeStamp as nvarchar(50)) + '.'
		commit tran

		exec app.LogEventStop @EventIDStack = @EventIDStack out
		--------------------------------------------------------------------------
		-- Stop
		--------------------------------------------------------------------------
	end try
	begin catch	
		--
		-- Roll back any transactions and log errors
		--
		if @TranCount = 0 and @@trancount > 0 rollback tran
		exec app.HandleProcError @EventIDStack out, @ParentEventID, @ProcName
		exec app.ReThrowError
	end catch
END
GO
