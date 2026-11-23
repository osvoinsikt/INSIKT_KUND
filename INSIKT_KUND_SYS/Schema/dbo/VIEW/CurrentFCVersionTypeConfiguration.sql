SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[CurrentFCVersionTypeConfiguration] as
		select c.id, t.Name as TypeName, f.Name as FieldName, IsVisible, ReadOnly
		from FCVersionTypeConfiguration as c
		INNER JOIN FCVersionField as f ON c.FCVersionFieldID=f.ID
		INNER JOIN FCVersionType as t ON c.FCVersionTypeID=t.ID;
GO
