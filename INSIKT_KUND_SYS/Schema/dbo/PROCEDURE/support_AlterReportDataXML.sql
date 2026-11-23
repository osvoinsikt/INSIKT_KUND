SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************
 #Desc:         Search and replace in Reports data field (tabel Reports, column Data)
 #              This procedure is used manually to bulk edit
 #              report XML data. 
 #              Only the first occurence of @searchFor will be replaced
 #              in each report.
 #
 #InParam:      @SearchStr      String to search for.
 #              @ReplaceStr     String to replace @SearchStr with.
 #              @ReportID       Report ID to search in or NULL for all reports.
 #              @CommitChanges  Whether to commit the changes to the database.
 #                              The changes will otherwise just be returned through a SELECT.
********************************************************************/
CREATE procedure [dbo].[support_AlterReportDataXML] (
	@SearchStr varchar(4000)
	,@ReplaceStr varchar(4000)
	,@ReportID int = null
	,@CommitChanges bit = 1
)
as

select
	ReportID = r.ID
	,ReportName = r.Name
	,Before = Data
	,[After] = cast(replace(cast(r.Data as nvarchar(max)), @SearchStr, @ReplaceStr) as xml) 
	from Report r
	
where
	(r.ID = @ReportID or @ReportID is null)
	
if @@ERROR = 0 and @CommitChanges = 1
	update r
	set
		Data = replace(cast(r.Data as nvarchar(max)), @SearchStr, @ReplaceStr)
	from
		Report r
	where
		(r.ID = @ReportID or @ReportID is null)
GO
