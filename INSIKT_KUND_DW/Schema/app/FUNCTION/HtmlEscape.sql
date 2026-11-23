SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [app].[HtmlEscape]
(
	-- Add the parameters for the function here
	@Value nvarchar(max)
)
RETURNS nvarchar(max)
AS
BEGIN
	declare @Result nvarchar(max)
	select @Result = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@Value,'&', '&amp;'),'<', '&lt;'),'>', '&gt;'),'"', '&quot;'),'''', '&#39;')
	return  @Result
END
GO
