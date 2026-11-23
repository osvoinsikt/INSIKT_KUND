SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [app].[DbSchemaLog_InitAll] as
declare 
	@ObjectID int
	,@SQL nvarchar(max)
	,@LastLogDefinition nvarchar(max)
	,@EventType nvarchar(50);

with LastLogId as
(
	select
		l.SchemaName
		,l.TargetObjectType
		,l.TargetObjectName
		,MaxID = max(Id)
	from
		app.DbSchemaLog l
	group by
		l.SchemaName
		,l.TargetObjectName
		,l.TargetObjectType
)
select
	object_id = object_id(quotename(l.SchemaName) + '.' + quotename(l.TargetObjectName))
	,l.*
into
	#LastLogEntry
from
	LastLogId ll
		inner join app.DbSchemaLog l on
			l.Id = ll.MaxID
		


--
-- INIT för tabeller
--
select
	@ObjectID = min(object_id)
from
	sys.objects o
where
	o.type = 'U'
while @ObjectID is not null
	begin
		set @SQL= null		
		set @LastLogDefinition = null
		exec app.GetCreateTableScript
			@SQL = @SQL output
			,@object_id = @ObjectID

		
		select 
			@LastLogDefinition = TargetObjectDefinition
		from
			#LastLogEntry
		where
			object_id = @ObjectID
		set @EventType = 
			case
				when @LastLogDefinition is null and @SQL is not null then 'LOG INIT'
				when @LastLogDefinition <> @SQL then 'LOG REINIT'
				else null
			end
		
			
		if @EventType is not null
			begin
				INSERT INTO [app].[DbSchemaLog]
				(
					[EventType]
				   ,[SchemaName]
				   ,[ObjectType]
				   ,[ObjectName]
				   ,[TargetObjectName]
				   ,[TargetObjectType]
				   ,[TargetObjectDefinition]
				   ,[DbSchemaLogBatchID]
				   ,[EventData]
				  )		  		  
				  select
						[EventType] = 'LOG INIT'
					   ,[SchemaName] = OBJECT_SCHEMA_NAME(@ObjectID)
					   ,[ObjectType] = 'TABLE'
					   ,[ObjectName] = o.name
					   ,[TargetObjectName] = o.name
					   ,[TargetObjectType] = 'TABLE'
					   ,[TargetObjectDefinition] = @SQL
					   ,[DbSchemaLogBatchID] = null
					   ,[EventData] = cast(
N'<EVENT_INSTANCE>
	<EventType>' + @EventType + N'</EventType>
	<PostTime>' + convert(nvarchar(50), getutcdate(), 127) + N'</PostTime>
	<SPID>' + cast(@@SPID as nvarchar(12)) + N'</SPID>
	<ServerName>' +  cast((select @@SERVERNAME for xml path(''), type) as nvarchar(max)) + N'</ServerName>
	<LoginName>' +  cast((select SUSER_NAME() for xml path(''), type) as nvarchar(max)) + N'</LoginName>
	<UserName>' +  cast((select USER_NAME() for xml path(''), type) as nvarchar(max)) + N'</UserName>
	<DatabaseName>' +  cast((select db_name() for xml path(''), type) as nvarchar(max)) + N'</DatabaseName>
	<SchemaName>' +  cast((select OBJECT_SCHEMA_NAME(@ObjectID) for xml path(''), type) as nvarchar(max)) + N'</SchemaName>
	<ObjectName>' +  cast((select o.name for xml path(''), type) as nvarchar(max)) + N'</ObjectName>
	<ObjectType>TABLE</ObjectType>
	<TSQLCommand>    
	<CommandText>' + cast((select @SQL for xml path(''), type) as nvarchar(max)) + N'</CommandText>
	</TSQLCommand>
</EVENT_INSTANCE>
' as xml)
				from
					sys.objects o
				where
					o.object_id = @ObjectID
			end
		select
			@ObjectID = min(object_id)
		from
			sys.objects o
		where
			o.type = 'U'
			and o.object_id > @ObjectID
	end

--
-- Init för övriga procedurer, vyer osv.
--
;with ObjectData as
(
	 select
		[SchemaName] = SCHEMA_NAME(o.schema_id)
		,[ObjectType] = 
			case o.type
				when 'P' then 'PROCEDURE'
				when 'V' then 'VIEW'
				when 'IF' then 'FUNCTION'
				when 'FN' then 'FUNCTION'
				when 'SN' then 'SYNONYM'
			end
		,ObjectName = o.name
		,TargetObjectDefinition = 
			coalesce
			(
				m.[definition]
				,'CREATE SYNONYM ' + quotename(SCHEMA_NAME(syn.schema_id)) + '.' + quotename(syn.name) + ' FOR ' + syn.base_object_name
			)
		,LastLogTargetObjectDefinition = ll.TargetObjectDefinition
		,EventPrefix = ''
	from
		sys.objects o
			left join sys.synonyms syn on
				syn.object_id = o.object_id
			left join sys.sql_modules m on
				m.object_id = o.object_id
			left join #LastLogEntry ll on
				ll.object_id = o.object_id
	where
		o.type in ('P', 'V', 'FN', 'IF', 'SN')
	union all
	select
		[SchemaName] = ll.SchemaName
		,[ObjectType] = ll.TargetObjectType
		,ObjectName = ll.TargetObjectName
		,TargetObjectDefinition = 
			N'DROP ' + ll.TargetObjectType + N' ' + quotename(ll.SchemaName) + '.' + quotename(ll.TargetObjectName)
			
		,LastLogTargetObjectDefinition = ll.TargetObjectDefinition
		,EventPrefix = 'DROP_'
	
	from
		#LastLogEntry ll	
	where
		ll.object_id is null
		and ll.TargetObjectType in
		(
			'PROCEDURE'
			,'VIEW'
			,'FUNCTION'
			,'SYNONYM'
			,'TABLE'
		)
	
)
INSERT INTO [app].[DbSchemaLog]
(
	[EventType]
    ,[SchemaName]
    ,[ObjectType]
    ,[ObjectName]
    ,[TargetObjectName]
    ,[TargetObjectType]
    ,[TargetObjectDefinition]
    ,[DbSchemaLogBatchID]
    ,[EventData]
	)		
select
	[EventType] = EventPrefix +
		case
			when o.[LastLogTargetObjectDefinition] is null and o.[TargetObjectDefinition] is not null then 'LOG INIT'
			when o.[LastLogTargetObjectDefinition] <> o.[TargetObjectDefinition] then 'LOG REINIT'
		end
	,[SchemaName] = o.[SchemaName]
	,[ObjectType] = o.[ObjectType]
	,[ObjectName] = o.ObjectName
	,[TargetObjectName] = o.ObjectName
	,[TargetObjectType] = o.[ObjectType]
	,[TargetObjectDefinition] = o.[TargetObjectDefinition]
	,[DbSchemaLogBatchID] = null
	,[EventData] = cast(
N'<EVENT_INSTANCE>
  <EventType>' + EventPrefix +
	case
		when o.[LastLogTargetObjectDefinition] is null and o.[TargetObjectDefinition] is not null then N'LOG INIT'
		when o.[LastLogTargetObjectDefinition] <> o.[TargetObjectDefinition] then N'LOG REINIT'
		else N'Error'
	end 
+ N'</EventType>
  <PostTime>' + convert(nvarchar(50), getutcdate(), 127) + N'</PostTime>
  <SPID>' + cast(@@SPID as nvarchar(12)) + N'</SPID>
  <ServerName>' +  cast((select @@SERVERNAME for xml path(''), type) as nvarchar(max)) + N'</ServerName>
  <LoginName>' +  cast((select SUSER_NAME() for xml path(''), type) as nvarchar(max)) + N'</LoginName>
  <UserName>' +  cast((select USER_NAME() for xml path(''), type) as nvarchar(max)) + N'</UserName>
  <DatabaseName>' +  cast((select db_name() for xml path(''), type) as nvarchar(max)) + N'</DatabaseName>
  <SchemaName>' +  cast((select o.[SchemaName] for xml path(''), type) as nvarchar(max)) + N'</SchemaName>
  <ObjectName>' +  cast((select o.ObjectName for xml path(''), type) as nvarchar(max)) + N'</ObjectName>
  <ObjectType>' +  cast((select o.[ObjectType] for xml path(''), type) as nvarchar(max)) + N'</ObjectType>
  <TSQLCommand>    
    <CommandText>' + cast((select o.[TargetObjectDefinition] for xml path(''), type) as nvarchar(max)) + N'</CommandText>
  </TSQLCommand>
</EVENT_INSTANCE>
' as xml)
from
	ObjectData o
where
	(o.[LastLogTargetObjectDefinition] is null and o.[TargetObjectDefinition] is not null) -- LOG INIT
	or (o.[LastLogTargetObjectDefinition] <> o.[TargetObjectDefinition]) -- LOG REINIT
GO
