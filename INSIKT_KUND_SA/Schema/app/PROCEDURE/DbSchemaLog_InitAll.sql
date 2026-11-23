SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure app.DbSchemaLog_InitAll as
declare 
	@ObjectID int
	,@SQL nvarchar(max)

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
		exec app.GetCreateTableScript
			@SQL = @SQL output
			,@object_id = @ObjectID

			
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
'<EVENT_INSTANCE>
  <EventType>LOG INIT</EventType>
  <PostTime>' + convert(nvarchar(50), getutcdate(), 127) + '</PostTime>
  <SPID>' + cast(@@SPID as nvarchar(12)) + '</SPID>
  <ServerName>' +  cast((select @@SERVERNAME for xml path(''), type) as nvarchar(max)) + '</ServerName>
  <LoginName>' +  cast((select SUSER_NAME() for xml path(''), type) as nvarchar(max)) + '</LoginName>
  <UserName>' +  cast((select USER_NAME() for xml path(''), type) as nvarchar(max)) + '</UserName>
  <DatabaseName>' +  cast((select db_name() for xml path(''), type) as nvarchar(max)) + '</DatabaseName>
  <SchemaName>' +  cast((select OBJECT_SCHEMA_NAME(@ObjectID) for xml path(''), type) as nvarchar(max)) + '</SchemaName>
  <ObjectName>' +  cast((select o.name for xml path(''), type) as nvarchar(max)) + '</ObjectName>
  <ObjectType>TABLE</ObjectType>
  <TSQLCommand>    
    <CommandText>' + cast((select @SQL for xml path(''), type) as nvarchar(max)) + '</CommandText>
  </TSQLCommand>
</EVENT_INSTANCE>
' as xml)
		from
			sys.objects o
		where
			o.object_id = @ObjectID
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
	from
		sys.objects o
			left join sys.synonyms syn on
				syn.object_id = o.object_id
			left join sys.sql_modules m on
				m.object_id = o.object_id
	where
		o.type in ('P', 'V', 'FN', 'IF', 'SN')
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
	[EventType] = 'LOG INIT'
	,[SchemaName] = o.[SchemaName]
	,[ObjectType] = o.[ObjectType]
	,[ObjectName] = o.ObjectName
	,[TargetObjectName] = o.ObjectName
	,[TargetObjectType] = o.[ObjectType]
	,[TargetObjectDefinition] = o.[TargetObjectDefinition]
	,[DbSchemaLogBatchID] = null
	,[EventData] = cast(
'<EVENT_INSTANCE>
  <EventType>LOG INIT</EventType>
  <PostTime>' + convert(nvarchar(50), getutcdate(), 127) + '</PostTime>
  <SPID>' + cast(@@SPID as nvarchar(12)) + '</SPID>
  <ServerName>' +  cast((select @@SERVERNAME for xml path(''), type) as nvarchar(max)) + '</ServerName>
  <LoginName>' +  cast((select SUSER_NAME() for xml path(''), type) as nvarchar(max)) + '</LoginName>
  <UserName>' +  cast((select USER_NAME() for xml path(''), type) as nvarchar(max)) + '</UserName>
  <DatabaseName>' +  cast((select db_name() for xml path(''), type) as nvarchar(max)) + '</DatabaseName>
  <SchemaName>' +  cast((select o.[SchemaName] for xml path(''), type) as nvarchar(max)) + '</SchemaName>
  <ObjectName>' +  cast((select o.ObjectName for xml path(''), type) as nvarchar(max)) + '</ObjectName>
  <ObjectType>' +  cast((select o.[ObjectType] for xml path(''), type) as nvarchar(max)) + '</ObjectType>
  <TSQLCommand>    
    <CommandText>' + cast((select o.[TargetObjectDefinition] for xml path(''), type) as nvarchar(max)) + '</CommandText>
  </TSQLCommand>
</EVENT_INSTANCE>
' as xml)
from
	ObjectData o
GO
