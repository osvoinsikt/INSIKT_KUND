SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ==========================================================================================
-- Author:		TRIMMA Affärsutveckling AB
-- Description:	Procedur för att ladda data till datalagret.
-- ==========================================================================================
-- LOG:
--	2013-03-26, TRIMMA	Standardimplementation
-- ==========================================================================================
CREATE procedure [visma].[Extract]
(
	@Type nvarchar(4000) = null
	,@ParamList nvarchar(4000) = null	
	,@ParentEventID int = null
	
	--@SA_SourceSystemID int = null	
	--,@ParentEventID int = null
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
	declare @SA_SourceSystemID nvarchar(max) 
	if (@ParamList is not null)
		select @SA_SourceSystemID = @ParamList

	declare @LoadType nvarchar(4000)
	set @LoadType = @Type

	declare @Message varchar(1000)	
	
	exec app.LogEventStart @ParentEventID = @ParentEventID, @EventIDStack = @EventIDStack output
			,@EventObject = @ProcName
			,@EventTitle = 'Ladda data från VISMA till SA'
			,@Description = @Message
			
	--------------------------------------------------------------------------
	-- Huvudbok
	--------------------------------------------------------------------------
	exec sa.ExtractTable
		@SourceTable = 'AcTr'
		,@TargetSchema = 'visma'
		,@SA_SourceSystemID = @SA_SourceSystemID
		,@ParentEventID = @EventIDStack
		,@SyncMethod = 4 -- Synca förändringar med Insert/Update
		,@DynamicFilterSetterQuery = 
			'select top 1 @SourceFilter =
				''(ChDt = '' + cast(ChDt as varchar(12)) + '' and ChTm >= '' + cast(ChTm as varchar(12)) + '') or ChDt > '' + cast(ChDt as varchar(12))
			from 
				¤TargetTable¤
			where
				SA_SourceSystemID = @SA_SourceSystemID
			order by
				ChDt desc
				,ChTm desc'

	--------------------------------------------------------------------------
	-- Huvudbok
	--------------------------------------------------------------------------
	exec sa.ExtractTable
		@SourceTable = 'AcTr_Extended'
		,@TargetSchema = 'visma'
		,@SA_SourceSystemID = @SA_SourceSystemID
		,@ParentEventID = @EventIDStack
		,@SyncMethod = 4 -- Synca förändringar med Insert/Update
		,@DynamicFilterSetterQuery = 
			'select top 1 @SourceFilter =
				''(ChDt = '' + cast(ChDt as varchar(12)) + '' and ChTm >= '' + cast(ChTm as varchar(12)) + '') or ChDt > '' + cast(ChDt as varchar(12))
			from 
				¤TargetTable¤
			where
				SA_SourceSystemID = @SA_SourceSystemID
			order by
				ChDt desc
				,ChTm desc'

	--------------------------------------------------------------------------
	-- Produkttans
	--------------------------------------------------------------------------
	exec sa.ExtractTable
		@SourceTable = 'ProdTr'
		,@TargetSchema = 'visma'
		,@SA_SourceSystemID = @SA_SourceSystemID
		,@ParentEventID = @EventIDStack

	--------------------------------------------------------------------------
	-- Orderrad
	--------------------------------------------------------------------------
	exec sa.ExtractTable
		@SourceTable = 'OrdLn'
		,@TargetSchema = 'visma'
		,@SA_SourceSystemID = @SA_SourceSystemID
		,@ParentEventID = @EventIDStack

	--------------------------------------------------------------------------
	-- Orderhuvud
	--------------------------------------------------------------------------
	exec sa.ExtractTable
		@SourceTable = 'Ord'
		,@TargetSchema = 'visma'
		,@SA_SourceSystemID = @SA_SourceSystemID
		,@ParentEventID = @EventIDStack

		
	--------------------------------------------------------------------------
	-- Konto
	--------------------------------------------------------------------------
	exec sa.ExtractTable
		@SourceTable = 'Ac'
		,@TargetSchema = 'visma'
		,@SA_SourceSystemID = @SA_SourceSystemID
		,@ParentEventID = @EventIDStack


	--------------------------------------------------------------------------
	-- Budgetrader
	--------------------------------------------------------------------------
	exec sa.ExtractTable
		@SourceTable = 'BgtLn'
		,@TargetSchema = 'visma'
		,@SA_SourceSystemID = @SA_SourceSystemID
		,@ParentEventID = @EventIDStack
		
		
	--------------------------------------------------------------------------
	-- Kontogrupperigar
	--------------------------------------------------------------------------
	if [app].[CheckParamType](@LoadType, 'Ekonomi') = 1
		begin
			exec sa.ExtractTable
				@SourceTable = 'AcGr'
				,@TargetSchema = 'visma'
				,@SA_SourceSystemID = @SA_SourceSystemID
				,@ParentEventID = @EventIDStack
		end

		
	--------------------------------------------------------------------------
	-- R1
	--------------------------------------------------------------------------
	if [app].[CheckParamType](@LoadType, 'Ekonomi') = 1
		begin
			exec sa.ExtractTable
				@SourceTable = 'R1'
				,@TargetSchema = 'visma'
				,@SA_SourceSystemID = @SA_SourceSystemID
				,@ParentEventID = @EventIDStack
		end

	--------------------------------------------------------------------------
	-- R2
	--------------------------------------------------------------------------
	if [app].[CheckParamType](@LoadType, 'Ekonomi') = 1
		begin
			exec sa.ExtractTable
				@SourceTable = 'R2'
				,@TargetSchema = 'visma'
				,@SA_SourceSystemID = @SA_SourceSystemID
				,@ParentEventID = @EventIDStack
		end	

	--------------------------------------------------------------------------
	-- R3
	--------------------------------------------------------------------------
	if [app].[CheckParamType](@LoadType, 'Ekonomi') = 1
		begin
			exec sa.ExtractTable
				@SourceTable = 'R3'
				,@TargetSchema = 'visma'
				,@SA_SourceSystemID = @SA_SourceSystemID
				,@ParentEventID = @EventIDStack
		end
	--------------------------------------------------------------------------
	-- R4
	--------------------------------------------------------------------------
	if [app].[CheckParamType](@LoadType, 'Ekonomi,ProdStat, Order') = 1
		begin
			exec sa.ExtractTable
				@SourceTable = 'R4'
				,@TargetSchema = 'visma'
				,@SA_SourceSystemID = @SA_SourceSystemID
				,@ParentEventID = @EventIDStack
		end
	-------------
	-------------------------------------------------------------
	-- R5
	--------------------------------------------------------------------------
	if [app].[CheckParamType](@LoadType, 'Ekonomi') = 1
		begin
			exec sa.ExtractTable
				@SourceTable = 'R5'
				,@TargetSchema = 'visma'
				,@SA_SourceSystemID = @SA_SourceSystemID
				,@ParentEventID = @EventIDStack
		end

	-------------------------------------------------------------
	-- R6
	--------------------------------------------------------------------------
	if [app].[CheckParamType](@LoadType, 'Ekonomi') = 1
		begin
			exec sa.ExtractTable
				@SourceTable = 'R6'
				,@TargetSchema = 'visma'
				,@SA_SourceSystemID = @SA_SourceSystemID
				,@ParentEventID = @EventIDStack
		end

	-------------------------------------------------------------
	-- R7
	--------------------------------------------------------------------------
	if [app].[CheckParamType](@LoadType, 'Ekonomi') = 1
		begin
			exec sa.ExtractTable
				@SourceTable = 'R7'
				,@TargetSchema = 'visma'
				,@SA_SourceSystemID = @SA_SourceSystemID
				,@ParentEventID = @EventIDStack
		end

	-------------------------------------------------------------
	-- R8
	--------------------------------------------------------------------------
	if [app].[CheckParamType](@LoadType, 'Ekonomi') = 1
		begin
			exec sa.ExtractTable
				@SourceTable = 'R8'
				,@TargetSchema = 'visma'
				,@SA_SourceSystemID = @SA_SourceSystemID
				,@ParentEventID = @EventIDStack
		end
	
	-------------------------------------------------------------
	-- R9
	--------------------------------------------------------------------------
	if [app].[CheckParamType](@LoadType, 'Ekonomi') = 1
		begin
			exec sa.ExtractTable
				@SourceTable = 'R9'
				,@TargetSchema = 'visma'
				,@SA_SourceSystemID = @SA_SourceSystemID
				,@ParentEventID = @EventIDStack
		end
	
	-------------------------------------------------------------
	-- R10
	--------------------------------------------------------------------------
	if [app].[CheckParamType](@LoadType, 'Ekonomi') = 1
		begin
			exec sa.ExtractTable
				@SourceTable = 'R10'
				,@TargetSchema = 'visma'
				,@SA_SourceSystemID = @SA_SourceSystemID
				,@ParentEventID = @EventIDStack
		end
	
	-------------------------------------------------------------
	-- R11
	--------------------------------------------------------------------------
	if [app].[CheckParamType](@LoadType, 'Ekonomi') = 1
		begin
			exec sa.ExtractTable
				@SourceTable = 'R11'
				,@TargetSchema = 'visma'
				,@SA_SourceSystemID = @SA_SourceSystemID
				,@ParentEventID = @EventIDStack
		end
	
	-------------------------------------------------------------
	-- R12
	--------------------------------------------------------------------------
	if [app].[CheckParamType](@LoadType, 'Ekonomi') = 1
		begin
			exec sa.ExtractTable
				@SourceTable = 'R12'
				,@TargetSchema = 'visma'
				,@SA_SourceSystemID = @SA_SourceSystemID
				,@ParentEventID = @EventIDStack
		end
	

	-------------------------------------------------------------
	-- Actor (kunder, leverantörer, personal, mm.)
	--------------------------------------------------------------------------
	if [app].[CheckParamType](@LoadType, 'Ekonomi') = 1
		begin
			exec sa.ExtractTable
				@SourceTable = 'Actor'
				,@TargetSchema = 'visma'
				,@SA_SourceSystemID = @SA_SourceSystemID
				,@ParentEventID = @EventIDStack
		end

	-------------------------------------------------------------
	-- Prop (anläggningar)
	--------------------------------------------------------------------------
	if [app].[CheckParamType](@LoadType, 'Ekonomi') = 1
		begin
			exec sa.ExtractTable
				@SourceTable = 'Prop'
				,@TargetSchema = 'visma'
				,@SA_SourceSystemID = @SA_SourceSystemID
				,@ParentEventID = @EventIDStack
		end

	--------------------------------------------------------------------------
	-- Produkter
	--------------------------------------------------------------------------
	exec sa.ExtractTable
		@SourceTable = 'Prod'
		,@TargetSchema = 'visma'
		,@SA_SourceSystemID = @SA_SourceSystemID
		,@ParentEventID = @EventIDStack
		
	--------------------------------------------------------------------------
	-- Texter
	--------------------------------------------------------------------------
	exec sa.ExtractTable
		@SourceTable = 'Txt'
		,@TargetSchema = 'visma'
		,@SA_SourceSystemID = @SA_SourceSystemID
		,@ParentEventID = @EventIDStack

	--------------------------------------------------------------------------
	-- Verifikattyper
	--------------------------------------------------------------------------
	exec sa.ExtractTable
		@SourceTable = 'VoTp'
		,@TargetSchema = 'visma'
		,@SA_SourceSystemID = @SA_SourceSystemID
		,@ParentEventID = @EventIDStack
	


	--------------------------------------------------------------------------
	-- Lager
	--------------------------------------------------------------------------
	exec sa.ExtractTable
		@SourceTable = 'Stc'
		,@TargetSchema = 'visma'
		,@SA_SourceSystemID = @SA_SourceSystemID
		,@ParentEventID = @EventIDStack

	
	--------------------------------------------------------------------------
	-- Företagsinformation
	--------------------------------------------------------------------------
	exec sa.ExtractTable
		@SourceTable = 'FrmData'
		,@TargetSchema = 'visma'
		,@SA_SourceSystemID = @SA_SourceSystemID
		,@ParentEventID = @EventIDStack


	--------------------------------------------------------------------------
	-- Bokföringsperioder
	--------------------------------------------------------------------------
	exec sa.ExtractTable
		@SourceTable = 'AcPr'
		,@TargetSchema = 'visma'
		,@SA_SourceSystemID = @SA_SourceSystemID
		,@ParentEventID = @EventIDStack

	--------------------------------------------------------------------------
	-- Lager
	--------------------------------------------------------------------------
	exec sa.ExtractTable
		@SourceTable = 'Stc'
		,@TargetSchema = 'visma'
		,@SA_SourceSystemID = @SA_SourceSystemID
		,@ParentEventID = @EventIDStack

	
		--------------------------------------------------------------------------
	-- Fakturainformation
	--------------------------------------------------------------------------
	exec sa.ExtractTable
		@SourceTable = 'VWDocumentFile'
		,@TargetSchema = 'visma'
		,@SA_SourceSystemID = @SA_SourceSystemID
		,@ParentEventID = @EventIDStack
		
	exec sa.ExtractTable
		@SourceTable = 'VWDocument'
		,@TargetSchema = 'visma'
		,@SA_SourceSystemID = @SA_SourceSystemID
		,@ParentEventID = @EventIDStack

		exec app.LogEventStop @EventIDStack = @EventIDStack out
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
