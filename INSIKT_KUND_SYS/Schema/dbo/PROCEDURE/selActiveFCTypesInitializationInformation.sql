SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		EMAH
-- Create date: 2016-11-21
-- Description:	Procedure that selects necessary data used when initializing budgets during login.
--				This was previously done with multiple calls to getFCProperty which reduced performance.
-- Modified date: 2026-06-22
-- Log:			
--				EMAH	Modifications after the new FCType configuration.
--				OSLY	Added Description field to the result set.
-- =============================================
CREATE PROCEDURE [dbo].[selActiveFCTypesInitializationInformation]
AS
BEGIN
	DECLARE @INT_MAX int = 2147483647

	SELECT
		fct.ID as FCTypeID,
		fct.Caption as FCTypeCaption,
		fct.FCTypeTypeID as FCTypeTypeID,
		fct.Description as FCTypeDescription,
		coalesce(ep_DisableMultiCompany.ValueNumeric, 0) as DisableMultiCompany
	FROM
		FCType fct
		left join FCTypeGroupRelation groupRel on fct.ID = groupRel.FCTypeID
		left join ModuleFCTypeRelation moduleRel on (fct.ID = moduleRel.FCTypeID or groupRel.GroupID = moduleRel.FCTypeGroupID)
		left join FCElementProperty ep_DisableMultiCompany on (ep_DisableMultiCompany.PropertyID = 526
			and ep_DisableMultiCompany.FCTypeID = fct.ID)
	WHERE IsActive = 1
	ORDER BY coalesce(moduleRel.SortOrder, @INT_MAX)

	-- Also return configured companies for each FCType
	SELECT DISTINCT CompanyID, FCTypeID
	FROM FCElementProperty
	WHERE CompanyID IS NOT NULL
		AND FCTypeID IN (SELECT ID FROM FCType WHERE IsActive = 1)
END

GO
