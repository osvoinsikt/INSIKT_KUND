SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dw].[dim_Time](
	[DateID] [int] NOT NULL,
	[Date] [datetime] NOT NULL,
	[DateName] [varchar](10) NOT NULL,
	[Year] [int] NOT NULL,
	[YearName] [varchar](50) NOT NULL,
	[Halfyear] [int] NOT NULL,
	[HalfyearID] [int] NOT NULL,
	[HalfyearName] [varchar](50) NOT NULL,
	[HalfyearNameWithYear] [varchar](50) NOT NULL,
	[ThreePartYear] [int] NOT NULL,
	[ThreePartYearID] [int] NOT NULL,
	[ThreePartYearName] [varchar](50) NOT NULL,
	[ThreePartYearNameWithYear] [varchar](50) NOT NULL,
	[Quarter] [int] NOT NULL,
	[QuarterID] [int] NOT NULL,
	[QuarterName] [varchar](50) NOT NULL,
	[QuarterNameWithYear] [varchar](50) NOT NULL,
	[Month] [int] NOT NULL,
	[MonthID] [int] NOT NULL,
	[MonthName] [varchar](50) NOT NULL,
	[MonthNameWithYear] [varchar](50) NOT NULL,
	[MonthShortName] [varchar](50) NOT NULL,
	[MonthShortNameWithYear] [varchar](50) NOT NULL,
	[Week] [int] NOT NULL,
	[WeekID] [int] NOT NULL,
	[WeekName] [varchar](50) NULL,
	[WeekNameWithYear] [varchar](50) NULL,
	[YearForWeek] [int] NOT NULL,
	[YearForWeekName] [varchar](50) NOT NULL,
	[Day] [int] NOT NULL,
	[DayName] [varchar](50) NOT NULL,
	[DayOfWeek] [int] NOT NULL,
	[DayOfWeekName] [varchar](50) NOT NULL,
	[DayOfYear] [int] NOT NULL,
	[DayOfYearName] [varchar](50) NOT NULL,
	[DayOfYearWithYear] [varchar](50) NOT NULL,
	[FiscalYear] [int] NOT NULL,
	[FiscalYearName] [varchar](50) NOT NULL,
	[FiscalPeriod] [int] NULL,
	[FiscalPeriodID] [int] NULL,
	[FiscalPeriodName] [varchar](50) NOT NULL,
	[FiscalPeriodNameWithYear] [varchar](50) NOT NULL,
	[FiscalQuarter] [int] NOT NULL,
	[FiscalQuarterID] [int] NOT NULL,
	[FiscalQuarterName] [varchar](50) NOT NULL,
	[FiscalQuarterNameWithYear] [varchar](50) NOT NULL,
	[IsHoliday] [bit] NOT NULL,
	[HolidayName] [varchar](100) NULL,
	[IsWorkday] [bit] NOT NULL,
	[FiscalThreePartYear] [int] NOT NULL,
	[FiscalThreePartYearID] [int] NOT NULL,
	[FiscalThreePartYearName] [varchar](50) NOT NULL,
	[FiscalThreePartYearNameWithYear] [varchar](50) NOT NULL,
	[FiscalDateID] [int] NOT NULL,
 CONSTRAINT [PK_dw_dim_Time] PRIMARY KEY CLUSTERED 
(
	[DateID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
