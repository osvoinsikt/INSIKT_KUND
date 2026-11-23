SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[selCellCommentDimensionsByCommentTypeId]
	@CellCommentTypeId int
AS
BEGIN

	--declare @CellCommentTypeId int
	--set @CellCommentTypeId = 10

	select CellCommentID, DimensionName, HierarchyName, FullMemberName
	from CellCommentDimension
	where CellCommentTypeID = @CellCommentTypeId
	order by CellCommentID

END
GO
