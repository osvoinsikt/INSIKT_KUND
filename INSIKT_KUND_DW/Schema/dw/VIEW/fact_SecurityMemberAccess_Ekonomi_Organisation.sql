SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dw].[fact_SecurityMemberAccess_Ekonomi_Organisation] as 
with Map as 
( 
    select distinct 
        ID = L0_ID 
        ,Leaf = Organisation_LeafID 
    from 
        dw.dim_Organisation 
    union select distinct 
        ID = L1_ID 
        ,Leaf = Organisation_LeafID 
    from 
        dw.dim_Organisation 
    union select distinct 
        ID = L2_ID 
        ,Leaf = Organisation_LeafID 
    from 
        dw.dim_Organisation 
    union select distinct 
        ID = L3_ID 
        ,Leaf = Organisation_LeafID 
    from 
        dw.dim_Organisation 
    union select distinct 
        ID = L4_ID 
        ,Leaf = Organisation_LeafID 
    from 
        dw.dim_Organisation 
) 
select 
    u.UserName 
    ,Organisation_LeafID = m.Leaf 
	,HasOrgAccess = 1
from 
    [INSIKT_KUND_SYS].dbo.UserOrganisationRelation rel 
        inner join [INSIKT_KUND_SYS].dbo.UserSecurityGroup u on 
            u.UserID = rel.UserID 
        inner join Map m on 
            m.ID = rel.FCElementKey 
            or rel.FCElementKey = '0' 
where 
    rel.FCTypeID = 1 
    and isnull(u.isDeleted,0) <> 1
GO
