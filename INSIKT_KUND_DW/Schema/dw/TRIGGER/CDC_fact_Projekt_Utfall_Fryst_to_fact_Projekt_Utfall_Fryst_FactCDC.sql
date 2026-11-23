SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create trigger [CDC_fact_Projekt_Utfall_Fryst_to_fact_Projekt_Utfall_Fryst_FactCDC] on dw.fact_Projekt_Utfall_Fryst for 
	insert, update, delete as
begin
	set nocount on
	/*
	--
	-- Disbale trigger in current session
	--
	EXEC sys.sp_set_session_context 
		@key = N'Disable:fact_Projekt_Utfall_Fryst_FactCDC', 
		@value = 1; -- 1 = Disable; NULL/0 = Enabled
	*/
	if SESSION_CONTEXT(N'Disable:fact_Projekt_Utfall_Fryst_FactCDC') = 1
		return;
	
	
	
	insert into [dw].[fact_Projekt_Utfall_Fryst_FactCDC]
	(
		[FCProjectID]
		,[FCVersionID]
		,[ProjektID]
		,[MonthID]
		,[KontoID]
		,[Amount]
	)
	--
	-- Turn deleted/updated rows
	--
	select
		[FCProjectID] = f.[FCProjectID]
		,[FCVersionID] = f.[FCVersionID]
		,[ProjektID] = f.[ProjektID]
		,[MonthID] = f.[MonthID]
		,[KontoID] = f.[KontoID]
		,[Amount] = -f.[Amount]
	from
		deleted f			
	union all
	--
	-- Add new value for inserted/updated rows
	--
	select
		[FCProjectID] = f.[FCProjectID]
		,[FCVersionID] = f.[FCVersionID]
		,[ProjektID] = f.[ProjektID]
		,[MonthID] = f.[MonthID]
		,[KontoID] = f.[KontoID]
		,[Amount] = f.[Amount]
	from
		inserted f		
	
end
GO
ALTER TABLE [dw].[fact_Projekt_Utfall_Fryst] ENABLE TRIGGER [CDC_fact_Projekt_Utfall_Fryst_to_fact_Projekt_Utfall_Fryst_FactCDC]
GO
