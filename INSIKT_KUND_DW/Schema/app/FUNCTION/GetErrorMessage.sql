SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function app.GetErrorMessage
(	
)
returns nvarchar(max)
as
BEGIN
	declare 
		@ErrorMessage    nvarchar(4000),
		@ErrorNumber     int,
		@ErrorSeverity   int,
		@ErrorState      int,
		@ErrorLine       int,
		@ErrorProcedure  nvarchar(200);

	select
		@ErrorMessage = error_message(),
		@ErrorNumber = error_number(),
		@ErrorSeverity = error_severity(),
		@ErrorState = error_state(),
		@ErrorLine = error_line(),
		@ErrorProcedure = isnull(error_procedure(), '-');

	-- Build the message string that will contain original
	-- error information.


	

	
	-- Return the result of the function
	return formatmessage 
		(
			N'Error %d, Level %d, State %d, Procedure %s, Line %d, Message: %s', 		             
			@ErrorNumber,    -- parameter: original error number.
			@ErrorSeverity,  -- parameter: original error severity.
			@ErrorState,     -- parameter: original error state.
			@ErrorProcedure, -- parameter: original error procedure name.
			@ErrorLine,       -- parameter: original error line number.
			@ErrorMessage
		);
end
GO
