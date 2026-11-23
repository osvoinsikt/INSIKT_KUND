SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [app].[PrintError] 
as
begin
    set nocount on;

    -- Print error information. 
    print 'Error ' + convert(varchar(50), error_number()) +
          ', Severity ' + convert(varchar(5), error_severity()) +
          ', State ' + convert(varchar(5), error_state()) + 
          ', Procedure ' + isnull(error_procedure(), '-') + 
          ', Line ' + convert(varchar(5), error_line());
    print error_message();
end;
GO
