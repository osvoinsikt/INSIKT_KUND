SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [integration].[GetKPITargetValue]
(
	@JsonData nvarchar(max) output
	,@ChangesAfterVersionStamp binary(8) =null
	,@KPIKey nvarchar(512) = null
	,@OrganisationMemberElementKey nvarchar(512) = null
	,@ReturnColumns nvarchar(max) = null
)
as

declare @LogID int = null
declare @DatasetName varchar(128) = 'KPITargetValue_Output'
declare @CallingProcedure varchar(128) = quotename(object_schema_name(@@procid) ) + '.' + quotename(object_name(@@procid))

exec integrationInternal.EndpointUsageLogStart @Endpoint = @DatasetName, @CallingProcedure = @CallingProcedure, @LogID = @LogID output

declare @DatasetFilter nvarchar(max)
set @DatasetFilter =
				N'1 = 1 ' + ISNULL(N'
				and KPIKey = ''' + replace(@KPIKey, '''', '''''') + ''''
				,N'' ) + ISNULL(N'
				and OrganisationMemberElementKey = ''' + replace(@OrganisationMemberElementKey, '''', '''''') + ''''
				,N'' ) + ISNULL(N'
				and VersionStamp >' + convert(nvarchar(max), @ChangesAfterVersionStamp, 1)
				,N'' ) 


exec integrationInternal.GetDataset
	@DatasetName = @DatasetName
	,@JsonData = @JsonData output
	,@ReturnColumns = @ReturnColumns
	,@DatasetFilter = @DatasetFilter

exec integrationInternal.EndpointUsageLogEnd @LogID = @LogID
GO
