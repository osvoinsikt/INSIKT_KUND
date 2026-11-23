SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [app].[GetParamList](@ParamList nvarchar(4000)) 
returns table 
as
return
	(
		select	
			ParamName = pn.Item
			,ParamValue = pv.Item
		from
			app.Split(@ParamList, ';') params
				outer apply (select * From app.Split(params.Item, '=') where ListPos = 1) pn
				outer apply (select * From app.Split(params.Item, '=') where ListPos = 2) pv
		)
GO
