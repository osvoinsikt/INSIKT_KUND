SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[support_CopyPeriodicDistributionsToNewVersionFcType] 
           @OldVersionKey int,
           @NewVersionKey int,
           @FCType int,
           @FCProcessKey int = NULL
           
AS
BEGIN
           
	SET NOCOUNT ON;
    
	BEGIN TRANSACTION

	declare @versionDimensionName nvarchar(50) = (
		select top 1 ValueString
		from FCElementProperty
		where FCTypeID = @FCType and PropertyID = 9
	)

	-- Find all distributions connected to the old version and optionally the FCProcessKey.
	declare distCursor cursor fast_forward for
		select dist.ID
		from FCElementPeriodicDistribution dist
			join FCElementPeriodicDistributionDimension dim_version
				on dim_version.PeriodicDistributionID = dist.ID
			join FCElementProperty ep_version
				on ep_version.PropertyID = 9
					and ep_version.FCTypeID = dist.FCTypeID
					and ep_version.CompanyID = dist.CompanyID
					and ep_version.ValueString = dim_version.DimensionName
			join FCElementPeriodicDistributionDimension dim_org
				on dim_org.PeriodicDistributionID = dist.ID
			join FCElementProperty ep_org
				on ep_org.PropertyID = 8
					and ep_org.FCTypeID = dist.FCTypeID
					and ep_org.CompanyID = dist.CompanyID
					and ep_org.ValueString = dim_org.DimensionName
	where dist.FCTypeID = @FCType
		and dim_version.ElementKey = cast(@OldVersionKey as varchar)
		and (@FCProcessKey is null or dim_org.ElementKey = cast(@FCProcessKey as varchar))

	open distCursor

	declare @oldDistID int
	fetch next from distCursor into @oldDistID

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
				when DimensionName = @versionDimensionName then
					cast(@NewVersionKey as varchar)
				else
					ElementKey
			end
		from FCElementPeriodicDistributionDimension
		where PeriodicDistributionID = @oldDistID

		fetch next from distCursor into @oldDistID
	end

	close distCursor
	deallocate distCursor

	COMMIT TRANSACTION
    
END
GO
