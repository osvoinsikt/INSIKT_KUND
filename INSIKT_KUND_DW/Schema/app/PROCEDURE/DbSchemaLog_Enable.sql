SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [app].[DbSchemaLog_Enable] 
(
	@Enable bit = 1
)
as
declare 
	@TriggerExists bit
	,@TriggerEnabled bit
	,@DynSQL varchar(max)
select 
	@TriggerExists = iif(object_id <> 0, 1, 0)
	,@TriggerEnabled = iif(is_disabled = 0, 1, 0)
From 
	sys.triggers where name = 'Trigger_Add_DbSchemaLog'

if @Enable = 1
	begin
		if (select count(*) from app.DbSchemaLog) <= 0
			begin
				exec app.DbSchemaLog_InitAll
			end
select @DynSQL =
'
' + iif(@TriggerExists = 1, 'ALTER', 'CREATE') + ' TRIGGER [Trigger_Add_DbSchemaLog]
ON DATABASE 
FOR DDL_DATABASE_LEVEL_EVENTS 
AS
BEGIN
    SET NOCOUNT ON;
    IF OBJECT_ID(''[app].[DbSchemaLog]'') IS NOT NULL
    BEGIN
        BEGIN TRY
            DECLARE @Eventdata XML;
            SET @Eventdata = EVENTDATA();


			declare
				 @LoginName nvarchar(128)
				,@UserName nvarchar(128)
				,@SchemaName nvarchar(128)
				,@ObjectName nvarchar(128)
				,@TargetObjectName nvarchar(128)
				,@EventType nvarchar(128)
				,@ObjectType nvarchar(128)
				,@TargetObjectType nvarchar(128)

				,@TableFQN nvarchar(256)
				,@ObjectCreateScript nvarchar(max)

			

			select
				@LoginName = @Eventdata.value(''(/EVENT_INSTANCE/LoginName)[1]'', ''nvarchar(128)'')
				,@UserName = @Eventdata.value(''(/EVENT_INSTANCE/UserName)[1]'', ''nvarchar(128)'')
				,@SchemaName = @Eventdata.value(''(/EVENT_INSTANCE/SchemaName)[1]'', ''nvarchar(128)'')
				,@ObjectName = @Eventdata.value(''(/EVENT_INSTANCE/ObjectName)[1]'', ''nvarchar(128)'')
				,@TargetObjectName = @Eventdata.value(''(/EVENT_INSTANCE/TargetObjectName)[1]'', ''nvarchar(128)'')
				,@EventType = @Eventdata.value(''(/EVENT_INSTANCE/EventType)[1]'', ''nvarchar(128)'')
				,@ObjectType = @Eventdata.value(''(/EVENT_INSTANCE/ObjectType)[1]'', ''nvarchar(128)'')
				,@TargetObjectType = @Eventdata.value(''(/EVENT_INSTANCE/TargetObjectType)[1]'', ''nvarchar(128)'')


			--
			-- Alla event är inte nödvändiga att logga
			--
			if @EventType in
				(
					''UPDATE_STATISTICS''
				)
					return;
			--
			-- För Rename-event vill vi ha nya namnet som TargetObject
			-- 
			if @EventType = ''RENAME''
				select 
					@TargetObjectName = @Eventdata.value(''(/EVENT_INSTANCE/NewObjectName)[1]'', ''nvarchar(128)'')
					,@TargetObjectType = @ObjectType
			
			--
			-- Sätt inte TargetObjectName till det som synonymen pekar på.
			--
			if @ObjectType = ''SYNONYM''
				select 
					@TargetObjectName = @ObjectName
					,@TargetObjectType = @ObjectType

			--
			-- I de fall TargetObject saknas sätter vi target object till Event-object.
			-- Det för att underlätta utsökning av ett specifikt objekt.
			--
			if @TargetObjectName is null
				select
					@TargetObjectName = @ObjectName
					,@TargetObjectType = @ObjectType
					

			if @TargetObjectType = N''TABLE''
				set @TableFQN = quotename(@SchemaName) + N''.''  + quotename(@TargetObjectName)
			if @TableFQN is null and @ObjectType = N''TABLE''
				set @TableFQN = quotename(@SchemaName) + N''.''  + quotename(@ObjectName)


			if @TableFQN is not null
				begin
					exec 
						app.GetCreateTableScript
							@SQL = @ObjectCreateScript output
							,@object_name = @TableFQN
				end
			else
				begin
					select 
						@ObjectCreateScript = OBJECT_DEFINITION(object_id(quotename(@SchemaName) + N''.''  + quotename(@ObjectName)))
					
				end

			if @ObjectCreateScript is null
				set @ObjectCreateScript = @Eventdata.value(''(/EVENT_INSTANCE/TSQLCommand/CommandText)[1]'', ''nvarchar(max)'')


			insert into [app].[DbSchemaLog]
			(    				
				[EventType]
				,[SchemaName]
				,[ObjectName]
				,[ObjectType]
				,[TargetObjectName]				
				,[TargetObjectType]
				,[TargetObjectDefinition]

				,[EventData]
			)
			select
				[EventType] = @EventType
				,[SchemaName] = @SchemaName
				,[ObjectName] = @ObjectName
				,[ObjectType] = @ObjectType
				,[TargetObjectName] = @TargetObjectName
				,[TargetObjectType] = @TargetObjectType
				,[TargetObjectDefinition] = @ObjectCreateScript

				,[EventData] = @Eventdata
			where
				@TargetObjectType in 
				(
					''PROCEDURE''
					,''VIEW''
					,''FUNCTION''
					,''SYNONYM''
					,''TABLE''
				)
			union all
			select
				[EventType] = ''DROP_RENAME_OLD''
				,[SchemaName] = @SchemaName
				,[ObjectName] = @ObjectName
				,[ObjectType] = @ObjectType
				,[TargetObjectName] = @ObjectName
				,[TargetObjectType] = @TargetObjectType
				,[TargetObjectDefinition] = ''DROP  '' +  @TargetObjectType + '' '' + quotename(@SchemaName) + ''.'' + quotename(@ObjectName)

				,[EventData] = @Eventdata
			where
				@EventType = ''RENAME''

        END TRY
        BEGIN CATCH
            SET @Eventdata= NULL;
        END CATCH
    END
END

'
		exec (@DynSQL)
		exec ('ENABLE TRIGGER [Trigger_Add_DbSchemaLog] ON DATABASE')

		
			
	end
else
	begin
		--if @TriggerEnabled = 1
		--	exec ('DISABLE TRIGGER [Trigger_Add_DbSchemaLog] ON DATABASE')
		exec ('DROP TRIGGER [Trigger_Add_DbSchemaLog] ON DATABASE')
	end
GO
