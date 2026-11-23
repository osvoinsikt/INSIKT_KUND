SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[FCCurrentProjectCalcStepChangedTriggerConfiguration] AS

SELECT category.ID AS VersionCategoryID, category.Name AS VersionCategoryName,
	[version].ID AS VersionID, [version].Name AS VersionName,
	stepType.ID AS StepTypeID, stepType.Name AS StepTypeName,
	[trigger].ID AS TriggerID, triggerType.Name AS TriggerTypeName, [trigger].TriggerOnLeave,
	actionType.Name As ActionType, 
	[action].ID As ActionId,
	[action].SQLScript, property.Name AS PropertyName, [action].FCProjectPropertyValueString, 
	[action].FCProjectPropertyValueNumeric, [action].FCProjectPropertyPredefinedValueID, 
	predef.VisibleName As PredefinedValueVisibleName,
	[trigger].FCTypeID, [trigger].CompanyID,
	NULL As CustomTransitionID, NULL As CustomTransitionCaption, 
	NULL AS CustomTransitionFromStepTypeID, NULL AS CustomTransitionFromStepTypeName
FROM FCVersionCategory category
	LEFT JOIN FCVersion [version] ON  category.ID = [version].FCVersionCategoryID
	LEFT JOIN FCProjectCalcStepVersionCategoryTypeRelation versionCategoryStepTypeRelation ON versionCategoryStepTypeRelation.FCVersionCategoryID = category.ID
	LEFT JOIN FCProjectCalcStepType stepType ON stepType.ID = versionCategoryStepTypeRelation.FCProjectCalcStepTypeID
	LEFT JOIN FCProjectCalcTrigger [trigger] ON ([trigger].FCVersionID = [version].ID OR [trigger].FCVersionCategoryID = category.[ID]) AND [trigger].FCProjectCalcStepTypeID = stepType.ID
	LEFT JOIN FCProjectCalcTriggerType triggerType ON triggerType.ID = [trigger].FCProjectCalcTriggerTypeID
	LEFT JOIN FCProjectCalcTriggerActionRelation triggerActionRelation ON triggerActionRelation.FCProjectCalcTriggerID = [trigger].ID
	LEFT JOIN FCProjectCalcTriggerAction [action] ON [action].ID = triggerActionRelation.FCProjectCalcTriggerActionID
	LEFT JOIN FCProjectCalcTriggerActionType actionType ON actionType.ID = [action].FCProjectCalcTriggerActionTypeID
	LEFT JOIN FCProjectProperty property ON property.ID = [action].FCProjectPropertyID
	LEFT JOIN FCProjectPropertyPredefinedValue predef ON [action].FCProjectPropertyPredefinedValueID = predef.ID
UNION
--Fråga för att endast hämta ut customtransition-triggers med rätt antal kolumner.
SELECT category.ID AS VersionCategoryID, category.Name AS VersionCategoryName,
	[version].ID AS VersionID, [version].Name AS VersionName,
	stepType.ID AS StepTypeID, stepType.Name AS StepTypeName,
	[trigger].ID AS TriggerID, triggerType.Name AS TriggerTypeName, [trigger].TriggerOnLeave,
	actionType.Name As ActionType, 
	[action].ID As ActionId,
	[action].SQLScript, property.Name AS PropertyName, [action].FCProjectPropertyValueString, 
	[action].FCProjectPropertyValueNumeric, [action].FCProjectPropertyPredefinedValueID, 
	predef.VisibleName As PredefinedValueVisibleName,
	[trigger].FCTypeID, [trigger].CompanyID,
	customtransition.ID As CustomTransitionID, customtransition.ActionCaption As CustomTransitionCaption, 
	customtransition.StepTypeID AS CustomTransitionFromStepTypeID, customtransitionfromsteptype.Name AS CustomTransitionFromStepTypeName
FROM FCVersionCategory As category
	LEFT JOIN FCVersion [version] ON  category.ID = [version].FCVersionCategoryID
	LEFT JOIN FCProjectCalcStepVersionCategoryTypeRelation versionCategoryStepTypeRelation ON versionCategoryStepTypeRelation.FCVersionCategoryID = category.ID
	LEFT JOIN FCProjectCalcStepType stepType ON stepType.ID = versionCategoryStepTypeRelation.FCProjectCalcStepTypeID
	INNER JOIN FCProjectCalcCustomTransition customtransition ON customtransition.TargetStepTypeID = stepType.ID
	INNER JOIN FCProjectCalcTrigger [trigger] ON ([trigger].FCVersionID = [version].ID OR [trigger].FCVersionCategoryID = category.[ID]) AND [trigger].FCProjectCalcCustomTransitionID = customtransition.ID
	INNER JOIN FCProjectCalcStepType customtransitionfromsteptype ON customtransitionfromsteptype.ID = customtransition.StepTypeID
	LEFT JOIN FCProjectCalcTriggerType triggerType ON triggerType.ID = [trigger].FCProjectCalcTriggerTypeID
	LEFT JOIN FCProjectCalcTriggerActionRelation triggerActionRelation ON triggerActionRelation.FCProjectCalcTriggerID = [trigger].ID
	LEFT JOIN FCProjectCalcTriggerAction [action] ON [action].ID = triggerActionRelation.FCProjectCalcTriggerActionID
	LEFT JOIN FCProjectCalcTriggerActionType actionType ON actionType.ID = [action].FCProjectCalcTriggerActionTypeID
	LEFT JOIN FCProjectProperty property ON property.ID = [action].FCProjectPropertyID
	LEFT JOIN FCProjectPropertyPredefinedValue predef ON [action].FCProjectPropertyPredefinedValueID = predef.ID


GO
