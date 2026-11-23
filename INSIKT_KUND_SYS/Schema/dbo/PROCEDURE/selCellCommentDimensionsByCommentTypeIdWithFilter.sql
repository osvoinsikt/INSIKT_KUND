SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[selCellCommentDimensionsByCommentTypeIdWithFilter]
	@CellCommentTypeId int,
	@DimensionName nvarchar(255),
	@HierarchyName nvarchar(255),
	@FullMemberNames nvarchar(max)
AS
BEGIN
	
	--declare @CellCommentTypeId int, @DimensionName nvarchar(255), @HierarchyName nvarchar(255), @FullMemberNames nvarchar(max)
	--set @CellCommentTypeId = 10
	--set @DimensionName = 'Kostnadsställe'
	--set @HierarchyName = 'Organisation'
	--set @FullMemberNames = '[Kostnadsställe].[Organisation].[Land].&[748].&[750].&[754].&[759].&[431]¤[Kostnadsställe].[Organisation].[Land].&[748].&[750].&[764].&[756].&[432]'

	create table #temp (UniqueName nvarchar(max) collate database_default)
	insert into #temp (UniqueName)
	select strings from dbo.sepstring(@FullMemberNames, '¤')

	;with filter as (
    select distinct CellCommentID
    from CellCommentDimension d
		join #temp t on d.FullMemberName = t.UniqueName
    where CellCommentTypeID = @CellCommentTypeId
        and DimensionName = @DimensionName
        and HierarchyName = @HierarchyName
	)
	select d.CellCommentID, DimensionName, HierarchyName, FullMemberName
	from CellCommentDimension d
		inner join filter f on d.CellCommentID = f.CellCommentID
	order by CellCommentID

	drop table #temp

END
GO
