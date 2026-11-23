SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Description:	Hämtar ID på de analysrapporter som använder sig av en viss beräknad medlem.
-- =============================================
CREATE PROCEDURE [dbo].[selReportsUsingSpecificCustomMember]
	@customMemberID INT
AS
BEGIN
	SET NOCOUNT ON;
	SET ARITHABORT ON;

	SELECT r.ID
	FROM (SELECT ID,
	             Version,
	             Data AS XmlData
	      FROM Report
		  WHERE ReportTypeID = 1
		    AND (Inactive = 0)) AS r
    WHERE (r.Version = 1 AND r.XmlData.exist('//selectedCustomMembers/*[. = sql:variable("@customMemberID")]') = 1)
	  OR  (r.Version IN (2, 3) AND r.XmlData.exist('//DimensionSelectionMember/CustomCalculationId[. = sql:variable("@customMemberID")]') = 1)
END
GO
