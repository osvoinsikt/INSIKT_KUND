SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Adam Holmström
-- Create date: 2011-09-13
-- Description:	Inserts a new FCCubeUpdate entry.
-- =============================================
CREATE PROCEDURE [dbo].[insFCCubeUpdate] 
	@server varchar(50), 
	@database varchar(50),
	@mdxQuery nvarchar(max),
	@userId int,
	@date datetime
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO FCCubeUpdate
           ([ASServer]
           ,[ASDatabase]
           ,[MDXQuery]
           ,[UserID]
           ,[Date]
           ,[isCommited]
           ,[UpdateFailed]
           ,[CommitFailed])
    VALUES
           (@server
           ,@database
           ,@mdxQuery
           ,@userId
           ,@date
           ,0
           ,0
           ,0)
END
GO
