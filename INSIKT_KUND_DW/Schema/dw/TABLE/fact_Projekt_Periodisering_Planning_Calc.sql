SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dw].[fact_Projekt_Periodisering_Planning_Calc](
	[FCProjectID] [int] NOT NULL,
	[FCVersionID] [int] NOT NULL,
	[MonthID] [int] NOT NULL,
	[KontoID] [int] NOT NULL,
	[BeräknatPeriodiseratBelopp] [decimal](28, 8) NULL,
 CONSTRAINT [PK__fact_Projekt_Periodisering_Planning_Calc] PRIMARY KEY CLUSTERED 
(
	[FCProjectID] ASC,
	[FCVersionID] ASC,
	[MonthID] ASC,
	[KontoID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create trigger [CDC_fact_Projekt_Periodisering_Planning_Calc_to_fact_Projekt_Periodisering_Planning_Calc_FactCDC] on dw.fact_Projekt_Periodisering_Planning_Calc for 
	insert, update, delete as
begin
	set nocount on
	/*
	--
	-- Disbale trigger in current session
	--
	EXEC sys.sp_set_session_context 
		@key = N'Disable:fact_Projekt_Periodisering_Planning_Calc_FactCDC', 
		@value = 1; -- 1 = Disable; NULL/0 = Enabled
	*/
	if SESSION_CONTEXT(N'Disable:fact_Projekt_Periodisering_Planning_Calc_FactCDC') = 1
		return;
	
	
	
	insert into [dw].[fact_Projekt_Periodisering_Planning_Calc_FactCDC]
	(
		[FCProjectID]
		,[FCVersionID]
		,[MonthID]
		,[KontoID]
		,[BeräknatPeriodiseratBelopp]
	)
	--
	-- Turn deleted/updated rows
	--
	select
		[FCProjectID] = f.[FCProjectID]
		,[FCVersionID] = f.[FCVersionID]
		,[MonthID] = f.[MonthID]
		,[KontoID] = f.[KontoID]
		,[BeräknatPeriodiseratBelopp] = -f.[BeräknatPeriodiseratBelopp]
	from
		deleted f			
	union all
	--
	-- Add new value for inserted/updated rows
	--
	select
		[FCProjectID] = f.[FCProjectID]
		,[FCVersionID] = f.[FCVersionID]
		,[MonthID] = f.[MonthID]
		,[KontoID] = f.[KontoID]
		,[BeräknatPeriodiseratBelopp] = f.[BeräknatPeriodiseratBelopp]
	from
		inserted f		
	
end
GO
ALTER TABLE [dw].[fact_Projekt_Periodisering_Planning_Calc] ENABLE TRIGGER [CDC_fact_Projekt_Periodisering_Planning_Calc_to_fact_Projekt_Periodisering_Planning_Calc_FactCDC]
GO
