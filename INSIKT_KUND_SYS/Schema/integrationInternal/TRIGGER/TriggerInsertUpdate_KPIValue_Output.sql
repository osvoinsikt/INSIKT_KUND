SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create trigger [integrationInternal].[TriggerInsertUpdate_KPIValue_Output]
on [integrationInternal].[KPIValue_Output]
for insert, update, delete
as
begin
	set nocount on;

	raiserror ('This table does not allow inserts, updates or deletes. To write KPI values to the integration area, use the designated table with suffix "_Input".',16,1)
end
GO
ALTER TABLE [integrationInternal].[KPIValue_Output] ENABLE TRIGGER [TriggerInsertUpdate_KPIValue_Output]
GO
