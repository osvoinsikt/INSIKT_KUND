SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--
-- Procedure för att generera rader i FCProcess så att det går att klarmarkera processer utan att en enda skrivning gjords i Input-flikarna
-- Detta kan vara väldigt praktiskt i de fall som en budget förfylls med data som kanske inte kräver ändring men som måste godkännas.
--
CREATE procedure [dbo].[support_StartAllFCProcesses]
(
	--
	-- Skapa processer för denna planeringsversion
	--
	@PlanningVersionID int 

	--
	-- Vilkan användare ska stå som skapare av processerna
	-- Default hämtas användarnamn för den första användaren som är admin
	--
	,@CreatedBy int = null 

	--
	-- Skapa bara processer för angiven FCTypeID
	-- Om null skapas processer för samtliga FCTypeID:s som är relaterade till planeringsversionen
	--
	,@FCTypeID int = null 
)
as
set nocount on
if not exists(select 1 from FCVersion where ID = @PlanningVersionID)
	begin
		raiserror('Planeringsversionen %d finns inte i tabellen FCVersion', 16 ,10, @PlanningVersionID)
		return;
	end


if @CreatedBy is null
	set @CreatedBy = -1


--
-- Hämta vilka FCTyper som ska hanteras av vald planeringsversion
--
select
	FCTypeID
into #FCType
from
	FCVersionFCTypeRelation
where
	FCVersionID = @PlanningVersionID
	and 
	(
		FCTypeID = @FCTypeID
		or @FCTypeID is null
	)
if @@ROWCOUNT = 0
	insert into #FCType
	(
		FCTypeID
	)
	select
		ID
	from
		FCType
	where	
		ID = @FCTypeID
		or @FCTypeID is null
	
	
--
-- Filtrera bort alla typer som inte behöver hanteras på grund av att de inte är första FCTypen i en FCTypeGroup
--
;with FCTypeData as
(
	select 
		FCTypeID = t.ID
		,FCTypeInGroupOrder =
			row_number() over
			(
				partition by
					isnull(gr.GroupID * -10000, t.ID)
				order by
					gr.[SortOrder]
					,gr.FCTypeID
			)
	from
		dbo.FCType t
			left join dbo.FCTypeGroupRelation gr on
				gr.FCTypeID = t.ID
)
delete from #FCType
where
	FCTypeID not in (select FCTypeID from FCTypeData where FCTypeInGroupOrder = 1)


--
-- Vi hanterar inte att sätta unika LastGeneratedTransactionID inom en budgettyp, så skippa
-- budgettyper med den inställningen.
--
if exists (
	select *
	from #FCType fct
	left join FCElementProperty epUnique on -- TransactionNrUniquePerFCType
		epUnique.FCTypeID = fct.FCTypeID and epUnique.PropertyID = 324
	where epUnique.ID is not null
)
begin
	print 'Inga processer kommer att skapas för budgettyper med TransactionNrUniquePerFCType. Den konfigurationen hanteras inte av den här proceduren.'
end

delete fct
from #FCType fct
	left join FCElementProperty epUnique on -- TransactionNrUniquePerFCType
		epUnique.FCTypeID = fct.FCTypeID and epUnique.PropertyID = 324
where epUnique.ID is not null


--
-- Leta reda på eventuella dolda löv (via FCProperty 280)
--
select 
	t.FCTypeID
	,epProcessDim.CompanyID
	,dimLeaf.ElementKey
into #HiddenMembers
from 
	#FCType t		
		inner join dbo.FCElementProperty epProcessDim on
			epProcessDim.FCTypeID = t.FCTypeID
			and epProcessDim.PropertyID = 8 -- FCProcessDimension
		inner join dbo.FCElementProperty epHiddenMember on
			epHiddenMember.FCTypeID = t.FCTypeID
			and epHiddenMember.CompanyID = epProcessDim.CompanyID
			and epHiddenMember.PropertyID = 280 -- HideMemberFromMainDimension
			and epHiddenMember.ValueNumeric = 1 

		--
		-- Den träff vi får i join nedan kan eventuellt vara en grupperingsnivå
		--
		inner join dbo.FCDimension dim on
			dim.ElementKey = epHiddenMember.ElementKey
			and dim.FCTypeID = epHiddenMember.FCTypeID
			and dim.CompanyID = epProcessDim.CompanyID
			and dim.DimensionName = epProcessDim.ValueString

		--
		-- Och därför joinar vi vidare för att hitta alla löv under grupperingsnivån
		--
		left join dbo.FCDimensionAncestorRelation dimMemberRel on
			dimMemberRel.AncestorID = dim.ID
		inner join dbo.FCDimension dimLeaf on
			dimLeaf.ID = isnull(dimMemberRel.DecendantID, dim.ID)
			and dimLeaf.isLeaf = 1

set nocount off
insert into dbo.FCProcess
(
	FCVersion
	,CompanyID
	,FCTypeID
	,FCLevel01
	,CreatedDate
	,CreatedBy
	,LastGeneratedTransactionID
)
select 
	FCVersion = @PlanningVersionID
	,CompanyID = epProcessDim.CompanyID
	,FCTypeID = t.FCTypeID
	,FCLevel01 = processDim.ElementKey
	,CreatedDate = getutcdate()
	,CreatedBy = @CreatedBy
	,LastGeneratedTransactionID = 1
from 
	#FCType t
		inner join dbo.FCElementProperty epProcessDim on
			epProcessDim.FCTypeID = t.FCTypeID
			and epProcessDim.PropertyID = 8 -- FCProcessDimension
		inner join dbo.FCDimension processDim on
			processDim.FCTypeID = epProcessDim.FCTypeID
			and processDim.DimensionName = epProcessDim.ValueString
			and processDim.CompanyID = epProcessDim.CompanyID
			and processDim.isLeaf = 1
		left join #HiddenMembers epHiddenMember on
			epHiddenMember.FCTypeID = epProcessDim.FCTypeID
			and epHiddenMember.ElementKey = processDim.ElementKey
			and epHiddenMember.CompanyID = epProcessDim.CompanyID
		left join FCProcess process on
			process.FCVersion = @PlanningVersionID
			and process.CompanyID = epProcessDim.CompanyID
			and process.FCTypeID = t.FCTypeID
			and process.FCLevel01 = processDim.ElementKey
where
	epHiddenMember.FCTypeID is null -- Starta inte processer för dolda medlemmar i processdimensionen
	and process.ID is null -- Lägg inte till rader som redan finns.


drop table #FCType
drop table #HiddenMembers
GO
