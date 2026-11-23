SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Calle
-- Create date: 2019-02-11
-- Description:	Procedure to bulk bump revision ids for process sync
-- =============================================
CREATE PROCEDURE [process].[bumpProcessIds]
AS
BEGIN

	--CREATE TABLE #tempActivityIds (InstanceEntityID int, RevisionEntityID int)
	--CREATE TABLE #tempStepIds (InstanceEntityID int, RevisionEntityID int)

	update i
	set i.ProcessTemplateActivityRevisionID = a.RevisionEntityID
	from process.ProcessInstanceActivity i
		join #tempActivityIds a on i.ID = a.InstanceEntityID

	update i
	set i.ProcessTemplateActivityStepRevisionID = s.RevisionEntityID
	from process.ProcessInstanceActivityStep i
		join #tempStepIds s on i.ID = s.InstanceEntityID

END
GO
