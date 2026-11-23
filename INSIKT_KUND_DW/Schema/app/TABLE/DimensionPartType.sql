SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [app].[DimensionPartType](
	[DimensionPartTypeID] [int] NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[Description] [nvarchar](512) NULL,
	[IDColumnName] [nvarchar](100) NULL,
	[AddNullMembers] [bit] NOT NULL,
	[TableName]  AS ('[dw].'+quotename('base_'+[Name])),
 CONSTRAINT [PK_app_DimensionPartType] PRIMARY KEY CLUSTERED 
(
	[DimensionPartTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING ON

GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_DimensionPartType] ON [app].[DimensionPartType]
(
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [app].[DimensionPartType] ADD  CONSTRAINT [DF_DimensionPartType_AddNullMembers]  DEFAULT ((0)) FOR [AddNullMembers]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [app].[AppDimensionPartTypeCheckTrigger] on [app].[DimensionPartType]
   after insert,update
as 
begin
	set nocount on;

	if update(IDColumnName) or update(Name)
		begin		
			if exists
			(
				select
					*
				from
					inserted i						
						inner join app.DimensionPartType t on
							isnull(parsename(t.IDColumnName, 1), t.Name + 'ID') = isnull(parsename(i.IDColumnName, 1), i.Name + 'ID')																
							and t.DimensionPartTypeID <> i.DimensionPartTypeID
			)
			begin
				raiserror('IDColumnName must be unique in table app.DimensionPartType (Default IDColumnName when NULL is <Name>ID.', 16, 10)
				rollback tran		
			end
	end
end
GO
ALTER TABLE [app].[DimensionPartType] ENABLE TRIGGER [AppDimensionPartTypeCheckTrigger]
GO
