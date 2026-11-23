SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****************************************************************
 #Desc:					Kopierar budgetkommentarer till en ny version/kalkylversion.
						
						Används antingen genom att ange @OldVersionUniqueName och 
						@NewVersionUniqueName eller genom att ange @DimensionName, 
						@OldElementKey samt @NewElementKey.

						När kommentarer kopieras mellan versioner med olika FiscalYear måste i allmänhet även
						tidsmedlemmen ersättas. Det ordas genom att peka ut den genom @OptionalDimensionName1,
						@OptionalDimensionOldUniqueName1, @OptionalDimensionNewUniqueName1,
						@OptionalDimensionOldElementKey1 och @OptionalDimensionNewElementKey1.

						Om @fcTypeID, @ReportID eller @CellCommentTypeID anges kommer endast
						kommentarer kopplade mot rätt FCType/Report/CellCommentType att kopieras.
						Om ingen av parametrarna anges kommer alla kommentarer med matchande
						dimensionskopplingar att kopieras oavsett FCType/Report/CellCommentType.

						För att kommentarer kopplade mot Report eller CellCommentType ska hanteras
						måste UniqueName-parametrarna anges. Det räcker inte med ElementKey.
						 
 #Used By:              Supportprocedur som körs vid skapande av ny version/kalkyl
 
 #InParam:              @OldVersionUniqueName - Den gamla versionens UniqueName i kuben
						@NewVersionUniqueName - Den nya versionens UniqueName i kuben
						@fcTypeID - Anges om kommentarer ska kopieras för en specifik budgettyp
						@VersionDimensionName - Namn på versionsdimensionen 
						@OldVersionElementKey - Nyckel på den gamla versionen
						@NewVersionElementKey - Nyckel på den nya versionen
						@OptionalFilterUniqueName - UnqiueName för filter (Optional)
						@OptionalFilterDimension - Dimensionnamn för filter (Optional)
						@OptionalFilterElementKey - Nyckel för filter (Optional)
						@OptionalDimensionName1 - Annan dimension som ska ersättas (Optional)
						@OptionalDimensionOldUniqueName1 - Den gamla medlemmens UniqueName (Optional)
						@OptionalDimensionNewUniqueName1 - Den nya medlemmens UniqueName (Optional)
						@OptionalDimensionOldElementKey1 - Den gamla medlemmens nyckel (Optional)
						@OptionalDimensionNewElementKey1 - Den nya medlemmens nyckel (Optional)
						@OptionalDimensionName2 - Annan dimension som ska ersättas (Optional)
						@OptionalDimensionOldUniqueName2 - Den gamla medlemmens UniqueName (Optional)
						@OptionalDimensionNewUniqueName2 - Den nya medlemmens UniqueName (Optional)
						@OptionalDimensionOldElementKey2 - Den gamla medlemmens nyckel (Optional)
						@OptionalDimensionNewElementKey2 - Den nya medlemmens nyckel (Optional)
						@CopyDetails - Om CellCommentDetails ska kopieras (Optional, default 0)
						@CopyValues - Om CellCommentValues ska kopieras (Optional, default 0)
						@ReportID - Anges om kommentarer ska kopieras för en specifik rapport
						@CellCommentTypeID - Anges om kommentarer ska kopieras för en specifik kommentartyp
						
						
 #Returns:				-
 
 
 #Examples				Kopiera alla kommentarer för budgetversion 4 till 5
							
							EXEC support_CopyCommentsToNewVersion 
											@OldVersionUniqueName = '[Budgetversion].[Lista].&[4]'
											,@NewVersionUniqueName = '[Budgetversion].[Lista].&[25]'
											,@NewVersionElementKey = '25'
											,@OptionalDimensionName1 = 'Budgetperiod'
											,@OptionalDimensionOldUniqueName1 = '[Budgetperiod].[År-månad].&[2015]'
											,@OptionalDimensionNewUniqueName1 = '[Budgetperiod].[År-månad].&[2016]'
											,@OptionalDimensionOldElementKey1 = '2015'
											,@OptionalDimensionNewElementKey1 = '2016'
						  eller
							
							EXEC support_CopyCommentsToNewVersion 
											@VersionDimensionName = 'Budgetversion'
											,@OldVersionElementKey = '4'
											,@NewVersionElementKey = '26'
											,@NewVersionUniqueName = '[Budgetversion].[Lista].&[26]'
											,@OptionalDimensionName1 = 'Budgetperiod'
											,@OptionalDimensionOldUniqueName1 = '[Budgetperiod].[År-månad].&[2015]'
											,@OptionalDimensionNewUniqueName1 = '[Budgetperiod].[År-månad].&[2016]'
											,@OptionalDimensionOldElementKey1 = '2015'
											,@OptionalDimensionNewElementKey1 = '2016'
						  
						  
						  Kopiera alla kommentarer för budgetversion 1002 till 1003 för ett visst projekt
							
							Baserat på UniqueNames	
								EXEC support_CopyCommentsToNewVersion 
											@OldVersionUniqueName = '[Kalkylversion].[Lista].&[1002]'
											,@NewVersionUniqueName = '[Kalkylversion].[Lista].&[1003]'
											,@NewVersionElementKey = '1003'
											,@OptionalFilterUniqueName = '[Projekt planering].[Lista].&[50341]'
						  
							eller baserat på nycklar:
							
								EXEC support_CopyCommentsToNewVersion 
											@VersionDimensionName = 'Budgetversion'
											,@OldVersionElementKey = '1002'
											,@NewVersionElementKey = '1003'
											,@NewVersionUniqueName = '[Kalkylversion].[Lista].&[1003]'
											,@OptionalFilterDimension = 'Projekt planering'
											,@OptionalFilterElementKey = '50341'
						  
						  
						  OBS! Det bästa är att ange både @NewVersionElementKey och @NewVersionUniqueName 
						       så hålls CellComentDimensions intakt med värden i båda kolumnerna
 
 #Log:

	
