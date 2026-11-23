SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [app].[CheckParamType]
(
	@TypeParam nvarchar(4000)
	,@Type nvarchar(4000)
)
returns bit
as
begin
	return
		(
			select
				case
					when 
						exists
						(
							select Item from app.Split(@TypeParam, ',') 
							intersect
							select Item from app.Split(@Type, ',')
						)
						or
						@TypeParam is null
					then 1 else 0
					end
		)
end



GO
