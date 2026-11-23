SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [app].[DbSchemaLogView] as
select 
	ID = l.Id
	,l.[DateTime]
	,LoginName = l.[Eventdata].value('(/EVENT_INSTANCE/LoginName)[1]', 'nvarchar(128)')
	,[UserName] = l.[Eventdata].value('(/EVENT_INSTANCE/UserName)[1]', 'nvarchar(128)')
	,EventType = l.EventType
	,l.SchemaName
	,l.ObjectType
	,l.ObjectName
	,l.TargetObjectType
	,l.TargetObjectName
	,l.TargetObjectDefinition
	,TargetObjectRowVersionID = 
		row_number() over
		(
			partition by
				l.SchemaName
				,l.TargetObjectType
				,l.TargetObjectName
			order by
				l.Id
		)	
	,ChangeScript = l.[Eventdata].value('(/EVENT_INSTANCE/TSQLCommand/CommandText)[1]', 'nvarchar(max)')
	,ChangedTargetDefinition =
		iif
		(
			Lag(l.TargetObjectDefinition, 1) over
			(
				partition by
					l.SchemaName
					,l.TargetObjectType
					,l.TargetObjectName
				order by l.Id
			)
			=
			l.TargetObjectDefinition
			,
			0
			,
			1
		)

From 
	app.DbSchemaLog l



GO
