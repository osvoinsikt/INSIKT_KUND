SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create procedure [integration].[GetScorecardOrganisationMember]
(
	@JsonData nvarchar(max) output

	,@ReturnColumns nvarchar(max) = null
)
as

declare @LogID int = null
declare @DatasetName varchar(128) = 'ScorecardOrganisationMember'
declare @CallingProcedure varchar(128) = quotename(object_schema_name(@@procid) ) + '.' + quotename(object_name(@@procid))

exec integrationInternal.EndpointUsageLogStart @Endpoint = @DatasetName, @CallingProcedure = @CallingProcedure, @LogID = @LogID output

declare
	@DynSQL nvarchar(max)
	,@DynSQLParam nvarchar(max)

if @ReturnColumns <> ''
	select
		@ReturnColumns =
			stuff
			(
				(
					select
						ColumnList = ',' + quotename(resultCol.[Name])
					from
						(
							select
								[Name] = c.[Name]
							from
								(
									values		
										('ElementKey')	
		
								)c([Name])
							union
							select
								[Name] = parsename(ltrim(ltrim(strings)), 1)
							from
								[dbo].[sepstring](@ReturnColumns, ',')
						) resultCol
					for xml path, type
				).value(N'.[1]', N'nvarchar(max)')
				,1,1,''
			)
select
	@DynSQLParam = '@JsonData nvarchar(max) output'
	,@DynSQL = N'
select
	@JsonData = 
		(
			select
				' + isnull(@ReturnColumns, N'*') + N'
			from
				integrationInternal.ScorecardOrganisationMember
			
			for json auto
		);'
exec sp_executesql @DynSQL, @DynSQLParam,  
	@JsonData = @JsonData output;	

exec integrationInternal.EndpointUsageLogEnd @LogID = @LogID
GO
