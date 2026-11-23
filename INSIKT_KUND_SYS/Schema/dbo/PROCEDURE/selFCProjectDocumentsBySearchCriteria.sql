SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************
 #Desc: 		Söker bland och i projektdokument. Sökningen görs
				ord för ord och alla ord måste förekomma. Till att
				börja med görs sökningen på dokumentets attribut, 
				t ex projektets kod och namn, dokumentets namn
				och typ, vem som laddade upp det o s v.
				Om Full Text Search Index finns på DocumentData
				görs sökningen även i dokumentet, för de filformat
				där det är möjligt.
 #Used By:		-
 #InParam:		-
 #ResultSet:		-
 #
 #Returns:		-
 #Owner:		DBO
 #Creator:		Adam Holmström
 #CreateDate:		140425
 #Modified by:	Emil Ahlqvist	
 #ModifiedDate:		170103
 #Modified by:		
 #ModifiedDate:		
 #Log:			
				EA 170103: Lagt till stöd för att söka bland processinstansdokument.
				EA 170118: Tar in FCTypeID för att inte returnera onödigt många dokument om en kund har flera projektbudgettyper uppsatta.
				EA 170118: Lagt till stöd för att söka bland projektkalkyldokument (bifogade i kommentarer på gridceller).

********************************************************************/
--[selFCProjectDocumentsBySearchCriteria] 'flodhästen', 2
CREATE PROCEDURE [dbo].[selFCProjectDocumentsBySearchCriteria]
	@searchText varchar(250),
	@fcTypeId	int
