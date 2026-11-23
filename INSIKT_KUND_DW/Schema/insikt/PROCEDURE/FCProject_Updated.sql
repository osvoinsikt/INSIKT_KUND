SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [insikt].[FCProject_Updated]
(
	@FCProjectID int
	,@UserID int
	,@parentProjectID int
	,@ParentEventID int = null
)
as
begin try
	--
	-- Standardvariabler
	--
	declare @ProcName sysname, @TranCount int, @EventIDStack varbinary(max)
	set @ProcName = app.GetObjectFullName(@@procid)
	set @TranCount = @@trancount

    --------------------------------------------------------------------------
    -- Start
    --------------------------------------------------------------------------
	declare @LogDescription nvarchar(max),@EventName nvarchar(50)
    select @LogDescription = 'FCProjectID ' + cast(@FCProjectID as nvarchar(max)) + ' har uppdaterats'

  
    exec app.LogEventStart @ParentEventID = @ParentEventID, @EventIDStack = @EventIDStack output, @EventObject = @ProcName
            ,@EventTitle = 'FCProject_Updated'
            ,@Description = @LogDescription

	declare @projectPropertyID_FCProjectCode int = 1
			,@projectPropertyID_SA_Projekt int = 8
	--
	-- Projektnummer ändrat
	-- select * from [insikt].[FCProjectEventCurrentConfiguration] where FCProjectEventID = 4
	--
	
	if exists(
		select 1 
		from #projectPropertyValues ppv
			inner join [insikt].[FCProjectPropertyEventRelation] e on 
				e.FCProjectPropertyID = ppv.FCProjectPropertyID
		where 
			e.FCProjectEventID = 4
			and ppv.HasChanged = 1
		)
	begin
		declare @projectcode varchar(50)
		select @projectcode = p.Code
		from #projectPropertyValues ppv
			inner join dw.base_Projekt p on
				 p.ProjektID = ppv.ValueNumeric
		where ppv.FCProjectPropertyID = @projectPropertyID_SA_Projekt 
		-- Rent tekniskt är detta en update på FCProject.Code, men supportproceduren är ett säkrare sätt än en update
		exec INSIKT_KUND_SYS.[dbo].[Support_Project_SetProjectPropertyValue] @projectID = @FCProjectID, @projectPropertyID = @projectPropertyID_FCProjectCode, @userID = @UserID, @valuestring = @projectcode
	end

	--
	--Processa projektdimension  
	--select * from [insikt].[FCProjectEventCurrentConfiguration] where FCProjectEventID = 1
	--
	if exists(
		select 1 
		from #projectPropertyValues ppv
			inner join [insikt].[FCProjectPropertyEventRelation] e on 
				e.FCProjectPropertyID = ppv.FCProjectPropertyID
		where 
			e.FCProjectEventID = 1 --INSIKT Planeringsprojekt
			and ppv.HasChanged = 1
		)
	begin 
		declare @DynXMLA nvarchar(max)
		set @DynXMLA = 
			'<Batch xmlns="http://schemas.microsoft.com/analysisservices/2003/engine">
			  <Process xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ddl2="http://schemas.microsoft.com/analysisservices/2003/engine/2" xmlns:ddl2_2="http://schemas.microsoft.com/analysisservices/2003/engine/2/2" xmlns:ddl100_100="http://schemas.microsoft.com/analysisservices/2008/engine/100/100" xmlns:ddl200="http://schemas.microsoft.com/analysisservices/2010/engine/200" xmlns:ddl200_200="http://schemas.microsoft.com/analysisservices/2010/engine/200/200">
				<Object>
					<DatabaseID>INSIKT_KUND_Projekt</DatabaseID>
					<DimensionID>INSIKT Planeringsprojekt</DimensionID>
				</Object>
				<Type>ProcessUpdate</Type>
				<WriteBackTableCreation>UseExisting</WriteBackTableCreation>
			  </Process>
			</Batch>'
		--print @DynXMLA
		exec (@DynXMLA) at [INSIKT_KUND_AS]
	end

	-- Ladda om och processa INSIKT Projekt
	exec [dbo].[ETL_DimensionPart_FCProject]
		@Type = 'FCProject_Updated'
		,@FCProjectID = @FCProjectID

	--
	--Ladda om utfall
	--select * from [insikt].[FCProjectEventCurrentConfiguration] where FCProjectEventID = 2
	--
	if exists(
		select 1 
		from #projectPropertyValues ppv
			inner join [insikt].[FCProjectPropertyEventRelation] e on 
				e.FCProjectPropertyID = ppv.FCProjectPropertyID
		where 
			e.FCProjectEventID = 2 --Utfall
			and ppv.HasChanged = 1
		)
	begin 
		insert into dbo.FCproject_TriggerIncUpdateEvent(FCProjectID, TriggerEvent_Utfall)
		values (@FCProjectID, 1)
	end

	--
	--Ladda om utilities
	--select * from [insikt].[FCProjectEventCurrentConfiguration] where FCProjectEventID = 3
	--
	if exists(
		select 1 
		from #projectPropertyValues ppv
			inner join [insikt].[FCProjectPropertyEventRelation] e on 
				e.FCProjectPropertyID = ppv.FCProjectPropertyID
		where 
			e.FCProjectEventID = 3 --Utilities
			and ppv.HasChanged = 1
		)
	begin 
	
		insert into [dbo].[FCProject_TriggerIncUpdateEvent]([FCProjectID], [TriggerEvent_Utilities])
		values (@FCProjectID, 1)
		declare @FCVersionID int
		select @FCVersionID = FCVersionID from [insikt].[FCProject_Versions] where FCProjectID = @FCProjectID
		insert into [dbo].[FCProject_TriggerIncUpdateEvent]([FCProjectID], [FCVersionID], [TriggerEvent_Periodisering])
		values (@FCProjectID, @FCVersionID, 1)

	end

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
