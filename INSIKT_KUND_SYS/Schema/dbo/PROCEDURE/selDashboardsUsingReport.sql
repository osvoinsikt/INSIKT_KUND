SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[selDashboardsUsingReport]
	@reportID int
as
begin
	declare @result as table (
		MultiReportID int,
		FCDashboardID int,
		DashboardName nvarchar(50)
	)

	insert into @result
	select r.ID, null, r.Name
	from Report r
	where ReportTypeID = 4
		and Inactive = 0
		and case
				when exists(
						select 1
						from r.Data.nodes('/MultiReport/PresentationObjects/MultiReportPartBase') as T(N)
						where T.N.value('ReportDatabaseId[1]', 'int') = @reportID)
					then 1
				else 0
			end = 1

	insert into @result
	select null, d.ID, d.Caption
	from FCDashboardPresentationObjectRelation rel
		join FCDashboard d on d.ID = rel.FCDashboardID
	where rel.ReportID = @reportID

	select * from @result
end

GO
