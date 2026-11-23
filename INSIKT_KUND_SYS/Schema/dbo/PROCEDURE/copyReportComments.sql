SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure dbo.copyReportComments
	@sourceReportID int,
	@targetReportID int
as
begin
	-- Remove existing comments from target report. We mark them as deleted to not lose them in case
	-- it was a mistake to overwrite the report and lose the comments.

	update e
	set IsDeleted = 1
	from CellCommentEntry e
		join CellComment c on c.ID = e.CellCommentID
	where c.ReportID = @targetReportID


	-- Copy comments from the source report.

	select ID
	into #commentsToCopy
	from CellComment
	where ReportID = @sourceReportID

	while exists (select * from #commentsToCopy)
	begin
		declare @sourceCommentID int = (select top 1 ID from #commentsToCopy)

		insert into CellComment(ReportID) values (@targetReportID)
		declare @targetCommentID int = scope_identity()

		insert into CellCommentDimension(CellCommentID, DimensionName, ElementKey, FullMemberName, HierarchyName)
		select @targetCommentID, DimensionName, ElementKey, FullMemberName, HierarchyName
		from CellCommentDimension
		where CellCommentID = @sourceCommentID

		select ID
		into #entriesToCopy
		from CellCommentEntry
		where CellCommentID = @sourceCommentID

		while exists (select * from #entriesToCopy)
		begin
			declare @sourceEntryID int = (select top 1 ID from #entriesToCopy)
			
			insert into CellCommentEntry (CellCommentID, Comment, CreatedBy, CreatedDate, IsDeleted, IsReadOnly, ModifiedDate)
			select @targetCommentID, Comment, CreatedBy, CreatedDate, IsDeleted, IsReadOnly, ModifiedDate
			from CellCommentEntry
			where ID = @sourceEntryID

			declare @targetEntryID int = scope_identity()

			select DocumentID
			into #documentsToCopy
			from CellCommentDocument
			where CellCommentEntryID = @sourceEntryID

			while exists (select * from #documentsToCopy)
			begin
				declare @sourceDocumentID int = (select top 1 DocumentID from #documentsToCopy)

				insert into Document(FileType, GUID, IsDeleted, ModifiedBy, ModifiedDate, Name, UploadedBy, UploadedDate)
				select FileType, newid(), IsDeleted, ModifiedBy, ModifiedDate, Name, UploadedBy, UploadedDate
				from Document
				where ID = @sourceDocumentID

				declare @targetDocumentID int = scope_identity()

				insert into DocumentRevision(DocumentDataID, DocumentID, IsLatestRevision, RevisionID, UploadedBy, UploadedDate)
				select top 1 DocumentDataID, @targetDocumentID, 1, 1, UploadedBy, UploadedDate
				from DocumentRevision
				where DocumentID = @sourceDocumentID and IsLatestRevision = 1

				insert into CellCommentDocument(CellCommentEntryID, DocumentID) values (@targetEntryID, @targetDocumentID)

				delete from #documentsToCopy where DocumentID = @sourceDocumentID
			end

			drop table #documentsToCopy
			delete from #entriesToCopy where ID = @sourceEntryID
		end

		drop table #entriesToCopy
		delete from #commentsToCopy where ID = @sourceCommentID
	end

	drop table #commentsToCopy
end
GO
