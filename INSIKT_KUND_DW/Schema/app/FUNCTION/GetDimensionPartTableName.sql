SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [app].[GetDimensionPartTableName]
(
	@DimensionPartTypeID int
)
returns nvarchar(256)
with schemabinding
as
begin
	declare @TableName nvarchar(256)
	select 
		@TableName = '[dw].' + quotename('base_' + Name)
	from
		app.DimensionPartType
	where
		DimensionPartTypeID = @DimensionPartTypeID
	return @TableName
end
GO
