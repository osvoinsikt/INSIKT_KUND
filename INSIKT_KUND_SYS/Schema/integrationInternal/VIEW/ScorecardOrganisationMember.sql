SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [integrationInternal].ScorecardOrganisationMember
as
select
	ElementKey
	,Name
	,ID
	,ParentMemberID
	,SortOrder
	,UniqueName
	,IsDeleted
from scorecard.OrganisationMember

GO
