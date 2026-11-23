SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create function [app].[StackListInt]
(
	@IntBuffer varbinary(max)
)
returns table
as
return
(
	with BinIntList as
	(
		select 		
			Pos = LEN(@IntBuffer) / 4
			,Value = cast(@IntBuffer as integer)
		where
			LEN(@IntBuffer) >= 4
		union all
		select
			Pos = nxt.Pos - 1
			,Value = cast(substring(@IntBuffer,nxt.Pos * 4 - 7, 4) as integer)
		from	
			BinIntList nxt			
		where
			nxt.Pos > 1
	)
	select
		Pos
		,Value
	from
		BinIntList
)




GO
