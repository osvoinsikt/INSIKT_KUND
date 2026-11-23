SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [integration].[GetMaxVersionStamp]
(
	@DatasetNames nvarchar(max)
	,@MaxVersionStamp binary(8) output
)
as
declare 
	@DynSQL nvarchar(max)
	,@DynSQL_Param nvarchar(max)

	select 
		@DynSQL_Param = '@MaxVersionStamp binary(8) output'
		,@DynSQL = 
			N'select
				@MaxVersionStamp = MAX(MaxVersionStamp)
			from
				[integrationInternal].[MaxVersionStamp]
			where
				DatasetName in (
				' 
				+ 
				stuff
				(
					(
						select
							N',''' + replace(ltrim(rtrim(dsName.strings)), N'''', N'''''') + N''''
						from
							[dbo].[sepstring](@DatasetNames, N',') dsName
						for xml path, type
					).value(N'.[1]', N'nvarchar(max)')
					,1,1,N''
				)
				+ N')'

	exec sp_executesql 
		@DynSQL
		,@DynSQL_Param
		,@MaxVersionStamp output
GO
