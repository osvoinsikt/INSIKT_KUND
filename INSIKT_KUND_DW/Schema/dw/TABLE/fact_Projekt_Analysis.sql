SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dw].[fact_Projekt_Analysis](
	[FCProjectID] [int] NOT NULL,
	[DateID] [int] NOT NULL,
	[KontoID] [int] NOT NULL,
	[AktuellKalkyl] [numeric](28, 8) NULL,
	[PrevKalkyl] [numeric](28, 8) NULL,
	[Förkalkyl] [numeric](28, 8) NULL,
	[Budget] [numeric](28, 8) NULL,
	[Prognos] [numeric](28, 8) NULL,
	[PrevPrognos] [numeric](28, 8) NULL,
 CONSTRAINT [PK_fact_Projekt_Analysis] PRIMARY KEY CLUSTERED 
(
	[FCProjectID] ASC,
	[DateID] ASC,
	[KontoID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create trigger [CDC_fact_Projekt_Analysis_to_fact_Projekt_Analysis_FactCDC] on [dw].[fact_Projekt_Analysis] for 
	insert, update, delete as
begin
	set nocount on
	/*
	--
	-- Disbale trigger in current session
	--
	EXEC sys.sp_set_session_context 
		@key = N'Disable:fact_Projekt_Analysis_FactCDC', 
		@value = 1; -- 1 = Disable; NULL/0 = Enabled
	*/
	if SESSION_CONTEXT(N'Disable:fact_Projekt_Analysis_FactCDC') = 1
		return;
	
	
	
	insert into [dw].[fact_Projekt_Analysis_FactCDC]
	(
		[FCProjectID]
		,[DateID]
		,[KontoID]
		,[AktuellKalkyl]
		,[PrevKalkyl]
		,[Förkalkyl]
		,[Budget]
		,[Prognos]
		,[PrevPrognos]
	)
	--
	-- Turn deleted/updated rows
	--
	select
		[FCProjectID] = f.[FCProjectID]
		,[DateID] = f.[DateID]
		,[KontoID] = f.[KontoID]
		,[AktuellKalkyl] = -f.[AktuellKalkyl]
		,[PrevKalkyl] = -f.[PrevKalkyl]
		,[Förkalkyl] = -f.[Förkalkyl]
		,[Budget] = -f.[Budget]
		,[Prognos] = -f.[Prognos]
		,[PrevPrognos] = -f.[PrevPrognos]
	from
		deleted f			
	union all
	--
	-- Add new value for inserted/updated rows
	--
	select
		[FCProjectID] = f.[FCProjectID]
		,[DateID] = f.[DateID]
		,[KontoID] = f.[KontoID]
		,[AktuellKalkyl] = f.[AktuellKalkyl]
		,[PrevKalkyl] = f.[PrevKalkyl]
		,[Förkalkyl] = f.[Förkalkyl]
		,[Budget] = f.[Budget]
		,[Prognos] = f.[Prognos]
		,[PrevPrognos] = f.[PrevPrognos]
	from
		inserted f		
	
end
GO
ALTER TABLE [dw].[fact_Projekt_Analysis] ENABLE TRIGGER [CDC_fact_Projekt_Analysis_to_fact_Projekt_Analysis_FactCDC]
GO
