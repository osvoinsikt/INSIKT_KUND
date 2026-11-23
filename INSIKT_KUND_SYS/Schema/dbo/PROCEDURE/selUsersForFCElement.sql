SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************
 #Desc: 		Selects all users for a FCElement
 #Used By:		-
 #InParam:		-
 #ResultSet:		All users for the specified FCElement
 #
 #Owner:		DBO
 #Creator:		Daniel Hellström
 #CreateDate:		060821
 #Modified by:		Jonas Markström
 #ModifiedDate:		171011
 
 #Log:
		080314	ANHO	Remake to match new admin. Added FCTypeID, CompanyID
		090416	ANHO	Changed to return all users and roles for a given ElementKey
		090416	ANHO	Added tmp-tables to speed things up when using DISTINCT
		171011  JOMA    Uses UserSecurityGroup instead of [User] due to performance

********************************************************************/
CREATE Procedure [dbo].[selUsersForFCElement]
	@vsFCElementKey varchar(20)
	,@iCompanyID int
	,@iFCTypeID int
AS

DECLARE @isLeaf bit
SELECT @isLeaf = isLeaf 
FROM FCDimension 
WHERE	ElementKey = @vsFCElementKey
AND		[CompanyID] = @iCompanyID
AND		[FCTypeID] = @iFCTypeID

IF (@isLeaf = 1)
BEGIN
		-- Lägger till de uor-som är kopplade på en högre nivå
		SELECT 
				uor.[UserID],
				rt.ID as RoleTypeID,
				rt.Name as RoleType,
				r.[Order] as RoleOrder,
				u.[UserName], 
				u.[FullName],
				u.[EmailAdress],
				r.SortOrder
		INTO #tmp1
		FROM [UserOrganisationRelation] uor
		INNER JOIN UserSecurityGroup u on (uor.[UserID] = u.[UserID] AND u.IsDeleted = 0)
		INNER JOIN FCRole r on uor.RoleID = r.ID
		INNER JOIN FCRoleType rt on r.RoleTypeID = rt.ID
		INNER JOIN FCDimension oAncestor on uor.FCElementKey = oAncestor.ElementKey
		INNER JOIN FCDimensionAncestorRelation fdar on oAncestor.[ID] = fdar.[AncestorID]
		INNER JOIN FCDimension oDecendant on fdar.DecendantID = oDecendant.ID and oDecendant.[ElementKey] = @vsFCElementKey

		WHERE 		uor.[CompanyID] = @iCompanyID
				AND	uor.[FCTypeID] = @iFCTypeID
				AND	oAncestor.[CompanyID] = @iCompanyID
				AND	oAncestor.[FCTypeID] = @iFCTypeID
				AND	oDecendant.[CompanyID] = @iCompanyID
				AND	oDecendant.[FCTypeID] = @iFCTypeID

		-- Lägger till de uor-som är kopplade på lägsta nivå
		SELECT 
				uor.[UserID],
				rt.ID as RoleTypeID,
				rt.Name as RoleType,
				r.[Order] as RoleOrder, 
				u.[UserName], 
				u.[FullName],
				u.[EmailAdress],
				r.SortOrder
		INTO #tmp2
		FROM [UserOrganisationRelation] uor
		INNER JOIN UserSecurityGroup u on (uor.[UserID] = u.[UserID] AND u.IsDeleted = 0)
		INNER JOIN FCRole r on uor.RoleID = r.ID
		INNER JOIN FCRoleType rt on r.RoleTypeID = rt.ID
		
		WHERE 		uor.[FCElementKey] = @vsFCElementKey
				AND	uor.[CompanyID] = @iCompanyID
				AND	uor.[FCTypeID] = @iFCTypeID

		select distinct * from #tmp1 
		union 
		select distinct * from #tmp2 ORDER BY SortOrder, FullName
	
END
ELSE
BEGIN
		-- Lägger till de uor-som är kopplade på en högre nivå
		SELECT 	
				uor.[UserID],
				rt.ID as RoleTypeID,
				rt.Name as RoleType,
				r.[Order] as RoleOrder,
				u.[UserName], 
				u.[FullName],
				u.[EmailAdress],
				r.SortOrder
		INTO #tmp3
		FROM [UserOrganisationRelation] uor
		INNER JOIN UserSecurityGroup u on (uor.[UserID] = u.[UserID] AND u.IsDeleted = 0)
		INNER JOIN FCRole r on uor.RoleID = r.ID
		INNER JOIN FCRoleType rt on r.RoleTypeID = rt.ID
		INNER JOIN FCDimension oAncestor on uor.FCElementKey = oAncestor.ElementKey
		INNER JOIN FCDimensionAncestorRelation fdar on oAncestor.[ID] = fdar.[AncestorID]
		INNER JOIN FCDimension oDecendant on fdar.DecendantID = oDecendant.ID

		LEFT JOIN FCDimension oAncestor2 on oAncestor2.ElementKey = @vsFCElementKey
		INNER JOIN FCDimensionAncestorRelation fdar2 on oAncestor2.[ID] = fdar2.[AncestorID]
		INNER JOIN FCDimension oDecendant2 on fdar2.DecendantID = oDecendant2.ID AND oDecendant.ID = oDecendant2.ID

		WHERE 	uor.[CompanyID] = @iCompanyID
		AND		uor.[FCTypeID] = @iFCTypeID
		AND		oAncestor.[CompanyID] = @iCompanyID
		AND		oAncestor.[FCTypeID] = @iFCTypeID
		AND		oDecendant.[CompanyID] = @iCompanyID
		AND		oDecendant.[FCTypeID] = @iFCTypeID
		AND		oDecendant.isLeaf = 1	

		-- Lägger till de uor-som är kopplade på lägsta nivå
		SELECT 
				
				uor.[UserID],
				rt.ID as RoleTypeID,
				rt.Name as RoleType,
				r.[Order] as RoleOrder,
				u.[UserName], 
				u.[FullName],
				u.[EmailAdress],
				r.SortOrder
		INTO #tmp4
		FROM [UserOrganisationRelation] uor
		INNER JOIN UserSecurityGroup u on (uor.[UserID] = u.[UserID] AND u.IsDeleted = 0)
		INNER JOIN FCRole r on uor.RoleID = r.ID
		INNER JOIN FCRoleType rt on r.RoleTypeID = rt.ID
		LEFT JOIN FCDimension oAncestor on oAncestor.ElementKey = @vsFCElementKey
		INNER JOIN FCDimensionAncestorRelation fdar on oAncestor.[ID] = fdar.[AncestorID]
		INNER JOIN FCDimension oDecendant on fdar.DecendantID = oDecendant.ID and uor.[FCElementKey] = oDecendant.ElementKey
		
		WHERE 	uor.[CompanyID] = @iCompanyID
		AND		uor.[FCTypeID] = @iFCTypeID
		AND		oAncestor.[CompanyID] = @iCompanyID
		AND		oAncestor.[FCTypeID] = @iFCTypeID
		AND		oDecendant.[CompanyID] = @iCompanyID
		AND		oDecendant.[FCTypeID] = @iFCTypeID
		
		select distinct * from #tmp3 
		union 
		select distinct * from #tmp4 ORDER BY SortOrder, FullName
		
END
GO
