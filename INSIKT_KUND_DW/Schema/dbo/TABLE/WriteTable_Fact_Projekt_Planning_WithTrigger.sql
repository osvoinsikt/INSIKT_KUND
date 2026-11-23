SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WriteTable_Fact_Projekt_Planning_WithTrigger](
	[Kalkyl_0] [float] NULL,
	[FgKalkyl_1] [float] NULL,
	[FCVersionID_2] [int] NULL,
	[FCProjectID_3] [int] NULL,
	[KontoID_4] [int] NULL,
	[MS_AUDIT_TIME_5] [datetime] NULL,
	[MS_AUDIT_USER_6] [nvarchar](255) NULL
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create trigger [dbo].[TriggerInsert_WriteTable_fact_Projekt_Planning_WithTrigger]
    on [dbo].[WriteTable_Fact_Projekt_Planning_WithTrigger]
    after insert
as
begin
    set nocount on;
    insert into [dw].[fact_Projekt_Planning] 
        (
            [FCProjectID]
            ,[FCVersionID]
            ,[KontoID]
            ,[Kalkyl]
            ,[FgKalkyl]
            ,[AuditUser]
            ,[AuditTime]
            ,[ExistsInWriteTable]
            ,[IncUpdate]
            ,[RowTypeID]
        )
    select
        [FCProjectID] = w.FCProjectID_3
        ,[FCVersionID] = w.FCVersionID_2
        ,[KontoID] = w.KontoID_4
        ,[Kalkyl] = w.Kalkyl_0
        ,[FgKalkyl] = w.FgKalkyl_1
        ,[AuditUser] = w.MS_AUDIT_USER_6
        ,[AuditTime] = w.MS_AUDIT_TIME_5
        ,[ExistsInWriteTable] = 1
        ,[IncUpdate] = 1
        ,[RowTypeID] = 2001
    from 
        inserted w
        -- [dbo].[WriteTable_fact_Projekt_Planning_WithTrigger] w

    
end

GO
ALTER TABLE [dbo].[WriteTable_Fact_Projekt_Planning_WithTrigger] ENABLE TRIGGER [TriggerInsert_WriteTable_fact_Projekt_Planning_WithTrigger]
GO
