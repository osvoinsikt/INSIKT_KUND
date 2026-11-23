SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [app].[GetHierarchyDimensionPartTypes]
(
	@HierarchyID int
)
returns
	@DimensionParts table(DimensionPartTypeID int, DimensionPartNumber int, ReferenceConflict bit)
as
begin
declare @DimensionPartOrder table (DimensionPartTypeID int not null, JoinOrder int, LoopCount int)
declare @DimensionPartOrderToBeMoved table (DimensionPartTypeID int not null, LoopCount int)
insert into @DimensionPartOrder(DimensionPartTypeID, JoinOrder, LoopCount)
select
	DimensionPartTypeID
	,row_number() over(order by DimensionPartTypeID)
	,0
from
	app.HierarchyDimensionPartType
where
	HierarchyID = @HierarchyID

	
declare @DimensionPartRelations table (DimensionPartTypeID int, ParentDimensionPartTypeID int)
insert into @DimensionPartRelations(DimensionPartTypeID, ParentDimensionPartTypeID)
select 
	r.DimensionPartTypeID, r.ParentDimensionPartTypeID
from 
	@DimensionPartOrder c
		inner join app.showDimensionPartTypeRelation r on
			r.DimensionPartTypeID = c.DimensionPartTypeID





declare @ErrorMessage varchar(8000)
declare @DimensionPartTypeID int 
declare @JoinOrder int
declare @NrOfDimensionPartsToMove int
declare @DimensionPartCount int

select @DimensionPartCount = count(*) from @DimensionPartOrder
set @JoinOrder = 1
while @JoinOrder is not null
	begin
		select @DimensionPartTypeID = DimensionPartTypeID from  @DimensionPartOrder where JoinOrder = @JoinOrder
		

		insert into @DimensionPartOrderToBeMoved(DimensionPartTypeID,LoopCount)
		select
			r.ParentDimensionPartTypeID
			,o.LoopCount
		from
			@DimensionPartRelations r
				inner join @DimensionPartOrder o on
					o.DimensionPartTypeID = r.ParentDimensionPartTypeID 
		where
			r.DimensionPartTypeID = @DimensionPartTypeID
			and o.JoinOrder > @JoinOrder


		set @NrOfDimensionPartsToMove = @@RowCount

		if @NrOfDimensionPartsToMove > 0
			begin
				--select * from @DimensionPartOrderToBeMoved
				delete @DimensionPartOrder where DimensionPartTypeID in (select DimensionPartTypeID from @DimensionPartOrderToBeMoved)

				update @DimensionPartOrder set
					JoinOrder = JoinOrder + @NrOfDimensionPartsToMove
				where
					JoinOrder >= @JoinOrder

				insert into @DimensionPartOrder(DimensionPartTypeID, JoinOrder, LoopCount)
				select
					DimensionPartTypeID
					,(row_number() over(Order By DimensionPartTypeID) - 1) + @JoinOrder
					,LoopCount
				from
					@DimensionPartOrderToBeMoved

				delete from @DimensionPartOrderToBeMoved

				update @DimensionPartOrder set
					LoopCount = LoopCount + 1
				where
					@DimensionPartTypeID = @DimensionPartTypeID

				select @JoinOrder = max(JoinOrder) from @DimensionPartOrder where JoinOrder < @JoinOrder and LoopCount <= @DimensionPartCount
			end

		select @JoinOrder = min(JoinOrder) from @DimensionPartOrder where (JoinOrder > @JoinOrder or @JoinOrder is null) and LoopCount <= @DimensionPartCount

	end


--
--if exists(select 1 from @DimensionPartOrder where LoopCount > @DimensionPartCount)
--	begin
--		set @ErrorMessage = 'Error: Unable to determine the order to load code parts because code part types are dependent of each other. Please verify code part type configuration for the following code part types: '
--		select 
--			@ErrorMessage = @ErrorMessage + 
--				t.Name + ' (ID: ' + cast(t.ID as varchar(20)) + '), '
--		from 
--			@DimensionPartOrder o
--				inner join base_DimensionPartType t on
--					t.ID = o.ID
--		where 
--			o.LoopCount > @DimensionPartCount
--		raiserror(@ErrorMessage, 16, 10)
--	end

insert into @DimensionParts(DimensionPartTypeID, DimensionPartNumber, ReferenceConflict)
select
	DimensionPartTypeID
	,row_number() over( order by JoinOrder) DimensionPartNumber
	,case when LoopCount > @DimensionPartCount then 1 else 0 end
from 
	@DimensionPartOrder


	return


end
GO
