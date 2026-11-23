SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [app].[Support_Insikt_AddFCTypeConfiguration]
(
	@INSIKT_SYS nvarchar(max)
	,@FCTypeData xml
	,@AnalysisServerName nvarchar(max) = null
    ,@DWServerName nvarchar(max) = null
	,@MinInsiktVersion varchar(9) = null
)
as
declare @TranCount int
set @TranCount = @@TRANCOUNT

begin try

if @TranCount = 0 begin tran

	if @FCTypeData is null
	raiserror('@FCTypeData får inte vara null. Använd app.Support_Insikt_ExportFCTypeConfiguration för att export FCType-konfigurationer till XML.', 16, 10)

	declare @InsiktVer nvarchar(9)
	declare @DynSQL nvarchar(max), @DynSQL_Params nvarchar(max)
	select 
		@DynSQL = N'
			select
				@InsiktVer = 
					right(''00'' + ver1.Item, 2)
					+ ''.'' + right(''00'' + ver2.Item, 2)
					+ ''.'' + right(''000'' + ver3.Item, 3)
			from
				' + @INSIKT_SYS + N'.dbo.DatabaseVersion ver
					cross apply app.Split(ver.Version, ''.'') ver1
					cross apply app.Split(ver.Version, ''.'') ver2
					cross apply app.Split(ver.Version, ''.'') ver3
			where
				ver.IsCurrent = 1
				and ver1.ListPos = 1
				and ver2.ListPos = 2
				and ver3.ListPos = 3'
		,@DynSQL_Params = '@InsiktVer nvarchar(9) output'
	exec sp_executesql 
		@DynSQL
		,@DynSQL_Params
		,@InsiktVer output

	set @MinInsiktVersion = 
		right('00' + parsename(@MinInsiktVersion,3), 2)
		+ '.' + RIGHT('00' + parsename(@MinInsiktVersion, 2), 2)
		+ '.' + RIGHT('000' + parsename(@MinInsiktVersion, 1), 3)
    if @InsiktVer < '12.01.001'
		raiserror('Versionen av INSIKT är för gammal för denna procedur, uppgradera till minst 12.1.', 16, 10, @MinInsiktVersion, @InsiktVer)
	if @InsiktVer < @MinInsiktVersion	
		raiserror('Versionen av INSIKT är för gammal. Som minst krävs %s och just nu är version %s installerad.', 16, 10, @MinInsiktVersion, @InsiktVer)

	create table #FCType
	(
		[SourceFCTypeID] int not null primary key,
		[FCTypeID] [int],
		[Description] [nvarchar](max),
		[Caption] [varchar](max),
		[FCTypeTypeID] [int],
		[IsActive] [bit]
	)


    insert into #FCType
	(
		[SourceFCTypeID]
        ,[FCTypeID]
		,[Description]
        ,[Caption]
        ,[FCTypeTypeID]
		,[IsActive]
	)
    select
        [SourceFCTypeID] = fcType.c.value('./@ID[1]', 'int')
        ,[FCTypeID] = null
		,[Description] = fcType.c.value('./@Description[1]', 'nvarchar(max)')
        ,[Caption] = fcType.c.value('./@Caption[1]', 'nvarchar(max)')		
        ,[FCTypeTypeID] = fcType.c.value('./@FCTypeTypeID[1]', 'int')
		,[IsActive] = fcType.c.value('./@IsActive[1]', 'bit')
 
    from
        @FCTypeData.nodes('/FCType') fcType(c)
           

	 
	--exec 
	--(
	--	'
	--	update srcFCType set
	--		FCTypeID = tgtFCType.ID
	--	from
	--		' + @INSIKT_SYS + '.dbo.FCType tgtFCType
	--			inner join #FCType srcFCType on
	--				srcFCType.Caption = tgtFCType.Caption
	--	'
	--)
	
	--exec ('select * from ' + @INSIKT_SYS + '.dbo.FCType ')
	--select * from #FCType
	exec
	(
		'
		declare @MaxFCTypeID int
		select @MaxFCTypeID = isnull(max(ID), 0) from ' + @INSIKT_SYS + '.dbo.FCType
		INSERT INTO ' + @INSIKT_SYS + '.[dbo].[FCType]
		(
			[ID]
			,[Description]
			,[Caption]
			,[FCTypeTypeID]
			,[IsActive]
		)
		select
			[ID] = @MaxFCTypeID + row_number() over (order by t.SourceFCTypeID)
			,[Description] = isnull(t.[Description], t.[Caption])
			,[Caption] = isnull(t.[Caption], t.[Description])
			,[FCTypeTypeID] = t.[FCTypeTypeID]
			,[IsActive] = isnull(t.[IsActive], 1)
		From
			#FCType t
		;with TgtFCTypeID as
		(
			select
				SourceFCTypeID = t.SourceFCTypeID
				,FCTypeID = @MaxFCTypeID + row_number() over (order by t.SourceFCTypeID)
			from
				#FCType t
		)
		update t set
			FCTypeID = tgt.FCTypeID
		from
			#FCType t
				inner join TgtFCTypeID tgt on
					tgt.SourceFCTypeID = t.SourceFCTypeID
		'
	)

	--exec ('select * from ' + @INSIKT_SYS + '.dbo.FCType ')
	--select * from #FCType

	
	CREATE TABLE #DataSourceConnection
	(
		[SourceDataSourceConnectionID] [int] not null primary key,
		[DataSourceConnectionID] [int] NULL,
		[Server] [nvarchar](max) NOT NULL,
		[Database] [nvarchar](max) NOT NULL,
		[IsDeleted] [bit] NULL,
	)
	insert into #DataSourceConnection
	(
		[SourceDataSourceConnectionID]
        ,[DataSourceConnectionID]
		,[Server]
        ,[Database]
		,[IsDeleted]
	)
	select distinct
        [SourceDataSourceConnectionID] = conn.c.value('./@ID[1]', 'int')
        ,[DataSourceConnectionID] = null
		,[Server] = conn.c.value('./@Server[1]', 'nvarchar(max)')
        ,[Database] = conn.c.value('./@Database[1]', 'nvarchar(max)')
		,[IsDeleted] = conn.c.value('./@IsDeleted[1]', 'bit')
    from
        @FCTypeData.nodes('/FCType/DataSourceConnections/DataSourceConnection') conn(c)


	create table #ChangeServerName
    (
        AnalysisServerName nvarchar(max) null
        ,DWServerName nvarchar(max) null
    )
 
    insert into #ChangeServerName
    values(@AnalysisServerName, @DWServerName)
 

	exec 
	(
		'
        declare @AnalysisServerName nvarchar(max) = (select AnalysisServerName from #ChangeServerName)
         
        insert into ' + @INSIKT_SYS + '.dbo.DataSourceConnection
        (
            [Server]
            ,[Database]
            ,[IsDeleted]
        )
        select
            [Server] = isnull(@AnalysisServerName, src.[Server])
            ,[Database] = src.[Database]
            ,[IsDeleted] = isnull(src.[IsDeleted], 0)
        from
            #DataSourceConnection src
 
                left join ' + @INSIKT_SYS + '.dbo.DataSourceConnection tgt on
                    tgt.[Server] =  isnull(@AnalysisServerName, src.[Server])
                    and tgt.[Database] = src.[Database]
                 
        where
            tgt.ID is null
 
 
        update src set
            [DataSourceConnectionID] = tgt.ID
        from
            ' + @INSIKT_SYS + '.dbo.DataSourceConnection tgt
                inner join #DataSourceConnection src on
                    tgt.[Server] = isnull(@AnalysisServerName, src.[Server])
                    and tgt.[Database] = src.[Database]
 
        '
	)



	create table #DataSources
	(
		[SourceDataSourceID] [int] NOT NULL primary key,
		[SourceDataSourceConnectionID] [int] NOT NULL,
		[DataSourceID] [int] NULL,
		[Name] [varchar](max) NOT NULL,
		[Description] [nvarchar](max) NULL,
		[SourceCube] [nvarchar](max) NULL,
		[MainTimeDim] [nvarchar](50) NULL,
		[DTDQuery] [nvarchar](max) NULL,
		[DWServer] [nvarchar](max) NULL,
		[DWDatabase] [nvarchar](max) NULL,
		[AdminUser] [nvarchar](max) NULL,
		[AdminPassword] [nvarchar](max) NULL,
		[AllowDynamicFilter] [bit] NULL,
		[DynamicFilterDefault] [bit] NULL,
		[ReverseYearsInTimeDims] [bit] NULL,
		[DTDMethodID] [int] NULL,
		[OrderDimensionsAlphabetically] [bit] NULL,
		[IsDeleted] [bit] NULL,
		[AvailableInAnalysis] [bit] NULL,
		[DataSourceConnectionID] [int] NOT NULL,
		[IsDefault] [bit] NULL
	)
	insert into #DataSources
	(
		[SourceDataSourceID],
		[SourceDataSourceConnectionID],
		[DataSourceID],
		[Name],
		[Description],
		[SourceCube],
		[MainTimeDim],
		[DTDQuery],
		[DWServer],
		[DWDatabase],
		[AdminUser],
		[AdminPassword],
		[AllowDynamicFilter],
		[DynamicFilterDefault],
		[ReverseYearsInTimeDims],
		[DTDMethodID],
		[OrderDimensionsAlphabetically],
		[IsDeleted],
		[AvailableInAnalysis],
		[DataSourceConnectionID],
		[IsDefault]
	)
	select distinct
		[SourceDataSourceID] = ds.c.value('./@ID[1]', 'int')
		,[SourceDataSourceConnectionID] = ds.c.value('./@DataSourceConnectionID[1]', 'int')
		,[DataSourceID] = null
		,[Name] = ds.c.value('./@Name[1]', 'nvarchar(max)')
		,[Description] = ds.c.value('./@Description[1]', 'nvarchar(max)')
		,[SourceCube] = ds.c.value('./@SourceCube[1]', 'nvarchar(max)')
		,[MainTimeDim] = ds.c.value('./@MainTimeDim[1]', 'nvarchar(max)')
		,[DTDQuery] = ds.c.value('./@DTDQuery[1]', 'nvarchar(max)')
		,[DWServer] = ds.c.value('./@DWServer[1]', 'nvarchar(max)')
		,[DWDatabase] = ds.c.value('./@DWDatabase[1]', 'nvarchar(max)')
		,[AdminUser] = ds.c.value('./@AdminUser[1]', 'nvarchar(max)')
		,[AdminPassword] = ds.c.value('./@AdminPassword[1]', 'nvarchar(max)')
		,[AllowDynamicFilter] = ds.c.value('./@AllowDynamicFilter[1]', 'bit')
		,[DynamicFilterDefault] = ds.c.value('./@DynamicFilterDefault[1]', 'bit')
		,[ReverseYearsInTimeDims] = ds.c.value('./@ReverseYearsInTimeDims[1]', 'bit')
		,[DTDMethodID] = isnull(ds.c.value('./@DTDMethodID[1]', 'int'), 1)
		,[OrderDimensionsAlphabetically] = isnull(ds.c.value('./@OrderDimensionsAlphabetically[1]', 'bit'), 1)
		,[IsDeleted] = isnull(ds.c.value('./@IsDeleted[1]', 'bit'), 0)
		,[AvailableInAnalysis] = isnull(ds.c.value('./@AvailableInAnalysis[1]', 'bit'), 0)
		,[DataSourceConnectionID] = tgtConn.DataSourceConnectionID
		,[IsDefault] = isnull(ds.c.value('./@IsDefault[1]', 'bit'), 0)
    from
        @FCTypeData.nodes('/FCType/DataSources/DataSource') ds(c)
			left join #DataSourceConnection tgtConn on
				tgtConn.SourceDataSourceConnectionID = ds.c.value('./@DataSourceConnectionID[1]', 'int')


	exec 
	(
		'
        declare @DWServerName nvarchar(max) = (select DWServerName from #ChangeServerName)
         
 
        insert into ' + @INSIKT_SYS + '.dbo.[DataSources]
        (
            [Name]
            ,[Description]
            ,[SourceCube]
            ,[MainTimeDim]
            ,[DTDQuery]
            ,[DWServer]
            ,[DWDatabase]
            ,[AdminUser]
            ,[AdminPassword]
            ,[AllowDynamicFilter]
            ,[DynamicFilterDefault]
            ,[ReverseYearsInTimeDims]
            ,[DTDMethodID]
            ,[OrderDimensionsAlphabetically]
            ,[IsDeleted]
            ,[AvailableInAnalysis]
            ,[DataSourceConnectionID]
            ,[IsDefault]
        )
        select
            [Name] = src.[Name]
            ,[Description] = src.[Description]
            ,[SourceCube] = src.[SourceCube]
            ,[MainTimeDim] = src.[MainTimeDim]
            ,[DTDQuery] = src.[DTDQuery]
            ,[DWServer] = isnull(@DWServerName, src.[DWServer])
            ,[DWDatabase] = src.[DWDatabase]
            ,[AdminUser] = src.[AdminUser]
            ,[AdminPassword] = src.[AdminPassword]
            ,[AllowDynamicFilter] = src.[AllowDynamicFilter]
            ,[DynamicFilterDefault] = src.[DynamicFilterDefault]
            ,[ReverseYearsInTimeDims] = src.[ReverseYearsInTimeDims]
            ,[DTDMethodID] = src.[DTDMethodID]
            ,[OrderDimensionsAlphabetically] = src.[OrderDimensionsAlphabetically]
            ,[IsDeleted] = src.[IsDeleted]
            ,[AvailableInAnalysis] = src.[AvailableInAnalysis]
            ,[DataSourceConnectionID] = src.[DataSourceConnectionID]
            ,[IsDefault] = src.[IsDefault]
        from
            #DataSources src
                left join ' + @INSIKT_SYS + '.dbo.DataSources tgt on
                    tgt.[Name] = src.[Name]
                    and tgt.[SourceCube] = src.[SourceCube]
                    and tgt.[DataSourceConnectionID] = src.[DataSourceConnectionID]
                 
        where
            tgt.ID is null
 
 
        update src set
            [DataSourceID] = tgt.ID
        from
            #DataSources src
                inner join ' + @INSIKT_SYS + '.dbo.DataSources tgt on
                    tgt.[Name] = src.[Name]
                    and tgt.[SourceCube] = src.[SourceCube]
                    and tgt.[DataSourceConnectionID] = src.[DataSourceConnectionID]
 
        '
	)

	create table #FCTypeDataSourceRelation
	(
		[SourceFCTypeDataSourceRelationID] [int] NOT NULL,
		[SourceFCTypeID] [int] NOT NULL,
		[SourceDataSourceID] [int] NOT NULL,
		[FCTypeDataSourceRelationID] [int] ,
		[FCTypeID] [int] NOT NULL,
		[CompanyID] [int] NOT NULL,
		[DataSourceID] [int] NOT NULL,
	)
	insert into #FCTypeDataSourceRelation
	(
		[SourceFCTypeDataSourceRelationID],
		[SourceFCTypeID],
		[SourceDataSourceID],
		[FCTypeDataSourceRelationID],
		[FCTypeID],
		[CompanyID],
		[DataSourceID]
	)
	select
        [SourceFCTypeDataSourceRelationID] = conn.c.value('./@ID[1]', 'int')
        ,[SourceFCTypeID] =  conn.c.value('./@FCTypeID[1]', 'int')
        ,[SourceDataSourceID] =  conn.c.value('./@DataSourceID[1]', 'int')
		,[FCTypeDataSourceRelationID] = null
        ,[FCTypeID] = fcType.FCTypeID
		,[CompanyID] = conn.c.value('./@CompanyID[1]', 'int')
		,[DataSourceID] = ds.DataSourceID
    from
        @FCTypeData.nodes('/FCType/FCTypeDataSourceRelations/FCTypeDataSourceRelation') conn(c)
			inner join #FCType fcType on
				fcType.SourceFCTypeID = conn.c.value('./@FCTypeID[1]', 'int')
			inner join #DataSources ds on
				ds.SourceDataSourceID =  conn.c.value('./@DataSourceID[1]', 'int')

	exec
	(
		'
		INSERT INTO ' + @INSIKT_SYS + '.[dbo].[FCTypeDataSourceRelation]
		(
			[FCTypeID]
			,[CompanyID]
			,[DataSourceID]
		)
		select
			[FCTypeID]
			,[CompanyID]
			,[DataSourceID]
		from
			#FCTypeDataSourceRelation

		update src set
			[FCTypeDataSourceRelationID] = tgt.ID
		from
			#FCTypeDataSourceRelation src
				inner join ' + @INSIKT_SYS + '.dbo.FCTypeDataSourceRelation tgt on
					tgt.[FCTypeID] = src.[FCTypeID]
					and tgt.[CompanyID] = src.[CompanyID]
					and tgt.[DataSourceID] = src.[DataSourceID]
		'
	)


	

	CREATE TABLE #FCElement
	(
		[SourceFCElementID] [int] NOT NULL primary key,
		[SourceDataSourceID] [int] NOT NULL,
		
		[FCElementID] [int],
		[Name] nvarchar(max) NOT NULL,
		[Description] [nvarchar](max) NULL,
		[isDimension] [bit] NULL,
		[CompanyID] [int] NOT NULL,
		[DataSourceID] [int] NULL
	)
	insert into #FCElement
	select distinct
        [SourceFCElementID] = conn.c.value('./@ID[1]', 'int')
        ,[SourceDataSourceID] =  conn.c.value('./@DataSourceID[1]', 'int')
        ,[FCElementID] = null
		,[Name] = conn.c.value('./@Name[1]', 'nvarchar(max)')
        ,[Description] = conn.c.value('./@Description[1]', 'nvarchar(max)')
		,[isDimension] = conn.c.value('./@isDimension[1]', 'bit')
		,[CompanyID] = conn.c.value('./@CompanyID[1]', 'int')
		
		,[DataSourceID] = ds.DataSourceID
    from
        @FCTypeData.nodes('/FCType/FCElements/FCElement') conn(c)
			inner join #DataSources ds on
				ds.SourceDataSourceID =  conn.c.value('./@DataSourceID[1]', 'int')


	exec 
	(
		'
		insert into ' + @INSIKT_SYS + '.dbo.FCElement
		(
			[Name]
			,[Description]
			,[isDimension]
			,[CompanyID]
			,[DataSourceID]
		)
		select
			[Name] = src.[Name]
			,[Description] = src.[Description]
			,[isDimension] = isnull(src.[isDimension], 1)
			,[CompanyID] = src.[CompanyID]
			,[DataSourceID] = src.[DataSourceID]
		from
			#FCElement src
				left join ' + @INSIKT_SYS + '.dbo.FCElement tgt on
					tgt.[Name] = src.[Name]
					and tgt.[CompanyID] = src.[CompanyID]
					and tgt.[DataSourceID] = src.[DataSourceID]
		where
			tgt.ID is null


		update src set
			[FCElementID] = tgt.ID
		from
			#FCElement src
				inner join ' + @INSIKT_SYS + '.dbo.FCElement tgt on
					tgt.[Name] = src.[Name]
					and tgt.[CompanyID] = src.[CompanyID]
					and tgt.[DataSourceID] = src.[DataSourceID]

		'
	)

	


	CREATE TABLE #FCView
	(
		[SourceFCViewID] [int] NOT NULL primary key,
		FCViewID int null,
		[Name] [nvarchar](max) NULL,
		[FCTypeID] [int] NOT NULL,
		[CompanyID] [int] NOT NULL,
		[Description] [nvarchar](max) NULL,
		[HideEmpty] [bit]  NULL,
		[HideEmptyObligatory] [bit] NULL,
		[ReadOnly] [bit]  NULL,
		[ShowRowSum] [bit]  NULL,
		[ShowColumnSum] [bit]  NULL,
		[EnableGroupingCellWrite] [bit]  NULL,
		[GroupingCellDistributionOptionId] [int] NULL,
		[TransactionModeID] [int]  NULL,
		[ShowTransactionIcon] [bit]  NULL,
		[ShowTransactionDashboardButton] [bit]  NULL,
	)
	insert into #FCView
	(
		[SourceFCViewID]
		,[FCViewID]
		,[Name]
		,[FCTypeID]
		,[CompanyID]
		,[Description]
		,[HideEmpty]
		,[HideEmptyObligatory]
		,[ReadOnly]
		,[ShowRowSum]
		,[ShowColumnSum]
		,[EnableGroupingCellWrite]
		,[GroupingCellDistributionOptionId]
		,[TransactionModeID]
		,[ShowTransactionIcon]
		,[ShowTransactionDashboardButton]
	)
	select
		[SourceFCViewID] = n.c.value('./@ID[1]', 'int')
		,[FCViewID] = null
		,[Name] = n.c.value('./@Name[1]', 'nvarchar(max)')
		,[FCTypeID] = t.FCTypeID
		,[CompanyID] = n.c.value('./@CompanyID[1]', 'int')
		,[Description] = n.c.value('./@Description[1]', 'nvarchar(max)')
		,[HideEmpty] = isnull(n.c.value('./@HideEmpty[1]', 'bit'), 0)
		,[HideEmptyObligatory] = isnull(n.c.value('./@HideEmptyObligatory[1]', 'bit'), 0)
		,[ReadOnly] = isnull(n.c.value('./@ReadOnly[1]', 'bit'), 0)
		,[ShowRowSum] = isnull(n.c.value('./@ShowRowSum[1]', 'bit'), 0)
		,[ShowColumnSum] = isnull(n.c.value('./@ShowColumnSum[1]', 'bit'), 0)
		,[EnableGroupingCellWrite] = isnull(n.c.value('./@EnableGroupingCellWrite[1]', 'bit'), 0)
		,[GroupingCellDistributionOptionId] = n.c.value('./@GroupingCellDistributionOptionId[1]', 'int')
		,[TransactionModeID] = isnull(n.c.value('./@TransactionModeID[1]', 'int'), 1)
		,[ShowTransactionIcon] = isnull(n.c.value('./@ShowTransactionIcon[1]', 'bit'), 1)
		,[ShowTransactionDashboardButton] = isnull(n.c.value('./@ShowTransactionDashboardButton[1]', 'bit'), 1)
	from
		@FCTypeData.nodes('/FCType/FCViews/FCView') n(c)
			inner join #FCType t on
				t.SourceFCTypeID = n.c.value('./@FCTypeID[1]', 'int')

	exec
	(
		'
		INSERT INTO ' + @INSIKT_SYS + '.[dbo].[FCView]
		(
			[Name]
			,[FCTypeID]
			,[CompanyID]
			,[Description]
			,[HideEmpty]
			,[HideEmptyObligatory]
			,[ReadOnly]
			,[ShowRowSum]
			,[ShowColumnSum]
			,[EnableGroupingCellWrite]
			,[GroupingCellDistributionOptionId]
			,[TransactionModeID]
			,[ShowTransactionIcon]
			,[ShowTransactionDashboardButton]
		)
		select
			[Name]
			,[FCTypeID]
			,[CompanyID]
			,[Description]
			,[HideEmpty]
			,[HideEmptyObligatory]
			,[ReadOnly]
			,[ShowRowSum]
			,[ShowColumnSum]
			,[EnableGroupingCellWrite]
			,[GroupingCellDistributionOptionId]
			,[TransactionModeID]
			,[ShowTransactionIcon]
			,[ShowTransactionDashboardButton]
		from
			#FCView src

		
		
		update src set
			[FCViewID] = tgt.ID
		from
			#FCView src
				inner join ' + @INSIKT_SYS + '.dbo.FCView tgt on
					tgt.[Name] = src.[Name]
					and tgt.[FCTypeID] = src.[FCTypeID]
					and tgt.CompanyID = src.CompanyID
		'
	)
	



	CREATE TABLE #FCViewDimension
	(
		[SourceFCViewDimensionID] [int] NOT NULL primary key,
		FCViewDimensionID int,
		[FCViewID] [int] NOT NULL,
		[DimensionName] [nvarchar](max) NOT NULL,
		[PlacementTypeID] [int] NOT NULL,
		[PlacementSortOrder] [int] NULL,
		[DefaultMember] [nvarchar](500) NULL,
		[DefaultWriteMember] [nvarchar](max) NULL,
		[ModeTypeID] [int] NULL,
		[OnlyLeaves] [bit] NULL,
		[IncludeCalculationMembers] [bit] NULL,
		[SortAlphabetically] [bit] NULL,
		[PreExpanded] [bit] NULL,
		[PreDrillStopLevel] [int] NULL,
		[NonEmptyFilterMember] [nvarchar](max) NULL,
		[DoNotFilterOnQuery] [bit] NULL
	)
	insert into #FCViewDimension
	(
		[SourceFCViewDimensionID]
		,[FCViewDimensionID]
		,[FCViewID]
		,[DimensionName]
		,[PlacementTypeID]
		,[PlacementSortOrder]
		,[DefaultMember]
		,[DefaultWriteMember]
		,[ModeTypeID]
		,[OnlyLeaves]
		,[IncludeCalculationMembers]
		,[SortAlphabetically]
		,[PreExpanded]
		,[PreDrillStopLevel]
		,[NonEmptyFilterMember]
		,[DoNotFilterOnQuery]
	)
	select
		[SourceFCViewDimensionID] = n.c.value('./@ID[1]', 'int')
		,[FCViewDimensionID] =null
		,[FCViewID] = v.FCViewID
		,[DimensionName] = n.c.value('./@DimensionName[1]', 'nvarchar(max)')
		,[PlacementTypeID] = n.c.value('./@PlacementTypeID[1]', 'int')
		,[PlacementSortOrder] = n.c.value('./@PlacementSortOrder[1]', 'int')
		,[DefaultMember] = n.c.value('./@DefaultMember[1]', 'nvarchar(max)')
		,[DefaultWriteMember] = n.c.value('./@DefaultWriteMember[1]', 'nvarchar(max)')
		,[ModeTypeID] = n.c.value('./@ModeTypeID[1]', 'int')
		,[OnlyLeaves] = n.c.value('./@OnlyLeaves[1]', 'bit')
		,[IncludeCalculationMembers] = n.c.value('./@IncludeCalculationMembers[1]', 'int')
		,[SortAlphabetically] = n.c.value('./@SortAlphabetically[1]', 'int')
		,[PreExpanded] = n.c.value('./@PreExpanded[1]', 'int')
		,[PreDrillStopLevel] = n.c.value('./@PreDrillStopLevel[1]', 'int')
		,[NonEmptyFilterMember] = n.c.value('./@NonEmptyFilterMember[1]', 'nvarchar(max)')
		,[DoNotFilterOnQuery] = n.c.value('./@DoNotFilterOnQuery[1]', 'bit')	
	from
		@FCTypeData.nodes('/FCType/FCViews/FCView/FCViewDimensions/FCViewDimension') n(c)
			inner join #FCView v on
				v.SourceFCViewID = n.c.value('./@FCViewID[1]', 'int')


	exec
	(
		'
		INSERT INTO ' + @INSIKT_SYS + '.[dbo].[FCViewDimension]
		(
			[FCViewID]
			,[DimensionName]
			,[PlacementTypeID]
			,[PlacementSortOrder]
			,[DefaultMember]
			,[DefaultWriteMember]
			,[ModeTypeID]
			,[OnlyLeaves]
			,[IncludeCalculationMembers]
			,[SortAlphabetically]
			,[PreExpanded]
			,[PreDrillStopLevel]
			,[NonEmptyFilterMember]
			,[DoNotFilterOnQuery]
		)
		select
			[FCViewID]
			,[DimensionName]
			,[PlacementTypeID]
			,[PlacementSortOrder]
			,[DefaultMember]
			,[DefaultWriteMember]
			,[ModeTypeID]
			,[OnlyLeaves]
			,[IncludeCalculationMembers]
			,[SortAlphabetically]
			,[PreExpanded]
			,[PreDrillStopLevel]
			,[NonEmptyFilterMember]
			,[DoNotFilterOnQuery]
		from
			#FCViewDimension src

		
		
		update src set
			[FCViewDimensionID] = tgt.ID
		from
			#FCViewDimension src
				inner join ' + @INSIKT_SYS + '.dbo.FCViewDimension tgt on
					tgt.[FCViewID] = src.[FCViewID]
					and tgt.[DimensionName] = src.[DimensionName]
		'
	)



	create table #FCViewNonEmptyMember
	(
		[SourceFCViewNonEmptyMemberID] [int] NOT NULL primary key,
		FCViewNonEmptyMemberID int,
		[FCViewID] [int] NOT NULL,
		[UniqueName] [nvarchar](500) NOT NULL,
		[NonEmptyHint] [varchar](500) NULL,
		[NonZeroLimit] [float] NULL,
		[Obligatory] [bit] NOT NULL,
		[Level] [int] NOT NULL,
	 )
	 insert into #FCViewNonEmptyMember
	 (
		[SourceFCViewNonEmptyMemberID]
		,[FCViewID]
		,[UniqueName]
		,[NonEmptyHint]
		,[NonZeroLimit]
		,[Obligatory]
		,[Level]
	 )
	 select
		[SourceFCViewNonEmptyMemberID] = n.c.value('./@ID[1]', 'int')
		,[FCViewID] = v.FCViewID
		,[UniqueName] = n.c.value('./@UniqueName[1]', 'nvarchar(max)')
		,[NonEmptyHint] = n.c.value('./@NonEmptyHint[1]', 'nvarchar(max)')
		,[NonZeroLimit] = n.c.value('./@NonZeroLimit[1]', 'float')
		,[Obligatory] = n.c.value('./@Obligatory[1]', 'bit')
		,[Level] = n.c.value('./@Level[1]', 'int')
	from
		@FCTypeData.nodes('/FCType/FCViews/FCView/FCViewNonEmptyMembers/FCViewNonEmptyMember') n(c)
			inner join #FCView v on
				v.SourceFCViewID = n.c.value('./@FCViewID[1]', 'int')

	exec
	(
		'
		INSERT INTO ' + @INSIKT_SYS + '.[dbo].[FCViewNonEmptyMember]
		(
			[FCViewID]
			,[UniqueName]
			,[NonEmptyHint]
			,[NonZeroLimit]
			,[Obligatory]
			,[Level]
		)
		select
			[FCViewID]
			,[UniqueName]
			,[NonEmptyHint]
			,[NonZeroLimit]
			,[Obligatory]
			,[Level]
		from
			#FCViewNonEmptyMember src

		
		
		update src set
			[FCViewNonEmptyMemberID] = tgt.ID
		from
			#FCViewNonEmptyMember src
				inner join ' + @INSIKT_SYS + '.dbo.FCViewNonEmptyMember tgt on
					tgt.[FCViewID] = src.[FCViewID]
					and tgt.[UniqueName] = src.[UniqueName]
		'
	)

	CREATE TABLE #FCColumns
	(
		[SourceFCColumnID] [int] NOT NULL,
		[FCColumnID] int,
		[UniqueName] [nvarchar](max) NOT NULL,
		[Caption] [varchar](max) NULL,
		[Order] [int] NULL,
		[Writable] [bit] NOT NULL,
		[WritabilityProperty] [nvarchar](max) NULL,
		[WritabilityMeasure] [nvarchar](max) NULL,
		[Author] [nvarchar](max) NULL,
		[CompanyID] [int] NOT NULL,
		[FCTypeID] [int] NOT NULL,
		[MDX] [nvarchar](max) NULL,
		[FCProcessDimUniqueName] [nvarchar](max) NULL,
		[DTDCustomQuery] [nvarchar](max) NULL,
		[PeriodicDistributable] [bit] NOT NULL,
		[AggregateValues] [bit] NOT NULL,
		[DisableDirectInput] [bit] NOT NULL,
		[Tooltip] [nvarchar](max) NULL,
		[ReplaceByYear] [bit] NOT NULL,
		[IsHidden] [bit] NOT NULL,
		[CommentsAreMandatory] [bit] NOT NULL,
		[IsUnitPrice] [bit] NOT NULL,
		[IsDynamic] [bit] NOT NULL,
		[FilterMeasure] nvarchar(max) NULL,
		[IgnoreLockedPeriods] [bit] NOT NULL,
		[PeriodsOffset] [int] NOT NULL,
		[HidePeriodicDistributionTotal] [bit] NOT NULL,
		[DefaultValueMeasure] [nvarchar](max) NULL,
		[CommentTemplate] [nvarchar](max) NULL
	)
	insert into #FCColumns
	(
		[SourceFCColumnID]
		,[FCColumnID]
		,[UniqueName]
		,[Caption]
		,[Order]
		,[Writable]
		,[WritabilityProperty]
		,[WritabilityMeasure]
		,[Author]
		,[CompanyID]
		,[FCTypeID]
		,[MDX]
		,[FCProcessDimUniqueName]
		,[DTDCustomQuery]
		,[PeriodicDistributable]
		,[AggregateValues]
		,[DisableDirectInput]
		,[Tooltip]
		,[ReplaceByYear]
		,[IsHidden]
		,[CommentsAreMandatory]
		,[IsUnitPrice]
		,[IsDynamic]
		,[FilterMeasure]
		,[IgnoreLockedPeriods]
		,[PeriodsOffset]
		,[HidePeriodicDistributionTotal]
		,[DefaultValueMeasure]
		,[CommentTemplate]
	)
	select
		[SourceFCColumns] = n.c.value('./@ID[1]', 'int')
		,[FCColumnID] = null
		,[UniqueName] = n.c.value('./@UniqueName[1]', 'nvarchar(max)')
		,[Caption] = n.c.value('./@Caption[1]', 'nvarchar(max)')
		,[Order] = n.c.value('./@Order[1]', 'int')
		,[Writable] = isnull(n.c.value('./@Writable[1]', 'bit'), 0)
		,[WritabilityProperty] = n.c.value('./@WritabilityProperty[1]', 'nvarchar(max)')
		,[WritabilityMeasure] = n.c.value('./@WritabilityMeasure[1]', 'nvarchar(max)')
		,[Author] = n.c.value('./@Author[1]', 'nvarchar(max)')
		,[CompanyID] = n.c.value('./@CompanyID[1]', 'int')
		,[FCTypeID] = t.FCTypeID
		,[MDX] = n.c.value('./@MDX[1]', 'nvarchar(max)')
		,[FCProcessDimUniqueName] = n.c.value('./@FCProcessDimUniqueName[1]', 'nvarchar(max)')
		,[DTDCustomQuery] = n.c.value('./@DTDCustomQuery[1]', 'nvarchar(max)')
		,[PeriodicDistributable] = isnull(n.c.value('./@PeriodicDistributable[1]', 'bit'), 0)
		,[AggregateValues] = isnull(n.c.value('./@AggregateValues[1]', 'bit'), 1)
		,[DisableDirectInput] = isnull(n.c.value('./@DisableDirectInput[1]', 'bit'), 0)
		,[Tooltip] = n.c.value('./@Tooltip[1]', 'nvarchar(max)')
		,[ReplaceByYear] = isnull(n.c.value('./@ReplaceByYear[1]', 'bit'), 0)
		,[IsHidden] = isnull(n.c.value('./@IsHidden[1]', 'bit'), 0)
		,[CommentsAreMandatory] = isnull(n.c.value('./@CommentsAreMandatory[1]', 'bit'), 0)
		,[IsUnitPrice] = isnull(n.c.value('./@IsUnitPrice[1]', 'bit'), 0)
		,[IsDynamic] = isnull(n.c.value('./@IsDynamic[1]', 'bit'), 0)
		,[FilterMeasure] = n.c.value('./@FilterMeasure[1]', 'nvarchar(max)')
		,[IgnoreLockedPeriods] = n.c.value('./@IgnoreLockedPeriods[1]', 'bit')
		,[PeriodsOffset] = isnull(n.c.value('./@PeriodsOffset[1]', 'int'), 0)
		,[HidePeriodicDistributionTotal] = isnull(n.c.value('./@HidePeriodicDistributionTotal[1]', 'bit'), 0)
		,[DefaultValueMeasure] = n.c.value('./@DefaultValueMeasure[1]', 'nvarchar(max)')
		,[CommentTemplate] = n.c.value('./@CommentTemplate[1]', 'nvarchar(max)')
	from
		@FCTypeData.nodes('/FCType/FCColumns/FCColumn') n(c)
			inner join #FCType t on
				t.SourceFCTypeID = n.c.value('./@FCTypeID[1]', 'int')

	if exists(select 1 from #FCColumns where WritabilityProperty <> '')
		raiserror('@FCTypeData contains configuration for FCColumns.WritabilityProperty but WritabilityProperty was removed in INSIKT 12.1. ', 16, 10)

	exec
	(
		'
			INSERT INTO ' + @INSIKT_SYS + '.[dbo].[FCColumns]
			(
				[UniqueName]
				,[Caption]
				,[Order]
				,[Writable]
				,[WritabilityMeasure]
				,[Author]
				,[CompanyID]
				,[FCTypeID]
				,[MDX]
				,[FCProcessDimUniqueName]
				,[DTDCustomQuery]
				,[PeriodicDistributable]
				,[AggregateValues]
				,[DisableDirectInput]
				,[Tooltip]
				,[ReplaceByYear]
				,[IsHidden]
				,[CommentsAreMandatory]
				,[IsUnitPrice]
				,[IsDynamic]
				,[FilterMeasure]
				,[IgnoreLockedPeriods]
				,[PeriodsOffset]
				,[HidePeriodicDistributionTotal]
				,[DefaultValueMeasure]
				,[CommentTemplate]
			)
			select
				[UniqueName]
				,[Caption]
				,[Order]
				,[Writable]
				,[WritabilityMeasure]
				,[Author]
				,[CompanyID]
				,[FCTypeID]
				,[MDX]
				,[FCProcessDimUniqueName]
				,[DTDCustomQuery]
				,[PeriodicDistributable]
				,[AggregateValues]
				,[DisableDirectInput]
				,[Tooltip]
				,[ReplaceByYear]
				,[IsHidden]
				,[CommentsAreMandatory]
				,[IsUnitPrice]
				,[IsDynamic]
				,[FilterMeasure]
				,[IgnoreLockedPeriods]
				,[PeriodsOffset]
				,[HidePeriodicDistributionTotal]
				,[DefaultValueMeasure]
				,[CommentTemplate]
			from
				#FCColumns src	


		update src set
			[FCColumnID] = tgt.ID
		from
			#FCColumns src
				inner join ' + @INSIKT_SYS + '.dbo.FCColumns tgt on
					tgt.[UniqueName] = src.[UniqueName]
					and tgt.[FCTypeID] = src.[FCTypeID]
					and tgt.CompanyID = src.CompanyID
		'
	)



	create table #FCElementProperty
	(
		--[ID] [int] IDENTITY(1,1) NOT NULL primary key,
		[FCElementID] [int] NOT NULL,
		[PropertyID] [int] NOT NULL,
		[ElementKey] [nvarchar](max) NOT NULL,
		[ValueNumeric] [float] NULL,
		[ValueString] [varchar](1000) NULL,
		[FCTypeID] [int] NULL,
		[CompanyID] [int] NULL,
		[OptionalCode] [nvarchar](max) NULL,
		[UserID] [int] NULL,
		[AdditionalFilter] [nvarchar](max) NULL
	)
	insert into #FCElementProperty
	select distinct
        [FCElementID] = iif(n.c.value('./@FCElementID[1]', 'int') = 1, 1, e.FCElementID )
        ,[PropertyID] =  n.c.value('./@PropertyID[1]', 'int')
        ,[ElementKey] = n.c.value('./@ElementKey[1]', 'nvarchar(max)')
		,[ValueNumeric] = 
			case n.c.value('./@PropertyID[1]', 'int')
				when 20 then -- DefaultView
					v.FCViewID
				else n.c.value('./@ValueNumeric[1]', 'float')
			end
        ,[ValueString] = n.c.value('./@ValueString[1]', 'nvarchar(max)')
		,[FCTypeID] = t.FCTypeID
		,[CompanyID] = n.c.value('./@CompanyID[1]', 'int')
		,[OptionalCode] = n.c.value('./@OptionalCode[1]', 'nvarchar(max)')
		,[UserID] = n.c.value('./@UserID[1]', 'int')
		,[AdditionalFilter] = n.c.value('./@AdditionalFilter[1]', 'nvarchar(max)')
    from
        @FCTypeData.nodes('/FCType/FCElementProperties/FCElementProperty') n(c)
			left join #FCElement e on
				e.SourceFCElementID = n.c.value('./@FCElementID[1]', 'int')
			inner join #FCType t on
				t.SourceFCTypeID = n.c.value('./@FCTypeID[1]', 'int')
			left join #FCView v on
				v.SourceFCViewID = n.c.value('./@ValueNumeric[1]', 'float')
				and n.c.value('./@PropertyID[1]', 'int') = 20 -- DefaultView
			

	create table #MissingProperties(Missing_PropertyID int not null primary key)
	insert into #MissingProperties
	exec
	(
		'select distinct
			ep.PropertyID
		from
			#FCElementProperty ep
				left join ' + @INSIKT_SYS + '.dbo.FCProperty p on
					p.ID = ep.[PropertyID]
		where
			p.ID is null'
	)
	if exists(select 1 from #MissingProperties)
		begin
			select * from #MissingProperties
			raiserror('En eller fler FCPropertyID:s saknas i %s. Verifiera resultatfliken för info om vilka properties som saknas.', 16, 10, @INSIKT_SYS)
		end
	exec 
	(

	'
		INSERT INTO ' + @INSIKT_SYS + '.[dbo].[FCElementProperty]
		(
			[FCElementID]
			,[PropertyID]
			,[ElementKey]
			,[ValueNumeric]
			,[ValueString]
			,[FCTypeID]
			,[CompanyID]
			,[OptionalCode]
			,[UserID]
			,[AdditionalFilter]
		)
		select
			[FCElementID]
			,[PropertyID]
			,[ElementKey]
			,[ValueNumeric]
			,[ValueString]
			,[FCTypeID]
			,[CompanyID]
			,[OptionalCode]
			,[UserID]
			,[AdditionalFilter]
		from
			#FCElementProperty src
		where
			not exists (select 1 from #MissingProperties mp where mp.Missing_PropertyID = src.PropertyID)
			'
	)

	CREATE TABLE #FCRole
	(
		[SourceFCRoleID] [int] NOT NULL primary key,
		[FCRoleID] int,
		[RoleTypeID] [int] NOT NULL,
		[Name] nvarchar(max) NOT NULL,
		[Description] nvarchar(max) NULL,
		[Order] [int] NULL,
		[SortOrder] [int] NULL
	)
	insert into #FCRole
	(
		[SourceFCRoleID]
		,[FCRoleID]
		,[RoleTypeID]
		,[Name]
		,[Description]
		,[Order]
		,[SortOrder]
	)
	select distinct
		[SourceFCRoleID] = n.c.value('./@ID[1]', 'int')
		,[FCRoleID] = null
		,[RoleTypeID] = n.c.value('./@RoleTypeID[1]', 'int')
		,[Name] = n.c.value('./@Name[1]', 'nvarchar(max)')
		,[Description] = n.c.value('./@Description[1]', 'nvarchar(max)')
		,[Order] = n.c.value('./@Order[1]', 'int')
		,[SortOrder] = n.c.value('./@SortOrder[1]', 'int')
	from
		@FCTypeData.nodes('/FCType/FCRoles/FCRole') n(c)


	exec
	(
		'
		INSERT INTO ' + @INSIKT_SYS + '.[dbo].[FCRole]
		(
			[RoleTypeID]
			,[Name]
			,[Description]
			,[Order]
			,[SortOrder]
		)
		select
			src.[RoleTypeID]
			,src.[Name]
			,src.[Description]
			,src.[Order]
			,src.[SortOrder]
		from
			#FCRole src
				left join ' + @INSIKT_SYS + '.[dbo].[FCRole] tgt on
					tgt.[RoleTypeID] = src.[RoleTypeID]
					and tgt.[Name] = src.[Name]
		where
			tgt.ID is null

		update src set
			[FCRoleID] = tgt.ID
		from
			#FCRole src
				inner join ' + @INSIKT_SYS + '.dbo.FCRole tgt on
					tgt.[RoleTypeID] = src.[RoleTypeID]
					and tgt.[Name] = src.[Name]
		'
	)



	CREATE TABLE #FCRoleTypeCompanyRelation
	(
		[SourceFCRoleTypeCompanyRelationID] [int]  NOT NULL primary key,
		[FCRoleTypeCompanyRelationID] int,
		[FCRoleID] [int] NOT NULL,
		[FCTypeID] [int] NOT NULL,
		[CompanyID] [int] NOT NULL
	)
	insert into #FCRoleTypeCompanyRelation
	(
		[SourceFCRoleTypeCompanyRelationID]
		,[FCRoleTypeCompanyRelationID]
		,[FCRoleID]
		,[FCTypeID]
		,[CompanyID]
	)
	select
		[SourceFCRoleTypeCompanyRelationID] = n.c.value('./@ID[1]', 'int')
		,[FCRoleTypeCompanyRelationID] = null
		,[FCRoleID] = r.FCRoleID
		,[FCTypeID] = t.FCTypeID
		,[CompanyID] = n.c.value('./@CompanyID[1]', 'int')
	from
		@FCTypeData.nodes('/FCType/FCRoleTypeCompanyRelations/FCRoleTypeCompanyRelation') n(c)
			inner join #FCType t on
				t.SourceFCTypeID = n.c.value('./@FCTypeID[1]', 'int')
			inner join #FCRole r on
				r.SourceFCRoleID = n.c.value('./@FCRoleID[1]', 'int')


	exec
	(
		'
		INSERT INTO ' + @INSIKT_SYS + '.[dbo].[FCRoleTypeCompanyRelation]
		(
			[FCRoleID]
			,[FCTypeID]
			,[CompanyID]
		)
		select
			[FCRoleID]
			,[FCTypeID]
			,[CompanyID]
		from
			#FCRoleTypeCompanyRelation src


		update src set
			[FCRoleTypeCompanyRelationID] = tgt.ID
		from
			#FCRoleTypeCompanyRelation src
				inner join ' + @INSIKT_SYS + '.dbo.FCRoleTypeCompanyRelation tgt on
					tgt.[FCRoleID] = src.[FCRoleID]
					and tgt.[FCTypeID] = src.[FCTypeID]
					and tgt.CompanyID = src.CompanyID
		'
	)



	CREATE TABLE #FormattingRule
    (
        [SourceFormattingRuleID] [int] NOT NULL primary key,
        [FormattingRuleID] int null,
        [Data] nvarchar(max) null,
        [Name] nvarchar(max) null,
        [Description] nvarchar(max) null,
        [RowNumber] int IDENTITY(1,1) not null
     
 
    )
    insert into #FormattingRule
    (
         
        [SourceFormattingRuleID]
        ,[FormattingRuleID]
        ,[Data]
        ,[Name]
        ,[Description]
 
    )
    select distinct
        [SourceFormattingRuleID] = n.c.value('./@ID[1]', 'int')
        ,[FormattingRuleID] = NULL
        ,[Data] = n.c.value('./@Data[1]', 'nvarchar(max)')
        ,[Name] = n.c.value('./@Name[1]', 'nvarchar(max)')
        ,[Description] = n.c.value('./@Description[1]', 'nvarchar(max)')
    from
        @FCTypeData.nodes('/FCType/FormattingRules/FormattingRule') n(c)
 
 
     
     
    exec
    (
        '
        declare @SourceFormattingRuleID int
		select @SourceFormattingRuleID = min([SourceFormattingRuleID]) from #Formattingrule src
		while @SourceFormattingRuleID is not null
			begin
				INSERT INTO ' + @INSIKT_SYS + '.[dbo].[FormattingRule]
				(
					  [Name]
					  ,[Description]
					  ,[Data]
				)		
				select
					  src.[Name]
					  ,src.[Description]
					  ,src.[Data]
				from
					#Formattingrule src
				where
					src.SourceFormattingRuleID = @SourceFormattingRuleID
					
 
				update src set
					[FormattingRuleID] = scope_identity()
				from
					#FormattingRule src
				where
					src.SourceFormattingRuleID = @SourceFormattingRuleID


				select @SourceFormattingRuleID = min([SourceFormattingRuleID]) from #Formattingrule src where src.SourceFormattingRuleID > @SourceFormattingRuleID
			end                
        '
    )
 
    CREATE TABLE #FCViewFormattingRuleRelation
    (
        [SourceFormattingRuleID] [int] NOT NULL primary key
         ,[SourceFCTypeID] int null
         ,[SourceFCViewID] int null
         ,[FormattingRuleID] int null
         ,[FCTypeID]  int null
         ,[FCViewID] int null
         ,[CompanyID] int null
         ,[IsSwitchedView] int null
         ,[SwitchedViewID] int null
         ,[IsTransactionView] int null
     
 
    )
 
 
 
    insert into #FCViewFormattingRuleRelation
    (
        [SourceFormattingRuleID]
          ,[SourceFCTypeID]
          ,[SourceFCViewID]
          ,[FormattingRuleID]
          ,[FCTypeID]
          ,[FCViewID]
          ,[CompanyID]
          ,[IsSwitchedView]
          ,[SwitchedViewID]
          ,[IsTransactionView]
    )
    select distinct 
         [SourceFormattingRuleID] = n.c.value('./@FormattingRuleID[1]', 'int')
          ,[SourceFCTypeID] = n.c.value('./@FCTypeID[1]', 'int')
          ,[SourceFCViewID] = n.c.value('./@FCViewID[1]', 'int')
          ,[FormattingRuleID] = NULL
          ,[FCTypeID] = NULL
          ,[FCViewID] = NULL
          ,[CompanyID] = n.c.value('./@CompanyID[1]', 'int')
          ,[IsSwitchedView] = 0
          ,[SwitchedViewID] = NULL --ids inte lägga in stöd för det
          ,[IsTransactionView] = n.c.value('./@IsTransactionView[1]', 'int')
    from
        @FCTypeData.nodes('/FCType/FCViewFormattingRuleRelations/FCViewFormattingRuleRelation') n(c)
     
 
    update rel
    set    
        FormattingRuleID = frule.FormattingRuleID
        ,FCTypeID = fctype.FCTypeID
        ,FCViewID = fcview.FCViewID
    from 
        #FCViewFormattingRuleRelation rel
        inner join #FormattingRule frule on
            frule.SourceFormattingRuleID = rel.SourceFormattingRuleID
        inner join #FCType fctype on
            fctype.SourceFCTypeID = rel.SourceFCTypeID
        inner join #FCView fcview on
            fcview.SourceFCViewID = rel.SourceFCViewID
 
 
 
    exec
    (
        '
 
 
        INSERT INTO ' + @INSIKT_SYS + '.[dbo].[FCViewFormattingRuleRelation]
        (
            [FormattingRuleID]
              ,[FCTypeID]
              ,[FCViewID]
              ,[CompanyID]
              ,[IsSwitchedView]
              ,[SwitchedViewID]
              ,[IsTransactionView]
        )
        select
            [FormattingRuleID]
              ,[FCTypeID]
              ,[FCViewID]
              ,[CompanyID]
              ,[IsSwitchedView]
              ,[SwitchedViewID]
              ,[IsTransactionView]
        from
            #FCViewFormattingRuleRelation
            where FormattingRuleID is not null
        '
 
    )
 


	--select * From #FCTypeDataSourceRelation
	--exec ('select * from ' + @INSIKT_SYS + '.dbo.DataSourceConnection')
	--select * from #DataSourceConnection
	--
	--exec ('select * from ' + @INSIKT_SYS + '.dbo.DataSources')
	drop table #FCType
	drop table #DataSourceConnection
	drop table #DataSources
	drop table #FCTypeDataSourceRelation
	drop table #FCElement
	drop table #FCElementProperty
	drop table #MissingProperties
	drop table #FCView
	drop table #FCViewDimension
	drop table #FCColumns
	drop table #FCRole
	drop table #FCRoleTypeCompanyRelation
	drop table #FormattingRule
	drop table #FCViewFormattingRuleRelation
	
if @TranCount = 0 commit tran;
end try
begin catch
	if @TranCount = 0 and @@TRANCOUNT > 0 rollback tran;
	throw;
end catch
GO
