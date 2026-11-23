SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*******************************************************************
 #Desc: 		Finishes all FCProcesses with the given IDs
 #Used By:			-
 #Creator:			Andreas Bäärnhielm
 #CreateDate:		240812
 #Modified by
 #ModifiedDate:
 #Change history:
 #Log:

********************************************************************/

CREATE	Procedure [dbo].[unFinishFCprocesses]
	@iProcessIDs VARCHAR(MAX)
AS
BEGIN
	DECLARE @IdTable TABLE (Id NVARCHAR(max))

	INSERT INTO @IdTable
	SELECT strings AS Id
	FROM dbo.sepstring(@iProcessIDs, ',')
	WHERE strings IS NOT NULL;

	-- Update the FCProcess table in a single statement using a join
	UPDATE p
	SET p.FinishedDate = null,
		p.FinishedBy = null
	FROM dbo.FCProcess p
	INNER JOIN @IdTable it ON p.ID = it.Id;
END


GO
