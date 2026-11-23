SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_GetNameOfProcessInstancePhase]
	/**
		Gets the name of an instnace phase
		Input:		process.ProcessInstancePhase.ID
		Output:		process.ProcessTemplateActivityRevision.Name

		By: caal
	**/
(
	@processInstancePhaseID int
)
RETURNS nvarchar(255)
AS
BEGIN
	RETURN (
		SELECT a.[Name] FROM process.ProcessInstancePhase i
			JOIN process.ProcessTemplatePhaseRevision r ON r.ID = i.ProcessTemplatePhaseRevisionID
			JOIN process.ProcessTemplateActivityRevision a ON a.ID = r.MainDecisionPointActivityID
		WHERE i.ID = @processInstancePhaseID
	)
END
GO
