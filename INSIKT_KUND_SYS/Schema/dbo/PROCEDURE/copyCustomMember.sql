SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Linus Nilsson
-- Create date: 2014-11-11
-- Description: Skapar en kopia av en beräkning.
-- =============================================
CREATE PROCEDURE [dbo].[copyCustomMember]
	@customMemberId int,
	@copyIsCommon bit,
	@userIdForCopy int
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO CustomMembers(
		Name,
		[Description],
		Dimension,
		Hierarchy,
		[Function],
		[Cube],
		MDXFormula,
		FormatString,
		PositionReferenceMember,
		[Database],
		DisplayFolder,
		IsCommon,
		CreatedBy,
		CreatedDate,
		IsAlwaysAvailable,
		IsDeleted)
	SELECT
		Name,
		[Description],
		Dimension,
		Hierarchy,
		[Function],
		[Cube],
		MDXFormula,
		FormatString,
		PositionReferenceMember,
		[Database],
		DisplayFolder,
		@copyIsCommon,
		@userIdForCopy,
		GETUTCDATE(), -- TODO ska vi kopiera datumet istället?
		IsAlwaysAvailable,
		0
	FROM CustomMembers
	WHERE ID = @customMemberId;

	DECLARE @newCustomMemberId int;
	SET @newCustomMemberId = @@IDENTITY;

	INSERT INTO CustomMemberMembers(Caption, UniqueName, CustomMemberID)
	SELECT Caption, UniqueName, @newCustomMemberId
	FROM CustomMemberMembers
	WHERE CustomMemberID = @customMemberId;

	SELECT @newCustomMemberId;
END
GO
