SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [app].[StackPushInt]
(
	@Value int
	,@IntBuffer varbinary(max) output
)
as
if @IntBuffer is null
	set @IntBuffer = cast(@Value as binary(4))
else	
	set @IntBuffer = @IntBuffer +  cast(@Value as binary(4))
GO
