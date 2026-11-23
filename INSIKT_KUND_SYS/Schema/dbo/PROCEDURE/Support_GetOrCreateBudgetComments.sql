SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Hämtar ut rätt CellCommentID eller skapar en ny om den inte redan finns. Kan användas
-- för en enskild kommentar eller för flera. SourceID används för att skilja på kommentarer
-- men det kan vara vilket heltal som helst och används bara för att gruppera ihop
-- dimensionskopplingar för en och samma kommentar.
--
-- Anroparen måste skapa och fylla tabellen #cellCommentDimensions med dimensionskopplingar
-- innan den här proceduren anropas.
--
-- #cellCommentDimensions ser ut som följande:
-- create table #cellCommentDimensions(
--     SourceID int NOT NULL, DimensionName nvarchar(100) NOT NULL, 
--		FullMemberName nvarchar(600) NOT NULL, ElementKey nvarchar(200) NOT NULL, 
--		CellCommentID int NULL)
--
-- SourceID är valfritt ID som grupperar ihop dimensionskopplingarna.
--
CREATE PROCEDURE [dbo].[Support_GetOrCreateBudgetComments]
	@fcTypeID int,
	@companyID int
AS
BEGIN
	set nocount on;

	if OBJECT_ID(N'tempdb..#cellCommentDimensions') is null begin
		-- Anroparen ska egentligen skapa och fylla den här tabellen.
		raiserror ('Tabellen %s finns ej.', 16, 10, '#cellCommentDimensions')	
	end
	
	-- Hämta redan existerande kommentarer
	;with dimensionCount as (
		select SourceID, count(*) as Count 
		from #cellCommentDimensions
		group by SourceID
	), toUpdate as (
		select c.ID as CellCommentID, f.SourceID
		from CellComment c
		inner join CellCommentDimension cd on cd.CellCommentID = c.ID
		inner join #cellCommentDimensions f on 
			cd.DimensionName = f.DimensionName 
			and isnull(cd.ElementKey, '') = isnull(f.ElementKey, '') 
			and isnull(cd.FullMemberName, '') = isnull(f.FullMemberName, '')
		inner join dimensionCount dc on f.SourceID = dc.SourceID
		where c.CompanyID = @companyID and c.FCTypeID = @fcTypeID
		group by c.ID, f.SourceID, dc.Count
		having count(cd.ID) = dc.Count
	)
	update f
	set f.CellCommentID = c.CellCommentID
	from toUpdate c
		inner join #cellCommentDimensions f on c.SourceID = f.SourceID
	
	-- Skapa nya för de som inte fanns
	-- Hämta ut kommentarer kopplade till angiven versio
	DECLARE comment_cursor CURSOR FOR 
		SELECT DISTINCT SourceID
		FROM #cellCommentDimensions
		WHERE CellCommentID IS NULL					

	OPEN comment_cursor

	DECLARE @commentSourceID int
	FETCH NEXT FROM comment_cursor
	INTO @commentSourceID

	WHILE @@FETCH_STATUS = 0
	BEGIN
		insert into CellComment(CompanyID, FCTypeID)
		values(@companyID, @fcTypeID)

		declare @cellCommentID int
		select @cellCommentID = @@IDENTITY

		insert into CellCommentDimension(CellCommentID, DimensionName, FullMemberName, ElementKey)
		select @cellCommentID, DimensionName, FullMemberName, ElementKey
		from #cellCommentDimensions
		where SourceID = @commentSourceID

		update #cellCommentDimensions
		set CellCommentID = @cellCommentID
		where SourceID = @commentSourceID

		FETCH NEXT FROM comment_cursor
		INTO @commentSourceID
	END

	CLOSE comment_cursor
	DEALLOCATE comment_cursor

END
GO
