SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

------- Arbetsfiler\INSIKT-Projekt-Grund-0.3.0\INSIKT Projekt Grund\INSIKT_DW\insikt\PROCEDURE\FCProject_Inserted.sql -----START

CREATE PROCEDURE [insikt].[FCProject_Inserted]
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
    select @LogDescription = 'FCProjectID ' + cast(@FCProjectID as nvarchar(max)) + ' har skapats'

    exec app.LogEventStart @ParentEventID = @ParentEventID, @EventIDStack = @EventIDStack output, @EventObject = @ProcName
            ,@EventTitle = 'FCProject_Inserted'
            ,@Description = @LogDescription

	declare @projectPropertyID_FCProjectCode int = 1
			,@projectPropertyID_SA_Projekt int = 8

	-- I det fall projekt sätts vid uppskapning synkar vi det till projektnummeregenskapen som är kopplad till FCProject.Code
	declare @projectcode varchar(50)
	select @projectcode = p.Code
	from #projectPropertyValues ppv
		inner join dw.base_Projekt p on
				p.ProjektID = ppv.ValueNumeric
	where ppv.FCProjectPropertyID = @projectPropertyID_SA_Projekt 
	-- Rent tekniskt är detta en update på FCProject.Code, men supportproceduren är ett säkrare sätt än en update
	exec INSIKT_KUND_SYS.[dbo].[Support_Project_SetProjectPropertyValue] @projectID = @FCProjectID, @projectPropertyID = @projectPropertyID_FCProjectCode, @userID = @UserID, @valuestring = @projectcode

	declare @DynXMLA nvarchar(max)
	set @DynXMLA = 
		'<Batch xmlns="http://schemas.microsoft.com/analysisservices/2003/engine">
			<ErrorConfiguration xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ddl2="http://schemas.microsoft.com/analysisservices/2003/engine/2" xmlns:ddl2_2="http://schemas.microsoft.com/analysisservices/2003/engine/2/2" xmlns:ddl100_100="http://schemas.microsoft.com/analysisservices/2008/engine/100/100">
				<KeyDuplicate>IgnoreError</KeyDuplicate>
			</ErrorConfiguration>
		  <Process xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ddl2="http://schemas.microsoft.com/analysisservices/2003/engine/2" xmlns:ddl2_2="http://schemas.microsoft.com/analysisservices/2003/engine/2/2" xmlns:ddl100_100="http://schemas.microsoft.com/analysisservices/2008/engine/100/100" xmlns:ddl200="http://schemas.microsoft.com/analysisservices/2010/engine/200" xmlns:ddl200_200="http://schemas.microsoft.com/analysisservices/2010/engine/200/200">
			<Object>
				<DatabaseID>INSIKT_KUND_Projekt</DatabaseID>
				<DimensionID>INSIKT Planeringsprojekt</DimensionID>
			</Object>
			<Type>ProcessAdd</Type>
			<WriteBackTableCreation>UseExisting</WriteBackTableCreation>
		  </Process>
		</Batch>'
	--print @DynXMLA
	exec (@DynXMLA) at [INSIKT_KUND_AS]

	exec [dbo].[ETL_DimensionPart_FCProject]
		@Type = 'FCProject_Inserted'
		,@FCProjectID = @FCProjectID

	insert into dbo.FCproject_TriggerIncUpdateEvent(FCProjectID, TriggerEvent_Utfall)
	values (@FCProjectID, 1)

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



------- Arbetsfiler\INSIKT-Projekt-Grund-0.3.0\INSIKT Projekt Grund\INSIKT_DW\insikt\PROCEDURE\FCProject_Inserted.sql -----END


GO
