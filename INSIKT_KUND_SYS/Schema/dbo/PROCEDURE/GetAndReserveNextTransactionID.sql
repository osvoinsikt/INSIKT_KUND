SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************
 #Desc: 			Selects and reserves a unique ID for a process or fc type.
 #Used By:			-
 #InParam:			-
 #ResultSet:		-
 #
 #Returns:			-
 #Owner:			DBO
 #Creator:			Daniel Hellström
 #CreateDate:		120619
 #Modified by:		Andreas Bäärnhielm
 #ModifiedDate:		230505

 #Log:
 #
********************************************************************/
CREATE Procedure [dbo].[GetAndReserveNextTransactionID]
	@iProcessID int,
	@fcTypeID int,
	@shouldReserve bit,
	@FCLevel01 VARCHAR(20),
	@NextTransactionID int OUTPUT

AS
set nocount on

if exists (select 1 from FCTypeGroupRelation where FCTypeID = @fcTypeID) begin
	-- Byt FCTypeID till gruppens första FCType. Processer finns endast för gruppens första FCType.
	select
		@fcTypeID = grupp.FCTypeID
	from
		FCTypeGroupRelation flik
		inner join FCTypeGroupRelation grupp on grupp.GroupID = flik.GroupID
	where
		flik.FCTypeID = @fcTypeID
		and grupp.IsPrimary = 1
end

DECLARE @TransactionNrDeterminer As int
SELECT @TransactionNrDeterminer = ValueNumeric FROM FCElementProperty WHERE PropertyID = 516 AND FCTypeID = @fcTypeID
-- 1: Sekvens per process, dvs per FCVersion, FCType och FCProcess. Börjar på 1 per process.
-- 2: Sekvens per huvuddimensionsmedlem, dvs per FCLevel01 i FCProcess och per FCType men inte FCVersion. Fortsätter på motsvarande process i föregående versioner.
-- 3: Sekvens per budgettyp, dvs per FCType men inte FCVersion eller FCProcess. Börjar på 1 för varje budgettyp.

declare @FCTypeTypeID int = (select FCTypeTypeID from FCType where ID = @fcTypeID)

-- Default value
SET @NextTransactionID = 1

if @FCTypeTypeID in (1, 2)
begin
	-- Både Standard och Project använder FCProcess

	-- Sekvens per process
	IF @TransactionNrDeterminer = 1 OR @TransactionNrDeterminer IS NULL OR @TransactionNrDeterminer = 0 BEGIN

		IF (@iProcessID IS NULL)
		BEGIN
			SET @NextTransactionID = 1
		END
		ELSE
		BEGIN
			SELECT @NextTransactionID = ISNULL(LastGeneratedTransactionID, 0) + 1
			FROM FCProcess WITH(UPDLOCK)
			WHERE ID = @iProcessID
		END

		IF @shouldReserve = 1 BEGIN
			UPDATE FCProcess
			SET LastGeneratedTransactionID = @NextTransactionID
			WHERE ID = @iProcessID
		END
	END

	-- Sekvens per huvuddimensionsmedlem
	ELSE IF @TransactionNrDeterminer = 2 BEGIN

		SELECT @NextTransactionID = ISNULL(max(ISNULL(LastGeneratedTransactionID, 0) + 1), 1)
		FROM FCProcess
		WHERE FCTypeID = @fcTypeID AND FCLevel01 = @FCLevel01

		IF @shouldReserve = 1 BEGIN
			UPDATE FCProcess
			SET LastGeneratedTransactionID = @NextTransactionID
			WHERE FCTypeID = @fcTypeID AND FCLevel01 = @FCLevel01
		END
	END

	-- Sekvens per version för budgettyp
	ELSE IF @TransactionNrDeterminer = 3 BEGIN
		SELECT @NextTransactionID = ISNULL(MAX(ISNULL(LastGeneratedTransactionID, 0) + 1), 1)
		FROM FCProcess with(UPDLOCK)
		WHERE FCTypeID = @fcTypeID

		IF @shouldReserve = 1 BEGIN
			UPDATE FCProcess
			SET LastGeneratedTransactionID = @NextTransactionID
			WHERE FCTypeID = @fcTypeID
		END
	END
end
ELSE
begin
	-- ProjectCalc

	-- Sekvens per process
	IF @TransactionNrDeterminer = 1 OR @TransactionNrDeterminer IS NULL OR @TransactionNrDeterminer = 0 BEGIN

		IF (@iProcessID IS NULL)
		BEGIN
			SET @NextTransactionID = 1
		END
		ELSE
		BEGIN
			SELECT @NextTransactionID = ISNULL(LastGeneratedTransactionID, 0) + 1
			FROM FCProjectCalcProcess WITH(UPDLOCK)
			WHERE ID = @iProcessID
		END

		IF @shouldReserve = 1 BEGIN
			UPDATE FCProjectCalcProcess
			SET LastGeneratedTransactionID = @NextTransactionID
			WHERE ID = @iProcessID
		END
	END

	-- Sekvens per huvuddimensionsmedlem
	ELSE IF @TransactionNrDeterminer = 2 BEGIN

		SELECT @NextTransactionID = ISNULL(max(ISNULL(LastGeneratedTransactionID, 0) + 1), 1)
		FROM FCProjectCalcProcess
		WHERE cast(FCProjectID as varchar(20)) = @FCLevel01

		IF @shouldReserve = 1 BEGIN
			UPDATE FCProjectCalcProcess
			SET LastGeneratedTransactionID = @NextTransactionID
			WHERE cast(FCProjectID as varchar(20)) = @FCLevel01
		END
	END

	-- Sekvens per version för budgettyp
	ELSE IF @TransactionNrDeterminer = 3 BEGIN
		SELECT @NextTransactionID = ISNULL(MAX(ISNULL(LastGeneratedTransactionID, 0) + 1), 1)
		FROM FCProjectCalcProcess p with(UPDLOCK)
			join FCProject proj on proj.ID = p.FCProjectID
		WHERE proj.FCTypeID = @fcTypeID

		IF @shouldReserve = 1 BEGIN
			UPDATE p
			SET LastGeneratedTransactionID = @NextTransactionID
			from FCProjectCalcProcess p
				join FCProject proj on proj.ID = p.FCProjectID
			WHERE proj.FCTypeID = @fcTypeID
		END
	END
end
GO
