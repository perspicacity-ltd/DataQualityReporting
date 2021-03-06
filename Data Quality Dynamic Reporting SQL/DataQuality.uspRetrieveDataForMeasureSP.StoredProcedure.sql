USE [DataQuality_DynamicReporting]
GO
/****** Object:  StoredProcedure [DataQuality].[uspRetrieveDataForMeasureSP]    Script Date: 09/04/2019 10:41:48 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DataQuality].[uspRetrieveDataForMeasureSP]') AND type in (N'P', N'PC'))
DROP PROCEDURE [DataQuality].[uspRetrieveDataForMeasureSP]
GO
/****** Object:  StoredProcedure [DataQuality].[uspRetrieveDataForMeasureSP]    Script Date: 09/04/2019 10:41:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DataQuality].[uspRetrieveDataForMeasureSP]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [DataQuality].[uspRetrieveDataForMeasureSP] AS' 
END
GO


ALTER PROCEDURE [DataQuality].[uspRetrieveDataForMeasureSP] (@MyMeasureNumber INT, @DimensionGroupIds Varchar(3000), @IdentityId Varchar(255), @IdentityTypeId INT)
AS

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
Description:				Returns the data from the DQ measure view for a particular measure ID and restricts the output to just those
							records which are associated with the DimensionGroupIds and the IdentityId (IdentityType_RecordId) which is 
							passed to the procedure
**************************************************************************************************************************************************/

BEGIN

			-- Declare the variables for the procedure
			DECLARE		@DynamicSQL nVARCHAR(MAX)
						,@SQL nVarchar(Max)
						,@MyMeasureNumberText VARCHAR(255) = RIGHT('000'+CAST(@MyMeasureNumber AS VARCHAR(3)),3)
						,@GenericFieldCount int = 20 -- Use this to control the maximum number of generic fields there are in the output dataset

/**************************************************************************************************************************************************
--	Parse the @DimensionGroupIds parameter (which is passed as a comma delimited string) into a table of DQ_DimensionGroupId values and the
--	IdentityId (IdentityType_RecordId) / IdentityTypeId into a table of Measures and MeasureRecordIds associated with that IdentityId
**************************************************************************************************************************************************/

			-- Create a temp table of the dimension groups selected from parameters in SSRS report
			CREATE TABLE #DimensionGroups (DimensionGroupId Varchar(255))

				BEGIN
				IF @DimensionGroupIds is not null

				DECLARE @XML_DimensionGroupId as XML
				SET @XML_DimensionGroupId = CAST(('<a>'+replace(@DimensionGroupIds,',' ,'</a><a>') +'</a>') AS XML)
						INSERT INTO #DimensionGroups (DimensionGroupId)
						SELECT		DISTINCT CAST(rtrim(ltrim(T.C.value('.', 'NVARCHAR(100)'))) as int) as DimensionGroupId
						FROM		@XML_DimensionGroupId.nodes('a') as T(C)
				END

			-- Create table to hold DQ_MeasureRecordId when identities/identity type variables passed for drilling into single record
			If @IdentityTypeId <> 0
				BEGIN			
					CREATE TABLE #DQ_MeasureRecordId (DQ_MeasureRecordId int)
					INSERT INTO #DQ_MeasureRecordId (DQ_MeasureRecordId)
					SELECT		distinct DQ_MeasureRecordId
					FROM		DataQuality.fnIdentityMeasures(@IdentityTypeId,@IdentityId)
					WHERE		DQ_MeasureId = @MyMeasureNumber
				END

