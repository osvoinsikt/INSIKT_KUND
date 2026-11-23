SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Description: Säger om strängen är ett vanligt flyttal. Strängar i formen '1e2' accepteras inte.
--              Den inbyggda IsNumeric() accepterar många typer av strängen, exempelvis strängar
--              som kan konverteras till MONEY, vilket inte betyder att strängen är ett giltigt
--              flyttal eller kan konverteras till DECIMAL eller FLOAT.
-- =============================================
CREATE function [dbo].[fn_IsNumber]
(
	@arg varchar(max)
)
returns bit
as 
begin

-- Att lägga på 'e0' gör att strängen bara accepteras om grundsträngen är ett giltigt flyttal.
-- http://stackoverflow.com/a/2368954
return IsNumeric(@arg + 'e0');

end
GO
