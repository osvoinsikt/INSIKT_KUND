SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create function [app].[GetObjectFullName]
(
	@object_id int
) returns varchar(512) as
begin
	return
	(
		select
			'[' + s.name + '].[' + o.name + ']'
		from
			sys.objects o
				inner join sys.schemas s on
					s.schema_id = o.schema_id
				
		where
			o.object_id = @object_id
	)
	
end




GO
