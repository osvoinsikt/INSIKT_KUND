SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[selSubscriptionDocuments]
	@SubscriptionID int
AS
BEGIN
	SET NOCOUNT ON;

SELECT * FROM Document d
	INNER JOIN [dbo].SubscriptionDocumentRelation SDR on SDR.DocumentID = d.ID
	WHERE SDR.SubscriptionID = @SubscriptionID
END
GO
