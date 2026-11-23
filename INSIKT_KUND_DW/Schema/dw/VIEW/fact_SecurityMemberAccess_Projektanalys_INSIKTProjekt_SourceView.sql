SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	Vy för att hantera behörighetsstyrning i projektanalysen.
	Vyn tar ut behörigheter baserat på TaskID = 10 (Show all projects), 
	kopplingar i projektkorten och koppla användare och organisation
*/

create view [dw].[fact_SecurityMemberAccess_Projektanalys_INSIKTProjekt_SourceView] as 
with 
AdminSecurityGroupID as 
(
    select SecurityGroupID = usg.UserID
    from INSIKT_KUND_SYS.dbo.UserSecurityGroup usg
        inner join INSIKT_KUND_SYS.dbo.UserSecurityGroupRoleRelation usgrRel on 
            usgrRel.UserID = usg.UserID
        inner join INSIKT_KUND_SYS.dbo.Role r on
            r.ID = usgrRel.RoleID
    where
        usg.UserTypeID = 64 -- AD-grupp
        and (r.Name = 'System_Admin') -- Admin-roll
),
UsersWithShowAllFCProjects as
(
	--Manuella användare
    select distinct
        [UserID] = usg.[UserID]
        ,[UserName] = usg.[UserName]
    from INSIKT_KUND_SYS.[dbo].[UserSecurityGroupRoleRelation] usgrRel
        inner join INSIKT_KUND_SYS.[dbo].[RoleTaskRelation] rtRel on 
            rtRel.[RoleID] = usgrRel.[RoleID]
        inner join INSIKT_KUND_SYS.[dbo].[UserSecurityGroup] usg on 
            usg.[UserID] = usgrRel.[UserID]
        inner join INSIKT_KUND_SYS.[dbo].[UserSecurityGroupRelation] usgRel on 
            usgRel.[UserID] = usg.[UserID]
        left join AdminSecurityGroupID adminSG on 
            adminSG.SecurityGroupID = usgRel.[SecurityGroupID]
    where
        rtRel.[TaskID] = 10
        and adminSG.SecurityGroupID is null
        -- and usgRel.[SecurityGroupID] <> --Lägg in rätt Admin-säkerhetsgruppen här


    union
    
	--Fullt synkroniserad baserat på säkerhetsgrupp
    select distinct
        [UserID] = usg.[UserID]
        ,[UserName] = usg.[UserName]
    from INSIKT_KUND_SYS.[dbo].[UserSecurityGroupRoleRelation] usgrRel
        inner join INSIKT_KUND_SYS.[dbo].[RoleTaskRelation] rtRel on 
            rtRel.[RoleID] = usgrRel.[RoleID]
        inner join INSIKT_KUND_SYS.[dbo].[UserSecurityGroupRelation] usgRel on 
            usgRel.[SecurityGroupID] = usgrRel.[UserID]
        inner join INSIKT_KUND_SYS.[dbo].[UserSecurityGroup] usg on 
            usg.[UserID] = usgRel.[UserID]
        left join AdminSecurityGroupID adminSG on 
            adminSG.SecurityGroupID = usgRel.[SecurityGroupID]
    where
        rtRel.[TaskID] = 10
        and adminSG.SecurityGroupID is null
        -- and usgRel.[SecurityGroupID] <> --Lägg in rätt Admin-säkerhetsgruppen här

)
--TaskID = 10 (Show all projects)
select
    [UserID] = showAllFCProjects.[UserID]
    ,[UserName] = showAllFCProjects.[UserName]
    ,[FCProjectID] = fcp.[FCProjectID]
    ,[HasINSIKTProjektAccess] = 1
from [dw].[base_FCProject] fcp
    cross join UsersWithShowAllFCProjects showAllFCProjects
where
    ISNULL(fcp.[IsDeleted], 0) = 0

union

--Kopplingar i projektkort
select distinct
    [UserID] = usg.[UserID]
    ,[UserName] = usg.[UserName]
    ,[FCProjectID] = fcp.[FCProjectID]
    ,[HasINSIKTProjektAccess] = 1
from INSIKT_KUND_SYS.[dbo].[FCProjectPropertyValue] fcpv
    inner join [dw].[base_FCProject] fcp on 
        fcp.[FCProjectID] = fcpv.[ProjectID]
    inner join INSIKT_KUND_SYS.[dbo].[FCProjectProperty] fcpp on 
        fcpp.[ID] = fcpv.[ProjectPropertyID]
    inner join INSIKT_KUND_SYS.[dbo].[UserSecurityGroup] usg on 
            usg.[UserID] = fcpv.[ValueNumeric] 
    inner join INSIKT_KUND_SYS.[dbo].[UserSecurityGroupRelation] usgRel on 
            usgRel.[UserID] = usg.[UserID] 
    left join AdminSecurityGroupID adminSG on 
        adminSG.SecurityGroupID = usgRel.[SecurityGroupID]
where
    fcpp.[isUser] = 1
    and usg.[SuperAdmin] is null
    and adminSG.SecurityGroupID is null
    -- and usgRel.[SecurityGroupID] <> --Lägg in rätt Admin-säkerhetsgruppen här
    and ISNULL(fcp.[IsDeleted], 0) = 0

union 

--Koppla användare och organisation
select distinct
    [UserID] = usg.[UserID]
	,[UserName] = usg.[UserName]
    ,[FCProjectID] = fcp.[FCProjectID]
    ,[HasINSIKTProjektAccess] = 1
from INSIKT_KUND_SYS.[dbo].[FCProjectUserRelation] usgRel
	inner join INSIKT_KUND_SYS.[dbo].[UserSecurityGroup] usg on 
		usg.[UserID] = usgRel.[UserID]
	left join INSIKT_KUND_SYS.[dbo].[FCProjectPropertyValue] fpv on 
		fpv.[ProjectPropertyID] = usgRel.[FCProjectPropertyID]
		and 
        (
            fpv.[FCProjectPropertyPredefinedValueID] = usgRel.[FCProjectPropertyPredefinedValueID]
            or fpv.[ValueNumeric] = usgRel.[ValueNumeric]
            or fpv.[ValueString] = usgRel.[ValueString]
        )
	inner join [dw].[base_FCProject] fcp on 
		fcp.[FCProjectID] = ISNULL(fpv.[ProjectID], usgRel.[FCProjectID])
		or usgRel.[AllProjects] = 1

GO
