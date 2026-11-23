SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--
-- Genererar hjälpvyer som hjälper till att läsa ut information om data i FCObject.
-- @IncludeVisibleNameLookup är Deprecated och bör inte användas.
--
CREATE procedure [dbo].[support_FCObject_GenerateView]
(	
	@FCObjectTypeID int
	,@CreateInDB varchar(100) = null	-- Vid null kommer vyn att skapas i den databas varifrån denna procedur anropas.
	,@IncludeVisibleNameLookup bit = 0	-- DEPRECATED, Ger dålig prestanda och kan ge syntaxfel.
	,@Debug bit = 0						-- Skriv ut SQL för att skapa vy istället för att faktiskt skapa vyn.
)
as
--
-- Skapa vyn i samma databas som denna procedur anropas ifrån.
--
if @CreateInDB is null	
	select 
		@CreateInDB = DB_NAME(resource_database_id)
	From
		sys.dm_tran_locks 
	where 
		request_session_id = @@spid 
		and resource_type = 'DATABASE' 
		and resource_database_id <> DB_ID()
declare @NewLine char(2)
set @NewLine = char(13) + char(10)
if @FCObjectTypeID is null
	begin
		raiserror('@FCObjectTypeID cannot be NULL.', 16, 10)
		return
	end
if @IncludeVisibleNameLookup is null set @IncludeVisibleNameLookup = 0
declare @ElementView bit
set @ElementView = null			-- Vid null sätts denna utifrån IsStandAlone. @ElementView = not IsStandAlone.
if @ElementView is null
	select
		@ElementView = 1-isnull(t.IsStandAlone, 0)
	from
		FCObjectType t	
	where
		t.ID = @FCObjectTypeID
declare 
	@sqlCreateInDB varchar(max)
	,@sqlCreateAlter varchar(max)
	,@sqlViewName varchar(max)
	,@sqlSelect varchar(max)
    ,@sqlGroupBy varchar(max)
	,@sqlFrom varchar(max)
	,@sqlWhere varchar(max)
	,@sqlInsiktRef varchar(max)
	,@sql varchar(max)
if @CreateInDB is null
	begin
		set @CreateInDB = ''
		set @sqlCreateInDB = ''
		set @sqlInsiktRef = ''
	end
else
	begin
		set @sqlCreateInDB = 'use ' + '[' + parsename(@CreateInDB, 1) + ']' + ';' + @NewLine
		set @sqlInsiktRef = '[' + DB_NAME() + '].dbo.'
		set @CreateInDB = '[' + parsename(@CreateInDB, 1) + ']' + '.dbo.'
	end
select
	@sqlViewName =		
		'FCObject_' + replace(t.Name, ' ', '_') + '_' + case when @ElementView = 1 then 'Element' else '' end + 'View'		
from
	FCObjectType t	
where
	t.ID = @FCObjectTypeID
if @@ROWCOUNT = 0
	begin
		raiserror('FCObjectType with ID = %i does not exist in table FCObjectType.', 16, 10, @FCObjectTypeID)
		return
	end	
if object_id(@CreateInDB + '[' + @sqlViewName + ']') is null
	set @sqlCreateAlter = 'create'
else
	set @sqlCreateAlter = 'alter'
select
	@sqlSelect = 
		'select' + @NewLine +
		'	FCObjectID = o.ID' + @NewLine +
		'	,FCObjectCreatedBy = usg1.UserName' + @NewLine +
		'	,FCObjectCreatedDate = o.CreatedDate' + @NewLine +
		'	,FCObjectModifiedBy = usg2.UserName' + @NewLine +
		'	,FCObjectModifiedDate = o.ModifiedDate' + @NewLine +
		'	,FCObjectIsExternal = isnull(o.isExternal, 0)' + @NewLine +
		'	,FCObjectIsDeleted = isnull(o.isDeleted, 0)' +
		case 
			when @ElementView = 1 then
				@NewLine + 
				'	,FCObjectElementID = isnull(oe.ID, 0)' + @NewLine +
				'	,FCObjectElementKey = isnull(oe.ElementKey, 0)' + @NewLine +
				'	,FCObjectElementFCVersionID = oe.FCVersionID' + @NewLine +
				'	,FCObjectElementIsDeleted = isnull(oe.isDeleted, 0)'
			else
				''
		end
	,@sqlFrom = 
		'from' + @NewLine +
		'	' + @sqlInsiktRef + 'FCObject o' + @NewLine +
		'	inner join ' + @sqlInsiktRef + 'UserSecurityGroup usg1 on usg1.UserID = o.CreatedBy' + @NewLine +
		'	left join ' + @sqlInsiktRef + 'UserSecurityGroup usg2 on usg2.UserID = o.ModifiedBy' + @NewLine +
        '	left join ' + @sqlInsiktRef + 'FCObjectPropertyValue opv on opv.FCObjectID = o.ID'
		+
        case 
			when @ElementView = 1 then
				@NewLine +
				'	inner join ' + @sqlInsiktRef + 'FCObjectElement oe on' + @NewLine +
				'		oe.FCObjectID = o.ID'
			else
				''
		end

