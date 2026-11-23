SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************
 #Desc: 		Deletes a subscription
 #Used By:		
 #InParam:		-
 #ResultSet:		-
 #
 #Returns:		-
 #Owner:		DBO
 #Creator:		Daniel Hellström
 #CreateDate:		060419
 #Modified by:	Johan Kultti
 #ModifiedDate:		100301
 
 #Log:			070326 - ANHO - Changed order of DELETEs to fix FK-relations
				100201	JOKU	schedule wasn't deleting. Fixed FK temp table for intermediary storage during deletion

********************************************************************/
CREATE               Procedure [dbo].[delSubscription]
	@iID int
AS



set nocount on

declare @errmsg varchar(100)

begin transaction
	
	-- Delete subscription to user relation
	DELETE	
	FROM 	SubscriptionUserRelation	
	WHERE	SubscriptionID = @iID

	if @@error <> 0 goto err
	
	-- Store Schedule IDs to delete before deleting the relationship table entries	
	Select ScheduleID as ID
	into #tmp
	from SubscriptionScheduleRelation ssr
	WHERE ssr.SubscriptionID =  @iID
	
	if @@error <> 0 goto err
	
	-- Delete subscription to schedule relation	
	DELETE	
	FROM	SubscriptionScheduleRelation	
	WHERE	SubscriptionID = @iID
	
	if @@error <> 0 goto err

	DELETE	s
	FROM 	[Schedule] s
	INNER JOIN #tmp t ON t.ID = s.ID
	
	if @@error <> 0 goto err
	
	-- Delete attached document

	-- Iterate over all documents attached to the subscription
	DECLARE @SubscriptionDocumentID AS INT = 0

	WHILE (1 = 1) 
	BEGIN  
		-- Get next document id
		SELECT TOP 1 @SubscriptionDocumentID = DocumentID
		FROM SubscriptionDocumentRelation
		WHERE SubscriptionID = @iID AND DocumentID > @SubscriptionDocumentID
		ORDER BY DocumentID

		-- Exit loop if no more documents
		IF @@ROWCOUNT = 0 BREAK;
	
		-- Delete doc from subscription
		DELETE
		FROM SubscriptionDocumentRelation
		WHERE DocumentID = @SubscriptionDocumentID AND SubscriptionID = @iID
		
		IF @@error <> 0 GOTO err

		-- document delete
		EXEC delDocument @SubscriptionDocumentID

		IF @@error <> 0 GOTO err
	END

	-- Delete subscription to report relation	
	DELETE	
	FROM 	SubscriptionReportRelation	
	WHERE	SubscriptionID = @iID
	
	if @@error <> 0 goto err

	-- Delete subscription
	DELETE
	FROM 	Subscription
	WHERE 	[ID] = @iID
	
	if @@error <> 0 goto err

commit transaction

return

err:
	rollback transaction
	set @errmsg = @errmsg + '¤dbError_ErrorDeletingSubscription'
	raiserror (@errmsg,16,1)
	return (-100)






GO
