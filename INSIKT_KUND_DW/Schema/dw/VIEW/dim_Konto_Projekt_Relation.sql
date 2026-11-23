SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [dw].[dim_Konto_Projekt_Relation] as
select 
    [KontoID] = k.KontoID
from dw.base_Konto k

GO
