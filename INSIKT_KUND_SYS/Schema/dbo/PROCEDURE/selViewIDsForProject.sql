SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[selViewIDsForProject]
	@projectID int,
	@activeFCTypeID int,
	@companyID int
AS

SELECT vr.FCViewID, vr.IsDefault
FROM dbo.FCView v
	INNER JOIN dbo.FCProjectPropertyValueFCViewRelation as vr on vr.FCViewID = v.ID
	INNER JOIN dbo.FCProjectPropertyValue as pv on pv.ProjectID = @projectID AND pv.ProjectPropertyID = vr.FCProjectPropertyID
	INNER JOIN dbo.FCProjectProperty as p on p.ID = pv.ProjectPropertyID
WHERE
	v.FCTypeID = @activeFCTypeID AND
	v.CompanyID = @companyID AND
	(
		CASE
		WHEN p.ControlID = 2 AND p.QueryToFillPredefinedValues IS NULL THEN
			-- If the property uses predefined values that are not from queries, we will match on FCProjectPropertyPredefinedValueID (also handle NULL matches).
			CASE WHEN 
				pv.FCProjectPropertyPredefinedValueID = vr.FCProjectPropertyPredefinedValueID OR (pv.FCProjectPropertyPredefinedValueID IS NULL AND vr.FCProjectPropertyPredefinedValueID IS NULL)
			THEN 1 ELSE 0 END
		ELSE
			-- Otherwise, we match on ValueString/ValueNumeric (also handle NULL matches).
			CASE WHEN
				(LOWER(p.Datatype) = 'string' AND (pv.ValueString = vr.ValueString OR (pv.ValueString IS NULL AND vr.ValueString IS NULL))) OR
				(LOWER(p.Datatype) = 'numeric' AND (pv.ValueNumeric = vr.ValueNumeric OR (pv.ValueNumeric IS NULL AND vr.ValueNumeric IS NULL))) OR
				(LOWER(p.Datatype) = 'bit' AND (pv.ValueNumeric = vr.ValueNumeric OR (pv.ValueNumeric IS NULL AND vr.ValueNumeric IS NULL)))
			THEN 1 ELSE 0 END
		END
	) = 1
ORDER BY ISNULL(vr.SortOrder, 2147483647), v.ID
GO
