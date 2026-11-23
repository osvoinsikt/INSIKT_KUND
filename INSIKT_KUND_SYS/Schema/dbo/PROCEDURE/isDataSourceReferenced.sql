SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author: Linus Nilsson
-- Create date: 2013-07-09
-- Description: Säger om det finns rader i andra tabeller som refererar till den givna datakällan i DataSources.
-- =============================================
CREATE PROCEDURE [dbo].[isDataSourceReferenced]
	@dataSourceID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Det här behöver uppdateras när det tillkommer eller försvinner referenser till DataSources.

	select (case when exists(
			select 1 from DataSourceDimension where DataSourceID = @dataSourceID
			union
			select 1 from DataSourcesMeasureGroup where DataSourceID = @dataSourceID
			union
			select 1 from DataSourcePerspective where DataSourceID = @dataSourceID
			union
			select 1 from DrillthroughColumns where DataSourceID = @dataSourceID
			union
			select 1 from DrillThroughColumnFormatting where DataSourceID = @dataSourceID
			union
			select 1 from UserSecurityGroup where DefaultDatasourceID = @dataSourceID
			union
			select 1 from CellCommentType where DataSourceID = @dataSourceID
			union
			select 1 from FCTypeDataSourceRelation where DataSourceID = @dataSourceID
			union
			select 1 from FCElement where DataSourceID = @dataSourceID)
		then 1
		else 0
	end) as Result
END
GO
