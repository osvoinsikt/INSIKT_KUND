SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ReportsAsXML]
AS

SELECT [ID]
      ,[Name]
      ,[Description]
      ,[CreatedBy]
      ,[CreatedDate]
      ,[ModifiedBy]
      ,[ModifiedDate]
      ,[CategoryID]
      ,Data
      ,[isCommon]
      ,[User]
      ,[RowVersion]
      ,[ReportTypeID]
      ,[Restricted]
      ,[Inactive]
      ,[GUID]
      ,[Version]
      ,[DisplayModeID]
      ,[IsQuickReport]
      ,[LocalInReportID]
FROM [Report]
-- Analysis reports and multi reports are XML.
WHERE ReportTypeID in (1, 4)
GO
