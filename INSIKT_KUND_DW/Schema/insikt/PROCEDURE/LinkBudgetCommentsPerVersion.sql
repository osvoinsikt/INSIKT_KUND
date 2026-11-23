SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [insikt].[LinkBudgetCommentsPerVersion]
(
	@Type nvarchar(4000) = null
	,@ParamList nvarchar(4000) = null	
	,@ParentEventID int = null	
	,@PlanningVersionID int = null
)
as
--
-- Standardvariabler
--
declare @ProcName sysname, @TranCount int, @EventIDStack varbinary(max)
set @ProcName = app.GetObjectFullName(@@procid)
set @TranCount = @@trancount


begin try
	--------------------------------------------------------------------------
	-- Start
	--------------------------------------------------------------------------
	exec app.LogEventStart @ParentEventID = @ParentEventID, @EventIDStack = @EventIDStack output, @EventObject = @ProcName
			,@EventTitle = 'Länka planeringskommentarer'
			,@Description = null

		
		--
		-- Configtabell för vilka kolumner som ska få kommentarer från en föregående version.
		--
		create table #ColConf
		(
			FCColumnID int not null
			,Prev varchar(32) CHECK (Prev in ('PreviousBudgetID','PreviousPrognosID', 'PrevPreviousBudgetID'))
			,AllowEdit bit default 0	
			
		)

		
		--
		-- Konfigtabell för hur vi ska mappa respektive till föregående version
		--
		create table #ColSourceMap
		(
			FCColumnID int not null
			,FCVersionType int null
			,SourceFCTypeID int null				
			,SourceFCVersionLevelUniqueName varchar(512) not null
			,SourceCommentColUniqueName varchar(512) not null
		)
		--
		-- Kolumner som ska visa gamla kommentarer
		--
		-- Både budget och prognosversioner ska visa kommentarer enligt utpekad ursprungsversion (PreviousPrognosID).
		--
		declare @budgetFCColumnId int
		declare @prognosFCColumnId int

		select @budgetFCColumnId = c.ID 
			from [INSIKT_KUND_SYS].dbo.fccolumns c
			inner join [INSIKT_KUND_SYS].dbo.FCColumnFCVersionTypeRelation vRel on (c.ID = vRel.FCColumnID and vRel.FCVersionTypeID = 1)
			where c.UniqueName = '[Measures].[INSIKTPlanering (fg prognos helår)]'

		select @prognosFCColumnId = c.ID 
			from [INSIKT_KUND_SYS].dbo.fccolumns c
			inner join [INSIKT_KUND_SYS].dbo.FCColumnFCVersionTypeRelation vRel on (c.ID = vRel.FCColumnID and vRel.FCVersionTypeID = 2)
			where c.UniqueName = '[Measures].[INSIKTPlanering (fg prognos helår)]'

		insert into #ColConf(FCColumnID, Prev, AllowEdit)
		values
			(@budgetFCColumnId, 'PreviousPrognosID', 0),
			(@prognosFCColumnId, 'PreviousPrognosID', 0)
		
		-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
		-- Mappning per column och FCVersionType hur vi ska hitta de gamla kommentarerna.
		--
		--
		-- FCColumnID						ID på kolumn från FCColumns (måste finnas i #ColConf ovan)
		--
		-- FCVersionType					Mappningen beroende av [Type] på föregeånde planeringsversion eller NULL och det ska vara samma mappning oavsett FCVersionType.
		--
		-- SourceFCTypeID					Om budget och prognos läggs i olika FCTyper på grund av "anledningar" måste vi beroende på typ av planeringsversion kanske mappa
		--									till olika FCTyper. D.v.s. i prognos 1 så pekar prevPrognosisID på budget vars kommentarer ligger i en FCTypeID medan en prognos 2
		--									pekar tillbaka på prognos 1 vars kommentarer ligger i en annan FCTypeID.
		--
		-- SourceFCVersionLevelUniqueName	UniqueName på den nivå där uniqename på planeringsversion ligger. Ex. om kommentarer knyts till unique_name: 
		--									'[Planeringsversion].[Lista].[Planeringsversion].&[1]' så ska denna sättas till '[Planeringsversion].[Lista].[Planeringsversion]'
		--
		-- SourceCommentColUniqueName		UniqueName på det measure som den gamla kommentaren knutits mot.
		--
		insert into #ColSourceMap(FCColumnID, FCVersionType, SourceFCTypeID, SourceFCVersionLevelUniqueName, SourceCommentColUniqueName) values
			(@budgetFCColumnId, null, null, '[Planeringsversion].[Lista].[Planeringsversion]', '[Measures].[INSIKTPlanering Planering]'),
			(@prognosFCColumnId, null, null, '[Planeringsversion].[Lista].[Planeringsversion]', '[Measures].[INSIKTPlanering Planering]')
			

--			drop table #COlSourceMap
			

		select
			FCColumnID = colConf.FCColumnID
			,FCVersionID = ver.ID
			,SourceFCTypeID = prevFCType.ID
			,AllowEdit = colConf.AllowEdit
			,IncludeInExport = 0
	
			,SourceVersionElementKey =cast(prevVer.ID as varchar(512))
			,SourceVersionDimension = srcVerDim.ValueString
			,SourceVersionUniqueName = colSrcMap.SourceFCVersionLevelUniqueName + '.&[' +cast(prevVer.ID as varchar(12)) + ']'


			,SourceCommentColDimension = srcColDim.ValueString
			,SourceCommentColUniqueName = colSrcMap.SourceCommentColUniqueName
			,SourceCommentColElementKey = parsename(iif (right(colSrcMap.SourceCommentColUniqueName, charindex('.', reverse(colSrcMap.SourceCommentColUniqueName))-1) like '&%', right(colSrcMap.SourceCommentColUniqueName, charindex('.', reverse(colSrcMap.SourceCommentColUniqueName))-2), right(colSrcMap.SourceCommentColUniqueName, charindex('.', reverse(colSrcMap.SourceCommentColUniqueName))-1)), 1)

			,SourceDateDimension = srcTimeDim.ValueString
			,SourceDateElementKey = cast(prevVer.FiscalYear as varchar(512))
			,SourceDateUniqueName = replace(srcTimeTemplate.ValueString, '¤¤¤¤', prevVer.FiscalYear)
		into #CellCommentLinkData
		from
			#ColConf colConf
				inner join [INSIKT_KUND_SYS].dbo.FCColumns col on
					col.ID = colConf.FCColumnID
				left join [INSIKT_KUND_SYS].dbo.FCColumnFCVersionTypeRelation colRel on
					colRel.FCColumnID = colConf.FCColumnID
				left join [INSIKT_KUND_SYS].dbo.FCVersionFCTypeRelation verTypeRel on
					verTypeRel.FCTypeID = col.FCTypeID
				inner join [INSIKT_KUND_SYS].dbo.FCVersion ver on
					(
						ver.[Type] = colRel.FCVersionTypeID
						or colRel.FCVersionTypeID is null
					)
					and
					(
						ver.ID = verTypeRel.FCVersionID
						or verTypeRel.FCVersionID is null
					)
				inner join [INSIKT_KUND_SYS].dbo.FCVersion prevVer on
					(prevVer.ID = ver.PreviousBudgetID and colConf.Prev = 'PreviousBudgetID')
					or (prevVer.ID = ver.PreviousPrognosID and colConf.Prev = 'PreviousPrognosID')
					or (prevVer.ID = ver.PrevPreviousBudgetID and colConf.Prev = 'PrevPreviousBudgetID')
				inner join #ColSourceMap colSrcMap on
					colSrcMap.FCColumnID = col.ID
					and (colSrcMap.FCVersionType = prevVer.[Type] or colSrcMap.FCVersionType is null)
				inner join [INSIKT_KUND_SYS].dbo.FCType prevFCType on
					prevFCType.ID = isnull(colSrcMap.SourceFCTypeID, col.FCTypeID)
				inner join [INSIKT_KUND_SYS].dbo.FCElementProperty srcTimeTemplate on
					srcTimeTemplate.FCTypeID = prevFCType.ID
					and srcTimeTemplate.PropertyID = 55
				inner join [INSIKT_KUND_SYS].dbo.FCElementProperty srcTimeDim on
					srcTimeDim.FCTypeID = prevFCType.ID
					and srcTimeDim.PropertyID = 10
				inner join [INSIKT_KUND_SYS].dbo.FCElementProperty srcVerDim on
					srcVerDim.FCTypeID = prevFCType.ID
					and srcVerDim.PropertyID = 9
				inner join [INSIKT_KUND_SYS].dbo.FCElementProperty srcColDim on
					srcColDim.FCTypeID = prevFCType.ID
					and srcColDim.PropertyID = 6
		where
			(ver.ID = @PlanningVersionID or @PlanningVersionID is null)

		

			

		exec app.SyncTable
			@SourceTable = '#CellCommentLinkData'
			,@TargetTable = '[INSIKT_KUND_SYS].dbo.CellCommentLink'
			,@JoinColumns = 'FCColumnID, FCVersionID'
			,@DeleteMode = 3 -- Borttagna lämnas kvar (endast insert/update)
			,@ColumnMap = 'OverrideWithFCTypeID = SourceFCTypeID'



		select
			CellCommentLinkID = insiktLink.ID
			,DimensionName = linkData.SourceVersionDimension
			,UniqueName = linkData.SourceVersionUniqueName
			,ElementKey  = linkData.SourceVersionElementKey
		into #CellCommentLinkOverride	
		from
			[INSIKT_KUND_SYS].dbo.CellCommentLink insiktLink
				inner join #CellCommentLinkData linkData on
					linkData.FCColumnID = insiktLink.FCColumnID
					and linkData.FCVersionID = insiktLink.FCVersionID
		union all

		select
			CellCommentLinkID = insiktLink.ID
			,DimensionName = linkData.SourceCommentColDimension
			,UniqueName = linkData.SourceCommentColUniqueName
			,ElementKey  = linkData.SourceCommentColElementKey
	
		from
			[INSIKT_KUND_SYS].dbo.CellCommentLink insiktLink
				inner join #CellCommentLinkData linkData on
					linkData.FCColumnID = insiktLink.FCColumnID
					and linkData.FCVersionID = insiktLink.FCVersionID

		union all
		select
			CellCommentLinkID = insiktLink.ID
			,DimensionName = linkData.SourceDateDimension
			,UniqueName = linkData.SourceDateUniqueName
			,ElementKey  = linkData.SourceDateElementKey
	
		from
			[INSIKT_KUND_SYS].dbo.CellCommentLink insiktLink
				inner join #CellCommentLinkData linkData on
					linkData.FCColumnID = insiktLink.FCColumnID
					and linkData.FCVersionID = insiktLink.FCVersionID



		exec app.SyncTable
			@SourceTable = '#CellCommentLinkOverride'
			,@TargetTable = '[INSIKT_KUND_SYS].dbo.CellCommentLinkOverride'
			,@JoinColumns = 'CellCommentLinkID, DimensionName'
			,@DeleteMode = 1 -- Borttagna lämnas kvar (Borttagna rader raderas)
	
			,@TargetFilter = 'exists(select 1 from #CellCommentLinkOverride l where l.CellCommentLinkID = [CellCommentLinkOverride].CellCommentLinkID)'
	


		drop table #CellCommentLinkData
		drop table #CellCommentLinkOverride
		drop table #ColConf
		drop table #ColSourceMap
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
GO
