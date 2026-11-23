SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [app].[IncUpdate_Process_Full]
(
 @EventID int = null
    ,@LinkedServer nvarchar(1024) = null
    ,@CubeDatabaseID nvarchar(1024)
    ,@CubeID nvarchar(1024) = null
    ,@MeasureGroupID  nvarchar(1024) = null
    ,@PartitionID nvarchar(1024) = null
 ,@Type nvarchar(4000) = null
    ,@ParamList nvarchar(4000) = null 
    ,@ParentEventID int = null
)
as
--
-- Standardvariabler
--
declare @ProcName sysname, @TranCount int, @EventIDStack varbinary(max)
set @ProcName = app.GetObjectFullName(@@procid)
set @TranCount = @@trancount

declare
    @DynSql nvarchar(max)
    ,@DynSqlParam nvarchar(max)
    ,@XMLA nvarchar(max)
 ,@Message nvarchar(max)

begin try
    --------------------------------------------------------------------------
    -- Start
    --------------------------------------------------------------------------
    set @Message = 
  @CubeDatabaseID
  + isnull(' - ' + @CubeID, '')
  + isnull(' - ' + @MeasureGroupID, '')
  + isnull(' - ' + @PartitionID, '')
    exec app.LogEventStart @ParentEventID = @ParentEventID, @EventIDStack = @EventIDStack output, @EventObject = @ProcName
        ,@EventTitle = 'IncUpdate_Process_Full'
        ,@Description = @Message

 
  if @LinkedServer is null raiserror('LinkedServer must be set', 16, 10)
  if @CubeDatabaseID is null raiserror('CubeDatabaseID must be set', 16, 10)
  --if @CustomDimensionID is null raiserror('CustomDimensionID must be set', 16, 10)
 
        set @XMLA =
'<Batch xmlns="http://schemas.microsoft.com/analysisservices/2003/engine">
<Process xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ddl2="http://schemas.microsoft.com/analysisservices/2003/engine/2" xmlns:ddl2_2="http://schemas.microsoft.com/analysisservices/2003/engine/2/2" xmlns:ddl100_100="http://schemas.microsoft.com/analysisservices/2008/engine/100/100" xmlns:ddl200="http://schemas.microsoft.com/analysisservices/2010/engine/200" xmlns:ddl200_200="http://schemas.microsoft.com/analysisservices/2010/engine/200/200" xmlns:ddl300="http://schemas.microsoft.com/analysisservices/2011/engine/300" xmlns:ddl300_300="http://schemas.microsoft.com/analysisservices/2011/engine/300/300" xmlns:ddl400="http://schemas.microsoft.com/analysisservices/2012/engine/400" xmlns:ddl400_400="http://schemas.microsoft.com/analysisservices/2012/engine/400/400">
<Object>
<DatabaseID>' + @CubeDatabaseID + '</DatabaseID>       
  ' + isnull('<CubeID>' + @CubeID + '</CubeID>', '') + '
        ' + isnull('<MeasureGroupID>' + @MeasureGroupID + '</MeasureGroupID>', '') + '
        ' + isnull('<PartitionID>' + @PartitionID + '</PartitionID>', '') + '
</Object>
<Type>ProcessFull</Type>
<WriteBackTableCreation>UseExisting</WriteBackTableCreation>
</Process>   
</Batch>'
        print @XMLA
        set @DynSql = N'exec (@XMLA) at ' + @LinkedServer
        set @DynSqlParam = N'@XMLA nvarchar(max)'
        begin try
        exec sp_executesql
            @stmt = @DynSql
            ,@params = @DynSqlParam
            ,@XMLA = @XMLA
        end try
        begin catch
            declare @ErrorMessage nvarchar(max)
            set @ErrorMessage =
                cast(error_message() as nvarchar(max)) + N': XMLA =
'                               + @XMLA
            raiserror(@ErrorMessage, 16, 10)
        end catch

        exec app.LogEventStop @EventIDStack = @EventIDStack out
    --------------------------------------------------------------------------
    -- Stop
    --------------------------------------------------------------------------
end try
begin catch
    --
    -- Roll back any transactions and log errors
    --
    if @TranCount = 0 and @@trancount > 0 rollback tran
    exec app.HandleProcError @EventIDStack out, @ParentEventID, @ProcName
    exec app.ReThrowError
end catch
GO
