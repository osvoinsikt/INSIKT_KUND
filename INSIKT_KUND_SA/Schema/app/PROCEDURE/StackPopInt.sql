SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [app].[StackPopInt]
(
	@Value int output
	,@IntBuffer varbinary(max) output
)
as

declare @BufferSize int
set @BufferSize = datalength(@IntBuffer)

if @BufferSize is null or @BufferSize <= 4
	begin
		set @Value = cast(@IntBuffer as int)
		set @IntBuffer = null		
	end
else
	begin
		set @Value= cast(@IntBuffer as int)
		set @IntBuffer = substring(@IntBuffer, 1, @BufferSize - 4)
	end




GO
