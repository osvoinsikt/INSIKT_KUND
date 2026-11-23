SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [app].[LogError]
(	 
	 @ErrorMessage nvarchar(4000) = null
	,@ErrorNumber int = null
	,@ErrorSeverity int = null
	,@ErrorState int = null
	,@ErrorProcedure nvarchar(128) = null
	,@ErrorLine int = null
	,@ErrorUser nvarchar(255) = null	
	,@EventLogID int = null
	,@ETLID int = null
)
as
set nocount on

if @ErrorMessage is null set @ErrorMessage = error_message()
if @ErrorNumber is null set @ErrorNumber = error_number()
if @ErrorSeverity is null set @ErrorSeverity = error_severity()
if @ErrorState is null set @ErrorState = error_state()
if @ErrorProcedure is null set @ErrorProcedure = error_procedure()
if @ErrorLine is null set @ErrorLine = error_line()

if @ErrorUser is null set @ErrorUser = suser_sname()
if @ErrorUser is null set @ErrorUser = convert(sysname, current_user)

begin try

	 IF xact_state() = -1
        begin
			-- The current request has an active user transaction, but an error has occurred that has caused
			-- the transaction to be classified as an uncommittable transaction.
            rollback transaction
        end


	if @EventLogID is not null
		begin		
			update app.EventLog set
				 ErrorCount = ErrorCount + 1
			where
				ID = @EventLogID 
				
			if @@ROWCOUNT = 0
				begin
					insert into app.ErrorLog
					(	
						[ETLID]
						,[SPID]				 
						,[ErrorUser]
						,[ErrorNumber]
						,[ErrorSeverity]
						,[ErrorState]
						,[ErrorProcedure]
						,[ErrorLine]
						,[ErrorMessage])
					values
					(
						@ETLID
						,@@SPID
						,@ErrorUser
						,@ErrorNumber
						,@ErrorSeverity
						,@ErrorState
						,@ErrorProcedure
						,@ErrorLine
						,'Unable to update EventLog with ID: ' + CAST(@EventLogID as nvarchar(12)) + ' because it does not exist.'
					)
					
					set @EventLogID = null
				end
		end



	insert into app.ErrorLog
	(
		 [ETLID]
		,[EventID]
		,[SPID]
		,[ErrorUser]
		,[ErrorNumber]
		,[ErrorSeverity]
		,[ErrorState]
		,[ErrorProcedure]
		,[ErrorLine]
		,[ErrorMessage])
	values
	(
		 @ETLID
		,@EventLogID
		,@@SPID
		,@ErrorUser
		,@ErrorNumber
		,@ErrorSeverity
		,@ErrorState
		,@ErrorProcedure
		,@ErrorLine
		,@ErrorMessage
	)
	return scope_identity()
end try
begin catch
	print 'An error occurred in stored procedure ' + object_name(@@procid);
    execute app.PrintError
    return -1;
end catch
GO
