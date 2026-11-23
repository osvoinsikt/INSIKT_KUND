SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ETL_Organisation]
(
	@Type nvarchar(4000) = null
	,@ParamList nvarchar(4000) = null	
	,@ParentEventID int = null
	,@PassNr int = 1
) as
set nocount on
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
			,@EventTitle = 'ETL Organisation'
			,@Description = ''

		if @PassNr is null
			set @PassNr = 1

		select distinct
			org.Organisation_LeafID
			,OrgPath = 
				isnull(org.L0_DisplayName, '') 
				+ isnull(' > ' + L1_DisplayName, '')
				+ isnull(' > ' + L2_DisplayName, '')
				+ isnull(' > ' + L3_DisplayName, '')
				+ isnull(' > ' + L4_DisplayName, '')
			,[ToAvdelningID] =
				case
					when [Avdelning].[AvdelningID] <> 0 then [Avdelning].[AvdelningID]
					when org.[Avdelning] = '*' then -16
					else org.[AvdelningID]
				end
		into #OrgMap
		from	
			dw.dim_Organisation org
				left join [dw].[base_Avdelning] [Avdelning] on
					[Avdelning].Code = org.[Avdelning]
		select top 10
			org.Organisation_LeafID
			,org.OrgPath
			,DupCount = count(*)
			,Top5DupCombos = 
				(
					select top 5
						'Avdelning: ' + cast(isnull(cast([Avdelning].Code as varchar(500)), '*') as varchar(500)) + 
						'; '
					from
						#OrgMap dupLookup
							inner join [dw].[base_Avdelning] [Avdelning] on
								[Avdelning].[AvdelningID] = dupLookup.[ToAvdelningID]
					where
						dupLookup.Organisation_LeafID = org.Organisation_LeafID
					for xml path(''), type
				).value('.', 'varchar(max)')
		into #DupErrors
		from
			#OrgMap org
		group by
			org.Organisation_LeafID
			,org.OrgPath
		having 
			count(*) > 1

		if @@ROWCOUNT > 0
			begin
				select * from #DupErrors		
				raiserror('Skrivning på vissa noder leder till flera olika kombinationer av ingående koddelar', 16,10)
				return
			end
		drop table #DupErrors

		if @PassNr = 1
			begin
				insert into dw.dim_Organisation_AdditionalRelation
				(
					[AvdelningID]
				)
				select distinct
					m.[ToAvdelningID]
				from
					#OrgMap m							
						left join dw.dim_Organisation org on
							org.[AvdelningID] = m.[ToAvdelningID]
				where
					org.Organisation_LeafID is null
					and not exists
					(
						select 1
						from					
							dw.dim_Organisation_AdditionalRelation l
						where
							l.[AvdelningID] = m.[ToAvdelningID]
					)
				if @@ROWCOUNT > 0
					begin
						exec [dbo].[Hierarchy_dim_Organisation]
						exec dbo.ETL_Organisation @PassNr = 2
						return
					end
			end
	
		
		select
			m.Organisation_LeafID
			,SkrivningPåOrg = m.OrgPath
			,HamnarPåKoddelar =
				'Avdelning: ' + cast(isnull(cast([Avdelning].Code as varchar(500)), '*') as varchar(500)) + 
				''
			,SomMapparTillOrg = 'Annan org nod: ' + orgMap.OrgPath
		into #MapError
		from
			#OrgMap m
				inner join [dw].[base_Avdelning] [Avdelning] on
					[Avdelning].[AvdelningID] = m.[ToAvdelningID]
				left join dw.dim_Organisation org on
					org.[AvdelningID] = m.[ToAvdelningID]
			left join #OrgMap orgMap on
					orgMap.Organisation_LeafID = org.Organisation_LeafID
		where
			org.Organisation_LeafID is null
			or org.Organisation_LeafID <> m.Organisation_LeafID

		if @@ROWCOUNT > 0
			begin
				select * from #MapError		
				raiserror('Vissa noder mappar vid skrivning till en annan nod än sig själv.', 16,10)
				return
			end
		
		exec app.SyncTable
			@TargetTable = 'dw.dim_Organisation_PlanningMap'
			,@SourceTable = '#OrgMap'
	
		drop table #OrgMap

		drop table #MapError
		print 'Org OK'

		--
		-- Hantera fakta efter eventuella förändringar i org-dimensionen
		--
		-- Öppna versioner
		update f set
			[AvdelningID] = dimOrg.[ToAvdelningID]
		from
			dw.fact_Resultat_Planning f
				inner join dw.dim_PlanningVersion pv on
					pv.PlanningVersionID = f.PlanningVersionID
					and (pv.IsBudget = 1 or pv.OpenForSuperUsers = 1)
				inner join dw.dim_Organisation_PlanningMap dimOrg on
					dimOrg.Organisation_LeafID = f.Organisation_LeafID
		where
			f.[AvdelningID] <> dimOrg.[ToAvdelningID]
		-- Stängda versioner
		update f set
			Organisation_LeafID = dimOrg.Organisation_LeafID		
		from
			dw.fact_Resultat_Planning f
				inner join dw.dim_PlanningVersion pv on
					pv.PlanningVersionID = f.PlanningVersionID
					and  not (pv.IsBudget = 1 or pv.OpenForSuperUsers = 1)
				inner join dw.dim_Organisation dimOrg on
			f.[AvdelningID] = dimOrg.[AvdelningID]
		where
			f.Organisation_LeafID <> dimOrg.Organisation_LeafID
			

	exec app.LogEventStop @EventIDStack = @EventIDStack out
	-- Stop
	--------------------------------------------------------------------------
	
end try
begin catch	
	--
	-- Rulla tillbaka eventualla transaktioner startade i den här procedurn och logga fel.
	--
	if @TranCount = 0 and @@trancount > 0 rollback tran
	exec app.HandleProcError @EventIDStack out, @ParentEventID, @ProcName
	exec app.ReThrowError
end catch
GO
