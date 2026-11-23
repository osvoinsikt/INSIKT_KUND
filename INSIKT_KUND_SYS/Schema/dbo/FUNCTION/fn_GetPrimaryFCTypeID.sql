SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	Gets the primary FCTypeID in the FCTypeGroup that the given @fcTypeID belongs to. This might be
	@fcTypeID itself.
	
	If it it does not belong to a group, @fcTypeID is returned directly since it is its own primary.
	It means that this function works for both grouped and standalone FCTypes.
*/
create function dbo.fn_GetPrimaryFCTypeID
(
	@fcTypeID int
)
returns int
as
begin

	declare @primaryFCTypeID int = null

	select @primaryFCTypeID = primaryRel.FCTypeID
	from FCTypeGroupRelation thisRel
		join FCTypeGroupRelation primaryRel
			on primaryRel.GroupID = thisRel.GroupID
				and primaryRel.IsPrimary = 1
	where thisRel.FCTypeID = @fcTypeID

	if @primaryFCTypeID is null
	begin
		set @primaryFCTypeID = @fcTypeID
	end

	return @primaryFCTypeID

end
GO
