USE [DataQuality_DynamicReporting]
GO
/****** Object:  StoredProcedure [DataQualityMeasures].[uspDQ_xxx (template measure SP)]    Script Date: 09/04/2019 10:41:48 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DataQualityMeasures].[uspDQ_xxx (template measure SP)]') AND type in (N'P', N'PC'))
DROP PROCEDURE [DataQualityMeasures].[uspDQ_xxx (template measure SP)]
GO
/****** Object:  StoredProcedure [DataQualityMeasures].[uspDQ_xxx (template measure SP)]    Script Date: 09/04/2019 10:41:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DataQualityMeasures].[uspDQ_xxx (template measure SP)]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [DataQualityMeasures].[uspDQ_xxx (template measure SP)] AS' 
END
GO

ALTER PROCEDURE [DataQualityMeasures].[uspDQ_xxx (template measure SP)] @UpdateDQ int = null, @ReturnDataSet INT = NULL, @DimensionGroupIds Varchar(3000) = Null, @IdentityId Varchar(255), @IdentityTypeId INT  --, @IdentityTypeId INT = NULL, @Identity INT= NULL 
AS

/************************************************************ !!! READ ME !!! ********************************************************************
Stored procedure naming convention:
	The automated management and reporting of DQ measures in SSRS requires that all measure stored procedures have the same name (uspDQ_)  
	followed by their measure number, left padded with zeros (e.g. uspDQ_001). It is expected that these stored procedures will all exist within the 
	DataQualityMeasures schema.
	A template stored procedure, uspDQ_xxx (template measure SP), has been created to simplify the creation of new measures

Corresponding DQ data table:
	Each DQ measure SP needs a corresponding DQ table to insert records into. Again, the automated management and reporting of DQ measures in SSRS 
	requires that all measure tables have the same name (DQ_) followed by their measure number, left padded with zeros (e.g. DQ_001).
	It is expected that these tables will all exist within the DataQualityMeasures schema.
	A template table, DQ_xxx (template measure table), has been created to simplify the creation of new measures

Corresponding DQ data view:
	Each DQ measure SQ needs a corresponding DQ view to retrieve results from. This view is different from the DQ data table in that all the columns
	are converted to text, formatted as we want them presented in SSRS. This is important to do before it gets to SSRS so that the column widths can
	be calculated (in uspUpdateRelatedTables_WithinMeasure) and used to determine the which of the multi-width columns to use in SSRS.
	Again, the automated management and reporting of DQ measures in SSRS requires that all measure views have the same name (DQ_vwSSRS_) followed by  
	their measure number, left padded with zeros (e.g. DQ_vwSSRS_001).
	It is expected that these views will all exist within the DataQualityMeasures schema.
	A template view, DQ_vsSSRS_xxx (template measure view), has been created to simplify the creation of new measures

@UpdateDQ parameter instructions:
	@UpdateDQ = Null	- don't update the data
	@UpdateDQ = 1		- single measure update (update measure,dimension groups/history, LINKED IDS and Measure Dimension History Last Run)
	@updateDQ = 2		- as a part of the bulk update (update measure,dimension groups/history only - LINKED IDS and Measure Dimension History Last Run 
						  details are processed in the bulk procedure)

@ReturnDataSet parameter instructions:
	@ReturnDataSet = Null	- don't return any data
	@ReturnDataSet = 1		- SSRS report data
	@ReturnDataSet = 2		- SSRS report field names / widths

**************************************************************************************************************************************************/

/******************************************************** © Copyright & Licensing ****************************************************************
© 2018 Perspicacity Ltd

This code / file is part of Perspicacity's DataQualityReporting suite.

Perspicacity's DataQualityReporting suite is free software: you can 
redistribute it and/or modify it under the terms of the GNU Affero 
General Public License as published by the Free Software Foundation, 
either version 3 of the License, or (at your option) any later version.

Perspicacity's DataQualityReporting suite is distributed in the hope 
that it will be useful, but WITHOUT ANY WARRANTY; without even the 
implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.

A full copy of this code can be found at https://github.com/perspicacity-ltd/DataQualityReporting

You may also be interested in the other repositories at https://github.com/perspicacity-ltd

Original Work Created Date:	30/03/2018
Original Work Created By:	Perspicacity Ltd (Kelly Roberts & Matthew Bishop)
Original Work Contact:		07545 878906
Original Work Contact:		matthew.bishop@perspicacityltd.co.uk
Description:				A template stored procedure to use as a starting point to create 
							new DQ measures in Perspicacity's DataQualityReporting suite
**************************************************************************************************************************************************/

/******************************************************** Meaasure Details ****************************************************************
Measure Created Date:	<Enter measure creation date>
Measure Created By:		<Enter name of developer>
Description:			<Enter description here>
**************************************************************************************************************************************************/

DECLARE @MyProcedureName VARCHAR(255) = object_name(@@PROCID)
		,@MyMeasureNumber INT 
		,@UpdateDate datetime
