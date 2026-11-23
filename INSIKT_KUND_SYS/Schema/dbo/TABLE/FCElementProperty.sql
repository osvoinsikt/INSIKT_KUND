SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FCElementProperty](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FCElementID] [int] NOT NULL,
	[PropertyID] [int] NOT NULL,
	[ElementKey] [nvarchar](50) NOT NULL,
	[ValueNumeric] [float] NULL,
	[ValueString] [nvarchar](1000) NULL,
	[FCTypeID] [int] NULL,
	[CompanyID] [int] NULL,
	[OptionalCode] [varchar](50) NULL,
	[UserID] [int] NULL,
	[AdditionalFilter] [nvarchar](1000) NULL,
 CONSTRAINT [PK_FCElementProperty] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
CREATE NONCLUSTERED INDEX [IX_FCElementProperty_PropertyID] ON [dbo].[FCElementProperty]
(
	[PropertyID] ASC
)
INCLUDE([ValueNumeric],[ValueString]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FCElementProperty_PropertyIDAndElement] ON [dbo].[FCElementProperty]
(
	[PropertyID] ASC,
	[FCElementID] ASC,
	[FCTypeID] ASC,
	[CompanyID] ASC
)
INCLUDE([ElementKey],[ValueNumeric],[ValueString]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FCElementProperty]  WITH CHECK ADD  CONSTRAINT [FK_FCElementProperty_Company] FOREIGN KEY([CompanyID])
REFERENCES [dbo].[Company] ([ID])
GO
ALTER TABLE [dbo].[FCElementProperty] CHECK CONSTRAINT [FK_FCElementProperty_Company]
GO
ALTER TABLE [dbo].[FCElementProperty]  WITH CHECK ADD  CONSTRAINT [FK_FCElementProperty_FCElement] FOREIGN KEY([FCElementID])
REFERENCES [dbo].[FCElement] ([ID])
GO
ALTER TABLE [dbo].[FCElementProperty] CHECK CONSTRAINT [FK_FCElementProperty_FCElement]
GO
ALTER TABLE [dbo].[FCElementProperty]  WITH CHECK ADD  CONSTRAINT [FK_FCElementProperty_FCProperty] FOREIGN KEY([PropertyID])
REFERENCES [dbo].[FCProperty] ([ID])
GO
ALTER TABLE [dbo].[FCElementProperty] CHECK CONSTRAINT [FK_FCElementProperty_FCProperty]
GO
ALTER TABLE [dbo].[FCElementProperty]  WITH CHECK ADD  CONSTRAINT [FK_FCElementProperty_FCType] FOREIGN KEY([FCTypeID])
REFERENCES [dbo].[FCType] ([ID])
GO
ALTER TABLE [dbo].[FCElementProperty] CHECK CONSTRAINT [FK_FCElementProperty_FCType]
GO
ALTER TABLE [dbo].[FCElementProperty]  WITH CHECK ADD  CONSTRAINT [FK_FCElementProperty_UserSecurityGroup] FOREIGN KEY([UserID])
REFERENCES [dbo].[UserSecurityGroup] ([UserID])
GO
ALTER TABLE [dbo].[FCElementProperty] CHECK CONSTRAINT [FK_FCElementProperty_UserSecurityGroup]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The ID of the element' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FCElementProperty', @level2type=N'COLUMN',@level2name=N'FCElementID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The ID of the property' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FCElementProperty', @level2type=N'COLUMN',@level2name=N'PropertyID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'If this row corresponds to a specific member in a dimension its key is specified here. Otherwise ''Inställningar'' should be entered here.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FCElementProperty', @level2type=N'COLUMN',@level2name=N'ElementKey'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'If the property is numeric or boolean the value should be entered here.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FCElementProperty', @level2type=N'COLUMN',@level2name=N'ValueNumeric'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'If the property is of type string its value should be entered here.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FCElementProperty', @level2type=N'COLUMN',@level2name=N'ValueString'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Holds the ID of the type of budget this instance should be used. <NULL> value makes this a global setting.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FCElementProperty', @level2type=N'COLUMN',@level2name=N'FCTypeID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The ID fo the company this instance applies to.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FCElementProperty', @level2type=N'COLUMN',@level2name=N'CompanyID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Free text field to make this table more readable. Most commonly used to store the real key number of the dimension member when the dimension is built with keys without meaning.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FCElementProperty', @level2type=N'COLUMN',@level2name=N'OptionalCode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ID of User if this property is per user.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FCElementProperty', @level2type=N'COLUMN',@level2name=N'UserID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Används för att lagra ytterligare villkor. Innehållet varierar beroende på property.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FCElementProperty', @level2type=N'COLUMN',@level2name=N'AdditionalFilter'
GO
