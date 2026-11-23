SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create trigger [CDC_fact_Projekt_Utilities_to_fact_Projekt_Utilities_FactCDC] on dw.fact_Projekt_Utilities for 
	insert, update, delete as
begin
	set nocount on
	/*
	--
	-- Disbale trigger in current session
	--
	EXEC sys.sp_set_session_context 
		@key = N'Disable:fact_Projekt_Utilities_FactCDC', 
		@value = 1; -- 1 = Disable; NULL/0 = Enabled
	*/
	if SESSION_CONTEXT(N'Disable:fact_Projekt_Utilities_FactCDC') = 1
		return;
	
	
	
	insert into [dw].[fact_Projekt_Utilities_FactCDC]
	(
		[FCProjectID]
		,[FCVersionID]
		,[PrevFCVersionID]
		,[StartMonthID]
		,[StartWritabilityMonthID]
		,[EndMonthID]
		,[LastUtfallMonthID]
	)
	--
	-- Turn deleted/updated rows
	--
	select
		[FCProjectID] = f.[FCProjectID]
		,[FCVersionID] = f.[FCVersionID]
		,[PrevFCVersionID] = -f.[PrevFCVersionID]
		,[StartMonthID] = -f.[StartMonthID]
		,[StartWritabilityMonthID] = -f.[StartWritabilityMonthID]
		,[EndMonthID] = -f.[EndMonthID]
		,[LastUtfallMonthID] = -f.[LastUtfallMonthID]
	from
		deleted f			
	union all
	--
	-- Add new value for inserted/updated rows
	--
	select
		[FCProjectID] = f.[FCProjectID]
		,[FCVersionID] = f.[FCVersionID]
		,[PrevFCVersionID] = f.[PrevFCVersionID]
		,[StartMonthID] = f.[StartMonthID]
		,[StartWritabilityMonthID] = f.[StartWritabilityMonthID]
		,[EndMonthID] = f.[EndMonthID]
		,[LastUtfallMonthID] = f.[LastUtfallMonthID]
	from
		inserted f		
	
end
GO
ALTER TABLE [dw].[fact_Projekt_Utilities] ENABLE TRIGGER [CDC_fact_Projekt_Utilities_to_fact_Projekt_Utilities_FactCDC]
GO
