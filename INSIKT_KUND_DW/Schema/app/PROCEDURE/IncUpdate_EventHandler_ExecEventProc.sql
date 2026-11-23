SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [app].[IncUpdate_EventHandler_ExecEventProc]
(
    @ProcName nvarchar(1024)
    ,@Type nvarchar(4000) = null
    ,@ParamList nvarchar(4000) = null 
    ,@ParentEventID int = null
    ,@MaxIncUpdateID int = null
    ,@EventID int = null
    ,@LinkedServer nvarchar(1024) = null
    ,@CubeDatabaseID nvarchar(1024) = null
    ,@CubeID nvarchar(1024) = null
    ,@MeasureGroupID  nvarchar(1024) = null
    ,@PartitionID nvarchar(1024) = null
    ,@DataSourceID nvarchar(1024) = null
	,@CustomDimensionID nvarchar(1024) = null
    ,@WriteEnabledMeasuregroup bit = null
    ,@SourceTable nvarchar(1024) = null
    ,@SourceFilter nvarchar(max) = null
) as
begin
    if @ProcName <> ''
        begin
            if OBJECT_ID(@ProcName, 'P') <> 0
                begin
                    declare @DynSQL nvarchar(max) = ''            
                    select
                        @DynSQL = @DynSQL +
                            case p.name
                                when '@Type' then iif(@DynSQL = '', ' ', ', ') +
                                    '@Type = ' + isnull('''' + replace(@Type, '''', '''''') + '''', 'null')
                                when '@ParamList' then iif(@DynSQL = '', ' ', ', ') +
                                    '@ParamList = ' + isnull('''' + replace(@ParamList, '''', '''''') + '''', 'null')
                                when '@ParentEventID' then iif(@DynSQL = '', ' ', ', ') +
                                    '@ParentEventID = ' + isnull(cast(@ParentEventID as nvarchar(12)), 'null')
                                when '@MaxIncUpdateID' then iif(@DynSQL = '', ' ', ', ') +
                                    '@MaxIncUpdateID = ' + isnull(cast(@MaxIncUpdateID as nvarchar(20)), 'null')
                                when '@EventID' then iif(@DynSQL = '', ' ', ', ') +
                                    '@EventID = ' + isnull(cast(@EventID as nvarchar(20)), 'null')
  
                                when '@LinkedServer' then iif(@DynSQL = '', ' ', ', ') +
                                    '@LinkedServer = ' + isnull('''' + replace(@LinkedServer, '''', '''''') + '''', 'null')
                                when '@CubeDatabaseID' then iif(@DynSQL = '', ' ', ', ') +
                                    '@CubeDatabaseID = ' + isnull('''' + replace(@CubeDatabaseID, '''', '''''') + '''', 'null')
                                when '@CubeID' then iif(@DynSQL = '', ' ', ', ') +
                                    '@CubeID = ' + isnull('''' + replace(@CubeID, '''', '''''') + '''', 'null')
                                when '@MeasureGroupID' then iif(@DynSQL = '', ' ', ', ') +
                                    '@MeasureGroupID = ' + isnull('''' + replace(@MeasureGroupID, '''', '''''') + '''', 'null')
                                when '@PartitionID' then iif(@DynSQL = '', ' ', ', ') +
                                    '@PartitionID = ' + isnull('''' + replace(@PartitionID, '''', '''''') + '''', 'null')
                                when '@DataSourceID' then iif(@DynSQL = '', ' ', ', ') +
                                    '@DataSourceID = ' + isnull('''' + replace(@DataSourceID, '''', '''''') + '''', 'null')
								when '@CustomDimensionID' then iif(@DynSQL = '', ' ', ', ') +
                                    '@CustomDimensionID = ' + isnull('''' + replace(@CustomDimensionID, '''', '''''') + '''', 'null')
                                when '@SourceTable' then iif(@DynSQL = '', ' ', ', ') +
                                    '@SourceTable = ' + isnull('''' + replace(@SourceTable, '''', '''''') + '''', 'null')
                                when '@SourceFilter' then iif(@DynSQL = '', ' ', ', ') +
                                    '@SourceFilter = ' + isnull('''' + replace(@SourceFilter, '''', '''''') + '''', 'null')
                                when '@WriteEnabledMeasuregroup' then iif(@DynSQL = '', ' ', ', ') +
                                    '@WriteEnabledMeasuregroup = ' + isnull(cast(@WriteEnabledMeasuregroup as nvarchar(20)), 'null')
                                else ''
                            end
                    from
                        sys.parameters p
                    where
                        p.object_id = object_id(@ProcName)
                    set @DynSQL = 'exec ' + @ProcName + @DynSQL + ';'
                                  
                    
					begin try
						print @DynSQL
						exec (@DynSQL)
					end try
					begin catch
						declare @ErrorMessage nvarchar(max) = app.GetErrorMessage();
						raiserror('Error executing dynamic SQL "%s" for event id %i, Error: %s', 16, 10
							,@DynSQL
							,@EventID							
							,@ErrorMessage);						
					end catch
                end
            else
                raiserror('Event procedure %s does not exist.', 16, 10, @ProcName)
        end
          
              
end
GO
