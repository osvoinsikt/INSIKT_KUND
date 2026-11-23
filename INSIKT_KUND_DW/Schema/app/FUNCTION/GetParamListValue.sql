SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [app].[GetParamListValue]
(
	@ParamList nvarchar(4000)
	,@ParamName nvarchar(128)
	,@DefaultValue nvarchar(1024)
)
returns nvarchar(4000)
as
begin
return
		stuff
		(
			(
				select
					';' + isnull(ParamValue, @DefaultValue)
				from
					app.GetParamList(@ParamList)
				where
					ParamName = @ParamName
				FOR XML PATH, TYPE
			).value('.[1]','nvarchar(max)')
			,1,1,''
		)
end
GO
