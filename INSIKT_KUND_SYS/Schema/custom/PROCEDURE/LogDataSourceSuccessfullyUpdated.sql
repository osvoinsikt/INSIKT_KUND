SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create procedure [custom].[LogDataSourceSuccessfullyUpdated]
as
begin

	DECLARE
		@measureGroupID AS INT = NULL, -- Measure group id from DataSourcesMeasureGroup
		@eventDate AS DATETIME = GETUTCDATE(), -- Current datetime from function
		@dataUpdatedDate AS DATETIME = GETUTCDATE(),
		@status AS INT = 1, -- Status type from LogStatusType, 1 for success
		@message AS VARCHAR(500) = NULL -- Optional message

			SET @measureGroupID = 1
		 
		exec dbo.insDataSourceLog @measureGroupID, @eventDate, @dataUpdatedDate, @status, @message
	
			SET @measureGroupID = 4
		 
		exec dbo.insDataSourceLog @measureGroupID, @eventDate, @dataUpdatedDate, @status, @message
	
	end

GO
