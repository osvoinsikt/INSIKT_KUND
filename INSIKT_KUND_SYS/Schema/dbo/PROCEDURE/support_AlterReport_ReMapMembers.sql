SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************
 #Desc:         Update stored members to new uniquenames and element keys (based on @MemberMapTable/#ReportMemberMap) in relevant database tables:
				 - Reports (dbo.Report)
				 - Custom members (dbo.CustomMembers)
				 - Comments connected to budget types, comment types or reports (dbo.CellComment)
				 - User responsibilities/connections (dbo.UserHierarchyRelation)
 #
 #InParam:      @ReportFilter	Optional filter to search for specific reports which contains this in 'ReportData'
 #              @ReportID		Report ID to search in or NULL for all reports.
 #              @Database		Cube database name to limit the re-map (or NULL for all)
 #              @Cube			Cube name to limit the re-map (or NULL for all)
 #				@MemberMapTable	Table which specifies the mapping between old and new uniquenames.
 #
********************************************************************/
CREATE PROCEDURE [dbo].[support_AlterReport_ReMapMembers]
(	
	@ReportFilter nvarchar(512) = NULL,
	@ReportID int = NULL,
	@Database nvarchar(512) = NULL,
	@Cube nvarchar(512) = null,
	@MemberMapTable nvarchar(512) = '#ReportMemberMap'	
)
AS
BEGIN
	declare @TranCount int
	set @TranCount = @@trancount
	begin try
		set nocount on;
		if @TranCount = 0 begin tran


		declare @MemberMapTableFQN nvarchar(512)
		if left(parsename(@MemberMapTable, 1), 1) = '#'
			set @MemberMapTableFQN = 
				quotename('tempdb') + '.' 
				+ isnull(quotename(parsename(@MemberMapTable, 2)), '') 
				+ '.' + quotename(parsename(@MemberMapTable, 1))
		else
			set @MemberMapTableFQN = @MemberMapTable


	
		if object_id(@MemberMapTableFQN) is null
			raiserror ('Mappningstabellen %s finns ej.', 16, 10, @MemberMapTable)	


		declare @DynSQL nvarchar(max)
		select
			@DynSQL = 
				'if (select count(*) from ' + isnull(parsename(@MemberMapTableFQN, 3) + '.', '') + 'sys.columns where object_id = ' + cast(object_id(@MemberMapTableFQN) as nvarchar(12)) 
				+ ' and name in (''OldUniqueName'',''OldID'',''NewUniqueName'',''NewID'')) <> 4'
				+ ' raiserror(''Mappningstabellen måste innhålla kolumnerna OldUniqueName, OldID, NewUniqueName och NewID'', 16, 10)'
		exec (@DynSQL)


		declare @Report table
		(
			ReportID int not null
			,ReportData nvarchar(max)
			,FormattingRuleID int
			,FormattingRuleData nvarchar(max)
		)

		;with Reports as
		(
			select
				ReportID  = r.ID
				,ReportData = CAST(r.Data as nvarchar(max))
				,FormattingRuleID = r.FormattingRuleID
				,SourceServer = 
					isnull
					(
						c.[Server]
						,Data.value('/AnalysisReport[1]/DataSource[1]/Server[1]', 'varchar(500)')
					)
				,SourceDatabase = 
					isnull
					(
						c.[Database]
						,Data.value('/AnalysisReport[1]/DataSource[1]/Database[1]', 'varchar(500)')
					)
				,SourceCube = 
					isnull
					(
						ds.SourceCube
						,Data.value('/AnalysisReport[1]/DataSource[1]/Cube[1]', 'varchar(500)')
					)			
			from
				Report r
					left join DataSources ds on
						ds.ID = Data.value('/AnalysisReport[1]/DataSource[1]/DataSourceId[1]', 'int')
					left join DataSourceConnection c on
						c.ID = ds.DataSourceConnectionID
			where
				r.ReportTypeID in (1,4)
				and r.Inactive = 0
				and	(@ReportID is null or r.ID = @ReportID)
		)
		insert into @Report
		(
			ReportID
			,ReportData
			,FormattingRuleID
			,FormattingRuleData
		)
		select
			r.ReportID
			,ReportData = r.ReportData
			,FormattingRuleID = f.ID
			,FormattingRuleData = f.Data
		from
			Reports r
				left join dbo.FormattingRule f on
					f.ID = r.FormattingRuleID
		where
			(r.SourceDatabase =  @Database or @Database is null)
			and (r.SourceCube = @Cube or @Cube is null)
			and (r.ReportData like @ReportFilter or @ReportFilter is null)


		declare @NrOfReportsMessage nvarchar(max)
		select @NrOfReportsMessage = 'Söker och ersätter i ' + cast(count(*) as nvarchar(12)) + ' rapporter.' from @Report
		raiserror(@NrOfReportsMessage, 0, 0) with nowait;

		declare 
			@OldUniqueName nvarchar(512)
			,@OldID nvarchar(512)
			,@NewUniqueName nvarchar(512)
			,@NewID nvarchar(512)
			,@DeclareReportXML nvarchar(max)

		declare 
			@OldUniqueNameSearchStr nvarchar(1024)
			,@XmlOldUniqueName nvarchar(512)	
			,@XmlNewUniqueName nvarchar(512)
	
		declare @DynSqlSelectMapTable nvarchar(max)


		create table #___MAP___
		(
			[OldUniqueName] nvarchar(512)
			,[OldID] nvarchar(512)
			,[NewUniqueName] nvarchar(512)
			,[NewID] nvarchar(512)
		)
		select @DynSqlSelectMapTable =
			'select [OldUniqueName],[OldID],[NewUniqueName],[NewID] from ' + @MemberMapTable

		insert into #___MAP___
		exec (@DynSqlSelectMapTable)


		declare 
			@CurrentMapNr int
			,@MapCount int

		set @CurrentMapNr = 0
		select @MapCount = count(*) from #___MAP___
		

		declare SAR cursor LOCAL FORWARD_ONLY READ_ONLY for
			select
				[OldUniqueName] 
				,[OldID]
				,[NewUniqueName] 
				,[NewID]
			from
				#___MAP___
			order by
				len([OldUniqueName]) desc


		open SAR
		fetch next from SAR into
			@OldUniqueName
			,@OldID
			,@NewUniqueName
			,@NewID

	


		while @@FETCH_STATUS = 0
			begin
				set @CurrentMapNr = @CurrentMapNr + 1
				raiserror('Hanterar mappning %s -> %s (mappning %d av %d)', 0, 0, @OldUniqueName, @NewUniqueName, @CurrentMapNr, @MapCount) with nowait;

		
				set @XmlOldUniqueName = replace(@OldUniqueName, '&', '&amp;')
				set @XmlNewUniqueName = replace(@NewUniqueName, '&', '&amp;')

				set @OldUniqueNameSearchStr = '%' + replace(@XmlOldUniqueName, '[', '[[]') + '%'


				--
				-- Uppdatera rapport definitioner
				--
				update @Report set
					ReportData = replace(ReportData, @XmlOldUniqueName, @XmlNewUniqueName)		
					,FormattingRuleData = replace(FormattingRuleData, @XmlOldUniqueName, @XmlNewUniqueName)
				where
					ReportData like @OldUniqueNameSearchStr
					or FormattingRuleData like @OldUniqueNameSearchStr


				--
				-- Uppdatera beräkningar
				--			
				UPDATE m SET
					MDXFormula = REPLACE(MDXFormula, @OldUniqueName, @NewUniqueName)
				FROM
					dbo.CustomMembers m
				WHERE
					(@Database IS NULL OR m.[Database] = @Database)
					and (@Cube IS NULL OR m.[Cube] = @Cube)
					AND MDXFormula LIKE '%' + REPLACE(@OldUniqueName, '[', '[[]') + '%'

				update m set
					PositionReferenceMember = @NewUniqueName
				from
					dbo.CustomMembers m
				where				
					(@Database is null or m.[Database] = @Database)
					and (@Cube is null or m.[Cube] = @Cube)
					and PositionReferenceMember = @OldUniqueName
				
			

				--
				-- Uppdatera beräkningsmedlemar
				--
				update mm set
					UniqueName = @NewUniqueName
				from
					dbo.CustomMembers m
						inner join dbo.CustomMemberMembers mm on
							mm.CustomMemberID = m.ID
				where
					mm.UniqueName = @OldUniqueName
					and (@Database is null or m.[Database] = @Database)
					and (@Cube is null or m.[Cube] = @Cube)
					
				fetch next from SAR into
					@OldUniqueName
					,@OldID
					,@NewUniqueName
					,@NewID
			end

		close SAR
	
		deallocate SAR

		---- Påverkade budgettyper
		select 
			FCTypeID
		into #affectedFCTypes
		from FCTypeDataSourceRelation rel
		inner join DataSources ds on (rel.DataSourceID = ds.ID)
		inner join DataSourceConnection c on (c.ID = ds.DataSourceConnectionID)
		where
			(@Database is null or c.[Database] = @Database) and
			(@Cube is null or ds.SourceCube = @Cube)
		
		-- Uppdatera kopplingar till budgetkommentarer
		declare @NrOfChangedComments int
		set @NrOfChangedComments = 0
		update d
		set 
			d.FullMemberName = map.NewUniqueName,
			d.ElementKey = map.[NewID]
		from CellComment c
			inner join #affectedFCTypes on c.FCTypeID = #affectedFCTypes.FCTypeID
			inner join CellCommentDimension d on c.ID = d.CellCommentID
			inner join #___MAP___ map on d.FullMemberName = map.OldUniqueName
		set @NrOfChangedComments = @@ROWCOUNT

		---- Påverkade kommentarstyper
		select distinct
			cct.ID
		into #affectedCommentTypes
		from 
			CellCommentType cct
			inner join DataSources ds on
				ds.ID = cct.DataSourceID
			inner join DataSourceConnection c on
				ds.DataSourceConnectionID = c.ID
		where 
			isnull(cct.IsDeleted, 0) = 0
			and (@Database is null or c.[Database] = @Database)
			and (@Cube is null or ds.SourceCube = @Cube)

		-- Uppdatera kopplingar till kommentarer knutna mot kommentarstyper
		update d
		set 
			d.FullMemberName = map.NewUniqueName,
			d.ElementKey = map.[NewID]
		from CellComment c
			inner join #affectedCommentTypes on c.CellCommentTypeID = #affectedCommentTypes.ID
			inner join CellCommentDimension d on c.ID = d.CellCommentID
			inner join #___MAP___ map on d.FullMemberName = map.OldUniqueName

		set @NrOfChangedComments += @@ROWCOUNT -- Addera antal uppdaterade kommentarer knutna mot kommentarstyper

		-- Uppdatera kopplingar till rapportkommentarer
		update d
		set 
			d.FullMemberName = map.NewUniqueName,
			d.ElementKey = map.[NewID]
		from CellComment c
			inner join @Report r on c.ReportID = r.ReportID
			inner join CellCommentDimension d on c.ID = d.CellCommentID
			inner join #___MAP___ map on d.FullMemberName = map.OldUniqueName

		set @NrOfChangedComments += @@ROWCOUNT -- Addera antal uppdaterade kommentarer knutna mot rapporter

		-- Uppdatera användarkopplingar
		declare @NrOfChangedUserRelations int
		update r
		set 
			r.MemberUniqueName = map.NewUniqueName
		from UserHierarchyRelation r
			inner join UserHierarchyRelationSet s on r.UserHierarchyRelationSetID = s.ID
			inner join DataSourceDimensionHierarchy h on s.DimensionHierarchyID = h.ID
			inner join DataSourceDimension d on h.DataSourceDimensionID = d.ID
			inner join DataSources ds on d.DataSourceID = ds.ID
			inner join DataSourceConnection c on ds.DataSourceConnectionID = c.ID
			inner join #___MAP___ map on r.MemberUniqueName = map.OldUniqueName
		where
			(@Database is null or c.[Database] = @Database)
			and (@Cube is null or ds.SourceCube = @Cube)

		set @NrOfChangedUserRelations = @@ROWCOUNT

		raiserror('Sparar ändringar...', 0, 0) with nowait;

		declare @NrOfChangedReports int
		update old set
			Data = new.ReportData
		From 
			@Report new
				inner join Report old on
					old.ID = new.ReportID
		where
			cast(old.Data as nvarchar(max)) <> new.ReportData collate database_default
		set @NrOfChangedReports = @@ROWCOUNT

		declare @NrOfChangedReportsFormattingRules int
		update old set
			Data = new.FormattingRuleData
		From 
			@Report new
				inner join FormattingRule old on
					old.ID = new.FormattingRuleID
		where
			old.Data <> new.FormattingRuleData collate database_default
		set @NrOfChangedReportsFormattingRules = @@ROWCOUNT


		select 'Nr of changed reports' as [Type], @NrOfChangedReports as [Count]
		union select 'Nr of changed formatting rules' as [Type], @NrOfChangedReportsFormattingRules as [Count]
		union select 'Nr of changed comments' as [Type], @NrOfChangedComments as [Count]
		union select 'Nr of changed user relations' as [Type], @NrOfChangedUserRelations as [Count]
		if @TranCount = 0 commit tran
	end try
	begin catch	
		--
		-- Rulla tillbaka eventualla transaktioner startade i den här procedurn.
		--
		if @TranCount = 0 and @@trancount > 0 rollback tran
		declare @ErrorMessage nvarchar(max), @ErrorSeverity int, @ErrorState int;
		select 
			@ErrorMessage = error_message()
				--N'Error ' + cast(error_number() as nvarchar(12))
				--+ ', Level ' + cast(error_severity() as nvarchar(12))
				--+ ', State ' + cast(error_state() as nvarchar(12))
				--+ ', Procedure ' + isnull(error_procedure(), '-')
				--+ ', Line ' + cast(error_line() as nvarchar(12))
				--+ ', Message: ' + error_message()
			,@ErrorSeverity = error_severity()
			,@ErrorState = error_state();
		raiserror (@ErrorMessage, @ErrorSeverity, @ErrorState);
	end catch
END

GO
