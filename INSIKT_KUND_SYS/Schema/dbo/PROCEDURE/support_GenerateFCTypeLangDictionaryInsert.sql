SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[support_GenerateFCTypeLangDictionaryInsert] 
(
	@FCTypeID int
)
as
----
---- Uppdatera värdet på parametrar nedan...
---- Kör frågan och hyffsade översättningar insertas i INSIKT_SYS LangDictionary för FCType
----
--declare 	
--	@FCTypeID int
--select
--	@FCTypeID = 6

if not exists ( select 1 from FCType where ID = @FCTypeID)
	begin
		raiserror('FCType with ID %i does not exist', 16, 10, @FCTypeID)
		return
	end
declare @TypeOfBudget varchar(15)
set @TypeOfBudget = dbo.fn_GetTypeOfBudget(@FCTypeID)

declare @FCTypeName varchar(50)
SELECT @FCTypeName = Caption FROM dbo.FCType WHERE ID = @FCTypeID

declare @LangScript varchar(max)
set @LangScript = 
'--------------------------------------------------------------------------------------'
+ case @TypeOfBudget 
when 'Project' then
'
-- ÖVERSÄTTNINGAR FÖR PROJEKTBUDGET (' + @FCTypeName + '):
'
when 'ProjectCalc' then
'
-- ÖVERSÄTTNINGAR FÖR PROJEKTKALKYL (' + @FCTypeName + '):
'
when 'Prognosis' then
'
-- ÖVERSÄTTNINGAR FÖR VANLIG BUDGET (' + @FCTypeName + '):
'
end +
'-- Verifiera översättningar i detta script och kör det sedan i INSIKT_SYS-databasen.
--
-- (Dessa är endast några av de mer relevanta av alla möjliga översättningar som kan anpassas för budgeten)
--------------------------------------------------------------------------------------'
;with Controls as
(
	-- Översättningar för alla budgetar:
	select [ControlName] = 'CapInput'
			,Lang1Txt = 'Input'
			,Lang2Txt = 'Inmatning'
	union select [ControlName] = 'CapInfoTab'
			,Lang1Txt = 'Info'
			,Lang2Txt = 'Info'

	-- Översättningar för 'vanliga' budgetar:
	union select [ControlName] = 'CapOverview'
			,Lang1Txt = 'Overview'
			,Lang2Txt = 'Översikt' Where @TypeOfBudget = 'Prognosis'
	union select [ControlName] = 'CapProcessOverview'
			,Lang1Txt = 'Process overview'
			,Lang2Txt = 'Processöversikt'

	-- Översättningar för projektbudgetar:
	union select [ControlName] = 'CapProjectInformation'
			,Lang1Txt = 'Project information'
			,Lang2Txt = 'Projektinformation' Where @TypeOfBudget = 'Project' or @TypeOfBudget = 'ProjectCalc'
	union select [ControlName] = 'CapChangeProjectDates'
			,Lang1Txt = 'Change project dates'
			,Lang2Txt = 'Ändra projektdatum' Where @TypeOfBudget = 'Project' or @TypeOfBudget = 'ProjectCalc'
	union select [ControlName] = 'CapSynchronizeDates'
			,Lang1Txt = 'Keep project length'
			,Lang2Txt = 'Behåll projektlängd' Where @TypeOfBudget = 'Project' or @TypeOfBudget = 'ProjectCalc'
	union select [ControlName] = 'CannotMoveDataWhenChangingProjectDuration'
			,Lang1Txt = 'The input data will not be moved because the duration of the project will be changed.'
			,Lang2Txt = 'Inmatad data kommer inte att flyttas eftersom projektlängden ändras.' Where @TypeOfBudget = 'Project' or @TypeOfBudget = 'ProjectCalc'
	union select [ControlName] = 'CapProject'
			,Lang1Txt = 'Project'
			,Lang2Txt = 'Projekt' Where @TypeOfBudget = 'Project' or @TypeOfBudget = 'ProjectCalc'
	union select [ControlName] = 'CapProjectTotal'
			,Lang1Txt = 'Project total'
			,Lang2Txt = 'Projekttotal' Where @TypeOfBudget = 'Project' or @TypeOfBudget = 'ProjectCalc'
	union select [ControlName] = 'CapProjectDocuments'
			,Lang1Txt = 'Documents' 
			,Lang2Txt = 'Dokument' Where @TypeOfBudget = 'Project' or @TypeOfBudget = 'ProjectCalc'
	union select [ControlName] = 'PROJECT.CARD.BUTTON_CREATE_PROJECT'
			,Lang1Txt = 'Create project' 
			,Lang2Txt = 'Skapa projekt' Where @TypeOfBudget = 'Project' or @TypeOfBudget = 'ProjectCalc'
	union select [ControlName] = 'CapCreateNewSubProject'
			,Lang1Txt = 'Create subproject' 
			,Lang2Txt = 'Skapa delprojekt' Where @TypeOfBudget = 'Project' or @TypeOfBudget = 'ProjectCalc'
	union select [ControlName] = 'PROJECT.CARD.BUTTON_EDIT_PROJECT'
			,Lang1Txt = 'Edit project' 
			,Lang2Txt = 'Redigera projekt' Where @TypeOfBudget = 'Project' or @TypeOfBudget = 'ProjectCalc'
	union select [ControlName] = 'PROJECT.CARD.BUTTON_DELETE'
			,Lang1Txt = 'Delete project' 
			,Lang2Txt = 'Radera projekt' Where @TypeOfBudget = 'Project' or @TypeOfBudget = 'ProjectCalc'
	union select [ControlName] = 'PROJECT.CARD.BUTTON_SAVE'
			,Lang1Txt = 'Save project' 
			,Lang2Txt = 'Spara projekt' Where @TypeOfBudget = 'Project' or @TypeOfBudget = 'ProjectCalc'
	union select [ControlName] = 'PROJECT.CARD.BUTTON_CANCEL'
			,Lang1Txt = 'Cancel' 
			,Lang2Txt = 'Avbryt' Where @TypeOfBudget = 'Project' or @TypeOfBudget = 'ProjectCalc'
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
					'delete from LangDictionary where ControlName = ''' + c.ControlName + ''' and FCTypeID = ' + cast(@FCTypeID as varchar(8)) + '
'					
				else
					''
			end
		else 
			''			
	end +
	'insert into LangDictionary([ControlName],[Comment],[LangID],[VisibleName],[FCTypeID],[CustomName])values (''' + c.ControlName + ''',''''
	,' + cast(l.LangID as varchar(12)) + ' -- ' + l.LangName + '
	,''''
	,' + cast(@FCTypeID as varchar(8)) + '
	,''' + 
		replace
		(
			case l.LangID
				when 1 then c.Lang1Txt
				when 2 then c.Lang2Txt
			end
			, ''''
			, ''''''
		) + ''')
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
