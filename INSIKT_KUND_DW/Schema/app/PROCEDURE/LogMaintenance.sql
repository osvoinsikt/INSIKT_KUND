SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [app].[LogMaintenance]
(
	@MonthsInLog int
	,@Reseed bit = 0
)
as
if not @MonthsInLog > 0 and @MonthsInLog <> -1
	begin
		raiserror('Parameter @MonthsInLog must be a supplied positive number of months or -1 to keep all log posts. Log postes older than that amount of months will be removed.', 16, 10);
		return;
	end


declare 
	@TranCount int = @@trancount
	,@RemoveEventLogsOlderThan datetime = dateadd(month, -@MonthsInLog, getdate())
	,@IntCloseToMax int = 2147483647 * 0.90 -- 90% of int max value	
	;

begin try
	if @MonthsInLog > 0
		begin
			declare @EventLogID int = 
				(
					select
						max(l.ID)
					from
						app.EventLog l with(nolock)
					where
						l.EventStart < @RemoveEventLogsOlderThan
				);
				

			if @TranCount = 0 begin tran;

				delete from app.ErrorLog where EventID <= @EventLogID;
				delete from app.EventLog where ID <= @EventLogID;

			if @TranCount = 0 commit tran;

		end

	if exists(select 1  from app.EventLog where ID >= @intCloseToMax)
		raiserror('EventLog ID is close to max int value. Consider reseeding log tables (set parameter @Reseed to 1)', 9, 0);
	
	if @Reseed = 1
		begin
			if @TranCount = 0 begin tran;

			declare @dmy int;
			select top 1 @dmy = 1 from app.EventLog with (tablockx);
			select top 1 @dmy = 1 from app.ErrorLog with (tablockx);
			with ETLID as
			(
				select distinct
					ETLID = ETLID			
				from
					app.EventLog
			)
			select
				ETLID
				,NewETLID = row_number() over (order by ETLID)
			into #EventLog_ETLID_Reseed_Temp
			from
				ETLID;

		
		

			select 
				NewEventLogId = row_number() over( order by ID)			
				,*
			into #EventLog_Reseed_Temp
			from 
				app.EventLog;
		
			select
				*
			into #ErrorLog_Reseed_Temp
			from
				app.ErrorLog;

			create index TMP_ErrorLog_Reseed_Temp on #ErrorLog_Reseed_Temp (ID);

			truncate table app.ErrorLog;
			delete from app.EventLog;
			dbcc checkident ('app.EventLog', reseed, 0);

			set identity_insert app.EventLog on;
			insert into app.EventLog
			(
				[ID], [ETLID], [SPID], [EventUser], [EventType], [EventObject], [EventStart], [EventStop], [EventTitle], [Description], [ParentEventID], [ErrorCount]
			)
			select
				[ID] = l.[NewEventLogId]
				,[ETLID] = e.[NewETLID]
				,[SPID] = l.[SPID]
				,[EventUser] = l.[EventUser]
				,[EventType] = l.[EventType]
				,[EventObject] = l.[EventObject]
				,[EventStart] = l.[EventStart]
				,[EventStop] = l.[EventStop]
				,[EventTitle] = l.[EventTitle]
				,[Description] = l.[Description]
				,[ParentEventID] = p.[NewEventLogId]
				,[ErrorCount] = l.[ErrorCount]
			from
				#EventLog_Reseed_Temp l
					left join #EventLog_Reseed_Temp p on
						p.ID = l.ParentEventID
					left join #EventLog_ETLID_Reseed_Temp e on
						e.ETLID = l.ETLID
			order by
				l.ID;

			set identity_insert app.EventLog off;
			insert into app.ErrorLog
			(
				[ETLID]
				,[EventID]
				,[SPID]
				,[ErrorTime]
				,[ErrorUser]
				,[ErrorNumber]
				,[ErrorSeverity]
				,[ErrorState]
				,[ErrorProcedure]
				,[ErrorLine]
				,[ErrorMessage]
			)
			select
				[ETLID] = etlid.[NewETLID]
				,[EventID] = l.NewEventLogId
				,[SPID] = e.[SPID]
				,[ErrorTime] = e.[ErrorTime]
				,[ErrorUser] = e.[ErrorUser]
				,[ErrorNumber] = e.[ErrorNumber]
				,[ErrorSeverity] = e.[ErrorSeverity]
				,[ErrorState] = e.[ErrorState]
				,[ErrorProcedure] = e.[ErrorProcedure]
				,[ErrorLine] = e.[ErrorLine]
				,[ErrorMessage] = e.[ErrorMessage]
			from
				#ErrorLog_Reseed_Temp e
					left join #EventLog_Reseed_Temp l on 
						l.ID = e.EventID
					left join #EventLog_ETLID_Reseed_Temp etlid on
						etlid.ETLID = e.ETLID;

			if @TranCount = 0 commit tran;
		end
end try
begin catch
	if @TranCount = 0 and @@TRANCOUNT > 0 rollback tran;
	throw;
end catch
GO
