SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [insikt].[FCVersion_Inserted] 
	@FCVersionID int
AS
BEGIN
	--
	-- Uppdatera Planeringsversionsraden
	-- 	
	exec [insikt].[FCVersion_Updated] 
		@FCVersionID = @FCVersionID
		,@CallFromINSIKT = 1

	insert into [INSIKT_KUND_SYS].dbo.FCVersionFCTypeRelation
	(
		FCTypeID
		,FCVersionID
	)
	select FCTypeID = 1, FCVersionID = @FCVersionID

	-- Initiera planeringsversion med siffror i dw't. Förfyll prognos med utfall och budget/prognos från föregående version.
	exec [dbo].[ETL_Fact_Resultat_Planning_InitPlanningVersion]
		@PlanningVersionID = @FCVersionID
	
	-- Skapa kommentarslänkar till föregående planeringsversion.
	exec [insikt].[LinkBudgetCommentsPerVersion]

	SELECT 1 as Status, 'Version skapad' as Message
END
GO
