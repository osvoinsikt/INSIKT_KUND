SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*******************************************************************
	#Desc: 			Helper function that gets the (start or end) date for
					a process instance activity for a specific project.
	#Used By:			-
	#Creator:			Emil Ahlqvist
	#CreateDate:		160613
	#Modified by:		-
	#ModifiedDate:		-

	#Log:

********************************************************************/
CREATE FUNCTION [dbo].[fn_GetDateFromProjectProcessActivity]
(
	@fcProjectId int,
	@processActivityTemplateId int,
	@getEndDate bit
)
RETURNS DATETIME
AS
BEGIN
	DECLARE @date DATETIME = NULL

	select @date = (
		case when @getEndDate = 1 then
			instanceActivity.EndDate
		else
			instanceActivity.StartDate
		end
	)
	from dbo.FCProjectProcessInstanceRelation projProcessRel
	left outer join process.ProcessInstancePhase instancePhase on instancePhase.ProcessInstanceID = projProcessRel.ProcessInstanceID
	join process.ProcessTemplateActivityRevision templateRevision on templateRevision.ProcessTemplateActivityID = @processActivityTemplateId
	right join process.ProcessInstanceActivity instanceActivity on instanceActivity.ProcessInstancePhaseID = instancePhase.ID and instanceActivity.ProcessTemplateActivityRevisionID = templateRevision.ID
	where FCProjectID = @fcProjectId

	RETURN @date
END
GO
