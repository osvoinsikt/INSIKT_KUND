SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[CurrentConfiguration]
AS
SELECT        dbo.SystemProperty.ID AS SystemPropertyID, dbo.SystemProperty.Name, dbo.SystemProperty.Description, dbo.SystemSetting.ValueNumeric, 
                         dbo.SystemSetting.ValueString
FROM            dbo.SystemProperty INNER JOIN
                         dbo.SystemSetting ON dbo.SystemProperty.ID = dbo.SystemSetting.SystemPropertyID
GO
