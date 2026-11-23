SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[support_GenerateFCObjectLangDictionaryInsert] 
(
	@FCObjectTypeID int
	,@FCObjectTypeSweName varchar(100)
	,@FCObjectTypeEngName varchar(100)
)
as
----
---- Uppdatera värdet på parametrar nedan...
---- Kör frågan och hyffsade översättningar insertas i INSIKT_SYS LangDictionary för FCObject
----
--declare 	
--	@FCObjectTypeID int
--	,@FCObjectTypeSweName varchar(100)
--	,@FCObjectTypeEngName varchar(100)
--select
--	@FCObjectTypeID = 6
--	,@FCObjectTypeSweName = 'Lönekontokoppling'
--	,@FCObjectTypeEngName = 'Salary account connection'

if not exists ( select 1 from FCObjectType where ID = @FCObjectTypeID)
	begin
		raiserror('FCObjectType with ID %i does not exist', 16, 10, @FCObjectTypeID)
		return
	end

declare @LangScript varchar(max)
set @LangScript = 
'--------------------------------------------------------------------------------------
-- Verifiera översättningar i detta script och kör det sedan i INSIKT_SYS-databasen.
--------------------------------------------------------------------------------------'

;with Controls as
(
	select [ControlName] = 'CapActivateObject'
		   ,Lang1Txt = 'Activate'
		   ,Lang2Txt = 'Aktivera'
	union select [ControlName] = 'CapCreateObject'
		   ,Lang1Txt = 'New ' + @FCObjectTypeEngName
		   ,Lang2Txt = 'Ny ' + @FCObjectTypeSweName
	union select [ControlName] = 'CapEditObject'
		   ,Lang1Txt = 'Edit ' + @FCObjectTypeEngName
		   ,Lang2Txt = 'Redigera ' + @FCObjectTypeSweName
	union select [ControlName] = 'CapDeactivateObject'
		   ,Lang1Txt = 'Deactivate'
		   ,Lang2Txt = 'Avaktivera'
	union select [ControlName] = 'CapNoObjectMatched'
		   ,Lang1Txt = 'There are no objects to show.'
		   ,Lang2Txt = 'Det finns inga objekt att visa.'
	union select [ControlName] = 'CapProcessObjects'
		   ,Lang1Txt = 'Process ' + @FCObjectTypeEngName
		   ,Lang2Txt = 'Läs in ' + @FCObjectTypeSweName
	union select [ControlName] = 'txtConfirmRemoveObject'
		   ,Lang1Txt = 'Do you really want to remove the selected row?'
		   ,Lang2Txt = 'Vill du verkligen ta bort vald rad?'
)
,
Languages as
(
	select [LangID] = 1, LangName = 'Engelska'
	union select [LangID] = 2, LangName = 'Svenska'
)
select
	@LangScript = @LangScript + 
	case ROW_NUMBER() over (partition by c.ControlName order by l.LangID)
		when 1 then
'

--------------------------------------
-- ' + c.ControlName + '
--------------------------------------
'
			+
			case 
				when ld.ControlName is not null then
					'delete from LangDictionary where ControlName = ''' + c.ControlName + ''' and FCObjectTypeID = ' + cast(@FCObjectTypeID as varchar(12)) + '
'					
				else
					''
			end
		else 
			''			
	end +
	'insert into LangDictionary([ControlName],[Comment],[LangID],[VisibleName],[FCObjectTypeID],[CustomName])values (''' + c.ControlName + ''',''''
	,' + cast(l.LangID as varchar(12)) + ' -- ' + l.LangName + '
	,''''
	,' + cast(@FCObjectTypeID as varchar(12)) + '
	,''' + 
		replace
		(
			case l.LangID
				when 1 then c.Lang1Txt
				when 2 then c.Lang2Txt
			end
			, ''''
			, ''''''
		) + 
	''')
'
	
from	
	Controls c
		cross join Languages l
	left join LangDictionary ld on
		ld.LangID = l.LangID
		and ld.ControlName = c.ControlName
--where
--	ld.ControlName is null
order by
	c.ControlName, l.LangID


set @LangScript = @LangScript + 
'

--------------------------------------------------------------------------------------
-- Verifiera översättningar i detta script och kör det sedan i INSIKT_SYS-databasen.
--------------------------------------------------------------------------------------'
print @LangScript
GO