/**************************************************************************************************************************************************
--	Build the SQL statement with the relevant fields (and mapped field names for SSRS) from the DQ measure view for @MyMeasureNumber 
**************************************************************************************************************************************************/

			-- Build the first dynamic SQL statement (@DynamicSQL) that will look at the view schema for @MyMeasureNumber and the fields for @MyMeasureNumber in DQ_MeasureFields
			-- to create the second SQL statement (@SQL) with generic field names. This second SQL statment (@SQL) can be executed to return the data from the view for 
			-- @MyMeasureNumber, but with the original field names having been mapped to the generic field names assigned in DQ_MeasureFields
			SET			@DynamicSQL = 
						-- Generate a temp table to represent all the potential generic fields
						'IF object_id(''tempdb..#GenericFields'') IS NOT NULL DROP TABLE #GenericFields

						;WITH GenericFieldsCTE AS	(
													SELECT	1 AS GenericFieldSortOrder
													UNION ALL
													SELECT	GenericFieldSortOrder + 1 AS GenericFieldSortOrder
													FROM	GenericFieldsCTE
													WHERE	GenericFieldSortOrder < ' + CAST(@GenericFieldCount AS NVARCHAR(MAX)) + ' 
													)
						SELECT		CAST(''Field'' + CAST(GenericFieldSortOrder AS VARCHAR(255)) AS VARCHAR(255)) AS name
									,CAST(NULL AS INT) AS column_id
									,GenericFieldSortOrder 
						INTO		#GenericFields 
						FROM		GenericFieldsCTE ' + 
						
						-- Return the field names required for the select statement
						'SELECT		Distinct ''SELECT '' + 
									STUFF ' + --remove the leading comma from the FOR_XML generated select field list
						'			(
										(
										SELECT		'','' + SelectFieldNames' + CHAR(10) + -- select all the field names from the subquery (alias name fl) and use the FOR_XML PATH statement to concatencate the multiple rows up onto a single row
						'				FROM		(SELECT		SelectFieldNames = CASE WHEN tt.column_id IS NULL THEN ''CAST(NULL AS VARCHAR(255))'' ELSE ''ssrs.[''+tt.name+'']'' END + 
																'' AS '' + ISNULL(mf.GenericFieldName,tt.name) ' + CHAR(10) + -- pull all the field names from the associated SSRS view for this DQ measure, left join it to DQ_MeasureFields to see if the field name has a generic field name, and present the generic field name if it has one
						'										,TempFieldColumnId = tt.column_id
																,GenericFieldSortOrder = tt.GenericFieldSortOrder
													FROM		(SELECT		CAST(NULL AS int) AS GenericFieldSortOrder, column_id, name
																FROM		sys.columns t 
																WHERE		t.object_id = object_id(''DataQualityMeasures.DQ_vwSSRS_' + @MyMeasureNumberText + ''')
																UNION
																SELECT		gf.GenericFieldSortOrder, gf.column_id, gf.name
																FROM		#GenericFields gf
																LEFT JOIN	DataQuality.DQ_MeasureFields mf 
																				ON	gf.GenericFieldSortOrder = mf.SortOrder
																				AND	mf.DQ_MeasureId = ' + @MyMeasureNumberText + '
																WHERE		mf.DQ_MeasureId IS NULL
																) tt
													LEFT JOIN	DataQuality.DQ_MeasureFields mf 
																	ON tt.name = mf.FieldName
																	AND mf.DQ_MeasureId = ' + @MyMeasureNumberText + '
													) fl
										ORDER BY	GenericFieldSortOrder, TempFieldColumnId
										FOR XML PATH('''')
										), 1, 1, ''''
									) +
									'' FROM DataQualityMeasures.DQ_vwSSRS_' + @MyMeasureNumberText + ' ssrs'' AS FieldName
						FROM		(SELECT		SelectFieldNames = CASE WHEN tt.column_id IS NULL THEN ''CAST(NULL AS VARCHAR(255))'' ELSE ''ssrs.[''+tt.name+'']'' END + 
												'' AS '' + ISNULL(mf.GenericFieldName,tt.name) ' + -- pull all the field names from the associated SSRS view for this DQ measure, left join it to DQ_MeasureFields to see if the field name has a generic field name, and present the generic field name if it has one
		'										,TempFieldColumnId = tt.column_id
												,GenericFieldSortOrder = tt.GenericFieldSortOrder
									FROM		(SELECT		CAST(NULL AS int) AS GenericFieldSortOrder, column_id, name
												FROM		sys.columns t 
												WHERE		t.object_id = object_id(''DataQualityMeasures.DQ_vwSSRS_' + @MyMeasureNumberText + ''')
												UNION
												SELECT		gf.GenericFieldSortOrder, gf.column_id, gf.name
												FROM		#GenericFields gf
												LEFT JOIN	DataQuality.DQ_MeasureFields mf 
																ON	gf.GenericFieldSortOrder = mf.SortOrder
																AND	mf.DQ_MeasureId = ' + @MyMeasureNumberText + '
												WHERE		mf.DQ_MeasureId IS NULL
												) tt
									LEFT JOIN	DataQuality.DQ_MeasureFields mf 
													ON tt.name = mf.FieldName
													AND mf.DQ_MeasureId = ' + @MyMeasureNumberText + '
									) fl'

						

			-- Print @DynamicSQL for debugging purposes
			PRINT '-- Executing First (dynamic) SQL statement:' + CHAR(10)
			PRINT @DynamicSQL
			PRINT CHAR(10)

			-- Create temporary table to store the second SQL statement (@SQL) created by executing the first @DynamicSQL statement 
			If object_id ('tempdb.dbo.#Output','U') is not null drop table #Output
			CREATE TABLE #Output (FieldOutput varchar(max))

			-- Execute the first @DynamicSQL statement that creates the second SQL statement (the one that returns the data from the 
			-- view for @MyMeasureNumber, but with the original field names having been mapped to the generic field names assigned in DQ_MeasureFields) 
			-- Insert the resulting output into the #Output table
			INSERT INTO #Output
			EXEC sp_executesql @DynamicSQL


			-- Retrieve the second SQL statement (@SQL) from the #Output table
			SET @SQL = (SELECT			FieldOutput
										+ 
										CASE WHEN @DimensionGroupIds <> '0' THEN
										' 
										JOIN			#DimensionGroups dg
															ON	CAST(SSRS.DQ_DimensionGroupId as int) = dg.DimensionGroupId COLLATE Latin1_General_CI_AS
										' ELSE '' END
										+
										CASE WHEN @IdentityTypeId <> 0 THEN
										' 
										JOIN			#DQ_MeasureRecordId mri
															ON	SSRS.DQ_MeasureRecordId = mri.DQ_MeasureRecordId -- COLLATE Latin1_General_CI_AS
										' ELSE '' END
						FROM			#Output)

			
			PRINT '-- Executing Second SQL statement (with generic field names mapped):' + CHAR(10)
			PRINT @SQL --for debugging purposes
			PRINT CHAR(10)

/**************************************************************************************************************************************************
--	Execute the SQL statement with the relevant fields (and mapped field names for SSRS) from the DQ measure view for @MyMeasureNumber 
--	and return the data
**************************************************************************************************************************************************/

			-- Execute the second SQL statement to return the data from the view for @MyMeasureNumber
			EXEC sp_executesql @SQL

END


GO
