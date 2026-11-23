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
