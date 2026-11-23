SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fn_getUnderlyingCategories]
	/**
		Returns all underlying catalogs of the provided @RootCategoryID.
		The root category is included in the resulting table.

		By: joma
	**/
(
	@RootCategoryID int
)
RETURNS TABLE
AS
RETURN
(
	WITH GetUnderlyingCategories
	As 
	(
		SELECT c.ID
		FROM Category c
		WHERE c.ParentID = @RootCategoryID

		UNION ALL

		SELECT c1.ID
		FROM Category c1
		INNER JOIN GetUnderlyingCategories GUC ON (GUC.ID = c1.ParentID)
	)
	SELECT * FROM GetUnderlyingCategories
)
GO
