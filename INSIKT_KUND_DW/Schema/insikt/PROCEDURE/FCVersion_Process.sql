SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [insikt].[FCVersion_Process] AS
BEGIN
	DECLARE @status int
 
	EXEC [app].[StartJobAndWait] @JobName = 'INSIKT_KUND - Processa planeringsversionsdimension', @Status = @status output, @InitialWaitForJob = 1
 
	IF @status <> 1
	BEGIN
		SELECT 99 as Status, 'Ett fel uppstod' as Message
	END
	ELSE
	BEGIN
		SELECT 1 as Status, '' as Message
	END
END
GO
