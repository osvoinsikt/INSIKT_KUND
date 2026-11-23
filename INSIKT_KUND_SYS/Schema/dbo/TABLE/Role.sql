SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Role](
	[ID] [int] NOT NULL,
	[Caption] [nvarchar](255) NOT NULL,
	[Name] [nvarchar](255) NULL,
	[SystemModuleID] [int] NULL,
	[IsModulePrimary] [bit] NOT NULL,
	[IsSystemRole] [bit] NOT NULL,
	[Description] [varchar](3000) NULL,
	[SortOrder] [int] NOT NULL,
 CONSTRAINT [PK_Role] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[Role] ADD  CONSTRAINT [DF_Role_IsModulePrimary]  DEFAULT ((0)) FOR [IsModulePrimary]
GO
ALTER TABLE [dbo].[Role] ADD  CONSTRAINT [DF__Role__IsSystemRo__3A4D7454]  DEFAULT ((0)) FOR [IsSystemRole]
GO
ALTER TABLE [dbo].[Role]  WITH CHECK ADD  CONSTRAINT [FK_Role_SystemModules] FOREIGN KEY([SystemModuleID])
REFERENCES [dbo].[SystemModules] ([ID])
GO
ALTER TABLE [dbo].[Role] CHECK CONSTRAINT [FK_Role_SystemModules]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TriggerInsertUpdate_CustomRoleRestrictions]
    ON [dbo].[Role]
	FOR INSERT, UPDATE
    AS
    BEGIN
    SET NOCOUNT ON
		DECLARE @id int;
		DECLARE @isSystemRole int;
		SELECT @id = ID, @isSystemRole = IsSystemRole From inserted
		IF @id < 1001
		BEGIN
			raiserror ('If you want to insert or update a Role the ID must be over 1000. This is a safety measure to avoid collisions with future System Roles that might be added when upgrading INSIKT. You can however disable the trigger [TriggerInsertUpdate_CustomRoleRestrictions] temporarily if you are sure of what you are doing.',16,1)
			Rollback TRAN
		END
		ELSE IF @isSystemRole <> 0
		BEGIN
			raiserror ('A System Role can not be updated or inserted, you must define it as a Custom Role (ie., [isSystemRole]=0). You can however disable the trigger [TriggerInsertUpdate_CustomRoleRestrictions] temporarily if you are sure of what you are doing.',16,1)
			Rollback TRAN
		END
    END
GO
ALTER TABLE [dbo].[Role] ENABLE TRIGGER [TriggerInsertUpdate_CustomRoleRestrictions]
GO
