SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************
 #Desc: 		Inserts into FCDimension
 #Used By:		-
 #InParam:		-
 #ResultSet:		-
 #
 #Returns:		-
 #Owner:		DBO
 #Creator:		Daniel Hellström
 #CreateDate:		120102
 #Modified by:		Daniel Hellström
 #ModifiedDate:		-
 #Modified by:		-
 
 #Log:

********************************************************************/
CREATE  Procedure [dbo].[insFCDimension]
	@vsDimensionName varchar(50)
	,@nCompanyID int
	,@nFCTypeID int
	,@vsElementKey varchar (50)
	,@vsCaption nvarchar(255)
	,@vsUniqueName varchar(255)
	,@nLevel int
	,@vsLevelUniqueName varchar(255)
	,@vsParentKey varchar(255)
	,@bIsLeaf bit
	,@nSortOrder int
	,@nRowID int output

AS

-- [insFCDimension]

insert into FCDimension
	(
	DimensionName
	,CompanyID --,UserID
	,FCTypeID
	,ElementKey
	,Caption
	,UniqueName
	,[Level]
	,LevelUniqueName
	,ParentKey
	,isLeaf
	,SortOrder
	)
values
	(
	@vsDimensionName
	,@nCompanyID
	,@nFCTypeID
	,@vsElementKey
	,@vsCaption
	,@vsUniqueName
	,@nLevel
	,@vsLevelUniqueName
	,@vsParentKey
	,@bIsLeaf
	,@nSortOrder
	)

if @@error <> 0 goto err

set @nRowID = @@identity

if @vsParentKey is not null begin
	declare @parentID int
	select @parentID = ID 
	from FCDimension
	where FCTypeID = @nFCTypeID
		AND CompanyID = @nCompanyID
		AND ElementKey = @vsParentKey

	if @parentID is not null begin
		-- Koppla mot föräldern.
		insert into FCDimensionAncestorRelation(AncestorID, DecendantID)
		values (@parentID, @nRowID)
		
		-- Koppla mot förälderns anfäder.
		insert into FCDimensionAncestorRelation(AncestorID, DecendantID)
		  select AncestorID, @nRowID
		  from FCDimensionAncestorRelation where DecendantID = @parentID

		-- Sätt föräldern till inte vara ett löv längre
		UPDATE FCDimension
		SET isLeaf = 0
		WHERE ID = @parentID
	end
end

return

err:
	raiserror ('Misslyckades att lägga till rad i FCDimension.',16,1)
	return (-100)


GO
