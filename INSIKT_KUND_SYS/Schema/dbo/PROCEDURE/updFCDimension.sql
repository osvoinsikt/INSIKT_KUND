SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Linus Nilsson
-- Create date: 2015-02-10
-- Description: Ändrar en medlem i FCDimension och gör eventuella nödvändiga
--              ändringar i FCDimensionAncestorRelation.
-- =============================================
CREATE PROCEDURE [dbo].[updFCDimension]
	@companyID int,
	@fcTypeID int,
	@elementKey varchar(255),
	@newCaption nvarchar(255),
	@newLevel int,
	@newLevelUniqueName varchar(255),
	@newParentKey varchar(50)
AS
BEGIN
	SET NOCOUNT ON;

	declare @rowID int
	declare @oldParentKey varchar(255)

	select @rowID = ID,
		   @oldParentKey = ParentKey
	from FCDimension
	where FCTypeID = @fcTypeID
	  and CompanyID = @companyID
	  and ElementKey = @elementKey

	-- Uppdatera raden i FCDimension.
	update FCDimension
	set Caption = @newCaption,
		[Level] = @newLevel,
		LevelUniqueName = @newLevelUniqueName,
		ParentKey = @newParentKey
	where FCTypeID = @fcTypeID
	  and CompanyID = @companyID
	  and ElementKey = @elementKey

	-- Fixa FCDimensionAncestorRelation om föräldern har ändrats.
	if coalesce(@oldParentKey, '') <> coalesce(@newParentKey, '') begin
		create table #ancestors (
			AncestorID int
		)
		insert into #ancestors
		select AncestorID
		from FCDimensionAncestorRelation
		where DecendantID = @rowID

		create table #descendants (
			DescendantID int
		)
		insert into #descendants
		select DecendantID
		from FCDimensionAncestorRelation
		where AncestorID = @rowID

		-- Ta bort alla kopplingar från medlemmens avkommor till dess anfäder.
		-- Nya kopplingar skapas eventuellt senare.
		delete rel
		from FCDimensionAncestorRelation rel
		  inner join #ancestors a on a.AncestorID = rel.AncestorID
		  inner join #descendants d on d.DescendantID = rel.DecendantID

		-- Ta bort medlemmens kopplingar mot gamla anfäder.
		if @oldParentKey is not null begin
			delete from FCDimensionAncestorRelation
			where DecendantID = @rowID

			if not exists (select 1 from FCDimension
			               where FCTypeID = @fcTypeID
			                 and CompanyID = @companyID
			                 and ParentKey = @oldParentKey) begin
				-- Gamla föräldern är nu ett löv.
				update FCDimension
				set isLeaf = 1
				where FCTypeID = @fcTypeID
				  and CompanyID = @companyID
				  and ElementKey = @oldParentKey
			end
		end

		-- Koppla mot nya anfäderna.
		if @newParentKey is not null begin
			declare @newParentID int
			select @newParentID = ID
			from FCDimension
			where FCTypeID = @fcTypeID
			  and CompanyID = @companyID
			  and ElementKey = @newParentKey

			-- Nya föräldern.
			insert into FCDimensionAncestorRelation(AncestorID, DecendantID)
			values (@newParentID, @rowID)
		
			-- Nya förälderns anfäder.
			insert into FCDimensionAncestorRelation(AncestorID, DecendantID)
			select AncestorID, @rowID
			from FCDimensionAncestorRelation
			where DecendantID = @newParentID

			-- Nya föräldern är inte ett löv nu.
			update FCDimension
			set isLeaf = 0
			where ID = @newParentID

			-- Koppla medlemmens alla avkommor mot dess nya anfäder.
			insert into FCDimensionAncestorRelation(AncestorID, DecendantID)
			select rel.AncestorID, d.DescendantID
			from FCDimensionAncestorRelation rel
			  cross join #descendants d
			where rel.DecendantID = @rowID
		end
	end
END


GO
