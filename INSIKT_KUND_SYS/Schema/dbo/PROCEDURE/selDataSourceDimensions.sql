SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		Adam Holmström
-- Create date: 
-- Description:	Returnerar alla dimensionsinställningar för en datakälla.
-- =============================================
CREATE PROCEDURE [dbo].[selDataSourceDimensions] 
	@dataSourceId int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT * FROM DataSourceDimension Where DataSourceID = @dataSourceId
END

GO
