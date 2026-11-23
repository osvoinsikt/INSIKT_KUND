SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[RoleTaskConfiguration]
AS
SELECT
  r.ID AS RoleID,
  r.Name AS RoleName,
  t.ID AS TaskID,
  t.Name AS TaskName,
  fcr.ID as FCRoleID,
  fcr.Name as FCRoleName,
  it.Name AS InheritanceType,
  rtr.FCTypeID,
  rtr.FCObjectTypeID,
  rtr.FCProjectCalcStepTypeID
FROM dbo.Role AS r
  LEFT OUTER JOIN dbo.RoleTaskRelation AS rtr ON r.ID = rtr.RoleID
  LEFT OUTER JOIN dbo.Task AS t ON rtr.TaskID = t.ID
  LEFT OUTER JOIN dbo.FCRole AS fcr ON rtr.FCRoleID = fcr.ID
  LEFT OUTER JOIN dbo.RoleTaskInheritanceType it on rtr.InheritanceTypeID = it.ID

GO
