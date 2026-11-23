SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [integration].[PutKPITargetValue]
(
	@JsonData nvarchar(max)	
	,@JsonResult nvarchar(max) = null output
	,@AsyncResult bit = 1
)
as

declare @LogID int = null
declare @DatasetName varchar(128) = 'KPITargetValue_Input'
declare @CallingProcedure varchar(128) = quotename(object_schema_name(@@procid) ) + '.' + quotename(object_name(@@procid))

exec integrationInternal.EndpointUsageLogStart @Endpoint = @DatasetName, @CallingProcedure = @CallingProcedure, @LogID = @LogID output

declare @ReturnStatus int = 0 -- Success
exec @ReturnStatus = integrationInternal.PutDataset
	@DatasetName = @DatasetName
	,@JsonData = @JsonData
	,@JsonResult = @JsonResult output
	,@AsyncResult = @AsyncResult
	
exec integrationInternal.EndpointUsageLogEnd @LogID = @LogID

return @ReturnStatus;
GO
