SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		TR
-- Create date: 2016-05-17
-- Description:	Updates an existing SystemSetting corresponding to the SystemProperty with name @SystemPropertyName
--				if no such system setting exits the it is created
-- =============================================
CREATE PROCEDURE [dbo].[setSystemSetting]
	@SystemPropertyName varchar(256),
	@ValueNumeric float,
	@ValueString varchar(max)
AS
BEGIN
	SET NOCOUNT ON;
	if exists (select 1 from SystemSetting ss 
				join SystemProperty as sp on sp.Name = @SystemPropertyName 
				where ss.SystemPropertyID = sp.ID)
		Begin
			update SystemSetting
			set
				ValueString = @ValueString,
				ValueNumeric = @ValueNumeric
			from SystemSetting as ss
				join SystemProperty as sp on sp.Name = @SystemPropertyName
			where ss.SystemPropertyID = sp.ID
		end
	else
		begin
			INSERT INTO SystemSetting (SystemPropertyID, ValueNumeric, ValueString)
			select sp.ID as SystemPropertyID, @ValueNumeric, @ValueString
				from SystemProperty as sp
					where sp.Name = @SystemPropertyName
		end
END

GO
