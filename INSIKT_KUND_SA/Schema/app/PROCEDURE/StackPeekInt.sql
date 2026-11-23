SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [app].[StackPeekInt]
(
	@Value int output
	,@IntBuffer varbinary(max)
)
as
set @Value= cast(@IntBuffer as int)




GO
