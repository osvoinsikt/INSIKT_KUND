SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





/*******************************************************************
 #Desc: 		Updates organizational structure.
 #Used By:		-
 #InParam:		-
 #ResultSet:		-
 #
 #Returns:		-
 #Owner:		DBO
 #Creator:		Adam Holmström
 #CreateDate:		110627
 #Modified by:		-
 #ModifiedDate:		-
 
 #Log:
		110627	ADHO	Created

********************************************************************/
CREATE	PROCEDURE [dbo].[updOrganizationalStructure] @data XML
AS 
BEGIN
    DELETE  FROM dbo.OrganizationalStructure
    WHERE   ID NOT IN ( SELECT TOP 1 ID FROM dbo.OrganizationalStructure ORDER BY ID)
    
    IF EXISTS (SELECT * FROM dbo.OrganizationalStructure)
    BEGIN
		UPDATE dbo.OrganizationalStructure SET Data = @data
    END
    ELSE
		INSERT INTO dbo.OrganizationalStructure
		        ( Data )
		VALUES  ( @data)
    END
    
	--EXEC dbo.updOrganizationalStructure @data = '<?xml version="1.0" encoding="iso-8859-1"?><boksamling><bok språk="engelska"><titel>XSLT Cookbook</titel><författare>Sal Mangano</författare></bok><bok språk="svenska"><titel>Skriv med XML</titel><författare>Åsa Blom</författare></bok></boksamling>'
    

GO
