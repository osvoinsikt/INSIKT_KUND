SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dw].[dim_Projekt_NormalizedMainPC] as
with TreeData as
(
	select
		LeafDistance = 0 
		,ID = [ProjektID]
		,DisplayName = DisplayName
		,Sort =  isnull(Code, 2147483647)
		,ParentID = [ParentProjektID] * -1 -15000
		,LeafID = [ProjektID]
		,ParentDimensionPartID = 
			case when l.IsParent = 0 then 
				l.[ParentProjektID]
			else
				l.[ProjektID]
			end
	from
		[dw].[base_Projekt] l
		
		where 
		-- 
		-- NonLeafDataHidden, kommentera bort detta villkor för leaf data visible
		--
		l.IsParent = 0
		union all
	select
		LeafDistance = d.LeafDistance + 1
		,ID = pD.[ProjektID] * -1 -15000
		,DisplayName = pD.DisplayName
		,Sort = isnull(pD.Code, 2147483647)
		,ParentID = pD.[ParentProjektID] * -1 -15000
		,LeafID = d.LeafID
		,ParentDimensionPartID = pD.[ParentProjektID]
	from
		TreeData d
			inner join [dw].[base_Projekt] pD on
				pD.[ProjektID] = d.ParentDimensionPartID
)
,
TreeLevelData as
(
	select
		LeafID
		,LevelNr = 
			row_number() 
			over
			(
				partition by
					LeafID
				order by
					LeafDistance desc
			) - 1
		,ID
		,DisplayName
		,Sort
	from
		TreeData

)
,
NormalizedPC as
(
	select
		L0_ID = l0.ID
		,L0_DisplayName = l0.DisplayName
		,L0_Sort = dense_rank() over (order by l0.Sort)

		,L1_ID = coalesce(l1.ID, l0.ID)
		,L1_DisplayName = l1.DisplayName
		,L1_Sort = dense_rank() over (order by isnull(l1.Sort, 2147483646), l0.ID)

		,L2_ID = coalesce(l2.ID, l1.ID, l0.ID)
		,L2_DisplayName = l2.DisplayName
		,L2_Sort = dense_rank() over (order by isnull(l2.Sort, 2147483646), coalesce(l1.ID, l0.ID))

	
		,L3_ID = coalesce(l3.ID, l2.ID, l1.ID, l0.ID)
		,L3_DisplayName = l3.DisplayName
		,L3_Sort = dense_rank() over (order by isnull(l3.Sort, 2147483646), coalesce(l2.ID, l1.ID, l0.ID))

	
		,L4_ID = coalesce(l4.ID, l3.ID, l2.ID, l1.ID, l0.ID)
		,L4_DisplayName = l4.DisplayName
		,L4_Sort = dense_rank() over (order by isnull(l4.Sort, 2147483646), coalesce(l3.ID, l2.ID, l1.ID, l0.ID))

	
		,L5_ID = coalesce(l5.ID, l4.ID, l3.ID, l2.ID, l1.ID, l0.ID)
		,L5_DisplayName = l5.DisplayName
		,L5_Sort = dense_rank() over (order by isnull(l5.Sort, 2147483646), coalesce(l4.ID, l3.ID, l2.ID, l1.ID, l0.ID))

		,[Projekt_NormalizedMainPC_LeafID] = l0.LeafID
		,[ProjektID] = l0.LeafID

	from
		TreeLevelData l0
			left join TreeLevelData l1 on
				l1.LeafID = l0.LeafID
				and l1.LevelNr = 1
			left join TreeLevelData l2 on
				l2.LeafID = l0.LeafID
				and l2.LevelNr = 2
			left join TreeLevelData l3 on
				l3.LeafID = l0.LeafID
				and l3.LevelNr = 3
			left join TreeLevelData l4 on
				l4.LeafID = l0.LeafID
				and l4.LevelNr = 4
			left join TreeLevelData l5 on
				l5.LeafID = l0.LeafID
				and l5.LevelNr = 5
	where
		l0.LevelNr = 0
)
select
	pc.*
from
	NormalizedPC pc 

GO