SET		@MyMeasureNumber = (select CAST(dataQuality.fnMeasureNumber (@MyProcedureName, 'Measure Number') as INT))
SET		@UpdateDate = GETDATE()
	
	-- Update data (as part of single measure or bulk update)
	IF @UpdateDQ >=1
	BEGIN
		-- Clear the UpdatedDate for all unresolved records
		UPDATE		DataQualityMeasures.DQ_001
		SET			UpdatedDate = CAST(NULL AS datetime)
		WHERE		ResolvedDate IS NULL
		
		-- Insert the new persisted data in the associated measures table
		INSERT INTO DataQualityMeasures.[DQ_xxx (template measure table)]
					([DQ_MeasureId]
					,[Confidence]
					,[CreatedDate]
					,[UpdatedDate]
					,[PrimaryIdentityTypeId]
					,[PrimaryIdentityType_RecordId]
					,[<Enter Measure Fields Herein>])
		SELECT		[DQ_MeasureId] = @MyMeasureNumber				-- this should always be @yMeasureNumber
					,[Confidence] = 0								-- this will often be 0, but can also be calculated using an algorithm where there is a quantifiable degree of confidence in the data. Records should never have a confidence of 1 (we are totally confident in the record)
					,[CreatedDate] = @UpdateDate					-- this should always be GETDATE()
					,[UpdatedDate] = @UpdateDate					-- this should always be GETDATE()
					,PrimaryIdentityTypeId = 1						-- this should be the identity type id of the main identity for the record
					,PrimaryIdentityType_RecordId = DummyRecordId	-- this should be the main identity for the record and will be populated from the source data (e.g. for a personnel record, we might have the ESR ID and their National Insurance number. Both are unique ID's, but the ESR ID is the main identity for personnel)
					,[<Enter Measure Fields Herein>] = ''			-- the remainder of the select statement will populate fields that are specific to this DQ measure
		FROM		(SELECT 'X' AS DummyRecordId) A
		LEFT JOIN	DataQualityMeasures.[DQ_xxx (template measure table)] DQ
						ON	A.DummyRecordId = DQ.DQ_MeasureRecordId
						AND	DQ.ResolvedDate IS NULL
		WHERE		DQ.DQ_MeasureRecordId IS NULL

		-- Update the existing persisted data in the associated measures table
		UPDATE		DQ
		SET			[Confidence] = 0								-- this will often be 0, but can also be calculated using an algorithm where there is a quantifiable degree of confidence in the data. Records should never have a confidence of 1 (we are totally confident in the record)
					,[UpdatedDate] = @UpdateDate					-- this should always be GETDATE()
					,[<Enter Measure Fields Herein>] = ''			-- the remainder of the select statement will populate fields that are specific to this DQ measure
		FROM		(SELECT 'X' AS DummyRecordId) A
		INNER JOIN	DataQualityMeasures.[DQ_xxx (template measure table)] DQ
						ON	A.DummyRecordId = DQ.DQ_MeasureRecordId
						AND	DQ.ResolvedDate IS NULL

		-- Mark any remaining unresolved records that haven't been updated as resolved
		UPDATE		DataQualityMeasures.[DQ_xxx (template measure table)]
		SET			UpdatedDate = @UpdateDate
					,ResolvedDate = @UpdateDate
		WHERE		UpdatedDate IS NULL
		AND			ResolvedDate IS NULL
		

		-- Insert Measure Identities into DQ_MeasureIdentities table
		-- If the record has multiple related identifiers (e.g. where a personnel record has an ESR ID and a National Insurance number), there will be multiple statements here
		DELETE FROM dataQuality.DQ_MeasureIdentities WHERE [DQ_MeasureId] = @MyMeasureNumber

		INSERT INTO	dataQuality.DQ_MeasureIdentities ([DQ_MeasureId], [DQ_IdentityTypeId],[IdentityType_RecordId],[DQ_MeasureRecordId],[Updated])
		SELECT		@MyMeasureNumber
					,1
					,[<Enter Measure Fields Herein>]
					,[DQ_MeasureRecordId]
					,@UpdateDate
		FROM		DataQualityMeasures.[DQ_xxx (template measure table)]
		WHERE		ResolvedDate IS NULL

		-- Update the dimension group combinations in the DQ_DimensionGroups table and append if missing, update the dimension group ids back to the measure table,
		-- update the DQ_MeasureDimensionHistory table with the latest row counts from the measure table and update the DQ_MeasureFields table for the data in the
		-- measures table
		EXEC DataQuality.uspUpdateRelatedTables_WithinMeasure @MyMeasureNumber

	END

		
	-- Update the linked DQ measure IDs and the InMeasureDimensionHistoryLastRun field in DQ_DimensionGroups if updating a single measure
	IF @UpdateDQ = 1
	BEGIN
		-- update linked DQ Measure Ids and the InMeasureDimensionHistoryLastRun field in DQ_DimensionGroups
		EXEC DataQuality.uspUpdateRelatedTables_AcrossMeasures @MyMeasureNumber
	END


	-- Returns the data from the Measures table with generic names 
	IF @ReturnDataSet = 1
		BEGIN
			-- Return the data for this measure from the associated measure table
			EXEC DataQuality.uspRetrieveDataForMeasureSP @MyMeasureNumber, @DimensionGroupIds, @Identityid, @IdentityTypeId --1, 0, 34254, 1
		END

	-- Returns the field names and widths from MeasureFields table if @ReturnDataSet = 2
	IF @ReturnDataSet = 2
		BEGIN
			SELECT		*, WidthDescription = dataQuality.fnFieldWidths (MaxWidth)
			FROM		DataQuality.DQ_MeasureFields
			WHERE		DQ_MeasureId = @MyMeasureNumber
		END	


GO
