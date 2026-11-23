SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*******************************************************************
 #Desc: 		Finishes all FCProcesses with the given IDs
 #Used By:			-
 #Creator:			Andreas Bäärnhielm
 #CreateDate:		240809
 #Modified by
 #ModifiedDate:
 #Change history:
 #Log:

********************************************************************/

CREATE PROCEDURE [dbo].[finishFCProcesses]
	@iProcessIDs NVARCHAR(MAX),
	@userID INT
AS
BEGIN
	DECLARE @errmsg VARCHAR(100);
	DECLARE @IdTable TABLE (Id NVARCHAR(max))

	INSERT INTO @IdTable
	SELECT strings AS Id
	FROM dbo.sepstring(@iProcessIDs, ',')
	WHERE strings IS NOT NULL;

	-- Update the FCProcess table in a single statement using a join
	UPDATE p
	SET p.FinishedDate = CONVERT(VARCHAR, GETUTCDATE(), 120),
		p.FinishedBy = @userID
	FROM dbo.FCProcess p
	INNER JOIN @IdTable it ON p.ID = it.Id
	WHERE p.FinishedBy Is NULL;
END
GO
