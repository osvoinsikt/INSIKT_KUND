SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [integrationInternal].[KPIValue_Output](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[KPIKey] [nvarchar](15) NOT NULL,
	[ScorecardPeriodID] [int] NOT NULL,
	[Frequency] [int] NOT NULL,
	[OrganisationMemberElementKey] [nvarchar](255) NULL,
	[OrganisationMemberUniqueName] [nvarchar](255) NULL,
	[Value] [decimal](28, 8) NULL,
	[ValueStatus] [int] NULL,
	[ChangedDate] [datetime] NOT NULL,
	[VersionStamp] [timestamp] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
 CONSTRAINT [PK_IntegrationInternal_KPIValue_Output] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE NONCLUSTERED INDEX [IX_IntegrationInternal_KPIValue_Output_VersionStamp] ON [integrationInternal].[KPIValue_Output]
(
	[VersionStamp] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
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
