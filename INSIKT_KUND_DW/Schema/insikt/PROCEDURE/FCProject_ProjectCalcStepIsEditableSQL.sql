SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Anropas från INSIKT om FCProperty 279 är konfigurerad i FCElementProperty
-- ValueString ska innehålla ett anrop likt följande:
/*
exec INSIKT_KUND_DW.[insikt].[FCProject_ProjectCalcStepIsEditableSQL]
    @FCTypeID = 2
    ,@FCProjectID = @projectId
    ,@FCVersionID = @versionId
    ,@UserID = @userId
    ,@StepID = @stepId
    ,@StepTypeID = @stepTypeId
    ,@Finish = @finish
*/
create procedure [insikt].[FCProject_ProjectCalcStepIsEditableSQL]
(
    @FCTypeID int -- @fcTypeId från INSIKT
    ,@FCProjectID int -- @projectId från INSIKT
    ,@FCVersionID int -- @versionId från INSIKT
    ,@UserID int -- @userId från INSIKT
    ,@StepID int -- @stepId från INSIKT
    ,@StepTypeID int -- @stepTypeId från INSIKT
    ,@Finish int -- 1 = användare vill klarmarkera, 0 = användare vill ta bort klarmarkering
)
as
begin
    -- Declare the return variable here
    declare @Editable int = 1
            ,@ReadOnlyReason nvarchar(max)
            
    if not exists (select 1 from insikt.FCProject_Versions v where v.FCProjectID = @FCProjectID and v.FCVersionID = @FCVersionID)
    begin
        select @Editable = 0
                ,@ReadOnlyReason = 'Avslutade versioner kan inte ändras'
    end

    select 
        [Editable] = @Editable
        ,[ReadOnlyReason] = @ReadOnlyReason
end
------- Arbetsfiler\INSIKT-Projekt-Grund-0.3.0\INSIKT Projekt Grund\INSIKT_DW\insikt\PROCEDURE\FCProject_ProjectCalcStepIsEditableSQL.sql -----END


GO
