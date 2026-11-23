SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [insikt].[FCVersion_UpdateInserting]
	@CompanyID int
	,@FCVersionID int
	,@FiscalYear int
	,@Type int
	,@OriginVersionID int
	,@PeriodMonth int
AS
BEGIN

	declare 
		@Message nvarchar(500)
		,@Status int

	declare @TempStr nvarchar(500)
	declare @TempType int
	
	if @Type = 2 and @FCVersionID <> 0
		begin
			--
			-- Verifiera att PeriodMonth inte har ändrats
			--
			if exists
			(
				select
					*
				from
					dw.dim_PlanningVersion pv
				where
					pv.PlanningVersionID = @FCVersionID
					and
					(
						isnull(pv.NrOfLockedPeriods, -1) <> isnull(RIGHT(@PeriodMonth, 2), -1)
					)
			)
				begin
					select
						Status = 99
						,Message = 'Det går inte att ändra ackumulerat utfall på en redan skapad prognos.'
					return
				end
		end

	
	if @Type = 1 and @OriginVersionID <> -1
		begin
			--
			-- Verifiera så att ursprungsversion tillhöra året innan budgetåret
			--
			if not exists
			(
				select 
					* 
				from  
					dw.dim_PlanningVersion originVer 
				where 
					originVer.PlanningVersionID = @OriginVersionID 
					and originVer.FiscalYear = @FiscalYear - 1
			)
				begin
					select
						Status = 99
						,Message = 'Ursprungsversionen måste vara från föregående budgetår.'
					return
				end			
		end


	if @Type = 2 and @OriginVersionID <> -1
		begin
			--
			-- Verifiera så att ursprungsversion tillhöra samma fiscala or som aktuell version
			--
			if not exists
			(
				select 
					* 
				from  
					dw.dim_PlanningVersion originVer 
				where 
					originVer.PlanningVersionID = @OriginVersionID 
					and originVer.FiscalYear = @FiscalYear
			)
				begin
					select
						Status = 99
						,Message = 'Ursprungsversionen måste ha samma budgetår.'
					return
				end
		end


	
	SELECT Status = 1, Message =  'OK'
END
GO