select @sqlGroupBy = 'group by' + @NewLine +
		'	 o.ID' + @NewLine +
		'	,usg1.UserName' + @NewLine +
		'	,o.CreatedDate' + @NewLine +
		'	,usg2.UserName' + @NewLine +
		'	,o.ModifiedDate' + @NewLine +
		'	,isnull(o.isExternal, 0)' + @NewLine +
		'	,isnull(o.isDeleted, 0)' +
		case 
			when @ElementView = 1 then
				@NewLine + 
				'	,isnull(oe.ID, 0)' + @NewLine +
				'	,isnull(oe.ElementKey, 0)' + @NewLine +
				'	,oe.FCVersionID' + @NewLine +
				'	,isnull(oe.isDeleted, 0)'
			else
				''
		end


;with PreFCObjectPropertyInfo as
(
	select
		FCObjectTypeID = t.ID
		,ID = p.ID
		,Name = p.Name	
		,QueryToFillPredefinedValues = nullif(ltrim(rtrim(p.QueryToFillPredefinedValues)), '')
		,isObjectID = p.isObjectID
		,isObjectCode = p.isObjectCode
		,isObjectName = p.isObjectName
		,IsObjectParentID = p.IsObjectParentID
		,DatatypeID = dt.ID
		,DatatypeName = dt.Name
		,ControlID = ct.ID
		,ControlName = ct.Name
		,PropertyValueTableAlias = 'pv' + CAST(p.ID as varchar(12))				
		,PropertyPredefinedValueTableAlias = 
			case when ct.Name like '%list' and p.IsObjectParentID = 0 then
				'pv' + CAST(p.ID as varchar(12)) + 'pd'
			end
		,PropertyValueColumnName = 
			case
				when  dt.Name ='string' then
					'ValueString'
				when dt.Name in ('bit', 'int', 'float') then
					'ValueNumeric'
				when dt.Name = 'datetime' then
					'ValueDate'
				else 'UNKNONWN DATATYPE'
			end		
	from
		FCObjectProperty p
			inner join FCObjectType t on
				t.ID = p.FCObjectTypeID
			inner join FCObjectPropertyDatatype dt on
				dt.ID = p.FCObjectPropertyDatatypeID
			inner join FCObjectPropertyControl ct on
				ct.ID = p.FCObjectPropertyControlID
)
,
FCObjectPropertyInfo as
(
	select
		*
		,PropertyValueColumnExpression = 
			case 			
				when p.isObjectID = 1 then
					'o.ID'
				when p.IsObjectParentID = 1 then
					'o.ParentID'
				when p.isObjectCode = 1 then
					case p.DatatypeName
						when 'bit' then
							'o.Code'
						when 'int' then
							'cast(o.Code as int)'
						when 'float' then
							'cast(o.Code as float)'
						else
							'o.Code'									
					end
				when p.isObjectName = 1 then
					case p.DatatypeName
						when 'bit' then
							'o.Name'
						when 'int' then
							'cast(o.Name as int)'
						when 'float' then
							'cast(o.Name as float)'
						else
							'o.Name'
					end					
				else
					case when p.DatatypeName in ('int') then 'cast(' else '' end
					+
					case 
						when p.QueryToFillPredefinedValues is null then		
							isnull(p.PropertyPredefinedValueTableAlias, 'opv') 
						else 
							'opv'
					end 
					+ '.' + PropertyValueColumnName 
					+ case when p.DatatypeName in ('int') then' as ' + p.DatatypeName + ')' else '' end
					
			end
	from
		PreFCObjectPropertyInfo p
)
select
	@sqlSelect = @sqlSelect + @NewLine +
		'	,[' + p.Name + '] = ' + 
			
			case when p.DatatypeName = 'bit' then 'cast(' else '' end +
			
			'max(' + 
			case when p.PropertyValueColumnExpression like 'o.%' or p.PropertyValueColumnExpression like 'cast(o.%' then
				p.PropertyValueColumnExpression
			else
				'case when opv.FCObjectPropertyID = ' + cast(p.ID as varchar(max)) + ' then ' + p.PropertyValueColumnExpression + ' end' 
			end
			+ 
			')'
			+

			case when p.DatatypeName = 'bit' then ' as bit)' else '' end +

			case
				when p.PropertyPredefinedValueTableAlias is not null then
					case when p.QueryToFillPredefinedValues is null then
						@NewLine +
					'	,[' + p.Name + '_PredefinedValueID] = max(case when opv.FCObjectPropertyID = ' + cast(p.ID as varchar(max)) + ' then ' + p.PropertyPredefinedValueTableAlias + '.ID end)'
					else
						''
					end 
					+
					case  
						when @IncludeVisibleNameLookup = 1 then
							@NewLine +
							'	,[' + p.Name + '_VisibleName] = max(case when opv.FCObjectPropertyID = ' + cast(p.ID as varchar(max)) + ' then ' + p.PropertyPredefinedValueTableAlias + '.VisibleName end)'
						else
							''
					end
				else
					''
			end
	,@sqlFrom = @sqlFrom + 
		case
			when p.PropertyPredefinedValueTableAlias is not null then
				@NewLine +
				case 
					when p.QueryToFillPredefinedValues is null then
						'	left join ' + @sqlInsiktRef + 'FCObjectPropertyPredefinedValue ' + p.PropertyPredefinedValueTableAlias + ' on' + @NewLine +
						'			' + p.PropertyPredefinedValueTableAlias + '.ID = opv.FCObjectPropertyPredefinedValueID and ' + p.PropertyPredefinedValueTableAlias + '.[FCObjectPropertyID] = opv.ID'
					when @IncludeVisibleNameLookup = 1 then
						'	left join' + @NewLine +
						'	(' + @NewLine +
								isnull(left(p.QueryToFillPredefinedValues, nullif(PATINDEX('%order by%', lower(p.QueryToFillPredefinedValues)) - 1, -1)), p.QueryToFillPredefinedValues) + @NewLine +
						'	) ' + p.PropertyPredefinedValueTableAlias + ' on' + @NewLine +
						'		' + p.PropertyPredefinedValueTableAlias + '.' + p.PropertyValueColumnName + ' = ' + 
							case 
								when p.isObjectID = 0 and p.isObjectCode = 0 and p.isObjectName = 0 and p.IsObjectParentID = 0 then
									'opv.' + p.PropertyValueColumnName
								else
									p.PropertyValueColumnExpression
							end
					else
						''
				end
			else
				''
		end
