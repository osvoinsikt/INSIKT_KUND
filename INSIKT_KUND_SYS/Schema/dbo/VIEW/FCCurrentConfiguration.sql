SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[FCCurrentConfiguration]
AS
SELECT        p.ID, p.Name, e.FCElementID, e.ElementKey, e.ValueNumeric, e.ValueString, e.FCTypeID, e.CompanyID
FROM            dbo.FCElementProperty AS e INNER JOIN
                         dbo.FCProperty AS p ON p.ID = e.PropertyID
WHERE        (e.PropertyID NOT IN (1, 2))
GO
