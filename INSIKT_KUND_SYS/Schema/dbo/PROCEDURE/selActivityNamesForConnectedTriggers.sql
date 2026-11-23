SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Calle
-- Create date: 2017-07-03
-- Description:	Hämtar namn på aktiviteter kopplade mot triggers.
-- =============================================
CREATE PROCEDURE [dbo].[selActivityNamesForConnectedTriggers]
	@FCTypeID int
AS
BEGIN

	select 
		t.ID as TriggerID, a.Name as ActivityName, s.Name as StepName,
		CAST(
			CASE
			   WHEN (p.MainDecisionPointActivityID = a.ID) THEN 1 ELSE 0
			END AS bit
        ) as IsMainDecisionPoint
	from 
		FCProjectCalcTrigger t 
		inner join process.ProcessTemplateActivityRevision a 
			on a.ID = t.ProcessTemplateActivityRevisionID
		inner join process.ProcessTemplatePhaseRevision p
			on a.ProcessTemplatePhaseRevisionID = p.ID
		left join process.ProcessTemplateActivityStepRevision s 
			on s.ID = t.ProcessTemplateActivityStepRevisionID
	where
		t.FCTypeID = @FCTypeID

END
GO
