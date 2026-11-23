SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [app].[DateAddMonth]
(
	@DateID int
	,@NrOfMonth int
) returns int 
with schemabinding
as
begin
	return
	iif
	(
		@DateID > 999999
		,		
		--
		-- DateID är egentligen ett DateID 
		--
		(
			cast(convert(varchar(8),dateadd(month,@NrOfMonth,convert(datetime,convert(char(8),nullif(@dateID, 0)), 112)),112) as int)
		)
		,
		--
		-- DateID är egentligen ett MonthID
		--
		(
			(
				@DateID / 100
				+ 
				case 
					when 
						( -- Add months 
							@DateID % 100 -- Månad i fråndatum 
							- 1 
							+
							@NrOfMonth
						) 
						< 0 then 
							(
								(
									( -- Add months 
										@DateID % 100 -- Månad i fråndatum 
										- 1 
										+
										@NrOfMonth
									)  
									+ 1
								)/ 12) - 1
					else 
						( -- Add months 
							@DateID % 100 -- Månad i fråndatum 
							- 1 
							+
							@NrOfMonth
						) 
						/ 12	
				end
			) * 100
			+
			case 
				when 
					( -- Add months 
						@DateID % 100 -- Månad i fråndatum 
						- 1 
						+
						@NrOfMonth
					)  
					% 12 < 0 then 
					13 + 
					( -- Add months 
						@DateID % 100 -- Månad i fråndatum 
						- 1 
						+
						@NrOfMonth
					)  
					% 12 
				else 
					1 + 
					( -- Add months 
						@DateID % 100 -- Månad i fråndatum 
						- 1 
						+
						@NrOfMonth
					)  
					% 12 
			end			
		)
	)
end
GO
