SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_GetCurrentProcessPhaseID]
	/**
		Gets the ID of the current phase of a process instance. Will return NULL if all phases are done.
		Input:		process.ProcessInstance.ID
		Output:		process.ProcessInstancePhase.ID

		By: joma
	**/
(
	@processInstanceID int
)
RETURNS INT
AS
BEGIN
	RETURN (
		SELECT TOP 1 pic.ID
		FROM process.ProcessInstancePhase pic
		JOIN process.ProcessTemplatePhaseRevision ptpr ON (pic.ProcessTemplatePhaseRevisionID = ptpr.ID)
		WHERE pic.ProcessInstanceID = @processInstanceID AND pic.IsFinished = 0
		ORDER BY ptpr.[Order] ASC
	)
END
GO
