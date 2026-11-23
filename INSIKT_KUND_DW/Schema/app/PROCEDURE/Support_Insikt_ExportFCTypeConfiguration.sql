SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [app].[Support_Insikt_ExportFCTypeConfiguration]
(
	@INSIKT_SYS nvarchar(max)
    ,@FCTypeIDs varchar(max) 
    ,@FCTypeData xml = null output
)
as
 
 
declare @DynSQL nvarchar(max)
select
	 @DynSQL = 
'	
select
    @FCTypeData =
    (
        select
            FCType.*
            ,DataSourceConnections =
                (
                    select distinct
                        DataSourceConnection.*
                    from
                        ' + @INSIKT_SYS + '.dbo.FCTypeDataSourceRelation FCTypeDataSourceRelation
                            inner join ' + @INSIKT_SYS + '.dbo.DataSources DataSources on
                                DataSources.ID = FCTypeDataSourceRelation.DataSourceID
                            inner join ' + @INSIKT_SYS + '.dbo.DataSourceConnection DataSourceConnection on
                                DataSourceConnection.ID = DataSources.DataSourceConnectionID
                    where
                        FCTypeDataSourceRelation.FCTypeID = FCType.ID
                    for xml auto, type
                )
             ,DataSources =
                (
                    select
                        DataSource.*
                    from
                        ' + @INSIKT_SYS + '.dbo.FCTypeDataSourceRelation FCTypeDataSourceRelation
                            inner join ' + @INSIKT_SYS + '.dbo.DataSources DataSource on
                                DataSource.ID = FCTypeDataSourceRelation.DataSourceID
                    where
                        FCTypeDataSourceRelation.FCTypeID = FCType.ID
                    for xml auto, type
                )
             ,FCTypeDataSourceRelations =
                (
                    select
                        FCTypeDataSourceRelation.*
                    from
                        ' + @INSIKT_SYS + '.dbo.FCTypeDataSourceRelation FCTypeDataSourceRelation                        
                    where
                        FCTypeDataSourceRelation.FCTypeID = FCType.ID
                    for xml auto, type
                )
            ,FCElements =
                (
                    select
                        FCElement.*
                    from
                        ' + @INSIKT_SYS + '.dbo.FCTypeDataSourceRelation FCTypeDataSourceRelation
                            inner join ' + @INSIKT_SYS + '.dbo.DataSources DataSources on
                                DataSources.ID = FCTypeDataSourceRelation.DataSourceID
                            inner join ' + @INSIKT_SYS + '.dbo.FCElement FCElement on
                                FCElement.DataSourceID = DataSources.ID
                    where
                        FCTypeDataSourceRelation.FCTypeID = FCType.ID
                    for xml auto, type
                )
            ,FCElementProperties =
                (
                    select
                        FCElementProperty.*
                    from
                        ' + @INSIKT_SYS + '.dbo.FCElementProperty FCElementProperty                         
                    where
                        FCElementProperty.FCTypeID = FCType.ID
                    for xml auto, type
                )
 
            ,FCViews =
                (
                    select
                        FCView.*
                            ,FCViewDimensions =
                            (
                                select
                                    FCViewDimension.*
                                from
                                    ' + @INSIKT_SYS + '.dbo.FCViewDimension FCViewDimension                         
                                where
                                    FCViewDimension.FCViewID = FCView.ID
                                for xml auto, type
                            )
                            ,FCViewNonEmptyMembers =
                            (
                                select
                                    FCViewNonEmptyMember.*
                                from
                                    ' + @INSIKT_SYS + '.dbo.FCViewNonEmptyMember FCViewNonEmptyMember                         
                                where
                                    FCViewNonEmptyMember.FCViewID = FCView.ID
                                for xml auto, type
                            )
                    from
                        ' + @INSIKT_SYS + '.dbo.FCView FCView
                    where
                        FCView.FCTypeID = FCType.ID
                    for xml auto, type
                )
  
            ,FCColumns =
                (
                    select
                        FCColumn.*
                    from
                        ' + @INSIKT_SYS + '.dbo.FCColumns FCColumn
                    where
                        FCColumn.FCTypeID = FCType.ID
                    for xml auto, type
                )
            ,FCRoles =
                (
                    select distinct
                        FCRole.*
                    from
                        ' + @INSIKT_SYS + '.dbo.FCRoleTypeCompanyRelation FCRoleTypeCompanyRelation
                            inner join ' + @INSIKT_SYS + '.dbo.FCRole FCRole on
                                FCRole.ID = FCRoleTypeCompanyRelation.FCRoleID
                    where
                        FCRoleTypeCompanyRelation.FCTypeID = FCType.ID
                    for xml auto, type
                )
            ,FCRoleTypeCompanyRelations =
                (
                    select
                        FCRoleTypeCompanyRelation.*
                    from
                        ' + @INSIKT_SYS + '.dbo.FCRoleTypeCompanyRelation FCRoleTypeCompanyRelation                        
                    where
                        FCRoleTypeCompanyRelation.FCTypeID = FCType.ID
                    for xml auto, type
                )
            ,FormattingRules =
                (
                    select
                        FormattingRule.*
                             
                    from
                        ' + @INSIKT_SYS + '.dbo.FCView FCView
                        inner join ' + @INSIKT_SYS + '.dbo.FCViewFormattingRuleRelation FCViewFormattingRuleRelation on
                            FCView.ID = FCViewFormattingRuleRelation.FCViewID
                        inner join ' + @INSIKT_SYS + '.dbo.FormattingRule FormattingRule on
                            FormattingRule.ID = FCViewFormattingRuleRelation.FormattingRuleID
                    where
                        FCView.FCTypeID = FCType.ID
                    for xml auto, type
                )
            ,FCViewFormattingRuleRelations =
                (
                    select
                        FCViewFormattingRuleRelation.*
                             
                    from
                        ' + @INSIKT_SYS + '.dbo.FCView FCView
                        inner join ' + @INSIKT_SYS + '.dbo.FCViewFormattingRuleRelation FCViewFormattingRuleRelation on
                            FCView.ID = FCViewFormattingRuleRelation.FCViewID      
                    where
                        FCView.FCTypeID = FCType.ID
                    for xml auto, type
                )
             
        from
            ' + @INSIKT_SYS + '.dbo.FCType FCType
                  
                      
        where
            FCType.ID in (select cast(Item as int) from app.Split(@FCTypeIDs, '',''))
        for xml auto, type
    )
 
 '
 declare @DynSQLParams nvarchar(max) = '@FCTypeIDs nvarchar(max), @FCTypeData xml output'
 exec sys.sp_executesql 
	@stmt = @DynSQL
	,@params = @DynSQLParams
	,@FCTypeIDs = @FCTypeIDs
	,@FCTypeData = @FCTypeData output

select FCTypeData = @FCTypeData
GO
