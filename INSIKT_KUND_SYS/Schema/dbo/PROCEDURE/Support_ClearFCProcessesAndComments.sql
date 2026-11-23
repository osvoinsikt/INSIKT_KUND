SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Support_ClearFCProcessesAndComments] 
AS
BEGIN
	
	-- Bara för att kunna spara proceduren med allt annat bortkommenterat av säkerhetsskäl
	select * from FCProcess
	
	-- Ta bort övergripande budgetkommentarer i alla budgettyper
	--delete from FCProcessCommentDocument
	--delete from FCProcessComment

	-- Ta bort kommentarer
	--delete from CellCommentDimension
	--delete from CellCommentDocument	
	--delete from CellCommentDetail
	--delete from CellComment

	-- Ta bort periodiseringar
	--delete from FCElementPeriodicDistributionDimension
	--delete from FCElementPeriodicDistribution

	-- Ta bort budgetmeddelanden
	--delete from UserReadMessageRelation
	--delete from FCMessage

	-- Ta bort processer
	--delete from FCProcess
    
END
GO
