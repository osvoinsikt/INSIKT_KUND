SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [app].[HierarchyExport] 
(
	@HierarcyID varchar(max)
	,@HierarchyData xml = null output
)
as



select
	@HierarchyData = 
	(
		select
			Hierarchy.*
			,DimensionPartTypes = 
				(
					select
						*
					from
						app.HierarchyDimensionPartType HierarchyDimensionPartType
							left join app.DimensionPartType DimensionPartType on
								DimensionPartType.DimensionPartTypeID = HierarchyDimensionPartType.DimensionPartTypeID
					where
						HierarchyDimensionPartType.HierarchyID = Hierarchy.HierarchyID
					for xml auto, type
				)

			,HierarchyExtraColumns = 
				(
					select
						*
					from
						app.HierarchyExtraColumn HierarchyExtraColumn
					where
						HierarchyExtraColumn.HierarchyID = Hierarchy.HierarchyID
					for xml auto, type
				)

			,HierarchyNodeAttributeTypes = 
				(
					select
						*
					from
						app.HierarchyNodeAttributeType HierarchyNodeAttributeType
					where
						HierarchyNodeAttributeType.HierarchyID = Hierarchy.HierarchyID
					for xml auto, type
				)

			,HierarchyOptions = 
				(
					select
						*
					from
						app.HierarchyOption HierarchyOption
					where
						HierarchyOption.HierarchyID = Hierarchy.HierarchyID
					for xml auto, type
				)

			,HierarchyLanguages = 
				(
					select
						HierarchyLanguage.*
						,Language.Code
						,Language.Name
					from
						app.HierarchyLanguage HierarchyLanguage
							inner join app.Language Language on
								Language.LanguageID = HierarchyLanguage.LanguageID
					where
						HierarchyLanguage.HierarchyID = Hierarchy.HierarchyID
					for xml auto, type
				)

			,HierarchyNodes = 
				(
					select
						*
						,HierarchyNodeAttributes = 
							(
								select
									*
								from
									app.HierarchyNodeAttribute HierarchyNodeAttribute
								where
									HierarchyNodeAttribute.HierarchyNodeID = HierarchyNode.HierarchyNodeID
								for xml auto, type
							)
						,HierarchyNodeLanguages = 
							(
								select
									*
								from
									app.HierarchyNodeLanguage HierarchyNodeLanguage
								where
									HierarchyNodeLanguage.HierarchyNodeID = HierarchyNode.HierarchyNodeID
								for xml auto, type
							)
					from
						app.HierarchyNode HierarchyNode
					where
						HierarchyNode.HierarchyID = Hierarchy.HierarchyID
					for xml auto, type
				)
			
		from
			app.Hierarchy Hierarchy
				
					
		where
			Hierarchy.HierarchyID in (select cast(Item as int) from app.Split(@HierarcyID, ','))
		for xml auto, type
	)


select HierarchyData = @HierarchyData
GO
