SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*******************************************************************
 #Desc:                 Selects all writable columns for a specific budget type,
                                a specific version type and a specific member in the FCProcess dimension
 #Used By:              -
 #InParam:              -
 #ResultSet:            -
 #
 #Returns:              -
 #Owner:                DBO
 #Creator:              Daniel Hellström
 #CreateDate:           070608
 #Modified by:          EMAH
 #ModifiedDate:         151214

 #Log:
        070608  DH      Created
        090914  DH      Added DTDCustomQuery
        111118  DH      Added Tooltip column
        151214  EA      Added HidePeriodicDistributionTotal column
        161124  TR      Added FCColumns.DefaultValueMeasure to return data
        180502  JM      Added FCColumns.CommentTemplate to return data
********************************************************************/
CREATE PROCEDURE [dbo].[selWritableColumnsByBudgetTypeVersionTypeAndFCProcessdim]
        @nFCTypeID int,
        @nCompanyID int,
        @nVersionTypeID int,
        @vsFCProcessDimUniqueName varchar(255)
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
FROM FCColumns AS c
	LEFT JOIN FCColumnFCVersionTypeRelation AS cvr ON cvr.FCColumnID = c.ID
WHERE FCTypeID = @nFCTypeID
	AND (CompanyID IS NULL OR CompanyID = @nCompanyID)
	AND (cvr.FCVersionTypeID IS NULL OR cvr.FCVersionTypeID = @nVersionTypeID)
	AND (FCProcessDimUniqueName IS NULL OR FCProcessDimUniqueName = @vsFCProcessDimUniqueName)
	AND (IsHidden IS NULL OR IsHidden = 0)

ORDER BY [Order]

GO