******************************************************************/
CREATE PROCEDURE [dbo].[support_CopyCommentsToNewVersion] 
	@OldVersionUniqueName varchar(500) = NULL,
	@NewVersionUniqueName varchar(500) = NULL,
	@fcTypeID int = null,
	@VersionDimensionName varchar(255) = NULL,
	@OldVersionElementKey varchar(99) = NULL,
	@NewVersionElementKey varchar(99) = NULL,
	@OptionalFilterUniqueName varchar (255) = NULL,
	@OptionalFilterDimension varchar (255) = NULL,
	@OptionalFilterElementKey varchar (99) = NULL,

	@OptionalDimensionName1 varchar(500) = NULL,
	@OptionalDimensionOldUniqueName1 varchar(500) = NULL,
	@OptionalDimensionNewUniqueName1 varchar(500) = NULL,
	@OptionalDimensionOldElementKey1 varchar(500) = NULL,
	@OptionalDimensionNewElementKey1 varchar(500) = NULL,
	
	@OptionalDimensionName2 varchar(500) = NULL,
	@OptionalDimensionOldUniqueName2 varchar(500) = NULL,
	@OptionalDimensionNewUniqueName2 varchar(500) = NULL,
	@OptionalDimensionOldElementKey2 varchar(500) = NULL,
	@OptionalDimensionNewElementKey2 varchar(500) = NULL,
	
	@CopyDetails bit = 0,
	@CopyValues bit = 0,
	@ReportID int = null,
	@CellCommentTypeID int = null

	AS BEGIN
	
	
	
	SET NOCOUNT ON;

    
    IF @OldVersionUniqueName = NULL AND @NewVersionUniqueName = NULL AND (@OldVersionElementKey = NULL OR @NewVersionElementKey = NULL OR @VersionDimensionName = NULL)
	 OR @OldVersionElementKey = NULL AND @NewVersionElementKey = NULL AND (@OldVersionUniqueName = NULL OR @NewVersionUniqueName = NULL)	 
	BEGIN
		
		RAISERROR ('Ange UniqueName eller ElementKey',
               16, -- Severity.
               1 -- State.
               );
	END
    
    BEGIN TRANSACTION
    
		BEGIN TRY

			DECLARE @CurrentCommentID integer
			DECLARE @LastInsertedCommentID integer

			SELECT CellCommentID
			INTO #NonEmptyCellComment
			FROM CellCommentEntry
			UNION
			SELECT CellCommentID
			FROM CellCommentDetail
			UNION
			SELECT CellCommentID
			FROM CellCommentValue

			-- Hämta ut kommentarer kopplade till angiven version
			DECLARE comment_cursor CURSOR FOR 
				SELECT CellComment.ID FROM dbo.CellComment 
				INNER JOIN dbo.CellCommentDimension bcd1 
					ON CellComment.ID = bcd1.CellCommentID 
					AND (bcd1.FullMemberName = @OldVersionUniqueName OR (bcd1.DimensionName = @VersionDimensionName AND bcd1.ElementKey = @OldVersionElementKey))
				LEFT JOIN dbo.CellCommentDimension bcd2 
					ON CellComment.ID = bcd2.CellCommentID 
					AND (bcd2.FullMemberName = @OptionalFilterUniqueName OR (bcd2.DimensionName = @OptionalFilterDimension AND bcd2.ElementKey = @OptionalFilterElementKey)) -- Antingen matchar FilterUniqueName eller så matchar dimension och nyckel.

				LEFT JOIN dbo.CellCommentDimension dimChange1 
					ON CellComment.ID = dimChange1.CellCommentID 
					AND (dimChange1.FullMemberName = @OptionalDimensionOldUniqueName1 OR (dimChange1.DimensionName = @OptionalDimensionName1 AND dimChange1.ElementKey = @OptionalDimensionOldElementKey1)) -- Antingen matchar FilterUniqueName eller så matchar dimension och nyckel.

				LEFT JOIN dbo.CellCommentDimension dimChange2 
					ON CellComment.ID = dimChange2.CellCommentID 
					AND (dimChange2.FullMemberName = @OptionalDimensionOldUniqueName2 OR (dimChange2.DimensionName = @OptionalDimensionName2 AND dimChange2.ElementKey = @OptionalDimensionOldElementKey2)) -- Antingen matchar FilterUniqueName eller så matchar dimension och nyckel.

				INNER JOIN #NonEmptyCellComment
					ON CellComment.ID = #NonEmptyCellComment.CellCommentID

				WHERE
					-- Alla parametrar är NULL, eller nån av de matchar aktuell rad.
					((@fcTypeID IS NULL AND @ReportID IS NULL AND @CellCommentTypeID IS NULL)
						OR FCTypeID = @fcTypeID
						OR ReportID = @ReportID
						OR CellComment.CellCommentTypeID = @CellCommentTypeID)
					AND ((@OptionalFilterUniqueName IS NULL AND @OptionalFilterElementKey IS NULL) OR bcd2.ID IS NOT NULL)  --Antingen har vi inget filter eller så ska vi ha fått träff i joinen ovan.

					AND ((@OptionalDimensionOldUniqueName1 IS NULL AND @OptionalDimensionOldElementKey1 IS NULL) OR dimChange1.ID IS NOT NULL)  --Antingen har vi inget filter eller så ska vi ha fått träff i joinen ovan.
					AND ((@OptionalDimensionOldUniqueName2 IS NULL AND @OptionalDimensionOldElementKey2 IS NULL) OR dimChange2.ID IS NOT NULL)  --Antingen har vi inget filter eller så ska vi ha fått träff i joinen ovan.
					
			OPEN comment_cursor

			FETCH NEXT FROM comment_cursor
			INTO @CurrentCommentID

			WHILE @@FETCH_STATUS = 0
			BEGIN

				INSERT INTO CellComment(CompanyID, FCTypeID, ReportID, CellCommentTypeID)
				SELECT CompanyID, FCTypeID, ReportID, CellCommentTypeID
				FROM CellComment
				WHERE [ID] = @CurrentCommentID

				SET @LastInsertedCommentID = @@identity 

				-- Lägg till alla dimensioner som inte ska ändras	
				INSERT INTO CellCommentDimension(CellCommentID, DimensionName, HierarchyName, FullMemberName, ElementKey, CellCommentTypeID)
				SELECT @LastInsertedCommentID, DimensionName, HierarchyName, FullMemberName, ElementKey, CellCommentTypeID
				FROM CellCommentDimension
				WHERE CellCommentID = @CurrentCommentID
				AND (FullMemberName <> @OldVersionUniqueName OR @OldVersionUniqueName IS NULL)
				AND (DimensionName <> @VersionDimensionName OR @VersionDimensionName IS NULL)

				AND (FullMemberName <> @OptionalDimensionOldUniqueName1 OR @OptionalDimensionOldUniqueName1 IS NULL)
				AND (DimensionName <> @OptionalDimensionName1 OR @OptionalDimensionName1 IS NULL)

				AND (FullMemberName <> @OptionalDimensionOldUniqueName2 OR @OptionalDimensionOldUniqueName2 IS NULL)
				AND (DimensionName <> @OptionalDimensionName2 OR @OptionalDimensionName2 IS NULL)


				--AND ((ElementKey <> @OldVersionElementKey AND DimensionName = @VersionDimensionName) OR @OldVersionElementKey = NULL OR DimensionName <> @VersionDimensionName)

				-- Lägg till prognosversionen som måste ändras om
				INSERT INTO CellCommentDimension(CellCommentID, DimensionName,HierarchyName, FullMemberName, ElementKey, CellCommentTypeID)
				SELECT @LastInsertedCommentID, DimensionName, HierarchyName, @NewVersionUniqueName, @NewVersionElementKey, CellCommentTypeID
				FROM CellCommentDimension
				WHERE CellCommentID = @CurrentCommentID
				AND (
					FullMemberName = @OldVersionUniqueName
					OR
					(ElementKey = @OldVersionElementKey AND DimensionName = @VersionDimensionName)
					)

				--
				-- Optinal change dim 1
				--
				INSERT INTO CellCommentDimension(CellCommentID, DimensionName, HierarchyName, FullMemberName, ElementKey, CellCommentTypeID)
				SELECT @LastInsertedCommentID, DimensionName, HierarchyName, @OptionalDimensionNewUniqueName1, @OptionalDimensionNewElementKey1, CellCommentTypeID
				FROM CellCommentDimension
				WHERE CellCommentID = @CurrentCommentID
				AND (
					FullMemberName = @OptionalDimensionOldUniqueName1
					OR
					(ElementKey = @OptionalDimensionOldElementKey1 AND DimensionName = @OptionalDimensionName1)
					)

				--
				-- Optinal change dim 2
				--
				INSERT INTO CellCommentDimension(CellCommentID, DimensionName, HierarchyName, FullMemberName, ElementKey, CellCommentTypeID)
				SELECT @LastInsertedCommentID, DimensionName, HierarchyName, @OptionalDimensionNewUniqueName2, @OptionalDimensionNewElementKey2, CellCommentTypeID
				FROM CellCommentDimension
				WHERE CellCommentID = @CurrentCommentID
				AND (
					FullMemberName = @OptionalDimensionOldUniqueName2
					OR
					(ElementKey = @OptionalDimensionOldElementKey2 AND DimensionName = @OptionalDimensionName2)
					)




				-- Lägg till inläggen, ett åt gången, genom iteration.
				DECLARE entry_cursor CURSOR FOR
				  SELECT ID
				  FROM CellCommentEntry
				  WHERE CellCommentID = @CurrentCommentID;

				DECLARE @currentEntryID int;

				OPEN entry_cursor;
				FETCH NEXT FROM entry_cursor INTO @currentEntryID;
				WHILE @@FETCH_STATUS = 0
				BEGIN
					-- Kopiera inlägget.
					INSERT INTO CellCommentEntry(CellCommentID, Comment, CreatedBy, CreatedDate, ModifiedDate, IsDeleted)
					SELECT @LastInsertedCommentID, Comment, CreatedBy, CreatedDate, ModifiedDate, IsDeleted
					FROM CellCommentEntry
					WHERE ID = @currentEntryID

					-- Hämta nya inläggets ID.
					DECLARE @lastInsertedEntryID int;
					set @lastInsertedEntryID = @@IDENTITY;

					-- Kopiera dokumenten till nya inlägget.
					DECLARE @currentDocumentID int;
					DECLARE document_cursor CURSOR FOR
						SELECT DocumentID
						FROM dbo.CellCommentDocument
						WHERE CellCommentEntryID = @currentEntryID;
					
					OPEN document_cursor;
					FETCH NEXT FROM document_cursor INTO @currentDocumentID;
					WHILE @@FETCH_STATUS = 0
					BEGIN
					
						DECLARE @newDocumentID int
						EXEC @newDocumentID = dbo.copyDocument @currentDocumentID

						INSERT INTO CellCommentDocument(CellCommentEntryID, DocumentID)
						VALUES(@lastInsertedEntryID, @newDocumentID)

						FETCH NEXT FROM document_cursor INTO @currentDocumentID
					END
					CLOSE document_cursor;
					DEALLOCATE document_cursor;

					FETCH NEXT FROM entry_cursor INTO @currentEntryID
				END
				CLOSE entry_cursor;
				DEALLOCATE entry_cursor;

				if ISNULL(@CopyDetails, 0) = 1
					insert into CellCommentDetail
					(
						CellCommentID
						,Code
						,Name
						,Description
						,UnitTypeID
						,Value
						,Quantity
						,UnitTypeReadOnly
						,NameReadOnly
						,DescriptionReadOnly
						,ValueReadOnly
						,QuantityReadOnly
					)
					select
						@LastInsertedCommentID
						,Code
						,Name
						,Description
						,UnitTypeID
						,Value
						,Quantity
						,UnitTypeReadOnly
						,NameReadOnly
						,DescriptionReadOnly
						,ValueReadOnly
						,QuantityReadOnly
					from
						CellCommentDetail
					where
						CellCommentID = @CurrentCommentID

			 	 if ISNULL(@CopyValues, 0) = 1
					insert into CellCommentValue
					(
						CellCommentID
						,MultipleChoiceID
						,CreatedBy
						,CreatedDate
						,BitValue
						,DateValue
						,TextValue
					)
					select
						@LastInsertedCommentID
						,MultipleChoiceID
						,CreatedBy
						,CreatedDate
						,BitValue
						,DateValue
						,TextValue
					from
						CellCommentValue
					where
						CellCommentID = @CurrentCommentID

				FETCH NEXT FROM comment_cursor
				INTO @CurrentCommentID
			END
			CLOSE comment_cursor
			DEALLOCATE comment_cursor

			DROP TABLE #NonEmptyCellComment

		END TRY
		BEGIN CATCH
		
			--------------------- RAISE ERROR ----------------------
			DECLARE @ErrorMessage NVARCHAR(4000);
			DECLARE @ErrorSeverity INT;
			DECLARE @ErrorState INT;

			SELECT 
				@ErrorMessage = ERROR_MESSAGE(),
				@ErrorSeverity = ERROR_SEVERITY(),
				@ErrorState = ERROR_STATE();
			
			RAISERROR (@ErrorMessage,@ErrorSeverity, @ErrorState);
			--------------------------------------------------------
		
			IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION;
		
		
		END CATCH;
			
		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION;
    
END
GO
