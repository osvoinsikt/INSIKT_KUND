SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************
 #Desc: 		Selects all fcprojectproperies
 #Used By:		Project Prognosis Module
 #InParam:
 #ResultSet:		All project properties
 #
 #Returns:		-
 #Owner:		DBO
 #Creator:		Anders Holm
 #CreateDate:		110325
 #Modified by:	Daniel Hellström
 #ModifiedDate:		140214

 #Log:
		110325	ANHO	- Created
		160421	ORSE	- Added script for: Updated to respect property filters
		160429	CAAL	- Now return filter relations in a separate table. 
		161109	JOMA	- Now returns separate table listing properties that are used in visibility filters.
		201222	EMAH	- Ignore deleted project properties

********************************************************************/
CREATE             Procedure [dbo].[selFCProjectProperties]
	@fcTypeID int,
	@companyID int
AS

-- exec [selFCProjectProperties] 1,1

select
	p.*,
	HasPredefinedValues = CASE WHEN EXISTS(SELECT ID FROM FCProjectPropertyPredefinedValue WHERE FCProjectPropertyID = p.ID) THEN 1 ELSE 0 END,
	groupRel.ProjectPropertyGroupID
from FCProjectProperty p
	left join FCProjectPropertyGroupRelation groupRel on groupRel.ProjectPropertyID = p.ID
where FCTypeID = @fcTypeID and CompanyID = @companyID and isnull(p.IsDeleted, 0) = 0
order by SortOrder;

select p.ID, filterRel.FCProjectPropertyFilterID FROM 
 FCProjectProperty p
 JOIN FCProjectPropertyFilterRelation filterRel ON filterRel.FCProjectPropertyID = p.ID
 where FCTypeID = @fcTypeID and CompanyID = @companyID and isnull(p.IsDeleted, 0) = 0

select distinct p.ID FROM 
 FCProjectProperty p
 JOIN FCProjectPropertyFilterValue fv ON fv.FCProjectPropertyID = p.ID
 JOIN FCProjectPropertyFilterPart fp ON fp.ID = fv.FCProjectPropertyFilterPartID
 LEFT JOIN FCProjectPropertyFilterTabRelation fctr ON fctr.FCProjectPropertyFilterID = fp.FCProjectPropertyFilterID
 LEFT JOIN FCProjectPropertyFilterRelation r ON r.FCProjectPropertyFilterID = fp.FCProjectPropertyFilterID
 where p.FCTypeID = @fcTypeID and CompanyID = @companyID and (fctr.ID is not null or r.ID is not null) and isnull(p.IsDeleted, 0) = 0
GO
