SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*******************************************************************
 #Desc: 			Select all FCTypeIDs where a user has an organisation relation.
					Ignores relations for the Analyzer role type, since it does not give access to planning types.
 #Used By:			-
 #InParam:			-
 #ResultSet:		-
 #
 #Returns:			-
 #Owner:			DBO
 #Creator:			Daniel Hellström
 #CreateDate:		080928
 #Modified by:		-
 #ModifiedDate:		-
 
 #Log:
		080928 DH	Created
		120605 ADHO Modified to include FCProjectUserRelation
		140428 LINI Kolla projektegenskaper markerade som isUser.
		170316 CAAL Joinar mot FCDimension för att kolla att kopplingen är giltig
		170911 CAAL Joinar INTE mot FCDimension om FCProjectID är null
		180108 LINI Går inte sönder om FCDimension.ElementKey är icke-numerisk vid join med ProjectID.
		190430 LINI Ger ingen åtkomst genom FCRoleType Custom.
		190430 LINI Ger ingen åtkomst där HideMemberFromMainDimension används.
		251201 LINI Ger tillbaka åtkomst till FCRoleType Custom.

********************************************************************/
CREATE Procedure [dbo].[selFCTypesForUser]
			@UserID int
	
AS
BEGIN
	-- selFCTypesForUser 12

	set nocount on

	declare @UserName nvarchar(255) = (select UserName from UserSecurityGroup where UserID = @UserID)

	-- Members hidden by FCProperty HideMemberFromMainDimension
	select ElementKey, FCTypeID, CompanyID
	into #HiddenMembers
	from FCElementProperty
	where PropertyID = 280 and ValueNumeric = 1
	union
	select des.ElementKey, des.FCTypeID, des.CompanyID
	from FCElementProperty ep
		join FCDimension anc
			on ep.ElementKey = anc.ElementKey
				and ep.FCTypeID = anc.FCTypeID
				and ep.CompanyID = anc.CompanyID
		join FCDimensionAncestorRelation rel on anc.ID = rel.AncestorID
		join FCDimension des on rel.DecendantID = des.ID
	where ep.PropertyID = 280 and ep.ValueNumeric = 1

	SELECT DISTINCT uor.FCTypeID
	FROM UserOrganisationRelation uor
		join [FCDimension] o
			on uor.FCElementKey = o.ElementKey
				and uor.FCTypeID = o.FCTypeID
				and uor.CompanyID = o.CompanyID
		join FCRole r on r.ID = uor.RoleID
		left join #HiddenMembers hidden
			on uor.FCTypeID = hidden.FCTypeID
				and uor.CompanyID = hidden.CompanyID
				and uor.FCElementKey = hidden.ElementKey
	WHERE uor.UserID = @UserID
		-- Ignore the Analyzer role type.
		and r.RoleTypeID <= 5
		-- Not hidden by HideMemberFromMainDimension.
		and hidden.ElementKey is null

	UNION

	-- FCProjectUserRelation where FCProjectID has a value
	-- This will return FCTypeIDs for users connected to a project
	SELECT DISTINCT pur.FCTypeID
	FROM FCProjectUserRelation pur
		join FCProject p on p.ID = pur.FCProjectID
		join FCDimension o
			on cast(pur.FCProjectID as varchar(20)) = o.ElementKey
				and pur.FCTypeID = o.FCTypeID
				and pur.CompanyID = o.CompanyID
		join FCRole r on r.ID = pur.FCRoleID
	WHERE pur.UserID = @UserID
		and IsNull(p.isDeleted, 0) = 0
		-- Ignore the Analyzer role type.
		and r.RoleTypeID <= 5


	UNION
	
	-- FCProjectUserRelation where FCProjectID DOESN'T have a value
	-- This will return FCTypeIDs for users connected to a Grouping or All Level
	SELECT DISTINCT pur.FCTypeID
	FROM FCProjectUserRelation pur
		join FCRole r on r.ID = pur.FCRoleID
	WHERE pur.UserID = @UserID
		and pur.FCProjectID is null
		-- Ignore the Analyzer role type.
		and r.RoleTypeID <= 5

	UNION

	-- Connections through project properties.
	SELECT DISTINCT pp.FCTypeID
	FROM FCProjectProperty pp
		INNER JOIN FCProjectPropertyValue ppv on ppv.ProjectPropertyID = pp.ID
		INNER JOIN FCProject p on p.ID = ppv.ProjectID
		INNER JOIN FCDimension o
			on cast(ppv.ProjectID as varchar(20)) = o.ElementKey 
				AND o.FCTypeID = pp.FCTypeID
				AND o.CompanyID = pp.CompanyID
	WHERE pp.isUser = 1
		AND ((pp.Datatype = 'string' AND ppv.ValueString = @UserName)
			OR (pp.Datatype = 'numeric' AND ppv.ValueNumeric = @UserID))
		AND IsNull(p.isDeleted, 0) = 0

	drop table #HiddenMembers
END
GO
