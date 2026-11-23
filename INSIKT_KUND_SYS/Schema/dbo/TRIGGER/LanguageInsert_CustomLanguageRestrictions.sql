SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create trigger [dbo].[LanguageInsert_CustomLanguageRestrictions]
on [dbo].[Language]
for insert
as
begin
	set nocount on

	declare @id int
	select @id = ID from inserted

	if @id < 1001
	begin
		raiserror ('If you want to insert a Language, the ID must be over 1000. This is a safety measure to avoid collisions with future builtin Languages that might be added when upgrading INSIKT. You can however disable the trigger [LanguageInsert_CustomLanguageRestrictions] temporarily if you are sure of what you are doing.', 16, 1)
		rollback tran
	end
end
GO
ALTER TABLE [dbo].[Language] ENABLE TRIGGER [LanguageInsert_CustomLanguageRestrictions]
GO
