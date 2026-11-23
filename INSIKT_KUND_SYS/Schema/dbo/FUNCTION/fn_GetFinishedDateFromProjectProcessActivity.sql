SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*******************************************************************
	#Desc: 			Helper function that gets the date when a 
					process instance activity is finished for a specific project.
					The last step for the activity is used.
	#Used By:			-
	#Creator:			Emil Ahlqvist
	#CreateDate:		161101
	#Modified by:		Emil Ahlqvist
	#ModifiedDate:		200901
 
	#Log:
		- Refactor to filter @processActivityTemplateId against "..ActivityID" and not "..ActivityRevisionID"

********************************************************************/
CREATE FUNCTION [dbo].[fn_GetFinishedDateFromProjectProcessActivity]
(
	@fcProjectId int,
	@processActivityTemplateId int
)
RETURNS DATETIME
AS
BEGIN
	DECLARE @date DATETIME = NULL

	select TOP 1 @date = step.FinishedDate
	from dbo.FCProjectProcessInstanceRelation projProcessRel
	left outer join process.ProcessInstancePhase instancePhase on (instancePhase.ProcessInstanceID = projProcessRel.ProcessInstanceID)
	join process.ProcessTemplateActivityRevision templateRevision on templateRevision.ProcessTemplateActivityID = @processActivityTemplateId
	right join process.ProcessInstanceActivity instanceActivity on (instanceActivity.ProcessInstancePhaseID = instancePhase.ID and instanceActivity.ProcessTemplateActivityRevisionID = templateRevision.ID)
	left join process.ProcessInstanceActivityStep step on (step.ProcessInstanceActivityID = instanceActivity.ID)
	where FCProjectID = @fcProjectId
	order by step.[Order] DESC

	--SELECT @date
	RETURN @date
END
GO
