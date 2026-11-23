SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[FCDashboardSelectionMappingConfiguration] AS

select
	dashboard.Caption as Dashboard,
	sourceT.Caption as SourceFCType,
	sourceR.Name as SourceReport,
	sourceD.DimensionName as SourceDimension,
	sourceH.Name as SourceHierarchy,
	sourceOt.Name as SourceFCObjectType,
	sourceOp.Name as SourceFCObjectProperty,
	targetT.Caption as TargetFCType,
	targetR.Name as TargetReport,
	targetD.DimensionName as TargetDimension,
	targetH.Name as TargetHierarchy,
	targetOt.Name as TargetFCObjectType,
	targetOp.Name as TargetFCObjectProperty,
	g.SelectionGeneratingMeasure,
	mapping.IsHierarchyTreeFilter,
	mapping.IsEnabled,
	mapping.Description
from FCDashboardSelectionMapping mapping
	left join FCDashboardPresentationObjectRelation sourcePo on mapping.SourceDashboardPresentationObjectID = sourcePo.ID
	left join FCType sourceT on sourcePo.FCTypeID = sourceT.ID
	left join Report sourceR on sourcePo.ReportID = sourceR.ID
	left join FCObjectType sourceOt on sourcePo.FCObjectTypeID = sourceOt.ID
	left join FCObjectProperty sourceOp on mapping.SourceFCObjectPropertyID = sourceOp.ID
	left join FCDashboardPresentationObjectRelation targetPo on mapping.TargetDashboardPresentationObjectID = targetPo.ID
	left join FCType targetT on targetPo.FCTypeID = targetT.ID
	left join Report targetR on targetPo.ReportID = targetR.ID
	left join FCObjectType targetOt on targetPo.FCObjectTypeID = targetOt.ID
	left join FCObjectProperty targetOp on mapping.TargetFCObjectPropertyID = targetOp.ID
	left join DataSourceDimensionHierarchy sourceH on mapping.SourceDatasourceHierarchyID = sourceH.ID
	left join DataSourceDimension sourceD on sourceH.DataSourceDimensionID = sourceD.ID
	left join DataSourceDimensionHierarchy targetH on mapping.TargetDatasourceHierarchyID = targetH.ID
	left join DataSourceDimension targetD on targetH.DataSourceDimensionID = targetD.ID
	left join DataSourceDimensionHierarchySelectionGenerator g on mapping.DatasourceDimensionHierarchySelectionGeneratorID = g.ID
	left join FCDashboard dashboard on targetPo.FCDashboardID = dashboard.ID
GO
