SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [app].[FactSumView_Enable]
(
	@SourceFactTable nvarchar(512)	
	,@Debug bit = 0
)
as
exec app.FactSumView_Disable 
	@SourceFactTable = @SourceFactTable
	,@Enable = 1
	,@Debug = @Debug
GO
