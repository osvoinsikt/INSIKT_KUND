SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[selFCDimension]
(
	@fcTypeID int,
	@companyID int,
	@locale varchar(20) = 'sv-SE'
)
as

-- selFCDimension 1, 1, 'sv-SE'

select 
	ElementKey,
	UniqueName,
	Caption = isnull(t.Caption, d.Caption),
	ParentKey,
	Level,
	LevelUniqueName
from FCDimension d
	left join FCDimensionMemberTranslation t on t.FCDimensionID = d.ID and t.Locale = @locale
where
	d.FCTypeID = @fcTypeID and
	d.CompanyID = @companyID
order by d.ID


GO
