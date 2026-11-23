SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*******************************************************************
 #Desc: 		Approves FCProcesses with the given IDs
 #Used By:			-
 #Creator:			Andreas Bäärnhielm
 #CreateDate:		240812
 #Modified by
 #ModifiedDate:
 #Change history:
 #Log:

********************************************************************/

CREATE PROCEDURE [dbo].[approveFCprocesses]
    @iProcessIDs NVARCHAR(MAX),
    @userID INT,
	@isFirstApprover BIT
AS
BEGIN
	DECLARE @IdTable TABLE (Id NVARCHAR(max))

	INSERT INTO @IdTable
	SELECT strings AS Id
	FROM dbo.sepstring(@iProcessIDs, ',')
	WHERE strings IS NOT NULL;

	IF @isFirstApprover = 1
	BEGIN
		UPDATE p
		SET p.ApprovedDate = CONVERT(VARCHAR, GETUTCDATE(), 120),
			p.ApprovedBy = @userID
		FROM dbo.FCProcess p
		INNER JOIN @IdTable it ON p.ID = it.Id
		WHERE p.ApprovedBy Is NULL;
	END
	ELSE
	BEGIN
		UPDATE p
		SET p.SecondaryApprovedDate = CONVERT(VARCHAR, GETUTCDATE(), 120),
			p.SecondaryApprovedBy = @userID
		FROM dbo.FCProcess p
		INNER JOIN @IdTable it ON p.ID = it.Id
		WHERE p.SecondaryApprovedBy Is NULL;
	END
END
GO
