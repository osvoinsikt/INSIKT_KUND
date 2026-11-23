SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [integration].[GetKPI]
(
	@JsonData nvarchar(max) output

	,@ReturnColumns nvarchar(max) = null
)
as

declare @LogID int = null
declare @DatasetName varchar(128) = 'KPI'
declare @CallingProcedure varchar(128) = quotename(object_schema_name(@@procid) ) + '.' + quotename(object_name(@@procid))

exec integrationInternal.EndpointUsageLogStart @Endpoint = @DatasetName, @CallingProcedure = @CallingProcedure, @LogID = @LogID output

exec integrationInternal.[GetDataset]
		@DatasetName = @DatasetName
		,@ReturnColumns = @ReturnColumns
		,@JsonData = @JsonData output

exec integrationInternal.EndpointUsageLogEnd @LogID = @LogID
GO
