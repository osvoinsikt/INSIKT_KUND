SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [app].[HierarchyImport] 
(
	@HierarchyData xml
	,@IgnoreWarnings bit = 0
)
as
--
-- Standardvariabler
--
declare @ProcName sysname, @TranCount int, @EventIDStack varbinary(max)
set @ProcName = app.GetObjectFullName(@@procid)
set @TranCount = @@trancount

begin try
	if @HierarchyData is null
		raiserror('@HierarchyData får inte vara null. Använd app.HierarchyExport för att export hierarki-konfigurationer till XML.', 16, 10)


	CREATE TABLE #Hierarchy(
		[SrcHierarchyID] int NOT NULL,
		[HierarchyID] int  NULL,
		[Name] [nvarchar](150) NULL,
		[Caption] nvarchar(150) null,
		[Description] [nvarchar](500) NULL,
	)
	insert into #Hierarchy
	select
		SrcHierarchyID = h.c.value('./@HierarchyID[1]', 'int')
		,HierarchyID = tgtHierarchy.HierarchyID
		,Name = h.c.value('./@Name[1]', 'nvarchar(150)')
		,[Caption] = isnull(h.c.value('./@Caption[1]', 'nvarchar(150)'), h.c.value('./@Name[1]', 'nvarchar(150)'))
		,Description = h.c.value('./@Description[1]', 'nvarchar(150)')

	from
		@HierarchyData.nodes('/Hierarchy') h(c)
			left join app.Hierarchy tgtHierarchy on
				tgtHierarchy.Name = h.c.value('./@Name[1]', 'nvarchar(150)')
		
	select
		SrcHierarchyID = h.c.value('./@HierarchyID[1]', 'int')
		,SrcDimensionPartTypeID = hdp.d.value('./@DimensionPartTypeID[1]', 'int')
		,SrcDimensionPartTypeName = hdp.d.value('DimensionPartType[1]/@Name[1]', 'nvarchar(150)')
		,HierarchyID = CAST(null as int)
		,DimensionPartTypeID = CAST(null as int)
		,DimensionPartFilterExpression = hdp.d.value('./@DimensionPartFilterExpression[1]', 'nvarchar(1000)')
		,DefaultSortOrderExpression = hdp.d.value('./@DefaultSortOrderExpression[1]', 'nvarchar(500)')
	into #HierarchyDimensionPartTypes
	from
		@HierarchyData.nodes('/Hierarchy') h(c)
			cross apply h.c.nodes('DimensionPartTypes[1]/HierarchyDimensionPartType') hdp(d)


	
	select
		SrcHierarchyID = h.c.value('./@HierarchyID[1]', 'int')
		,HierarchyOptionTypeID = hdp.d.value('./@HierarchyOptionTypeID[1]', 'varchar(4)')
		,ValueInt = hdp.d.value('./@ValueInt[1]', 'int')
		,ValueStr = hdp.d.value('./@ValueStr[1]', 'nvarchar(500)')
	into #HierarchyOptions
	from
		@HierarchyData.nodes('/Hierarchy') h(c)
			cross apply h.c.nodes('HierarchyOptions[1]/HierarchyOption') hdp(d)



	
	select
		SrcHierarchyID = h.c.value('./@HierarchyID[1]', 'int')
		,HierarchyID = CAST(null as int)
		,ColumnName = hdp.d.value('./@ColumnName[1]', 'nvarchar(128)')
		,ValueExpression = hdp.d.value('./@ValueExpression[1]', 'nvarchar(1000)')
		,DataType = hdp.d.value('./@DataType[1]', 'nvarchar(100)')
		,DefaultEmptyValueExpression = hdp.d.value('./@DefaultEmptyValueExpression[1]', 'nvarchar(1000)')
	into #HierarchyExtraColumns
	from
		@HierarchyData.nodes('/Hierarchy') h(c)
			cross apply h.c.nodes('HierarchyExtraColumns[1]/HierarchyExtraColumn') hdp(d)



	select
		SrcHierarchyID = h.c.value('./@HierarchyID[1]', 'int')
		,SrcHierarchyNodeAttributeTypeID =  hdp.d.value('./@HierarchyNodeAttributeTypeID[1]', 'int')
		,HierarchyID = CAST(null as int)
		,HierarchyNodeAttributeTypeID = CAST(null as int)
		,Name = hdp.d.value('./@Name[1]', 'nvarchar(100)')
		,Description = hdp.d.value('./@Description[1]', 'nvarchar(500)')
		,DataTypeID = hdp.d.value('./@DataTypeID[1]', 'char(4)')
	into #HierarchyNodeAttributeTypes
	from
		@HierarchyData.nodes('/Hierarchy') h(c)
			cross apply h.c.nodes('HierarchyNodeAttributeTypes[1]/HierarchyNodeAttributeType') hdp(d)


	select
		SrcHierarchyID = h.c.value('./@HierarchyID[1]', 'int')
		,SrcLanguageID =  hdp.d.value('./@LanguageID[1]', 'int')
		,HierarchyID = CAST(null as int)
		,LanguageID = CAST(null as int)
		,Caption = hdp.d.value('./@Caption[1]', 'nvarchar(150)')
		,LanguageCode = hdp.d.value('Language[1]/@Code[1]', 'nvarchar(3)')
		,LanguageName = hdp.d.value('Language[1]/@Name[1]', 'nvarchar(150)')
	into #HierarchyLanguages
	from
		@HierarchyData.nodes('/Hierarchy') h(c)
			cross apply h.c.nodes('HierarchyLanguages[1]/HierarchyLanguage') hdp(d)



	select
		SrcHierarchyID = h.c.value('./@HierarchyID[1]', 'int')
		,SrcHierarchyNodeID = hdp.d.value('./@HierarchyNodeID[1]', 'int')
		,SrcParentHierarchyNodeID = hdp.d.value('./@ParentHierarchyNodeID[1]', 'int')
		,SrcDimensionPartTypeID = hdp.d.value('./@DimensionPartTypeID[1]', 'int')
	

		,HierarchyNodeID = CAST(null as int)
		,SortOrder = hdp.d.value('./@SortOrder[1]', 'int')	
		,Priority = hdp.d.value('./@Priority[1]', 'int')


		,Expression = hdp.d.value('./@Expression[1]', 'nvarchar(1000)')
		,FilterExpression = hdp.d.value('./@FilterExpression[1]', 'nvarchar(max)')
		,SortOrderExpression = hdp.d.value('./@SortOrderExpression[1]', 'nvarchar(500)')
	
		,EmptyHeader = hdp.d.value('./@EmptyHeader[1]', 'bit')
	into #HierarchyNodes
	from
		@HierarchyData.nodes('/Hierarchy') h(c)
			cross apply h.c.nodes('HierarchyNodes[1]/HierarchyNode') hdp(d)




	select
		SrcHierarchyID = h.c.value('./@HierarchyID[1]', 'int')
		,SrcHierarchyNodeID = hdp.d.value('./@HierarchyNodeID[1]', 'int')
	
		,SrcHierarchyNodeAttributeTypeID = att.d.value('./@HierarchyNodeAttributeTypeID[1]', 'int')
		,ValueInt = att.d.value('./@ValueInt[1]', 'int')
		,ValueStr = att.d.value('./@ValueStr[1]', 'nvarchar(500)')
	into #HierarchyNodeAttributes
	from
		@HierarchyData.nodes('/Hierarchy') h(c)
			cross apply h.c.nodes('HierarchyNodes[1]/HierarchyNode') hdp(d)
			cross apply hdp.d.nodes('HierarchyNodeAttributes[1]/HierarchyNodeAttribute') att(d)

	
	select
		SrcHierarchyID = h.c.value('./@HierarchyID[1]', 'int')
		,SrcHierarchyNodeID = hdp.d.value('./@HierarchyNodeID[1]', 'int')
	
		,SrcLanguageID = att.d.value('./@LanguageID[1]', 'int')
		,LangExpression = att.d.value('./@LangExpression[1]', 'nvarchar(1000)')
	into #HierarchyNodeLanguages
	from
		@HierarchyData.nodes('/Hierarchy') h(c)
			cross apply h.c.nodes('HierarchyNodes[1]/HierarchyNode') hdp(d)
			cross apply hdp.d.nodes('HierarchyNodeLanguages[1]/HierarchyNodeLanguage') att(d)


	update t set
		DimensionPartTypeID = dpt.DimensionPartTypeID
	from
		#HierarchyDimensionPartTypes t
			inner join app.DimensionPartType dpt on
				dpt.Name = t.SrcDimensionPartTypeName


	if exists(select 1 from #HierarchyDimensionPartTypes where DimensionPartTypeID is null)
		begin
			select
				*
			from
				#HierarchyDimensionPartTypes 
			where 
				DimensionPartTypeID is null

			raiserror('Unable to map source hierarchy dimension part types to target dimensionpart types. Review Results for more information.', 16, 10)
		end

	if (select COUNT(*)	from #Hierarchy) = 0
		raiserror('Inga hierarkier hittades i @HierarchyData.', 16, 10)

	if exists
	(
		select
			*
		from 
			#Hierarchy h
		where
			not exists(select 1 from #HierarchyNodes n where n.SrcHierarchyID = h.SrcHierarchyID)
	)
	and isnull(@IgnoreWarnings, 0) = 0
		begin
			select
			*
			from 
				#Hierarchy h
			where
				not exists(select 1 from #HierarchyNodes n where n.SrcHierarchyID = h.SrcHierarchyID)
			
			raiserror('Hierarkier utan hierarkinoder hittades', 16, 10)
		end

	if @TranCount = 0 begin tran

	

	insert into app.Hierarchy
	(
		Name
		,Caption
		,Description
	)
	select
		h.Name
		,h.Caption
		,h.Description
	from
		#Hierarchy h
	where
		h.HierarchyID is null

	update h set 
		HierarchyID = nameLookup.HierarchyID
	from
		#Hierarchy h
			inner join app.Hierarchy nameLookup on
				nameLookup.Name = h.Name
	where
		h.HierarchyID is null


	exec app.SyncTable
		@SourceTable = '#Hierarchy'
		,@TargetTable = 'app.Hierarchy'
		,@DeleteMode = 3 -- = Borttagna lämnas kvar (endast insert/update)


	--
	-- Hierarkier utan tidigare import.
	-- Försök att behålla ID:n på hierarkinoder.
	--
	insert into app.HierarchyNodeImportMap
	(
		SrcHierarchyID
		,SrcHierarchyNodeID
		,HierarchyID
		,HierarchyNodeID
	)
	select
		h.SrcHierarchyID
		,n.SrcHierarchyNodeID
		,h.HierarchyID
		,HierarchyNodeID = n.SrcHierarchyNodeID
	from
		#Hierarchy h
			inner join #HierarchyNodes n on
				n.SrcHierarchyID = h.SrcHierarchyID
			left join app.HierarchyNode en on
				en.HierarchyNodeID = n.SrcHierarchyNodeID
		
	where
		not exists
		(
			select 1
			from
				app.HierarchyNodeImportMap m
			where
				m.SrcHierarchyID = h.SrcHierarchyID
				and m.HierarchyID = h.HierarchyID
		)
		and en.HierarchyNodeID is null



	update ec set
		HierarchyID = h.HierarchyID
	from
		#HierarchyExtraColumns ec
			inner join #Hierarchy h on
				h.SrcHierarchyID = ec.SrcHierarchyID

	exec app.SyncTable
		@SourceTable = '#HierarchyExtraColumns'
		,@TargetTable = 'app.HierarchyExtraColumn'
		,@TargetFilter = 'HierarchyID  in (select HierarchyID from #Hierarchy)'
		,@JoinColumns = 'HierarchyID, ColumnName'


	update l set
		l.HierarchyID = h.HierarchyID
		,l.LanguageID = langLookup.LanguageID
	from
		#HierarchyLanguages l
			inner join app.[Language] langLookup on
				langLookup.Code = l.LanguageCode
			inner join #Hierarchy h on
				h.SrcHierarchyID = l.SrcHierarchyID
	if exists(select 1 from #HierarchyLanguages where LanguageID is null)
		begin
			select * From  #HierarchyLanguages where LanguageID is null
			raiserror('Language codes are missing in app.Language. Review results for missing codes.', 16, 10)
		end

	exec app.SyncTable
		@SourceTable = '#HierarchyLanguages'
		,@TargetTable = 'app.HierarchyLanguage'
		,@TargetFilter = 'HierarchyID  in (select HierarchyID from #Hierarchy)'


	update ec set
		HierarchyID = h.HierarchyID
	from
		#HierarchyNodeAttributeTypes ec
			inner join #Hierarchy h on
				h.SrcHierarchyID = ec.SrcHierarchyID


	exec app.SyncTable
		@SourceTable = '#HierarchyNodeAttributeTypes'
		,@TargetTable = 'app.HierarchyNodeAttributeType'
		,@TargetFilter = 'HierarchyID  in (select HierarchyID from #Hierarchy)'
		,@JoinColumns = 'HierarchyID, Name'


	update ec set
		HierarchyNodeAttributeTypeID = a.HierarchyNodeAttributeTypeID
	from
		#HierarchyNodeAttributeTypes ec
			inner join #Hierarchy h on
				h.SrcHierarchyID = ec.SrcHierarchyID
			inner join app.HierarchyNodeAttributeType a on
				a.HierarchyID = h.HierarchyID
				and a.Name = ec.Name

				
	delete from app.HierarchyOption where HierarchyID in  (select HierarchyID from #Hierarchy)
	insert into app.HierarchyOption
	(
		HierarchyID
		,HierarchyOptionTypeID
		,ValueInt
		,ValueStr
	)
	select
		HierarchyID = h.HierarchyID
		,HierarchyOptionTypeID = o.HierarchyOptionTypeID
		,ValueInt = o.ValueInt
		,ValueStr = o.ValueStr
	from
		#Hierarchy h
			inner join #HierarchyOptions o on
				o.SrcHierarchyID = h.SrcHierarchyID


	delete from app.HierarchyNodeAttribute 
	where 
		HierarchyNodeID in
		(
			select n.HierarchyNodeID 
			from app.HierarchyNode n
			where HierarchyID in (select HierarchyID from #Hierarchy)
		)



	
	delete from app.HierarchyNodeLanguage 
	where 
		HierarchyNodeID in
		(
			select n.HierarchyNodeID 
			from app.HierarchyNode n
			where HierarchyID in (select HierarchyID from #Hierarchy)
		)

	delete from app.HierarchyNode
	where HierarchyID in (select HierarchyID from #Hierarchy)




	update ec set
		HierarchyID = h.HierarchyID
	from
		#HierarchyDimensionPartTypes ec
			inner join #Hierarchy h on
				h.SrcHierarchyID = ec.SrcHierarchyID
	exec app.SyncTable
		@SourceTable = '#HierarchyDimensionPartTypes'
		,@TargetTable = 'app.HierarchyDimensionPartType'
		,@TargetFilter = 'HierarchyID  in (select HierarchyID from #Hierarchy)'
		,@JoinColumns = 'HierarchyID, DimensionPartTypeID'

	;with InsertOrder as
	(
		select
			n0.SrcHierarchyID
			,n0.SrcHierarchyNodeID
			,InsertOrder = 1
		from
			#HierarchyNodes n0
		where
			n0.SrcParentHierarchyNodeID is null
		union all
		select
			pn.SrcHierarchyID
			,nx.SrcHierarchyNodeID
			,InsertOrder = pn.InsertOrder + 1
		from
			#HierarchyNodes nx
				inner join InsertOrder pn on
					pn.SrcHierarchyNodeID = nx.SrcParentHierarchyNodeID
					and pn.SrcHierarchyID = nx.SrcHierarchyID
	)
	select
		InsertNr = cast(row_number() over (order by InsertOrder, o.SrcHierarchyID, o.SrcHierarchyNodeID) as int)
		,o.*
	into
		#HierarchyNodeInsertOrder 
	from
		InsertOrder o

	
	declare @InsertNr int, @NewHierarchyNodeID int

	select @InsertNr = MIN(InsertNr) from #HierarchyNodeInsertOrder

	set identity_insert app.HierarchyNode on
	while (@InsertNr is not null)
		begin
			
			insert into app.HierarchyNode
			(
				HierarchyNodeID
				,HierarchyID
				,ParentHierarchyNodeID
				,SortOrder
				,DimensionPartTypeID
				,Priority
				,Expression
				,FilterExpression
				,SortOrderExpression
				,EmptyHeader
			)
			--output inserted.HierarchyID, inserted.HierarchyNodeID
			select
				HierarchyNodeID = 
					case
						when 
							map.HierarchyNodeID is not null
							and tgtExists.HierarchyNodeID is null
						then
							map.HierarchyNodeID
						else
							(select ISNULL(max(HierarchyNodeID), 0) + 1 from app.HierarchyNode)
					end
				,HierarchyID = h.HierarchyID
				,ParentHierarchyNodeID = parentNode.HierarchyNodeID
				,SortOrder = srcNode.SortOrder
				,DimensionPartTypeID = hdp.DimensionPartTypeID
				,Priority = srcNode.Priority
				,Expression = srcNode.Expression
				,FilterExpression = srcNode.FilterExpression
				,SortOrderExpression = srcNode.SortOrderExpression
				,EmptyHeader = srcNode.EmptyHeader
			from
				#HierarchyNodeInsertOrder i
					inner join #Hierarchy h on
						h.SrcHierarchyID = i.SrcHierarchyID
					inner join #HierarchyNodes srcNode on
						srcNode.SrcHierarchyNodeID = i.SrcHierarchyNodeID
						and srcNode.SrcHierarchyID = i.SrcHierarchyID
					left join #HierarchyNodes parentNode on
						parentNode.SrcHierarchyNodeID = srcNode.SrcParentHierarchyNodeID
						and parentNode.SrcHierarchyID = srcNode.SrcHierarchyID
				
					left join #HierarchyDimensionPartTypes hdp on
						hdp.SrcHierarchyID = srcNode.SrcHierarchyID
						and hdp.SrcDimensionPartTypeID =srcNode.SrcDimensionPartTypeID

					left join app.HierarchyNodeImportMap map on
						map.SrcHierarchyID = srcNode.SrcHierarchyID
						and map.SrcHierarchyNodeID = srcNode.SrcHierarchyNodeID
						and map.HierarchyID = h.HierarchyID

					left join app.HierarchyNode tgtExists on
						tgtExists.HierarchyNodeID = map.SrcHierarchyNodeID
			where
				i.InsertNr = @InsertNr
			select @NewHierarchyNodeID = scope_identity()
			
			select @NewHierarchyNodeID

			insert into app.HierarchyNodeAttribute
			(
				HierarchyNodeID 
				,HierarchyNodeAttributeTypeID
				,ValueInt
				,ValueStr
			)
			select
				HierarchyNodeID = @NewHierarchyNodeID
				,HierarchyNodeAttributeTypeID = t.HierarchyNodeAttributeTypeID
				,ValueInt = a.ValueInt
				,ValueStr = a.ValueStr
				
			from
				#HierarchyNodeInsertOrder i
					inner join #HierarchyNodeAttributes a on	
						a.SrcHierarchyID = i.SrcHierarchyID
						and a.SrcHierarchyNodeID = i.SrcHierarchyNodeID
					inner join #HierarchyNodeAttributeTypes t on
						t.SrcHierarchyID = i.SrcHierarchyID
						and t.SrcHierarchyNodeAttributeTypeID = a.SrcHierarchyNodeAttributeTypeID
				
			where
				i.InsertNr = @InsertNr

			
			insert into app.HierarchyNodeLanguage
			(
				HierarchyNodeID 
				,LanguageID
				,LangExpression
			)
			select
				HierarchyNodeID = @NewHierarchyNodeID
				,LanguageID = t.LanguageID
				,LangExpression = l.LangExpression
				
			from
				#HierarchyNodeInsertOrder i
					inner join #HierarchyNodeLanguages l on	
						l.SrcHierarchyID = i.SrcHierarchyID
						and l.SrcHierarchyNodeID = i.SrcHierarchyNodeID
					inner join #HierarchyLanguages t on
						t.SrcHierarchyID = i.SrcHierarchyID
						and t.SrcLanguageID = l.SrcLanguageID
				
			where
				i.InsertNr = @InsertNr
			
			


			update srcNode set
				HierarchyNodeID = @NewHierarchyNodeID
			from
				#HierarchyNodeInsertOrder i
					inner join #HierarchyNodes srcNode on
						srcNode.SrcHierarchyNodeID = i.SrcHierarchyNodeID
			where
				i.InsertNr = @InsertNr


			

			select @InsertNr = MIN(InsertNr) from #HierarchyNodeInsertOrder where InsertNr > @InsertNr
		end

	set identity_insert app.HierarchyNode off


	delete from app.HierarchyNodeImportMap where HierarchyID in (select HierarchyID from #Hierarchy)
	insert into app.HierarchyNodeImportMap
	(
		SrcHierarchyID
		,SrcHierarchyNodeID
		,HierarchyID
		,HierarchyNodeID
	)
	select
		SrcHierarchyID = n.SrcHierarchyID
		,SrcHierarchyNodeID = n.SrcHierarchyNodeID
		,HierarchyID = h.HierarchyID
		,HierarchyNodeID = n.HierarchyNodeID
	from
		#HierarchyNodes n
			inner join #Hierarchy h on
				h.SrcHierarchyID = n.SrcHierarchyID
	
	
	select
		*
	from 
		#Hierarchy


	drop table #Hierarchy
	drop table #HierarchyDimensionPartTypes
	drop table #HierarchyExtraColumns
	drop table #HierarchyNodeAttributes
	drop table #HierarchyNodeAttributeTypes
	drop table #HierarchyNodes
	drop table #HierarchyOptions

	drop table #HierarchyNodeInsertOrder
	drop table #HierarchyLanguages
	drop table #HierarchyNodeLanguages
	if @TranCount = 0 commit tran
end try
begin catch
	if @TranCount = 0 and @@trancount > 0 rollback tran
	exec app.ReThrowError
end catch
GO
