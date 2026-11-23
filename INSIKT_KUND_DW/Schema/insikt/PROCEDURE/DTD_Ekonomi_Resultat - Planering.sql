SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [insikt].[DTD_Ekonomi_Resultat - Planering]
(
	@measureUniqueName varchar(200),
	@userID int
)
as
	select ID
	into #DTD
	from [dw].[fact_Resultat_Planning_Analysis] f
		inner join #DrillthroughID dtd ON
					f.[KontoID] = dtd.[Resultatkonto_KontoID]
					and f.[PlanningVersionID] = dtd.[Planeringsversion_PlanningVersionID]
					and f.[KampanjID] = dtd.[Kampanj_KampanjID]
					and f.[ProjektID] = dtd.[Projekt_ProjektID]
					and f.[VarugruppID] = dtd.[Varugrupp_VarugruppID]
					and f.[AvdelningID] = dtd.[Avdelning_AvdelningID]
					and f.[PostingDateID] = dtd.[Datum_DateID]
					and f.[Organisation_LeafID] = dtd.[Organisation_Organisation_LeafID]
		

	if @measureUniqueName like '%Budget%'
		begin
			select
							[Datum] = [Datum].DateName
							
				,[Avdelning] = case when [Avdelning].[AvdelningID] < 0 then '' else [Avdelning].DisplayName end
				
				,[Kampanj] = case when [Kampanj].[KampanjID] < 0 then '' else [Kampanj].DisplayName end
				
				,[Projekt] = case when [Projekt].[ProjektID] < 0 then '' else [Projekt].DisplayName end
				
				,[Varugrupp] = case when [Varugrupp].[VarugruppID] < 0 then '' else [Varugrupp].DisplayName end
				
				,[Konto] = case when [Konto].[KontoID] < 0 then '' else [Konto].DisplayName end
							,[Planeringsversion] = case when [Planeringsversion].[PlanningVersionID] < 0 then '' else [Planeringsversion].Name end
				,[Senaste tid] = max(f.AuditTime)
				,[Senaste användaren] = (select f2.AuditUser from [dw].[fact_Resultat_Planning_Analysis] f2 where f2.ID = max(f.ID))
				,[Budget Belopp] = sum([BudgetAmount])
				,[Budget Antal] = nullif(sum(f.[BudgetQuantity]), 0)
			from [dw].[fact_Resultat_Planning_Analysis] f
					inner join #DTD dtd on
						f.ID = dtd.ID
										
					inner join [dw].[base_Avdelning] [Avdelning] on
						[Avdelning].[AvdelningID] = f.[AvdelningID]
										
					inner join [dw].[base_Kampanj] [Kampanj] on
						[Kampanj].[KampanjID] = f.[KampanjID]
										
					inner join [dw].[base_Projekt] [Projekt] on
						[Projekt].[ProjektID] = f.[ProjektID]
										
					inner join [dw].[base_Varugrupp] [Varugrupp] on
						[Varugrupp].[VarugruppID] = f.[VarugruppID]
										
					inner join [dw].[base_Konto] [Konto] on
						[Konto].[KontoID] = f.[KontoID]
														
					inner join [dw].[dim_Time] Datum on
						[Datum].[DateID] = f.[PostingDateID]
									inner join [dw].[dim_PlanningVersion] [Planeringsversion] on
						[Planeringsversion].[PlanningVersionID] = f.[PlanningVersionID]
			where [Planeringsversion].type = 1
			group by 
							[Datum].DateName
										,[Avdelning].[AvdelningID]
				,[Avdelning].DisplayName
							,[Kampanj].[KampanjID]
				,[Kampanj].DisplayName
							,[Projekt].[ProjektID]
				,[Projekt].DisplayName
							,[Varugrupp].[VarugruppID]
				,[Varugrupp].DisplayName
							,[Konto].[KontoID]
				,[Konto].DisplayName
							,[Planeringsversion].[PlanningVersionID]
				,[Planeringsversion].Name
		end
	else 
		begin
			select
							[Datum] = [Datum].DateName
							
				,[Avdelning] = case when [Avdelning].[AvdelningID] < 0 then '' else [Avdelning].DisplayName end
				
				,[Kampanj] = case when [Kampanj].[KampanjID] < 0 then '' else [Kampanj].DisplayName end
				
				,[Projekt] = case when [Projekt].[ProjektID] < 0 then '' else [Projekt].DisplayName end
				
				,[Varugrupp] = case when [Varugrupp].[VarugruppID] < 0 then '' else [Varugrupp].DisplayName end
				
				,[Konto] = case when [Konto].[KontoID] < 0 then '' else [Konto].DisplayName end
							,[Planeringsversion] = case when [Planeringsversion].[PlanningVersionID] < 0 then '' else [Planeringsversion].Name end
				,[Senaste tid] = max(f.AuditTime)
				,[Senaste användaren] = (select f2.AuditUser from [dw].[fact_Resultat_Planning_Analysis] f2 where f2.ID = max(f.ID))
				,[Prognos Belopp] = sum([PrognosAmount])
				,[Prognos Antal] = nullif(sum(f.[PrognosQuantity]), 0)
			from [dw].[fact_Resultat_Planning_Analysis] f
					inner join #DTD dtd on
						f.ID = dtd.ID
										
					inner join [dw].[base_Avdelning] [Avdelning] on
						[Avdelning].[AvdelningID] = f.[AvdelningID]
										
					inner join [dw].[base_Kampanj] [Kampanj] on
						[Kampanj].[KampanjID] = f.[KampanjID]
										
					inner join [dw].[base_Projekt] [Projekt] on
						[Projekt].[ProjektID] = f.[ProjektID]
										
					inner join [dw].[base_Varugrupp] [Varugrupp] on
						[Varugrupp].[VarugruppID] = f.[VarugruppID]
										
					inner join [dw].[base_Konto] [Konto] on
						[Konto].[KontoID] = f.[KontoID]
														
					inner join [dw].[dim_Time] Datum on
						[Datum].[DateID] = f.[PostingDateID]
									inner join [dw].[dim_PlanningVersion] [Planeringsversion] on
						[Planeringsversion].[PlanningVersionID] = f.[PlanningVersionID]
				where [Planeringsversion].type = 2
				group by 
									[Datum].DateName
													,[Avdelning].[AvdelningID]
					,[Avdelning].DisplayName
									,[Kampanj].[KampanjID]
					,[Kampanj].DisplayName
									,[Projekt].[ProjektID]
					,[Projekt].DisplayName
									,[Varugrupp].[VarugruppID]
					,[Varugrupp].DisplayName
									,[Konto].[KontoID]
					,[Konto].DisplayName
									,[Planeringsversion].[PlanningVersionID]
					,[Planeringsversion].Name
		end
GO
