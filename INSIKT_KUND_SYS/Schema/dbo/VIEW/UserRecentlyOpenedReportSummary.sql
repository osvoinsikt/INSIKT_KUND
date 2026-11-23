SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[UserRecentlyOpenedReportSummary]
	AS
		SELECT 
			urur.OpenedDate, 
			r.ID as ReportID, r.Name As ReportName, rt.Name As ReportType, 
			case when r.isCommon = 1 and not r.IsQuickReport = 1 then 1 else 0 end as IsCommon,
			usr.FullName As UserFullName 
		FROM UserRecentlyUsedReport urur
			INNER JOIN Report r ON urur.ReportID = r.ID
			INNER JOIN UserSecurityGroup usr ON urur.UserID = usr.UserID
			INNER JOIN ReportType rt ON r.ReportTypeID = rt.ID
		WHERE FullName NOT LIKE '%TRIMMA%'
			AND SuperAdmin is null
			AND r.LocalInReportID IS NULL
GO
