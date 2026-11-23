SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[selFCTypesWithHiddenInputTab]
/**
	Author:			joma
	Description:	Selects the IDs of FCTypes that have the FCProperty "PrognosisHideFCTypeInputsTab" enabled.
**/
AS
	
	SELECT ep.FCTypeID
	FROM [dbo].[FCElementProperty] ep
	JOIN [dbo].[FCProperty] p			ON (ep.PropertyID = p.ID)
	WHERE p.Name = 'PrognosisHideFCTypeInputsTab' AND ep.ValueNumeric = 1
GO
