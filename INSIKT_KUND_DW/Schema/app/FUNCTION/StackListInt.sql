SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [app].[StackListInt]
(
	@IntBuffer varbinary(max)
)
returns table
with schemabinding
as
return
(
	with BinIntList as
	(
		select 		
			Pos = datalength(@IntBuffer) / 4
			,Value = cast(@IntBuffer as integer)
		where
			datalength(@IntBuffer) >= 4
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