AS
BEGIN
	DECLARE @Result TABLE(
		ProjectID int,
		DocumentID int
	)

	DECLARE @SearchTextWords TABLE(
		Word varchar(100)
	)

	-- Dela upp söktexten i ord för att kunna matcha ord för ord.
	INSERT INTO @SearchTextWords(Word)
	SELECT strings
	FROM [dbo].[sepstring](@searchText, ' ')
	WHERE strings <> ''

	DECLARE @searchWordCount int
	SELECT @searchWordCount = count(*) from @SearchTextWords

	-- Store fcTypeIds that are valid for the user's search and join CellComment with it later.
	SELECT FCTypeID INTO #fcTypeIds 
	FROM FCTypeGroupRelation 
	WHERE GroupID = 
	(SELECT GroupID 
	FROM FCTypeGroupRelation 
	WHERE FCTypeID = @fcTypeId AND IsPrimary = 1) 
	UNION SELECT @fcTypeId

	-- Kontrollera om FTI finns.
	DECLARE @value INT;
	SELECT @value = COLUMNPROPERTY(OBJECT_ID('dbo.DocumentData'), 'Data', 'IsFulltextIndexed')

	IF @value = 1
	BEGIN
		DECLARE @searchWord varchar(100)
		DECLARE @TempResult TABLE(
			ProjectID int,
			DocumentID int
		)

		-- Sök varje ord var för sig och stoppa in resulatet i @TempResult
		-- Ett dokument som matchar alla ord ska innehålla lika många poster
		-- i @TempResult. Anledningen till detta tillvägagångssätt istället
		-- för en cross join och OR FREETEXT(Data, searchTextWords.Word)
		-- är att FREETEXT inte tillåter annat än strängkonstanter och variabler.
		DECLARE search_cursor CURSOR FOR  
		SELECT Word 
		FROM @SearchTextWords

		OPEN search_cursor   
		FETCH NEXT FROM search_cursor INTO @searchWord   

		WHILE @@FETCH_STATUS = 0   
		BEGIN   
			-- Sök bland dokumentens attribut och i dess innehåll
			DECLARE @sql nvarchar(max)
			SET @sql = N'
			SELECT pd.FCProjectID, pd.DocumentID
				FROM FCProjectDocument pd
					INNER JOIN Document doc ON pd.DocumentID = doc.ID
					INNER JOIN FCProject proj ON pd.FCProjectID = proj.ID
					LEFT JOIN [User] uploadedBy ON doc.UploadedBy = uploadedBy.UserID
					LEFT JOIN [User] modifiedBy ON doc.ModifiedBy = modifiedBy.UserID
					LEFT JOIN [User] approvedBy ON pd.ApprovedBy = approvedBy.UserID
					LEFT JOIN FCProjectDocumentType docType ON pd.FCProjectDocumentTypeID = docType.ID
					LEFT JOIN DocumentRevision rev ON doc.ID = rev.DocumentID and rev.IsLatestRevision = 1
					LEFT JOIN DocumentData data ON rev.DocumentDataID = data.ID
				WHERE
					proj.FCTypeID = @fcTypeId AND 
					(UPPER(doc.Name) LIKE ''%'' + @searchWord  + ''%''
					OR UPPER(uploadedBy.FullName) LIKE ''%'' + @searchWord  + ''%''
					OR UPPER(modifiedBy.FullName) LIKE ''%'' + @searchWord  + ''%''
					OR UPPER(approvedBy.FullName) LIKE ''%'' + @searchWord  + ''%''
					OR UPPER(docType.Caption) LIKE ''%'' + @searchWord  + ''%''
					OR UPPER(proj.Code) LIKE ''%'' + @searchWord  + ''%''
					OR UPPER(proj.Name) LIKE ''%'' + @searchWord  + ''%''
					OR FREETEXT(Data, @searchWord))
				GROUP BY pd.FCProjectID, pd.DocumentID
			UNION
			SELECT proj.ID as FCProjectID, pd.DocumentID
				FROM FCProjectProcessInstanceDocument pd
					INNER JOIN Document doc ON pd.DocumentID = doc.ID
					INNER JOIN FCProjectProcessInstanceRelation instance ON pd.ProcessInstanceID = instance.ProcessInstanceID
					INNER JOIN FCProject proj ON instance.FCProjectID = proj.ID
					LEFT JOIN [User] uploadedBy ON doc.UploadedBy = uploadedBy.UserID
					LEFT JOIN [User] modifiedBy ON doc.ModifiedBy = modifiedBy.UserID
					LEFT JOIN DocumentRevision rev ON doc.ID = rev.DocumentID and rev.IsLatestRevision = 1
					LEFT JOIN DocumentData data ON rev.DocumentDataID = data.ID
				WHERE
					proj.FCTypeID = @fcTypeId AND 
					(UPPER(doc.Name) LIKE ''%'' + @searchWord  + ''%''
					OR UPPER(uploadedBy.FullName) LIKE ''%'' + @searchWord  + ''%''
					OR UPPER(modifiedBy.FullName) LIKE ''%'' + @searchWord  + ''%''
					OR UPPER(proj.Code) LIKE ''%'' + @searchWord  + ''%''
					OR UPPER(proj.Name) LIKE ''%'' + @searchWord  + ''%''
					OR UPPER(doc.FileType) LIKE ''%'' + @searchWord + ''%''
					OR FREETEXT(Data, @searchWord))
				GROUP BY proj.ID, pd.DocumentID
			UNION
			SELECT proj.ID as FCProjectID, ccdoc.DocumentID
				FROM CellCommentDocument ccdoc
					INNER JOIN Document doc ON ccdoc.DocumentID = doc.ID
					INNER JOIN CellCommentEntry cce ON ccdoc.CellCommentEntryID = cce.ID
					INNER JOIN CellCommentDimension ccdim ON cce.CellCommentID = ccdim.CellCommentID
					INNER JOIN CellComment cc ON cce.CellCommentID = cc.ID AND cc.FCTypeID IN (SELECT FCTypeID FROM #fcTypeIds)
					INNER JOIN FCProject proj ON CAST(COALESCE(ccdim.ElementKey, dbo.fn_GetElementKeyFromUniqueName(ccdim.FullMemberName)) as int) = proj.ID
					LEFT JOIN FCElementProperty fcep ON fcep.FCTypeID = @fcTypeId AND fcep.PropertyID = 8
					LEFT JOIN [User] uploadedBy ON doc.UploadedBy = uploadedBy.UserID
					LEFT JOIN DocumentRevision rev ON doc.ID = rev.DocumentID and rev.IsLatestRevision = 1
					LEFT JOIN DocumentData data ON rev.DocumentDataID = data.ID
				WHERE
					proj.FCTypeID = @fcTypeId AND
					ccdim.DimensionName = fcep.ValueString AND
					(UPPER(doc.Name) LIKE ''%'' + @searchWord  + ''%''
					OR UPPER(uploadedBy.FullName) LIKE ''%'' + @searchWord  + ''%''
					OR UPPER(proj.Code) LIKE ''%'' + @searchWord  + ''%''
					OR UPPER(proj.Name) LIKE ''%'' + @searchWord  + ''%''
					OR UPPER(doc.FileType) LIKE ''%'' + @searchWord + ''%''
					OR FREETEXT(Data, @searchWord))
				GROUP BY proj.ID, ccdoc.DocumentID'

			INSERT @TempResult
			EXEC sp_executesql @sql, N'@searchWord varchar(100), @fcTypeId int', @searchWord = @searchWord, @fcTypeId = @fcTypeId

			FETCH NEXT FROM search_cursor INTO @searchWord
		END   

		CLOSE search_cursor   
		DEALLOCATE search_cursor

		-- I resultatet tar vi endast med de dokument som matchar alla sökord.
		INSERT INTO @Result(ProjectID, DocumentID)
		SELECT ProjectID, DocumentID
		FROM @TempResult
		GROUP BY ProjectID, DocumentID
		HAVING COUNT(*) = @searchWordCount
	END
	ELSE
	BEGIN
		-- Sök bland dokumentens attribut enbart
		INSERT INTO @Result(ProjectID, DocumentID)
		SELECT pd.FCProjectID, pd.DocumentID
		FROM FCProjectDocument pd
			INNER JOIN Document doc ON pd.DocumentID = doc.ID
			INNER JOIN FCProject proj ON pd.FCProjectID = proj.ID
			LEFT JOIN [User] uploadedBy ON doc.UploadedBy = uploadedBy.UserID
			LEFT JOIN [User] modifiedBy ON doc.ModifiedBy = modifiedBy.UserID
			LEFT JOIN [User] approvedBy ON pd.ApprovedBy = approvedBy.UserID
			LEFT JOIN FCProjectDocumentType docType ON pd.FCProjectDocumentTypeID = docType.ID
			CROSS JOIN @SearchTextWords searchTextWords
		WHERE
			proj.FCTypeID = @fcTypeId AND
			(UPPER(doc.Name) LIKE '%' + searchTextWords.Word  + '%'
			OR UPPER(uploadedBy.FullName) LIKE '%' + searchTextWords.Word  + '%'
			OR UPPER(modifiedBy.FullName) LIKE '%' + searchTextWords.Word  + '%'
			OR UPPER(approvedBy.FullName) LIKE '%' + searchTextWords.Word  + '%'
			OR UPPER(docType.Caption) LIKE '%' + searchTextWords.Word  + '%'
			OR UPPER(proj.Code) LIKE '%' + searchTextWords.Word  + '%'
			OR UPPER(proj.Name) LIKE '%' + searchTextWords.Word  + '%')
		GROUP BY pd.FCProjectID, pd.DocumentID
		HAVING COUNT(*) = @searchWordCount
		UNION
		SELECT proj.ID as FCProjectID, pd.DocumentID
		FROM FCProjectProcessInstanceDocument pd
			INNER JOIN Document doc ON pd.DocumentID = doc.ID
			INNER JOIN FCProjectProcessInstanceRelation instance ON pd.ProcessInstanceID = instance.ProcessInstanceID
			INNER JOIN FCProject proj ON instance.FCProjectID = proj.ID
			LEFT JOIN [User] uploadedBy ON doc.UploadedBy = uploadedBy.UserID
			LEFT JOIN [User] modifiedBy ON doc.ModifiedBy = modifiedBy.UserID
			LEFT JOIN DocumentRevision rev ON doc.ID = rev.DocumentID and rev.IsLatestRevision = 1
			CROSS JOIN @SearchTextWords searchTextWords
		WHERE
			proj.FCTypeID = @fcTypeId AND
			(UPPER(doc.Name) LIKE '%' + searchTextWords.Word   + '%'
			OR UPPER(uploadedBy.FullName) LIKE '%' + searchTextWords.Word   + '%'
			OR UPPER(modifiedBy.FullName) LIKE '%' + searchTextWords.Word   + '%'
			OR UPPER(proj.Code) LIKE '%' + searchTextWords.Word   + '%'
			OR UPPER(proj.Name) LIKE '%' + searchTextWords.Word   + '%'
			OR UPPER(doc.FileType) LIKE '%' + searchTextWords.Word  + '%')
		GROUP BY proj.ID, pd.DocumentID
		HAVING COUNT(*) = @searchWordCount
		UNION
		SELECT proj.ID as FCProjectID, ccdoc.DocumentID
		FROM CellCommentDocument ccdoc
			INNER JOIN Document doc ON ccdoc.DocumentID = doc.ID
			INNER JOIN CellCommentEntry cce ON ccdoc.CellCommentEntryID = cce.ID
			INNER JOIN CellCommentDimension ccdim ON cce.CellCommentID = ccdim.CellCommentID
			INNER JOIN CellComment cc ON cce.CellCommentID = cc.ID AND cc.FCTypeID IN (SELECT FCTypeID FROM #fcTypeIds)
			INNER JOIN FCProject proj ON CAST(COALESCE(ccdim.ElementKey, dbo.fn_GetElementKeyFromUniqueName(ccdim.FullMemberName)) as int) = proj.ID
			LEFT JOIN FCElementProperty fcep ON fcep.FCTypeID = @fcTypeId AND fcep.PropertyID = 8
			LEFT JOIN [User] uploadedBy ON doc.UploadedBy = uploadedBy.UserID
			LEFT JOIN DocumentRevision rev ON doc.ID = rev.DocumentID and rev.IsLatestRevision = 1
			CROSS JOIN @SearchTextWords searchTextWords
		WHERE
			proj.FCTypeID = @fcTypeId AND
			ccdim.DimensionName = fcep.ValueString AND
			(UPPER(doc.Name) LIKE '%' + searchTextWords.Word   + '%'
			OR UPPER(uploadedBy.FullName) LIKE '%' + searchTextWords.Word   + '%'
			OR UPPER(proj.Code) LIKE '%' + searchTextWords.Word   + '%'
			OR UPPER(proj.Name) LIKE '%' + searchTextWords.Word   + '%'
			OR UPPER(doc.FileType) LIKE '%' + searchTextWords.Word  + '%')
		GROUP BY proj.ID, ccdoc.DocumentID
		HAVING COUNT(*) = @searchWordCount
	END

	-- Remove temporary table.
	DROP TABLE #fcTypeIds

	-- Returnera resultatet
	SELECT DISTINCT 
		ProjectID,
		DocumentID
	FROM @Result
END
GO
