SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*******************************************************************
 #Desc: 			Removes the approval of an FCProcess
 #Used By:			-
 #Creator:			Andreas Bäärnhielm
 #CreateDate:		240812
 #Modified by
 #ModifiedDate:
 #Change history:
 #Log:

********************************************************************/
CREATE PROCEDURE [dbo].[unApproveFCprocesses]
    @iProcessIDs VARCHAR(MAX),
    @isFirstApprover BIT
AS
BEGIN
    DECLARE @IdTable TABLE (Id NVARCHAR(max))

	INSERT INTO @IdTable
	SELECT strings AS Id
	FROM dbo.sepstring(@iProcessIDs, ',')
	WHERE strings IS NOT NULL;

    -- Check the value of @isFirstApprover
    IF @isFirstApprover = 1
    BEGIN
        -- If @isFirstApprover is TRUE (1), update the first approval fields
        UPDATE p
        SET 
            [ApprovedDate] = NULL,
            [ApprovedBy] = NULL
        FROM FCProcess p
        INNER JOIN @IdTable t ON p.ID = t.Id;
    END
    ELSE
    BEGIN
        -- If @isFirstApprover is FALSE (0), update the secondary approval fields
        UPDATE p
        SET
            [SecondaryApprovedDate] = NULL,
            [SecondaryApprovedBy] = NULL
        FROM FCProcess p
        INNER JOIN @IdTable t ON p.ID = t.Id;
    END
END;
GO
