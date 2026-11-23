SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		EMAH
-- Create date: 2016-11-21
-- Description:	Procedure that selects all active FCTypes
-- Modified date: 2017-02-02
-- Log:			
--				EMAH	Modifications after the new FCType configuration.
-- =============================================
CREATE PROCEDURE [dbo].[selActiveFCTypes]
AS
BEGIN
	SELECT [ID], [Caption] FROM FCType WHERE IsActive = 1
END
GO
