SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[support_CopyPeriodicDistributionsToNewVersion] 
	@OldVersionKey int,
	@NewVersionKey int
	
AS
BEGIN
	
	SET NOCOUNT ON;
    
    BEGIN TRANSACTION

	-- Find all distributions connected to the old version.
	declare distCursor cursor fast_forward for
		select dist.ID, dim_version.DimensionName
		from FCElementPeriodicDistribution dist
			join FCElementPeriodicDistributionDimension dim_version
				on dim_version.PeriodicDistributionID = dist.ID
			join FCElementProperty ep_version
				on ep_version.PropertyID = 9
					and ep_version.FCTypeID = dist.FCTypeID
					and ep_version.CompanyID = dist.CompanyID
					and ep_version.ValueString = dim_version.DimensionName
	where dim_version.ElementKey = cast(@OldVersionKey as varchar)

	open distCursor

	declare @oldDistID int
	declare @oldDistVersionDimension nvarchar(50)
	fetch next from distCursor into @oldDistID, @oldDistVersionDimension

	while @@fetch_status = 0
	begin
		insert into FCElementPeriodicDistribution(
			CompanyID,
			PredefinedID,
			PredefinedRevisionID,
			PeriodPercent1,
			PeriodPercent2,
			PeriodPercent3,
			PeriodPercent4,
			PeriodPercent5,
			PeriodPercent6,
			PeriodPercent7,
			PeriodPercent8,
			PeriodPercent9,
			PeriodPercent10,
			PeriodPercent11,
			PeriodPercent12,
			ModifiedBy,
			ModifiedDate,
			FCTypeID,
			IsLocked
		)
		select
			CompanyID,
			PredefinedID,
			PredefinedRevisionID,
			PeriodPercent1,
			PeriodPercent2,
			PeriodPercent3,
			PeriodPercent4,
			PeriodPercent5,
			PeriodPercent6,
			PeriodPercent7,
			PeriodPercent8,
			PeriodPercent9,
			PeriodPercent10,
			PeriodPercent11,
			PeriodPercent12,
			ModifiedBy,
			getutcdate() as ModifiedDate,
			FCTypeID,
			IsLocked
		from FCElementPeriodicDistribution
		where ID = @oldDistID

		declare @newDistID int = SCOPE_IDENTITY()

		insert into FCElementPeriodicDistributionDimension(
			PeriodicDistributionID,
			DimensionName,
			ElementKey
		)
		select
			@newDistID,
			DimensionName,
			case
				when DimensionName = @oldDistVersionDimension then
					cast(@NewVersionKey as varchar)
				else
					ElementKey
			end
		from FCElementPeriodicDistributionDimension
		where PeriodicDistributionID = @oldDistID

		fetch next from distCursor into @oldDistID, @oldDistVersionDimension
	end

	close distCursor
	deallocate distCursor

	COMMIT TRANSACTION
    
END
GO
