SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Insert access tokens and roles into table [app].TokenRole
CREATE PROCEDURE [insikt].[WriteTokenRole]
(
    @Token UNIQUEIDENTIFIER,
    @RoleId INT,
    @Expires DATETIME,
	@UserName varchar(255)
)
AS

INSERT INTO [app].[TokenRole]
(
 [ID], [RoleId], [Expires], [UserName]
)
VALUES
(
 @Token, @RoleId, @Expires, @UserName
)

-- Remove any expired tokens
DELETE FROM [app].[TokenRole]
WHERE Expires < GETUTCDATE()
GO
