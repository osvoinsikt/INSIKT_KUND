SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [app].[ToExistingDateID]
(
	@DateID int	
) returns int 
with schemabinding
as
begin
	set @DateID =
		case
			when @DateID between 100000 and 999999 then 100 * @DateID
			when @DateID between 1000000 and 9999999 then 10 * @DateID
			when @DateID between 10000 and 99999 then 1000 * @DateID
			when @DateID between 1000 and 9999 then 10000 * @DateID
			when @DateID between 0 and 999 then 19000101
			
			
			else  cast(left(@DateID, 8) as int)
		end
	return
	(
		@DateID / 10000 * 10000
		+
		case
			when (@DateID / 100) % 100 > 12 then 12 
			when (@DateID / 100) % 100 = 0 then 1 
			else (@DateID / 100) % 100 
		end * 100
		+
		case (@DateID / 100) % 100 
				
			when 1 then case when @DateID % 100 > 31 then 31 when @DateID % 100 = 0 then 1 else @DateID % 100 end
			when 2 then 
				case 
					when @DateID % 100 > 
						(
							28 
							+ case when ((@DateID / 10000) % 4 = 0 AND (@DateID / 10000) % 100 <> 0) OR (@DateID / 10000) % 400 = 0 then 1 else 0 end
						) 
					then 
						(
							28 
							+ case when ((@DateID / 10000) % 4 = 0 AND (@DateID / 10000) % 100 <> 0) OR (@DateID / 10000) % 400 = 0 then 1 else 0 end
						) 
					when @DateID % 100 = 0 then 1 else @DateID % 100 end
			when 3 then case when @DateID % 100 > 31 then 31 when @DateID % 100 = 0 then 1 else @DateID % 100 end
			when 4 then case when @DateID % 100 > 30 then 30 when @DateID % 100 = 0 then 1 else @DateID % 100 end
			when 5 then case when @DateID % 100 > 31 then 31 when @DateID % 100 = 0 then 1 else @DateID % 100 end
			when 6 then case when @DateID % 100 > 30 then 30 when @DateID % 100 = 0 then 1 else @DateID % 100 end
			when 7 then case when @DateID % 100 > 31 then 31 when @DateID % 100 = 0 then 1 else @DateID % 100 end
			when 8 then case when @DateID % 100 > 31 then 31 when @DateID % 100 = 0 then 1 else @DateID % 100 end
			when 9 then case when @DateID % 100 > 30 then 30 when @DateID % 100 = 0 then 1 else @DateID % 100 end
			when 10 then case when @DateID % 100 > 31 then 31 when @DateID % 100 = 0 then 1 else @DateID % 100 end
			when 11 then case when @DateID % 100 > 30 then 30 when @DateID % 100 = 0 then 1 else @DateID % 100 end
			else case when @DateID % 100 > 31 then 31 when @DateID % 100 = 0 then 1 else @DateID % 100 end
		end

		
	)
end
GO
