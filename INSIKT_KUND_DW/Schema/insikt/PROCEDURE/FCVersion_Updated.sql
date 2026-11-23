SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [insikt].[FCVersion_Updated] 
	@FCVersionID int,
	@CallFromINSIKT bit = 1
AS
BEGIN
	--
	-- Uppdatera Planeringsversionsraden
	-- 
	update pv set	
		NrOfLockedPeriods = 
		case pv.Type				
			when 2 then -- Prognos
				RIGHT(pv.PeriodMonth, 2)
			else
				pv.NrOfLockedPeriods
		end,
		IDWithinType = 
		case 
			when pv.IDWithinType is null then 
				(
					SELECT ISNULL(MAX(CAST(IDWithinType AS INT)), 0) + 1  
					FROM [INSIKT_KUND_SYS].dbo.FCVersion as otherversion  
					where otherversion.ID <> pv.ID  
						and otherversion.FiscalYear = pv.FiscalYear  
						and otherversion.Type = pv.Type 
				)	
			else 
				pv.IDWithinType 
		end
	from
		[INSIKT_KUND_SYS].dbo.FCVersion pv
	where
		pv.ID = @FCVersionID
	

	-- Kopiera kommentarer från budget till analys om versionen stängs.
	declare @IsActiveBudget int
	select @IsActiveBudget = IsBudget from [INSIKT_KUND_SYS].dbo.FCVersion where ID = @FCVersionID
	if @IsActiveBudget = 0
		begin
			exec [insikt].[CopyCommentsFromResultatplaneringToAnalysis] @FCVersionID
		end


	if @CallFromINSIKT = 1
		begin		
			EXEC [app].[StartJob] 
				@JobName = 'INSIKT_KUND - Processa planeringsversionsdimension'
				,@InitialWaitForJob = 1

			SELECT 1 as Status, 'OK' as Message		
		end
END
GO
