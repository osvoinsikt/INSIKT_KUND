SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Emil Ahlqvist
-- Create date: 2015-09-02
-- Description:	Tar bort processdata för högnivåprocesser som felaktigt finns i databasen för de specificerade parametrarna fctypeid och companyid.
-- =============================================
CREATE PROCEDURE [dbo].[delInvalidFCProcesses]
	@FCTypeID int,
	@CompanyID int
AS

BEGIN
	IF exists (SELECT * FROM FCCurrentConfiguration WHERE ValueNumeric = 1 AND ID = 408 AND (ISNULL(FCTypeID,@FCTypeID) = @FCTypeID AND ISNULL(CompanyID,@CompanyID) = @CompanyID))
	BEGIN
		RAISERROR ('No process data was removed because "EnableHighLevelProcesses" is set to true.',16,10);
		RETURN (-100)
	END
	ELSE
	BEGIN
		-- SET NOCOUNT ON added to prevent extra result sets from
		-- interfering with SELECT statements.
		SET NOCOUNT ON;

		-- Ta bort processer för icke-löv.
		SELECT FCProcess.ID 
		INTO #ProcessesToDelete
		FROM FCDimension JOIN FCProcess ON (FCDimension.FCTypeID = FCProcess.FCTypeID AND FCLevel01 = ElementKey AND FCDimension.CompanyID = FcProcess.CompanyID) WHERE isLeaf = 0 AND FCDimension.FCTypeID = @FCTypeID And FCDimension.CompanyID = @CompanyID
		DELETE FCProcessComment FROM FCProcessComment JOIN #ProcessesToDelete ON (FCProcessComment.ProcessID = #ProcessesToDelete.ID)
		DELETE FCProcess FROM FCProcess JOIN #ProcessesToDelete ON (FCProcess.ID = #ProcessesToDelete.ID)
		DROP TABLE #ProcessesToDelete
	END
END
GO
