SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[FCCurrentProjectCalcCustomTriggerConfiguration] AS

SELECT category.ID AS VersionCategoryID, category.Name AS VersionCategoryName,
	[version].ID AS VersionID, [version].Name AS VersionName,
	[trigger].ID AS TriggerID, triggerType.Name AS TriggerTypeName,
	[trigger].UserInteractionCaption, [trigger].UserInteractionCanExecuteSQL,
	actionType.Name As ActionType, 
	[action].ID As ActionId,
	[action].SQLScript, property.Name AS PropertyName, [action].FCProjectPropertyValueString, 
	[action].FCProjectPropertyValueNumeric, [action].FCProjectPropertyPredefinedValueID, predef.VisibleName As PredefinedValueVisibleName,
	[trigger].FCTypeID, [trigger].CompanyID
	FROM FCProjectCalcTrigger [trigger]
	INNER JOIN FCProjectCalcTriggerType triggerType ON triggerType.ID = [trigger].FCProjectCalcTriggerTypeID
	LEFT JOIN FCVersion [version] ON [version].ID = [trigger].FCVersionID
	LEFT JOIN FCVersionCategory category ON [trigger].FCVersionCategoryID = category.ID
	LEFT JOIN FCProjectCalcTriggerActionRelation triggerActionRelation ON triggerActionRelation.FCProjectCalcTriggerID = [trigger].ID
	LEFT JOIN FCProjectCalcTriggerAction [action] ON [action].ID = triggerActionRelation.FCProjectCalcTriggerActionID
	LEFT JOIN FCProjectCalcTriggerActionType actionType ON actionType.ID = [action].FCProjectCalcTriggerActionTypeID
	LEFT JOIN FCProjectProperty property ON property.ID = [action].FCProjectPropertyID
	LEFT JOIN FCProjectPropertyPredefinedValue predef ON [action].FCProjectPropertyPredefinedValueID = predef.ID
	WHERE triggerType.ID <> 1

GO
