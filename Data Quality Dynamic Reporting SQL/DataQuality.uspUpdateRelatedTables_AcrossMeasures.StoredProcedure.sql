USE [DataQuality_DynamicReporting]
GO
/****** Object:  StoredProcedure [DataQuality].[uspUpdateRelatedTables_AcrossMeasures]    Script Date: 23/04/2020 19:47:02 ******/
IF OBJECT_ID('[DataQuality].[uspUpdateRelatedTables_AcrossMeasures]') IS NOT NULL
DROP PROCEDURE [DataQuality].[uspUpdateRelatedTables_AcrossMeasures]
GO
/****** Object:  StoredProcedure [DataQuality].[uspUpdateRelatedTables_AcrossMeasures]    Script Date: 23/04/2020 19:47:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [DataQuality].[uspUpdateRelatedTables_AcrossMeasures] (@DQ_Measure_ID INT = NULL) as

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
Description:				This procedure is to be run every time a batch of measures have been updated (including if just a single measure is 
							updated). It updates the DQ_LinkedMeasures field in every measures table and then updates the 
							InMeasureDimensionHistoryLastRun field in DQ_DimensionGroups (so that SSRS only presents options in the parameter
							dropdowns that are relevant to the dimensions in the measures data).
							Unlike uspUpdateRelatedTables_WithinMeasure, this SP requires all the other measure tables to have been
							updated before it can produce the correct output.
**************************************************************************************************************************************************/

DECLARE @TotalRecords INT
		,@CurrentRecord INT
		,@CurrentMeasureId VARCHAR(10)
		,@CurrentMeasureIdText VARCHAR(255)
		,@LinkedMeasureSQLUpdate nVarchar(Max)
		

/**************************************************************************************************************************************************
--	create a temp table of linked measures
**************************************************************************************************************************************************/

		-- Create a temp table with all the transitions from one identity type to another 
		-- (known because there are multiple records within the same measure ID and measure record id)
		SELECT		DISTINCT
					mi1.DQ_IdentityTypeId AS TypeFrom
					,mi1.IdentityType_RecordId AS RecFrom
					,mi2.DQ_IdentityTypeId AS TypeTo
					,mi2.IdentityType_RecordId AS RecTo
		INTO		#Transitions
		FROM		DataQuality.DQ_MeasureIdentities mi1
		INNER JOIN	DataQuality.DQ_MeasureIdentities mi2
						ON	mi1.DQ_MeasureId = mi2.DQ_MeasureId
						AND	mi1.DQ_MeasureRecordId = mi2.DQ_MeasureRecordId
						AND	mi1.DQ_IdentityTypeId != mi2.DQ_IdentityTypeId

		-- Create a temp table of all the relations between an original measure record and related measure 
		-- records, using the first iteration of the transitions between 1 record and the related records
		SELECT		mi1.DQ_MeasureId AS OriginalMeasureId
					,mi1.DQ_MeasureRecordId AS OriginalMeasureRecordId
					,mi2.DQ_MeasureId
					,mi2.DQ_MeasureRecordId
					,mi2.DQ_IdentityTypeId
					,mi2.IdentityType_RecordId
		INTO		#Relations
		FROM		DataQuality.DQ_MeasureIdentities mi1
		INNER JOIN	#Transitions T
						ON	mi1.DQ_IdentityTypeId = T.TypeFrom
						AND	mi1.IdentityType_RecordId = T.RecFrom
		INNER JOIN	DataQuality.DQ_MeasureIdentities mi2
						ON	T.TypeTo = mi2.DQ_IdentityTypeId
						AND	T.RecTo = mi2.IdentityType_RecordId
		WHERE NOT	(mi1.DQ_MeasureId = mi2.DQ_MeasureId				-- Don't join the record back to itself
		AND			mi1.DQ_MeasureRecordId = mi2.DQ_MeasureRecordId)	 -- Don't join the record back to itself
		--AND			mi1.DQ_MeasureId = 1 AND mi1.DQ_MeasureRecordId = 1

		DECLARE @UpdatedRecCount int
		SET @UpdatedRecCount = 1

		WHILE @UpdatedRecCount > 0
		BEGIN

				-- Create a list of relations that have already been found for each measure record
				SELECT		OriginalMeasureId
							,OriginalMeasureRecordId
							,DQ_MeasureId
				INTO		#RelationsToExclude
				FROM		#Relations
				GROUP BY	OriginalMeasureId
							,OriginalMeasureRecordId
							,DQ_MeasureId

				-- Insert any newly found relations between an original measure record and related measure 
				-- records, using the previously discovered related records and excluding any relations 
				-- that have already been found for the original measure record
				INSERT INTO	#Relations (OriginalMeasureId, OriginalMeasureRecordId, DQ_MeasureId, DQ_MeasureRecordId, DQ_IdentityTypeId, IdentityType_RecordId)
				SELECT		DISTINCT
							R.OriginalMeasureId
							,R.OriginalMeasureRecordId
							,mi2.DQ_MeasureId
							,mi2.DQ_MeasureRecordId
							,mi2.DQ_IdentityTypeId
							,mi2.IdentityType_RecordId
				FROM		#Relations R
				INNER JOIN	#Transitions T
								ON	R.DQ_IdentityTypeId = T.TypeFrom
								AND	R.IdentityType_RecordId = T.RecFrom
				INNER JOIN	DataQuality.DQ_MeasureIdentities mi2
								ON	T.RecTo = mi2.IdentityType_RecordId
								AND	T.TypeTo = mi2.DQ_IdentityTypeId
				LEFT JOIN	#RelationsToExclude RTE
								ON	R.OriginalMeasureId = RTE.OriginalMeasureId
								AND	R.OriginalMeasureRecordId = RTE.OriginalMeasureRecordId
								AND	mi2.DQ_MeasureId = RTE.DQ_MeasureId
				WHERE		RTE.OriginalMeasureId IS NULL						-- exclude any relations already found
				AND	NOT		(R.OriginalMeasureId = mi2.DQ_MeasureId				-- Don't join the record back to itself
				AND			R.OriginalMeasureRecordId = mi2.DQ_MeasureRecordId)	-- Don't join the record back to itself

				-- Keep a record of how many records were updated on this iteration (eventually there will be no further relations to be found)
				SET @UpdatedRecCount = @@ROWCOUNT

				-- Clear up the temporary exclusion tables ready for the next iteration
				DROP TABLE #RelationsToExclude

		END

		-- Create the temp table of linked measures
		SELECT		OriginalMeasureId
					,OriginalMeasureRecordId
					,STUFF
							(
								(
								SELECT		',' + CAST(DQ_MeasureId as varchar(255))
								FROM		#Relations R_xml
								WHERE		R_xml.OriginalMeasureId = R.OriginalMeasureId
								AND			R_xml.OriginalMeasureRecordId = R.OriginalMeasureRecordId
								GROUP BY	DQ_MeasureId
								ORDER BY	DQ_MeasureId
								FOR XML PATH('')
								), 1, 1, ''
							) AS DQ_LinkedMeasures
		INTO		#LinkedMeasures
		FROM		#Relations R
		WHERE		OriginalMeasureId != DQ_MeasureId -- Don't declare a measure linking to itself!
		GROUP BY	OriginalMeasureId
					,OriginalMeasureRecordId



