SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[FCCurrentProjectCalcConfiguration] AS

SELECT category.ID AS VersionCategoryID, category.Name AS VersionCategoryName,
	[version].ID AS VersionID, [version].Name AS VersionName,
	stepType.ID AS StepTypeID, stepType.Name AS StepTypeName,
	stepType.FCTypeID, stepType.CompanyID
	FROM FCVersionCategory category
	LEFT JOIN FCVersion [version] ON  category.ID = [version].FCVersionCategoryID
	LEFT JOIN FCProjectCalcStepVersionCategoryTypeRelation versionCategoryStepTypeRelation ON versionCategoryStepTypeRelation.FCVersionCategoryID = category.ID
	LEFT JOIN FCProjectCalcStepType stepType ON stepType.ID = versionCategoryStepTypeRelation.FCProjectCalcStepTypeID
	
GO
