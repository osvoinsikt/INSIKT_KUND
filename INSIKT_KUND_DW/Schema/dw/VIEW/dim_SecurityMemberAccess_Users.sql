SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dw].[dim_SecurityMemberAccess_Users] as
select
    UserName
    ,DisplayName = FullName
from
    [INSIKT_KUND_SYS].dbo.UserSecurityGroup
where
    UserTypeID not in
    (
        64 -- Security group
    )
GO
