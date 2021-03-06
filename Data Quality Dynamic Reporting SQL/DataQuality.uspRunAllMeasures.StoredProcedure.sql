USE [DataQuality_DynamicReporting]
GO
/****** Object:  StoredProcedure [DataQuality].[uspRunAllMeasures]    Script Date: 09/04/2019 10:41:48 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DataQuality].[uspRunAllMeasures]') AND type in (N'P', N'PC'))
DROP PROCEDURE [DataQuality].[uspRunAllMeasures]
GO
/****** Object:  StoredProcedure [DataQuality].[uspRunAllMeasures]    Script Date: 09/04/2019 10:41:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DataQuality].[uspRunAllMeasures]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [DataQuality].[uspRunAllMeasures] AS' 
END
GO

ALTER PROCEDURE [DataQuality].[uspRunAllMeasures] as

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
Description:				Loops through all measure stored procedures to update the data in the measure tables and then
							runs uspUpdateRelatedTables_AcrossMeasures to bulk update the linked IDs and DQ_DimensionGroups
							table for all measures at once 
**************************************************************************************************************************************************/

	DECLARE @TotalRecords INT
			,@CurrentRecord INT
			,@CurrentMeasureId VARCHAR(10)
			,@CurrentMeasureIdText VARCHAR(255)

	-- Create table of live measures ensuring that a procedure and view also exists for it
	SELECT		*
	INTO		#MeasuresWithProcedures
	FROM		DataQuality.vwMeasuresSQLComplete

	-- While loop updates all measures
	SELECT	@TotalRecords = (SELECT COUNT(*) from #MeasuresWithProcedures m);
	SELECT	@CurrentRecord = 1;
	SELECT	@CurrentMeasureId  =	(SELECT		DQ_MeasureId
									FROM		#MeasuresWithProcedures
									WHERE		[NewId] = @CurrentRecord)				
	SET		@CurrentMeasureIdText = RIGHT('000'+CAST(@CurrentMeasureId AS VARCHAR(3)),3)

			WHILE (@CurrentRecord <= @TotalRecords)
			BEGIN
			
				-- Update all measures
					DECLARE @SQLMeasure nVARCHAR(Max)
					SET @SQLMeasure = 'exec DataQualityMeasures.uspDQ_' + @CurrentMeasureIdText + ' 2,0,0,0,0'
					PRINT @SQLMeasure

					EXEC sp_executesql @SQLMeasure
				

				SELECT @CurrentRecord = @CurrentRecord + 1


				SELECT	@CurrentMeasureId  =	(SELECT		DQ_MeasureId
												FROM		#MeasuresWithProcedures
												WHERE		[NewId] = @CurrentRecord)
											
				SET		@CurrentMeasureIdText = RIGHT('000'+CAST(@CurrentMeasureId AS VARCHAR(3)),3)

			END;
		
		-- Run stored procedure to loop through all live measures to update the DQ_LinkedMeasure table
		EXEC DataQuality.uspUpdateRelatedTables_AcrossMeasures

GO