from
	FCObjectPropertyInfo p
where
	p.FCObjectTypeID = @FCObjectTypeID
select
	@sqlWhere = 
		'where' + @NewLine +
		'	o.FCObjectTypeID = ' + CAST(@FCObjectTypeID as varchar(12))
	declare @Header varchar(max)
	select @Header = 
		'--------------------------------------------------------------------------------------------------' + @NewLine +
		'-- AUTOMATICLY GENERATED VIEW' + @NewLine +
		'--------------------------------------------------------------------------------------------------' + @NewLine +
		'-- Generated by:	' + @sqlInsiktRef + coalesce(object_name(@@procid), '<unknown>') + @NewLine +
		'-- Generated at:	' + convert(varchar(20), getutcdate(), 120)+ @NewLine +
		'--------------------------------------------------------------------------------------------------' + @NewLine
	select
		@Header = @Header + 
			'-- ' + @NewLine +
			'--  FCObjectTypeView for ' + t.Name + ', FCObjectType = ' + cast(t.ID as varchar(12)) +  @NewLine +
			'-- ' + @NewLine
	from
		FCObjectType t
	where
		t.ID = @FCObjectTypeID
	select @Header = @Header +		
		'--------------------------------------------------------------------------------------------------'
select
	@sql = 
		@Header + @NewLine +
		@sqlCreateAlter + ' view [dbo].[' + @sqlViewName + '] as' + @NewLine +
		@sqlSelect + @NewLine +
		@sqlFrom + @NewLine +
		@sqlWhere + @NewLine +
        @sqlGroupBy
if @Debug = 1
	begin
		print @sql
		return
	end		
if @sqlCreateInDB <> ''
	select
		@sql = 
			@sqlCreateInDB +
			'exec' + @NewLine +
			'(' + @NewLine +
			'''' + replace(@sql, '''', '''''') + '''' + @NewLine +
			')'
exec(@sql)
print 'View ' + @CreateInDB + '[' + @sqlViewName + '] created/updated.'


GO
