SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[CurrentFCVersionTranslation] as
		select ControlName, Name as Language, VisibleName as DefaultName, CustomName, d.LangID
		from LangDictionary as d
        INNER JOIN Language as l ON d.LangID=l.ID
        where ControlName like '%PlanningVersion%Caption%' or ControlName like '%PlanningVersion%Description%'
GO
