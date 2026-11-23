SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*******************************************************************
 #Desc: 		Selects all writable columns
 #Used By:			-
 #Creator:			Andreas Bäärnhielm
 #CreateDate:		240109
 #Modified by
 #ModifiedDate:
 #Change history:
 #Log:

********************************************************************/
CREATE PROCEDURE [dbo].[selWritableColumnsByBudgetType]
        @nFCTypeID int,
        @nCompanyID int
AS

SET NOCOUNT ON

SELECT
	ID,
	UniqueName,
	Caption,
	[Order],
	Writable,
	Author,
	FCTypeID,
	CompanyID,
	DTDCustomQuery,
	PeriodicDistributable,
	AggregateValues,
	DisableDirectInput,
	Tooltip,
	ReplaceByYear,
	CommentsAreMandatory,
	IsUnitPrice,
	IsDynamic,
	FilterMeasure,
	IgnoreLockedPeriods,
	PeriodsOffset,
	HidePeriodicDistributionTotal,
	DefaultValueMeasure,
	CommentTemplate,
	WritabilityMeasure,
	ShowCommentsIcon
FROM FCColumns
WHERE FCTypeID = @nFCTypeID
	AND (CompanyID IS NULL OR CompanyID = @nCompanyID)
	AND (IsHidden IS NULL OR IsHidden = 0)
ORDER BY [Order]


GO
