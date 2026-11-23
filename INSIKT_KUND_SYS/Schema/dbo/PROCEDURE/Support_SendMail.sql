SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*******************************************************************
 #Desc: 		Sends a mail with INSIKT Service.
				This procedure will add rows in the ServiceJob and MailLog tables.
				Insikt Service will then handle sending the mail.
				The mail status can be found in the MailLog table in the database,
				or in the 'Admin -> System overview -> Mail' page in INSIKT.
 #Used By:		-
 #InParam:		-
 #ResultSet:	-
 #
 #Returns:		-
 #Owner:		DBO
 #Creator:		Anton Vermcrantz
 #CreateDate:	02/07/2019
 #Modified by:	Mathias Hedqvist	
 #ModifiedDate:	23/01/2023
 
 #Log:

********************************************************************/
CREATE      PROCEDURE [dbo].[Support_SendMail]
	@recipient VARCHAR(max)
	,@subject VARCHAR(max)
	,@body VARCHAR(max)
	,@sendAsPlainText bit = 0
	
AS
BEGIN
	DECLARE
		@MailLogID INT,
		@ServiceJobTypeBody NVARCHAR(max),
		@SenderAdress VARCHAR(max)
	
	-- Use generic MailFrom for module = Framework/null.
	SET @SenderAdress = IsNull(
		(SELECT top 1 ValueString FROM SystemSetting WHERE SystemPropertyID = 1067),
		'Insikt@insikt.se')

	INSERT INTO MailLog(
		Sender, Recipient, ReplyTo, Subject, Body, DateCreated,
		DateSent, StatusID, TypeID, StatusMessage, SendAsPlainText)
	VALUES(
		@SenderAdress, @recipient, NULL, @subject, @body, GETUTCDATE(),
		NULL, 1, 1, NULL, @sendAsPlainText)
	
	SET @MailLogID = SCOPE_IDENTITY()
	SET @ServiceJobTypeBody = '{"MailLogId":' + CONVERT(VARCHAR, @MailLogID) + '}'

	INSERT INTO ServiceJob(
		ServiceJobTypeID, Body, CreatedBy, CreatedDate, StartedDate, FinishedDate,
		Success, ResultBody, NotifyUserTypeID)
	VALUES(
		2, @ServiceJobTypeBody, -1, GETUTCDATE(), NULL, NULL,
		0, NULL, 1)
END

GO
