SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[selCellCommentDataByFCTypeIdAndCompanyIdWithFilters]
	@FCTypeIDs varchar(2000),
	@CompanyID int,
	@MainDimensionName nvarchar(50),
	@MainDimensionFilters nvarchar(max),
	@AdditionalFilters nvarchar(max),
	@UseElementKeys bit,
	@LoadEntries bit,
	@LoadOnlyDocumentsFromEntries bit,
	@LoadDetails bit
WITH RECOMPILE
AS
BEGIN

	create table #fcTypes (FCTypeID int)
	insert into #fcTypes(FCTypeID)
	  select convert(int, strings)
	  from dbo.sepstring(@FCTypeIDs, '¤')
	  where strings <> ''

	create table #mainDimensionMembers (Member varchar(300) collate database_default)
	insert into #mainDimensionMembers(Member)
	  select strings
	  from dbo.sepstring(@MainDimensionFilters, '¤')
	  where strings <> ''

	create table #filters (Dimension varchar(50) collate database_default, Member varchar(300) collate database_default)
	insert into #filters(Dimension, Member)
	  select substring(strings, 0, patindex('%=%', strings)),
	         substring(strings, patindex('%=%', strings) + 1, len(strings))
	  from dbo.sepstring(@AdditionalFilters, '¤')
	  where strings <> ''

	-- Används för att se till så alla filter är matchade.
	--
	-- Notera: Detta kommer inte fungera om vi implementerar så att man kan 
	-- välja flera medlemmar per dimension. Då kan vi inte använda @numFilter,
	-- utan vi måste kontollera att vi får en matchning per dimension.
	declare @numFilters int;
	select @numFilters = count(distinct dimension) from #filters

	create table #cellCommentIds (ID int)

	if @UseElementKeys = 1
		with CellCommentsFiltered as (
			select c.ID
			from CellComment c
				inner join #fcTypes fct on c.FCTypeID = fct.fcTypeID
			where exists(select 1 from CellCommentDimension cd
							inner join #mainDimensionMembers mdm on cd.DimensionName =  @MainDimensionName and cd.ElementKey = mdm.Member
							where cd.CellCommentID = c.ID)
				and c.CompanyID = @CompanyID
		)
		insert into #cellCommentIds with (tablock) (ID)
		select c.ID
		from CellCommentsFiltered c	
			inner join CellCommentDimension cd on cd.CellCommentID = c.ID
			left outer join #filters f on cd.DimensionName = f.dimension and cd.ElementKey = f.Member
		group by c.ID
		having
			count(f.member) = @numFilters -- Matches all filters
	else
		with CellCommentsFiltered as (
			select c.ID
			from CellComment c
				inner join #fcTypes fct on c.FCTypeID = fct.fcTypeID
			where exists(select 1 from CellCommentDimension cd
							inner join #mainDimensionMembers mdm on cd.DimensionName =  @MainDimensionName and cd.FullMemberName = mdm.Member	
							where cd.CellCommentID = c.ID)
				and c.CompanyID = @CompanyID
		)
		insert into #cellCommentIds with (tablock) (ID)
		select c.ID
		from CellCommentsFiltered c	
			inner join CellCommentDimension cd on cd.CellCommentID = c.ID
			left outer join #filters f on cd.DimensionName = f.dimension and cd.FullMemberName = f.Member
		group by c.ID
		having
			count(f.member) = @numFilters -- Matches all filters

	;with 
		Details (CellCommentID) as (select distinct CellCommentID from CellCommentDetail),
		Entries (CellCommentID) as (select distinct CellCommentID from CellCommentEntry where IsDeleted = 0)
	select 
		ccd.CellCommentID, 
		cc.FCTypeID, 
		DimensionName, 
		FullMemberName, 
		ElementKey,
		cast(case when ent.CellCommentID is not null then 1 else 0 end as bit) as HasEntries,
		cast(case when det.CellCommentID is not null then 1 else 0 end as bit) as HasDetails
	from CellCommentDimension ccd
	join CellComment cc on (ccd.CellCommentID = cc.ID)
	inner join #cellCommentIds ccids on ccd.CellCommentID = ccids.ID
	left outer join Details det on det.CellCommentID = ccids.ID
	left outer join Entries ent on ent.CellCommentID = ccids.ID

	if @LoadEntries = 1
	begin
		-- Entries table
		if @LoadOnlyDocumentsFromEntries = 1
		begin
			-- Some code-path only need the documents. Save network traffic and comment sanitization by
			-- not loading the comment texts. Information like CreatedBy is still used and must be loaded.
			select cE.ID, cE.CellCommentID, Comment = '', cE.CreatedBy, cE.CreatedDate, cE.ModifiedDate, cE.IsReadOnly
			from #cellCommentIds cIds
			join CellCommentEntry cE on cIds.ID = ce.CellCommentID
			where cE.IsDeleted = 0
		end else begin
			select cE.ID, cE.CellCommentID, cE.Comment, cE.CreatedBy, cE.CreatedDate, cE.ModifiedDate, cE.IsReadOnly
			from #cellCommentIds cIds
			join CellCommentEntry cE on cIds.ID = ce.CellCommentID
			where cE.IsDeleted = 0
		end

		-- Document table
		select cD.CellCommentEntryID, d.ID as DocumentID, d.GUID as DocumentGUID, d.Name as DocumentName
		from #cellCommentIds cIds
		join CellCommentEntry cE on cIds.ID = ce.CellCommentID
		join CellCommentDocument cD on cE.ID = cD.CellCommentEntryID
		join Document d on cD.DocumentID = d.ID
		where d.IsDeleted = 0 and cE.IsDeleted = 0
	end

	if @LoadDetails = 1
	begin
		select cD.ID, cD.CellCommentID, cD.[Name], cD.[Description], cD.CreatedBy, cD.CreatedDate, cD.ModifiedBy, cD.ModifiedDate, cD.Quantity, cD.[Value], cD.UnitTypeID, cD.NameReadOnly, cD.DescriptionReadOnly, cD.QuantityReadOnly, cD.ValueReadOnly, cD.UnitTypeReadOnly
		from CellCommentDetail cD
		join #cellCommentIds cIds on cIds.ID = cD.CellCommentID
	end

	drop table #fcTypes
	drop table #mainDimensionMembers
	drop table #filters
	drop table #cellCommentIds
END
GO
