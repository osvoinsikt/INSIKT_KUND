SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[RoleDescriptions] AS
SELECT ld.ControlName, 
		COALESCE(r.Caption,SUBSTRING(LEFT(ld.ControlName, LEN(ld.ControlName) - 11), 4, 99)) as RoleName, 
		r.ID as RoleID, 
		l.Name as Lang, 
		ld.VisibleName as DefaultRoleDescription, 
		ld.CustomName as RoleDescription
FROM LangDictionary as ld
LEFT JOIN Role as r ON (ld.ControlName = 'RoleDescription_' + r.Caption)
JOIN Language as l ON (ld.LangID = l.ID)
WHERE ControlName LIKE 'RoleDescription_%' 
					OR ControlName = 'txtSuperAdminDescription'
GO
