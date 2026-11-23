SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[Support_InitReportGuids] 
	
AS
BEGIN
	
	SET NOCOUNT ON;

    
    UPDATE Report
    SET [GUID] = newid()
    
    
END
GO
