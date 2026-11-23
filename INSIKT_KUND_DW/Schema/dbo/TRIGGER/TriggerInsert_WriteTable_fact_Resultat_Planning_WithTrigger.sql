SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[TriggerInsert_WriteTable_fact_Resultat_Planning_WithTrigger]
	ON [dbo].[WriteTable_fact_Resultat_Planning_WithTrigger]
	AFTER INSERT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	INSERT INTO [dw].[fact_Resultat_Planning]
	(
		[PlanningVersionID]
		,[PostingDateID]
		,[KontoID]
		,[Organisation_LeafID]

		,[AvdelningID]
		,[KampanjID]
		,[ProjektID]
		,[VarugruppID]
		,[PlanningAmount]
		,[PlanningQuantity]
		
		,[AuditUser]
		,[AuditTime]
		
		,[ExistsInWriteTable]
		,[IncUpdate]
		,[RowTypeID]
	)
	SELECT 
		[PlanningVersionID] = w.[PlanningVersionID_3]
		,[PostingDateID] = w.[DateID_7]
		,[KontoID] = w.[KontoID_2]
		,[Organisation_LeafID] = w.[Organisation_LeafID_8]

		,[AvdelningID] = isnull([dimOrganisation].[ToAvdelningID], -1)
		,[KampanjID] = w.[KampanjID_4]
		,[ProjektID] = w.[ProjektID_5]
		,[VarugruppID] = w.[VarugruppID_6]
		,[PlanningAmount] = w.[PlanningAmount_0]
		,[PlanningQuantity] = w.[PlanningQuantity_1]
		
		,[AuditUser] = w.[MS_AUDIT_USER_10]
		,[AuditTime] = w.[MS_AUDIT_TIME_9]

		,[ExistsInWriteTable] = 1
		,[IncUpdate] = 1
		,[RowTypeID] = 101
	FROM
		INSERTED w
		-- [dbo].[WriteTable_fact_Resultat_Planning_WithTrigger] w
			left join [dw].[dim_Organisation_PlanningMap] [dimOrganisation] on
				[dimOrganisation].[Organisation_LeafID] =  w.[Organisation_LeafID_8]
END

GO
ALTER TABLE [dbo].[WriteTable_fact_Resultat_Planning_WithTrigger] ENABLE TRIGGER [TriggerInsert_WriteTable_fact_Resultat_Planning_WithTrigger]
GO
