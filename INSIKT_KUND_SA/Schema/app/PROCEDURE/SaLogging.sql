SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [app].[SaLogging]
(
	@LogToDatabase sysname = '?'
)
as
set nocount on;
--
-- Standardvariabler
--
declare @ProcName sysname, @TranCount int, @EventIDStack varbinary(max)
set @ProcName = app.GetObjectFullName(@@procid)
set @TranCount = @@trancount


select
	LogType = syn.name
	,LogToDatabase = quotename(isnull(PARSENAME(syn.base_object_name, 3), DB_NAME()))
into #synonyms
from
	sys.synonyms syn
		inner join sys.schemas s on
			s.schema_id = syn.schema_id
where
	s.name = 'app'
	and syn.name in ('EventLog', 'ErrorLog')



if @LogToDatabase = '?'
	begin
		set @LogToDatabase = null
		
		select distinct
			@LogToDatabase = LogToDatabase
		from
			#synonyms

		
		if @@ROWCOUNT > 1
			begin				
				raiserror ('Fel, loggning av händelser och fel sker till olika databaser!
Kör denna procedur med databasnamn som inparameter för att återställa konfigurationen.', 16, 10)
			end
		else if (select count(*) from #synonyms) <> 2
			begin
				raiserror ('Fel, synonymer för loggning saknas.
Kör denna procedur med databasnamn som inparameter för att återställa konfigurationen.', 16, 10)				
			end
		else
			print 'Loggning sker till databasen ' + @LogToDatabase
		print ''
		print 'För att logga till annan databas kör:'
		print 'exec ' + @ProcName + ' <databasnamn>'
		print 'NULL som <databasnamn> ger loggning till lokal SA-databas.'
	end
else
	begin 
		if @LogToDatabase is null
			set @LogToDatabase = db_name()

		set @LogToDatabase = quotename(parsename(@LogToDatabase, 1))

		declare @DynSQL nvarchar(max)
		select
			@DynSQL = isnull(@DynSQL, '') +
				'drop synonym ' + quotename(s.name) + '.' + quotename(syn.name) + ';'
		from
			sys.synonyms syn
				inner join sys.schemas s on
					s.schema_id = syn.schema_id
		where
			s.name = 'app'
			and syn.name in ('EventLog', 'ErrorLog')
	
		
		if db_id(db_name()) = db_id(parsename(@LogToDatabase,1))
			begin
				--
				-- Logga till lokala loggtabeller
				--
				select @DynSQL = @DynSQL +
					'CREATE SYNONYM [app].[EventLog] FOR [app].[SaEventLog];'
				select @DynSQL = @DynSQL +
					'CREATE SYNONYM [app].[ErrorLog] FOR [app].[SaErrorLog];'
			end
		else
			begin
				--
				-- Logga till DW-databas
				--
				select @DynSQL = @DynSQL +
					'CREATE SYNONYM [app].[EventLog] FOR ' + @LogToDatabase + '.[app].[EventLog];'
				select @DynSQL = @DynSQL +
					'CREATE SYNONYM [app].[ErrorLog] FOR ' + @LogToDatabase + '.[app].[ErrorLog];'
			end
		exec (@DynSQL)

		print 'Loggning sker nu till databasen ' + @LogToDatabase	
	end
	
	drop table #synonyms



GO
