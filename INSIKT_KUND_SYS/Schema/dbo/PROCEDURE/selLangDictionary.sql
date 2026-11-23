SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[selLangDictionary]
	@LangID AS int
AS
BEGIN
	SET NOCOUNT ON

	-- Get translations for the specific language, but use a fallback for missing translations.

	declare @fallbackLangID int = 1 -- English

	;with SpecificLanguage as (
		-- These columns together are the key for a translation. ControlName cannot be null.
		select distinct ControlName, FCTypeID, FCObjectTypeID
		from dbo.LangDictionary
		where LangID = @LangID
	)
	select d.ControlName, VisibleName, CustomName, d.FCTypeID, d.FCObjectTypeID
	from LangDictionary d
		join SpecificLanguage c on
			c.ControlName = d.ControlName and
			((c.FCTypeID is null and d.FCTypeID is null) or c.FCTypeID = d.FCTypeID) and
			((c.FCObjectTypeID is null and d.FCObjectTypeID is null) or c.FCObjectTypeID = d.FCObjectTypeID)
	where d.LangID = @LangID

	union all

	select d.ControlName, VisibleName, CustomName, d.FCTypeID, d.FCObjectTypeID
	from LangDictionary d
		left join SpecificLanguage c on
			c.ControlName = d.ControlName and
			((c.FCTypeID is null and d.FCTypeID is null) or c.FCTypeID = d.FCTypeID) and
			((c.FCObjectTypeID is null and d.FCObjectTypeID is null) or c.FCObjectTypeID = d.FCObjectTypeID)
	where d.LangID = @fallbackLangID
		and c.ControlName is null
END
GO
