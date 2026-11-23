SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [app].[ReThrowError] as
	   
-- Return if there is no error information to retrieve.
if error_number() is null
	return;

declare 
	@ErrorMessage    nvarchar(4000),
	@ErrorNumber     int,
	@ErrorSeverity   int,
	@ErrorState      int,
	@ErrorLine       int,
	@ErrorProcedure  nvarchar(200);

-- Assign variables to error-handling functions that 
-- capture information for RAISERROR.
select 
	@ErrorNumber = error_number(),
	@ErrorSeverity = error_severity(),
	@ErrorState = error_state(),
	@ErrorLine = error_line(),
	@ErrorProcedure = isnull(error_procedure(), '-');

-- Build the message string that will contain original
-- error information.
select @ErrorMessage = 
	N'Error %d, Level %d, State %d, Procedure %s, Line %d, ' + 
		'Message: '+ error_message();

-- Raise an error: msg_str parameter of RAISERROR will contain
-- the original error information.
raiserror 
	(
	@ErrorMessage, 
	@ErrorSeverity, 
	1,               
	@ErrorNumber,    -- parameter: original error number.
	@ErrorSeverity,  -- parameter: original error severity.
	@ErrorState,     -- parameter: original error state.
	@ErrorProcedure, -- parameter: original error procedure name.
	@ErrorLine       -- parameter: original error line number.
	);



GO
