SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WriteTable_Fact_Projekt_Periodisering_Planning_WithTrigger](
	[PeriodiseratBelopp_0] [float] NULL,
	[FgPeriodiseratBelopp_1] [float] NULL,
	[FCProjectID_2] [int] NULL,
	[FCVersionID_3] [int] NULL,
	[MonthID_4] [int] NULL,
	[KontoID_5] [int] NULL,
	[MS_AUDIT_TIME_6] [datetime] NULL,
	[MS_AUDIT_USER_7] [nvarchar](255) NULL
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create trigger [dbo].[TriggerInsert_WriteTable_fact_Periodisering_Planning_WithTrigger]
    on [dbo].[WriteTable_Fact_Projekt_Periodisering_Planning_WithTrigger]
    after insert
as
begin
    set nocount on;

    insert into [dw].[fact_Projekt_Periodisering_Planning]
    (
        [FCProjectID]
        ,[FCVersionID]
        ,[MonthID]
        ,[KontoID]
        ,[PeriodiseratBelopp]
        ,[FgPeriodiseratBelopp]
        ,[AuditUser]
        ,[AuditTime]
        ,[ExistsInWriteTable]
        ,[IncUpdate]
        ,[RowTypeID] 
    )
    select
        [FCProjectID] = w.FCProjectID_2
        ,[FCVersionID] = w.FCVersionID_3
        ,[MonthID] = w.MonthID_4
        ,[KontoID] = w.KontoID_5
        ,[PeriodiseratBelopp] = w.PeriodiseratBelopp_0
        ,[FgPeriodiseratBelopp] = w.FgPeriodiseratBelopp_1
        ,[AuditUser] = w.MS_AUDIT_USER_7
        ,[AuditTime] = w.MS_AUDIT_TIME_6
        ,[ExistsInWriteTable] = 1
        ,[IncUpdate] = 1
        ,[RowTypeID] = 2011
    from
    inserted w
    -- [dbo].[WriteTable_Fact_Projekt_Periodisering_Planning_WithTrigger] w
end

GO
ALTER TABLE [dbo].[WriteTable_Fact_Projekt_Periodisering_Planning_WithTrigger] ENABLE TRIGGER [TriggerInsert_WriteTable_fact_Periodisering_Planning_WithTrigger]
GO
