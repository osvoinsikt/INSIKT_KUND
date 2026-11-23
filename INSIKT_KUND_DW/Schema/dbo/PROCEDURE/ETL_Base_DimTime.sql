SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==========================================================================================
-- Author:		TRIMMA Affärsutveckling AB
-- Description:	Procedur för att ladda tidsdimension
-- ==========================================================================================
-- LOG:
--	2013-03-26, TRIMMA	Standardimplementation
--  2014-09-25, TRIMMA	Uppdaterad med stöd för svenska helgdagar, buggfix: namn på veckor.
-- ==========================================================================================
CREATE Procedure [dbo].[ETL_Base_DimTime] (
	@startdate datetime
	,@stopdate datetime	
	,@lang char(2) = 'sv'
	,@addNotSet bit = 1
	,@ParentEventID int = null
	
)
as 

--
-- Standardvariabler
--
declare @ProcName sysname, @TranCount int, @EventIDStack varbinary(max)
set @ProcName = app.GetObjectFullName(@@procid)
set @TranCount = @@trancount


begin try
	--------------------------------------------------------------------------
	-- Start
	--------------------------------------------------------------------------
	declare @logMessage nvarchar(1000)
	select @logMessage = 'Intervall ' + convert(char(10), @startdate, 121) + ' - ' + convert(char(10), @stopdate, 121)
	exec app.LogEventStart @ParentEventID = @ParentEventID, @EventIDStack = @EventIDStack output, @EventObject = @ProcName
			,@EventTitle = 'dw.dim_Time'
			,@Description = @logMessage
		
		declare 
			@FiscalYear int
			,@FiscalYearName varchar(150)
			,@FiscalPeriodID int
			,@FiscalPeriod int
			,@FiscalPeriodNameWithYear varchar(150)
			,@FiscalThreePartYear int
			,@DefaultFiscalPeriodOffset int

		--------------------------------------------------------------------------
		-- FiscalPeriodExtractionScript
		--------------------------------------------------------------------------
		DECLARE	
	@FiscalFilterStart int
	,@FiscalFilterStop int

select
	@FiscalFilterStart = year(@startdate) * 10000 + month(@startdate) * 100
	,@FiscalFilterStop = year(@stopdate) * 10000 + month(@stopdate) * 100 + 99

select top 1
	@DefaultFiscalPeriodOffset = (Yr * 100 + Pr) - (FrDt / 100)
from
	[INSIKT_KUND_SA].visma.AcPr p
where
	Pr between 1 and 12
order by
	FrDt desc

;with FiscalData as
(
	select 
		FiscalYear = Yr
		,FiscalYearName = CAST(Yr AS VARCHAR(100))
		,FiscalPeriod = Pr
		,FiscalPeriodID = Yr * 100 + Pr
		,FiscalPeriodNameWithYear = cast(Pr as varchar(12)) + '-' + CAST(Yr as varchar(12))
		,MonthID = isnull(FrDt / 100, 0)

		,UseOne = 
			row_number() over
			(
				partition by
					FrDt / 100
				order by
					case when Pr between 1 and 12 then 1 else 2 end
					,case when Pr > 12 then 1 else 2 end
					,Pr
			)
	
	from 
		[INSIKT_KUND_SA].visma.AcPr p 
	where
		p.FrDt between @FiscalFilterStart and @FiscalFilterStop
					
)
select
	*
into #FiscalData
from
	FiscalData
where
	UseOne = 1