/**************************************************************************************************************************************************
--	update the DQ_LinkedMeasures field in every measures table
**************************************************************************************************************************************************/

-- Create table of live measure(s).  If @DQ_Measure_ID = 0, then all live measures otherwise DQ_Measure_ID
SELECT		*
INTO		#MeasuresWithProcedures
FROM		DataQuality.vwMeasuresSQLComplete
WHERE		DQ_MeasureId = CASE WHEN ISNULL(@DQ_Measure_ID,0) = 0 THEN DQ_MeasureId ELSE @DQ_Measure_ID END

-- Set variables for While statement
SELECT	@TotalRecords = (SELECT COUNT(*) from #MeasuresWithProcedures m);
SELECT	@CurrentRecord = 1;
SELECT	@CurrentMeasureId  =	(SELECT		DQ_MeasureId
								FROM		#MeasuresWithProcedures
								WHERE		[NewId] = @CurrentRecord
								)	
SET		@CurrentMeasureIdText = RIGHT('000'+CAST(@CurrentMeasureId AS VARCHAR(3)),3)

		WHILE (@CurrentRecord <= @TotalRecords)
		BEGIN

			-- Loop through and update all DQ_LinkedMeasures
					-- Update relevant DQ_Measure table with DQ_LinkedMeasures values
					SET  @LinkedMeasureSQLUpdate = NULL
					SET  @LinkedMeasureSQLUpdate = 'UPDATE		DQ
													SET			DQ_LinkedMeasures = lm.DQ_LinkedMeasures
													FROM		DataQualityMeasures.DQ_' + @CurrentMeasureIdText + ' dq
													LEFT JOIN	#LinkedMeasures lm
																	ON	dq.DQ_MeasureRecordId = lm.OriginalMeasureRecordId 
																	AND	lm.OriginalMeasureId = ' + @CurrentMeasureIdText

					PRINT @LinkedMeasureSQLUpdate
					EXEC sp_executesql @LinkedMeasureSQLUpdate

			SELECT @CurrentRecord = @CurrentRecord + 1
			SELECT	@CurrentMeasureId  =	(SELECT		DQ_MeasureId
								FROM		#MeasuresWithProcedures
								WHERE		[NewId] = @CurrentRecord)								
			SET		@CurrentMeasureIdText = RIGHT('000'+CAST(@CurrentMeasureId AS VARCHAR(3)),3)
		END;


/**************************************************************************************************************************************************
--	update the InMeasureDimensionHistoryLastRun field in DQ_DimensionGroups (so that SSRS only presents options in the parameter dropdowns that are 
--	relevant to the dimensions in the measures data)
**************************************************************************************************************************************************/

		-- Update dimension groups table where active (as per the LastRun field in MeasureDimensionHistory)
		UPDATE		dg
		SET			InMeasureDimensionHistoryLastRun = CASE WHEN mdh.DQ_DimensionGroupId IS NOT NULL THEN 1 ELSE 0 END
		FROM		DataQuality.DQ_DimensionGroups dg
		LEFT JOIN	DataQuality.DQ_MeasureDimensionHistory mdh
						on dg.DQ_DimensionGroupId = mdh.DQ_DimensionGroupId
						AND mdh.LastRun = 1
GO