alter table #FiscalData add primary key (MonthID)
		--------------------------------------------------------------------------
		
		if @DefaultFiscalPeriodOffset is null set @DefaultFiscalPeriodOffset = 0

		declare @dynSQL varchar(max)
		declare @curdate datetime
		 
		select @curdate = @startdate


		declare @ThreePartYear int

		create table #LangDict
		(
			ID varchar(50) not null primary key	
			,Txt varchar(150)
		)
		--select Txt from #LangDict where ID = 'MONT_' + cast(datepart(month,@curdate))
		if @lang = 'sv'
			begin
				insert into #LangDict(ID, Txt) values ('DAY_1', 'Måndag')
				insert into #LangDict(ID, Txt) values ('DAY_2', 'Tisdag')
				insert into #LangDict(ID, Txt) values ('DAY_3', 'Onsdag')
				insert into #LangDict(ID, Txt) values ('DAY_4', 'Torsdag')
				insert into #LangDict(ID, Txt) values ('DAY_5', 'Fredag')
				insert into #LangDict(ID, Txt) values ('DAY_6', 'Lördag')
				insert into #LangDict(ID, Txt) values ('DAY_7', 'Söndag')
				
				insert into #LangDict(ID, Txt) values ('MONTH_1', 'Januari')
				insert into #LangDict(ID, Txt) values ('MONTH_2', 'Februari')
				insert into #LangDict(ID, Txt) values ('MONTH_3', 'Mars')
				insert into #LangDict(ID, Txt) values ('MONTH_4', 'April')
				insert into #LangDict(ID, Txt) values ('MONTH_5', 'Maj')
				insert into #LangDict(ID, Txt) values ('MONTH_6', 'Juni')
				insert into #LangDict(ID, Txt) values ('MONTH_7', 'Juli')
				insert into #LangDict(ID, Txt) values ('MONTH_8', 'Augusti')
				insert into #LangDict(ID, Txt) values ('MONTH_9', 'September')
				insert into #LangDict(ID, Txt) values ('MONTH_10', 'Oktober')
				insert into #LangDict(ID, Txt) values ('MONTH_11', 'November')
				insert into #LangDict(ID, Txt) values ('MONTH_12', 'December')
				
				insert into #LangDict(ID, Txt) values ('MISSING', 'Saknas')
				insert into #LangDict(ID, Txt) values ('THREEPART', 'Tertial')
				insert into #LangDict(ID, Txt) values ('WEEK', 'Vecka')
				insert into #LangDict(ID, Txt) values ('QUARTER', 'Kvartal')		
				insert into #LangDict(ID, Txt) values ('FISCALPERIOD', 'Period')		
				insert into #LangDict(ID, Txt) values ('FISCALQUARTER', 'Kvartal')
				insert into #LangDict(ID, Txt) values ('FISCALTHREEPARTYEAR', 'Tertial')
				insert into #LangDict(ID, Txt) values ('HALFYEAR', 'Halvår')
				insert into #LangDict(ID, Txt) values ('NOTSET', 'Ej angivet')


				insert into #LangDict(ID, Txt) values ('HOLIDAY_Christmas_Day', 'Juldagen')
				insert into #LangDict(ID, Txt) values ('HOLIDAY_Boxing_Day', 'Annandag jul')
				insert into #LangDict(ID, Txt) values ('HOLIDAY_New_Years_Day', 'Nyårsdagen')
				insert into #LangDict(ID, Txt) values ('HOLIDAY_Epiphany', 'Trettondedag jul')
				insert into #LangDict(ID, Txt) values ('HOLIDAY_First_of_May', 'Första maj')
				insert into #LangDict(ID, Txt) values ('HOLIDAY_Swedens_National_Day', 'Sveriges nationaldag')
				insert into #LangDict(ID, Txt) values ('HOLIDAY_Easter_Sunday', 'Påskdagen')
				insert into #LangDict(ID, Txt) values ('HOLIDAY_Good_Friday', 'Långfredagen')
				insert into #LangDict(ID, Txt) values ('HOLIDAY_Easter_Eve', 'Påskafton')
				insert into #LangDict(ID, Txt) values ('HOLIDAY_Easter_Monday', 'Annandag påsk')
				insert into #LangDict(ID, Txt) values ('HOLIDAY_Ascension', 'Kristi himmelsfärdsdag')
				insert into #LangDict(ID, Txt) values ('HOLIDAY_Pentecost', 'Pingstdagen')
				insert into #LangDict(ID, Txt) values ('HOLIDAY_Midsummer_Day', 'Midsommardagen')
				insert into #LangDict(ID, Txt) values ('HOLIDAY_All_Saints_Day', 'Alla helgons dag')
			end
		else -- Engelska
			begin 
				insert into #LangDict(ID, Txt) values ('DAY_1', 'Monday')
				insert into #LangDict(ID, Txt) values ('DAY_2', 'Tuesday')
				insert into #LangDict(ID, Txt) values ('DAY_3', 'Wednesday')
				insert into #LangDict(ID, Txt) values ('DAY_4', 'Thursday')
				insert into #LangDict(ID, Txt) values ('DAY_5', 'Friday')
				insert into #LangDict(ID, Txt) values ('DAY_6', 'Saturday')
				insert into #LangDict(ID, Txt) values ('DAY_7', 'Sunday')
				
				insert into #LangDict(ID, Txt) values ('MONTH_1', 'January')
				insert into #LangDict(ID, Txt) values ('MONTH_2', 'February')
				insert into #LangDict(ID, Txt) values ('MONTH_3', 'March')
				insert into #LangDict(ID, Txt) values ('MONTH_4', 'April')
				insert into #LangDict(ID, Txt) values ('MONTH_5', 'May')
				insert into #LangDict(ID, Txt) values ('MONTH_6', 'June')
				insert into #LangDict(ID, Txt) values ('MONTH_7', 'July')
				insert into #LangDict(ID, Txt) values ('MONTH_8', 'August')
				insert into #LangDict(ID, Txt) values ('MONTH_9', 'September')
				insert into #LangDict(ID, Txt) values ('MONTH_10', 'October')
				insert into #LangDict(ID, Txt) values ('MONTH_11', 'November')
				insert into #LangDict(ID, Txt) values ('MONTH_12', 'December')
				
				insert into #LangDict(ID, Txt) values ('MISSING', 'Missing')
				insert into #LangDict(ID, Txt) values ('THREEPART', 'Three part')
				insert into #LangDict(ID, Txt) values ('WEEK', 'Week')
				insert into #LangDict(ID, Txt) values ('QUARTER', 'Quarter')		
				insert into #LangDict(ID, Txt) values ('FISCALPERIOD', 'Period')		
				insert into #LangDict(ID, Txt) values ('FISCALQUARTER', 'Quarter')
				insert into #LangDict(ID, Txt) values ('FISCALTHREEPARTYEAR', 'Three part')
				insert into #LangDict(ID, Txt) values ('HALFYEAR', 'Half year')		
				insert into #LangDict(ID, Txt) values ('NOTSET', 'Not set')

				insert into #LangDict(ID, Txt) values ('HOLIDAY_Christmas_Day', 'Christmas Day')
				insert into #LangDict(ID, Txt) values ('HOLIDAY_Boxing_Day', 'Boxing Day')
				insert into #LangDict(ID, Txt) values ('HOLIDAY_New_Years_Day', 'New Year''s Day')
				insert into #LangDict(ID, Txt) values ('HOLIDAY_Epiphany', 'Epiphany')
				insert into #LangDict(ID, Txt) values ('HOLIDAY_First_of_May', 'First of May')
				insert into #LangDict(ID, Txt) values ('HOLIDAY_Swedens_National_Day', 'Sweden''s National Day')
				insert into #LangDict(ID, Txt) values ('HOLIDAY_Easter_Sunday', 'Easter Sunday')
				insert into #LangDict(ID, Txt) values ('HOLIDAY_Good_Friday', 'Good Friday')
				insert into #LangDict(ID, Txt) values ('HOLIDAY_Easter_Eve', 'Easter Eve')
				insert into #LangDict(ID, Txt) values ('HOLIDAY_Easter_Monday', 'Easter Monday')
				insert into #LangDict(ID, Txt) values ('HOLIDAY_Ascension', 'Ascension')
				insert into #LangDict(ID, Txt) values ('HOLIDAY_Pentecost', 'Pentecost')
				insert into #LangDict(ID, Txt) values ('HOLIDAY_Midsummer_Day', 'Midsummer Day')
				insert into #LangDict(ID, Txt) values ('HOLIDAY_All_Saints_Day', 'All Saints Day')
				
			end 



		SET DATEFIRST 1

		declare @CurrentYear int
		set @CurrentYear = null
		declare @CurrentMonthID int
		set @CurrentMonthID = null
		
		declare 
					@Easter_c int 
					,@Easter_n int 
					,@Easter_k int 
					,@Easter_i int 
					,@Easter_j int 
					,@Easter_l int 
					,@Easter_m int 
					,@Easter_d int 
					,@EasterSunday datetime 
					,@HolidayName varchar(1000)

		while 1=1

		begin 
			if not exists (select 1 from dw.dim_Time where Date = @curdate)
			begin
				select 
					@ThreePartYear = CASE 
         								WHEN datepart(month,@curdate) BETWEEN 1 AND 4 THEN 1
         								WHEN datepart(month,@curdate) BETWEEN 5 AND 8 THEN 2
										WHEN datepart(month,@curdate) BETWEEN 9 AND 12 THEN 3
									END

				
				if @CurrentYear is null or year(@curdate) <> @CurrentYear
					begin
				

						set @Easter_c = (DATEPART(YEAR, @curdate) / 100) 
						set @Easter_n = DATEPART(YEAR, @curdate) - 19 * (DATEPART(YEAR, @curdate) / 19) 
						set @Easter_k = (@Easter_c - 17) / 25 
						set @Easter_i = @Easter_c - @Easter_c / 4 - ( @Easter_c - @Easter_k) / 3 + 19 * @Easter_n + 15 
						set @Easter_i = @Easter_i - 30 * ( @Easter_i / 30 ) 
						set @Easter_i = @Easter_i - (@Easter_i / 28) * (1 - (@Easter_i / 28) * (29 / (@Easter_i + 1)) * ((21 - @Easter_n) / 11)) 
						set @Easter_j = DATEPART(YEAR, @curdate) + DATEPART(YEAR, @curdate) / 4 + @Easter_i + 2 - @Easter_c + @Easter_c / 4 
						set @Easter_j = @Easter_j - 7 * (@Easter_j / 7) 
						set @Easter_l = @Easter_i - @Easter_j 
						set @Easter_m = 3 + (@Easter_l + 40) / 44 
						set @Easter_d = @Easter_l + 28 - 31 * ( @Easter_m / 4 ) 						

						set @EasterSunday = convert(char(4),DATEPART(YEAR, @curdate)) + '-' + right('0' + convert(varchar(2),@Easter_m),2) + '-' + right('0' + convert(varchar(2),@Easter_d),2)

					end

				if @CurrentMonthID is null or year(@curdate) * 100 + month(@curdate) <> @CurrentMonthID
					begin
						set @CurrentMonthID = year(@curdate) * 100 + month(@curdate)

						-- Ny månad
						select
							@FiscalPeriodID = FiscalPeriodID							
							,@FiscalYear = FiscalYear
							,@FiscalPeriod = FiscalPeriod
							,@FiscalYearName = FiscalYearName
							,@FiscalPeriodNameWithYear  = FiscalPeriodNameWithYear
						from
							#FiscalData
						where
							MonthID = @CurrentMonthID
						if @@ROWCOUNT = 0
							begin
								select
									@FiscalPeriodID = case when @curdate = '1900-01-01' then 0 else datepart(year,dateadd(month, @DefaultFiscalPeriodOffset, @curdate)) * 100 + datepart(month,dateadd(month, @DefaultFiscalPeriodOffset, @curdate)) end
									,@FiscalYear = case when @curdate = '1900-01-01' then 0 else datepart(year,dateadd(month, @DefaultFiscalPeriodOffset, @curdate)) end
									,@FiscalPeriod = case when @curdate = '1900-01-01' then 0 else datepart(month,dateadd(month, @DefaultFiscalPeriodOffset, @curdate)) end
								select
									@FiscalYearName = @FiscalYear
									,@FiscalPeriodNameWithYear  = cast(@FiscalPeriod as varchar(12)) + '-' + CAST(@FiscalYear as varchar(12))
							end

						select 
							@FiscalThreePartYear = (@FiscalPeriod - 1) / 4 + 1							
							
					end
				set @HolidayName = null
				select @HolidayName = Txt
				from 
					#LangDict where ID = 
						CASE
							WHEN DATEPART(MONTH, @curdate) = 12 AND DATEPART(DAY, @curdate) = 25 THEN 'HOLIDAY_Christmas_Day' -- 'Juldagen'
							WHEN DATEPART(MONTH, @curdate) = 12 AND DATEPART(DAY, @curdate) = 26 THEN 'HOLIDAY_Boxing_Day' -- 'Annandag jul'
							WHEN DATEPART(MONTH, @curdate) = 1 AND DATEPART(DAY, @curdate) = 1 THEN 'HOLIDAY_New_Years_Day'-- 'Nyårsdagen'
							WHEN DATEPART(MONTH, @curdate) = 1 AND DATEPART(DAY, @curdate) = 6 THEN 'HOLIDAY_Epiphany'-- 'Trettondedag jul'
							WHEN DATEPART(MONTH, @curdate) = 5 AND DATEPART(DAY, @curdate) = 1 THEN 'HOLIDAY_First_of_May' -- 'Första maj'
							WHEN DATEPART(MONTH, @curdate) = 6 AND DATEPART(DAY, @curdate) = 6 THEN 'HOLIDAY_Swedens_National_Day' -- 'Sveriges nationaldag'
							WHEN @EasterSunday = @curdate THEN 'HOLIDAY_Easter_Sunday' -- 'Påskdagen'
							WHEN DATEADD(DAY, -2, @EasterSunday) = @curdate THEN 'HOLIDAY_Good_Friday' -- 'Långfredagen'
							--
							-- Påskafton är inte en röd dag men vissa hanterar den tydligen som en röd dag ändå. I Så fall kan nedan rad kommenteras fram för att få IsHoliday satt till 1.
							--
							/* 
							WHEN DATEADD(DAY, -1, @EasterSunday) = @curdate THEN 'HOLIDAY_Easter_Eve' -- 'Påskafton' 
							*/
							WHEN DATEADD(DAY, 1, @EasterSunday) = @curdate THEN 'HOLIDAY_Easter_Monday' -- 'Annandag påsk'
							WHEN DATEADD(DAY, 39, @EasterSunday) = @curdate THEN 'HOLIDAY_Ascension' -- 'Kristi himmelsfärdsdag'
							WHEN DATEADD(DAY, 49, @EasterSunday) = @curdate THEN 'HOLIDAY_Pentecost' -- 'Pingstdagen'
							WHEN DATEPART(MONTH, @curdate) = 6 AND DATEPART(DAY, @curdate) >= 20 AND DATEPART(DAY, @curdate) <= 26 AND datepart(weekday,@curdate) = 6 THEN 'HOLIDAY_Midsummer_Day' -- 'Midsommardagen'
							WHEN ((DATEPART(MONTH, @curdate) = 10 AND DATEPART(DAY, @curdate) = 31) OR (DATEPART(MONTH, @curdate) = 11 AND DATEPART(DAY, @curdate) <= 6)) AND datepart(weekday,@curdate) = 6  THEN 'HOLIDAY_All_Saints_Day' -- 'Alla helgons dag'
							else null
						END;
									
				insert into dw.dim_Time
				(
					[DateID]
					,[Date]
					,[DateName]
					,[Year]
					,[YearName]
					,[Halfyear]
					,[HalfyearID]
					,[HalfyearName]
					,[HalfyearNameWithYear]
					,[ThreePartYear]
					,[ThreePartYearID]
					,[ThreePartYearName]
					,[ThreePartYearNameWithYear]
					,[Quarter]
					,[QuarterID]
					,[QuarterName]
					,[QuarterNameWithYear]
					,[Month]
					,[MonthID]
					,[MonthName]
					,[MonthNameWithYear]
					,[MonthShortName]
					,[MonthShortNameWithYear]
					,[Week]
					,[WeekID]
					,[WeekName]
					,[WeekNameWithYear]
					,[YearForWeek]
					,[YearForWeekName]
					,[Day]
					,[DayName]
					,[DayOfWeek]
					,[DayOfWeekName]
					,[DayOfYear]
					,[DayOfYearName]
					,[DayOfYearWithYear]
					,[FiscalYear]
					,[FiscalYearName]
					,[FiscalPeriod]
					,[FiscalPeriodID]
					,[FiscalPeriodName]
					,[FiscalPeriodNameWithYear]
					,[FiscalQuarter]
					,[FiscalQuarterID]
					,[FiscalQuarterName]
					,[FiscalQuarterNameWithYear]

					,[FiscalThreePartYear]
					,[FiscalThreePartYearID]
					,[FiscalThreePartYearName]
					,[FiscalThreePartYearNameWithYear]
					
					,[FiscalDateID]

					,[IsHoliday]
					,[HolidayName]
					,[IsWorkday]
				)
				select		
					[DateID] = datepart(year,@curdate) * 10000 + datepart(month,@curdate) * 100 + DATEPART(day, @curdate)
					,[Date] = @curdate
					,[DateName] = CONVERT(varchar(10), @curdate, 121)
					,[Year] = datepart(year,@curdate)
					,[YearName] = datepart(year,@curdate)
					,[Halfyear] = case when datepart(month,@curdate)>6 then 2 else 1 end
					,[HalfyearID] = case when datepart(month,@curdate)>6 then 2 else 1 end + (datepart(year,@curdate) * 10)
					,[HalfyearName] = (select Txt from #LangDict where ID = 'HALFYEAR') + ' ' + cast(case when datepart(month,@curdate)>6 then 2 else 1 end as CHAR(1))
					,[HalfyearNameWithYear] = (select Txt from #LangDict where ID = 'HALFYEAR') + ' ' + cast(case when datepart(month,@curdate)>6 then 2 else 1 end as char(1)) + ' ' + cast(datepart(year, @curdate) as char(4))
					,[ThreePartYear] = @ThreePartYear
					,[ThreePartYearID] = @ThreePartYear + (datepart(year,@curdate) * 10)
					,[ThreePartYearName] = (select Txt from #LangDict where ID = 'THREEPART') + ' ' + CAST(@ThreePartYear as CHAR(1)) 
					,[ThreePartYearNameWithYear] = (select Txt from #LangDict where ID = 'THREEPART') + ' ' + CAST(@ThreePartYear as CHAR(1))  + ' ' + cast(datepart(year, @curdate) as char(4))
					,[Quarter] = datepart(quarter,@curdate)
					,[QuarterID] = datepart(quarter,@curdate) + (datepart(year,@curdate) * 10)
					,[QuarterName] = (select Txt from #LangDict where ID = 'QUARTER') + ' ' + cast(datepart(quarter,@curdate) as char(1))
					,[QuarterNameWithYear] = (select Txt from #LangDict where ID = 'QUARTER') + ' ' + cast(datepart(quarter,@curdate) as char(1)) + ' '+ cast(datepart(year,@curdate) as char(4))
					,[Month] = datepart(month,@curdate)
					,[MonthID] = datepart(year,@curdate) * 100 + datepart(month,@curdate)
					,[MonthName] = (select Txt from #LangDict where ID = 'MONTH_' + cast(datepart(month,@curdate) as varchar(2)))
					,[MonthNameWithYear] = (select Txt from #LangDict where ID = 'MONTH_' + cast(datepart(month,@curdate) as varchar(2))) + ' '+ cast(datepart(year,@curdate) as char(4))
					,[MonthShortName] = (select left(Txt,3) from #LangDict where ID = 'MONTH_' + cast(datepart(month,@curdate) as varchar(2)))
					,[MonthShortNameWithYear] = (select left(Txt, 3) from #LangDict where ID = 'MONTH_' + cast(datepart(month,@curdate) as varchar(2))) + ' '+ cast(datepart(year,@curdate) as char(4))
					,[Week] = app.ISOWeek(@curdate)
					,[WeekID] = datepart(year,dateadd(day, 4-datepart(weekday,@curdate),@curdate)) * 100 + app.ISOWeek(@curdate)
					,[WeekName] = (select Txt from #LangDict where ID = 'WEEK') + ' ' + cast(app.ISOWeek(@curdate) as varchar(2))
					,[WeekNameWithYear] = (select Txt from #LangDict where ID = 'WEEK') + ' ' + cast(app.ISOWeek(@curdate) as varchar(2)) + ' ' + cast(datepart(year,dateadd(day, 4-datepart(weekday,@curdate),@curdate)) as char(4))
					,[YearForWeek] = datepart(year,dateadd(day, 4-datepart(weekday,@curdate),@curdate))
					,[YearForWeekName] = datepart(year,dateadd(day, 4-datepart(weekday,@curdate),@curdate))
					,[Day] = datepart(day,@curdate)
					,[DayName] = datepart(day,@curdate)
					,[DayOfWeek] = datepart(weekday,@curdate)
					,[DayOfWeekName] = (select Txt from #LangDict where ID = 'DAY_' + cast(datepart(weekday,@curdate) as varchar(2)))
					,[DayOfYear] = datepart(dayofyear,@curdate)
					,[DayOfYearName] = datepart(dayofyear,@curdate)
					,[DayOfYearWithYear] = CAST(datepart(dayofyear,@curdate) as varchar(3)) + ' ' + cast(datepart(year,@curdate) as char(4))
					,[FiscalYear] = @FiscalYear
					,[FiscalYearName] = @FiscalYearName
					,[FiscalPeriod] = @FiscalPeriod
					,[FiscalPeriodID] = @FiscalPeriodID
					,[FiscalPeriodName] = (select Txt from #LangDict where ID = 'FISCALPERIOD') + ' ' + cast(@FiscalPeriod as varchar(2)) + ', ' + (select left(Txt, 3) from #LangDict where ID = 'MONTH_' + cast(datepart(month,@curdate) as varchar(2))) 
					,[FiscalPeriodNameWithYear] = @FiscalPeriodNameWithYear
					,[FiscalQuarter] = case when @curdate = '1900-01-01' then 0 else ((@FiscalPeriod - 1) / 3) + 1 end
					,[FiscalQuarterID] = case when @curdate = '1900-01-01' then 0 else @FiscalYear * 100 + ((@FiscalPeriod - 1) / 3) + 1 end
					,[FiscalQuarterName] = (select Txt from #LangDict where ID = 'FISCALQUARTER') + ' ' + CAST(case when @curdate = '1900-01-01' then 0 else ((@FiscalPeriod - 1) / 3) + 1 end as varchar(1))
					,[FiscalQuarterNameWithYear] = (select Txt from #LangDict where ID = 'FISCALQUARTER') + ' ' + CAST(case when @curdate = '1900-01-01' then 0 else ((@FiscalPeriod - 1) / 3) + 1 end as varchar(1)) + ' ' + CAST(@FiscalYear as varchar(4))

					,[FiscalThreePartYear] = case when @curdate = '1900-01-01' then 0 else ((@FiscalPeriod - 1) / 4) + 1 end
					,[FiscalThreePartYearID] = case when @curdate = '1900-01-01' then 0 else @FiscalYear * 10 + ((@FiscalPeriod - 1) / 4) + 1 end
					,[FiscalThreePartYearName] = (select Txt from #LangDict where ID = 'FISCALTHREEPARTYEAR') + ' ' + CAST(case when @curdate = '1900-01-01' then 0 else ((@FiscalPeriod - 1) / 4) + 1 end as varchar(1))
					,[FiscalThreePartYearNameWithYear] = (select Txt from #LangDict where ID = 'FISCALTHREEPARTYEAR') + ' ' + CAST(case when @curdate = '1900-01-01' then 0 else ((@FiscalPeriod - 1) / 4) + 1 end as varchar(1)) + '-' + CAST(@FiscalYear as varchar(4))

					,[FiscalDateID] = @FiscalYear * 10000 + @FiscalPeriod * 100 + datepart(day,@curdate)

					,[IsHoliday] = case when @HolidayName is null then 0 else 1 end
					,[HolidayName] = @HolidayName
					,[IsWorkday] = case when datepart(weekday,@curdate) in (6,7) or @HolidayName is not null then 0 else 1 end
						
				if @curdate = '1900-01-01'
					begin
						set @dynSQL = null
						select
							@dynSQL = coalesce
							(
								@dynSQL + ','
								,''
							)
							+ '[' + name + '] = 0'
						from 
							sys.columns 
						where 
							object_id = object_id('dw.dim_Time') 
							and user_type_id = 56 -- int
							--and name not like '%ID'
							and is_computed = 0

						select
							@dynSQL = coalesce
							(
								@dynSQL + ','
								,''
							)
							+ '[' + name + '] = left(''' + (select Txt from #LangDict where ID = 'NOTSET') + ''', ' + CAST(max_length as varchar(12)) + ')' + CHAR(10) + CHAR(13)
						from 
							sys.columns 
						where 
							object_id = object_id('dw.dim_Time') 
							and user_type_id = 167
							and is_computed = 0
						
							
						select
							@dynSQL =
								'update dw.dim_Time set' + char(10) + char(13) +
									@dynSQL +									
								'where Date = ''1900-01-01'''
						exec (@dynSQL)
					end
			end
			if @curdate = '1900-01-01' or (@addNotSet = 0 and  @curdate >= @stopdate) break
			if @curdate >= @stopdate select @curdate = '1900-01-01'			
			else select @curdate = dateadd(day,1,@curdate)

		end
		drop table #LangDict

	
	exec app.LogEventStop @EventIDStack = @EventIDStack out
	-- Stop
	--------------------------------------------------------------------------
	
end try
begin catch	
	--
	-- Rulla tillbaka eventualla transaktioner startade i den här procedurn och logga fel.
	--
	if @TranCount = 0 and @@trancount > 0 rollback tran
	exec app.HandleProcError @EventIDStack out, @ParentEventID, @ProcName
	exec app.ReThrowError
end catch
SET ANSI_NULLS ON
GO
