USE [DataQuality_DynamicReporting]
GO
/****** Object:  StoredProcedure [DataQuality].[uspUpdateRelatedTables_WithinMeasure]    Script Date: 23/04/2020 19:47:02 ******/
IF OBJECT_ID('[DataQuality].[uspUpdateRelatedTables_WithinMeasure]') IS NOT NULL
DROP PROCEDURE [DataQuality].[uspUpdateRelatedTables_WithinMeasure]
GO
/****** Object:  StoredProcedure [DataQuality].[uspUpdateRelatedTables_WithinMeasure]    Script Date: 23/04/2020 19:47:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [DataQuality].[uspUpdateRelatedTables_WithinMeasure] @MyMeasureNumber INT as
				
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
Description:				This procedure is to be run every time a measure is updated. It updates 3 tables with information from the measure
							table - DQ_DimensionGroups, DQ_MeasureDimensionHistory, & DQ_MeasureFields.
							Unlike uspUpdateRelatedTables_AcrossMeasures, this SP does not require all the other measure tables to have been
							updated before it can produce the correct output.
**************************************************************************************************************************************************/

/**************************************************************************************************************************************************
--	Update DQ_DimensionGroups table with any new combinations of dimensions found within the data of the measure
**************************************************************************************************************************************************/
	-- truncate table DataQuality.DQ_DimensionGroups
	DECLARE @MeasureNumberText Varchar(255) = RIGHT('000'+CAST(@MyMeasureNumber AS VARCHAR(3)),3)
			,@InsertClauseForInsertDimensionGroups VARCHAR(Max)
			,@SelectClauseForInsertDimensionGroups VARCHAR(Max)
			,@LeftJoinForInsertDimensionGroups VARCHAR(Max)
			,@JoinForUpdateMeasureDimensionGroups VARCHAR(Max)
			,@SQL nVarchar(Max)
			,@SQL_MeasureDimensionHistoryAppend nVarchar(Max)
			
	-- Create table of common fields between measure table and dimension groups
	IF object_id('tempdb..#CommonNames') IS NOT NULL DROP TABLE #CommonNames
	SELECT		c.name
	INTO		#CommonNames
	FROM		sys.tables t
	JOIN		sys.columns c
				ON	t.object_id = c.object_id
	JOIN		sys.schemas s
				ON	t.schema_id = s.schema_id
	WHERE		(t.name = 'DQ_' + @MeasureNumberText  -- KR this needs to be a variable
	AND			s.name = 'DataQualityMeasures')
	OR			(t.name = 'DQ_DimensionGroups'
	AND			s.name = 'DataQuality')
	AND			c.name not in ('DQ_DimensionGroupId')
	GROUP BY	c.name
	HAVING		Count(*) >1


	-- Create table of Dimension field names
	IF object_id('tempdb..#DimensionFieldNames') IS NOT NULL DROP TABLE #DimensionFieldNames
	SELECT		c.name
	INTO		#DimensionFieldNames
	FROM		sys.tables t
	JOIN		sys.columns c
				ON	t.object_id = c.object_id
	JOIN		sys.schemas s
				ON	t.schema_id = s.schema_id
	WHERE		(t.name = 'DQ_DimensionGroups'
	AND			s.name = 'DataQuality')
	AND			c.name not in ('DQ_DimensionGroupId','InMeasureDimensionHistoryLastRun')
				
	-- Create SELECT and JOIN clauses used later to find combinations of dimension data returned from the current measure
	IF object_id('tempdb..#SelectWhere') IS NOT NULL DROP TABLE #SelectWhere
	SELECT		*
				,InsertClauseForInsertDimensionGroups = '[' + DimensionFieldName + ']'
				,SelectClauseForInsertDimensionGroups = CASE WHEN rn = 1 THEN 'DISTINCT ' ELSE '' END +	
									CASE WHEN MeasureDimensionField IS NOT NULL THEN 'CASE WHEN ISNULL(dq.[' + MeasureDimensionField + '], '''') = '''' THEN ''N/A or Missing Value'' ELSE dq.[' + MeasureDimensionField + '] END '
									 ELSE '[' + DimensionFieldName + '] = ''N/A or Missing Value''' END
				,LeftJoinForInsertDimensionGroups = CASE WHEN rn = 1 THEN 'ON ' ELSE 'AND ' END +				
									'CASE WHEN ISNULL(dg.[' + DimensionFieldName + '], '''') = '''' THEN ''N/A or Missing Value'' ELSE dg.[' + DimensionFieldName + '] END = ' 
									+ CASE WHEN MeasureDimensionField IS null then '''N/A or Missing Value''' ELSE 'CASE WHEN dq.[' + MeasureDimensionField + '] = '''' THEN ''N/A or Missing Value'' ELSE dq.[' + MeasureDimensionField + '] END' END
				,JoinForUpdateMeasureDimensionGroups = CASE WHEN rn = 1 THEN 'ON ' ELSE 'AND ' END +				
									'CASE WHEN ISNULL(dg.[' + DimensionFieldName + '], '''') = '''' THEN ''N/A or Missing Value'' ELSE dg.[' + DimensionFieldName + '] END = ' 
									+ CASE WHEN MeasureDimensionField IS null then '''N/A or Missing Value''' ELSE 'CASE WHEN ISNULL(dq.[' + MeasureDimensionField + '], '''') = '''' THEN ''N/A or Missing Value'' ELSE dq.[' + MeasureDimensionField + '] END' END
	INTO		#SelectWhere
	FROM		(SELECT		rn = row_number() over (partition by 1 order by dfn.name)
							,DimensionFieldName = dfn.name		
							,MeasureDimensionField = cn.name
				FROM		#DimensionFieldNames dfn
				LEFT JOIN	#CommonNames cn
								on dfn.name = cn.name
				) fn

	-- SELECT * FROM #SelectWhere

	-- Create the relevant concatenated fields needed to insert each of the derived clauses
	SET @InsertClauseForInsertDimensionGroups = (
						SELECT		DISTINCT 
									STUFF
									(
										(
										SELECT		', ' + sw1.InsertClauseForInsertDimensionGroups 
										FROM		#SelectWhere sw1
										--WHERE		df1.name = df2.name
										ORDER BY	sw1.rn
										FOR XML PATH('')
										), 1, 1, ''
									) AS FieldNames
						FROM		#SelectWhere sw2
						)

	-- Create the relevant concatenated fields needed to select each of the derived clauses
	SET @SelectClauseForInsertDimensionGroups = (
						SELECT		DISTINCT 
									STUFF
									(
										(
										SELECT		', ' + sw1.SelectClauseForInsertDimensionGroups 
										FROM		#SelectWhere sw1
										--WHERE		df1.name = df2.name
										ORDER BY	sw1.rn
										FOR XML PATH('')
										), 1, 1, ''
									) AS FieldNames
						FROM		#SelectWhere sw2
						)

	-- Create the left Join on/and statement to use for inserting the DimensionGroup into the DimensionGroupTable
	SET @LeftJoinForInsertDimensionGroups = (
						SELECT		DISTINCT 
									STUFF
									(
										(
										SELECT		' ' + sw1.LeftJoinForInsertDimensionGroups 
										FROM		#SelectWhere sw1
										--WHERE		df1.name = df2.name
										ORDER BY	sw1.rn
										FOR XML PATH('')
										), 1, 1, ''
									) AS FieldNames
						FROM		#SelectWhere sw2
						)

	-- Create the left Join on/and statement to use for updating the measure table DimensionGroupId 
	SET @JoinForUpdateMeasureDimensionGroups = (
						SELECT		DISTINCT 
									STUFF
									(
										(
										SELECT		' ' + sw1.JoinForUpdateMeasureDimensionGroups 
										FROM		#SelectWhere sw1
										--WHERE		df1.name = df2.name
										ORDER BY	sw1.rn
										FOR XML PATH('')
										), 1, 1, ''
									) AS FieldNames
						FROM		#SelectWhere sw2
						)

	-- Set the SQL to insert the derived dimension groups into the DimensionGroups table and update the DimensionGroupIds
	-- in the relevant measure table
	SET @SQL = CAST('
			INSERT INTO	DataQuality.DQ_DimensionGroups (' + @InsertClauseForInsertDimensionGroups + ') 
			SELECT		'+@SelectClauseForInsertDimensionGroups+
			' FROM		DataQualityMeasures.DQ_' + @MeasureNumberText +' dq
			LEFT JOIN	DataQuality.DQ_DimensionGroups dg '
							+ @LeftJoinForInsertDimensionGroups +
			' WHERE		dg.DQ_DimensionGroupId IS NULL -- Where dimension Group does not already exist'		 AS NVARCHAR(MAX))	

	PRINT CAST(@SQL AS varchar(4000))
	EXEC sp_executesql @SQL
	
	SET @SQL = CAST('
			-- Update DimensionGroupIds for this measure
			UPDATE		dq 
			SET			DQ_DimensionGroupId = dg.DQ_DimensionGroupId
			FROM		DataQualityMeasures.DQ_' + @MeasureNumberText +' dq
			JOIN		DataQuality.DQ_DimensionGroups dg '
							+ @JoinForUpdateMeasureDimensionGroups		 AS NVARCHAR(MAX))	

	PRINT CAST(@SQL AS varchar(4000))
	EXEC sp_executesql @SQL


/**************************************************************************************************************************************************
--	Update DQ_MeasureDimensionHistory table with any new combinations of dimensions found within the data of the measure
**************************************************************************************************************************************************/

	-- Update all records for this measure in MeasureDimensionHistory to LastRun = 0
	Update		mdh 
	SET			LastRun = 0
	FROM		DataQuality.DQ_MeasureDimensionHistory mdh
	WHERE		LastRun = 1
	AND			DQ_MeasureId = @MyMeasureNumber

	-- Create Dynamic SQL for Inserting Row into MeasureDimensionHistory for this measure, where LastRun = 1
	SET @SQL_MeasureDimensionHistoryAppend = 
				'Insert into DataQuality.DQ_MeasureDimensionHistory
							(DQ_MeasureId
							,DQ_DimensionGroupId
							,NumeratorRowcount
							,ConfidenceTotal
							,LastRun 
							,MeasureUpdated
							)
				SELECT		' +CAST(@MyMeasureNumber as Varchar(255))+ ' 
							,DQ_DimensionGroupId
							,TotalRecords = Count(*)
							,ConfidenceTotal = SUM(Confidence)
							,LastRun = 1
							,MeasureUpdated = Getdate()
				FROM		DataQualityMeasures.DQ_' + @MeasureNumberText + ' ' +
				'WHERE		ResolvedDate IS NULL
				GROUP BY	DQ_DimensionGroupId			'

/**************************************************************************************************************************************************
--	Update the measure widths within the DQ_MeasureFields table via a cursor running through the fieldnames within the measure view and 
	selecting the values from the relevant measure table
**************************************************************************************************************************************************/

	PRINT @SQL_MeasureDimensionHistoryAppend
	--Execute Dynamic SQL for Inserting Row into MeasureDimensionHistory for this measure
	EXEC sp_executesql @SQL_MeasureDimensionHistoryAppend


		DECLARE	@RecordsToUpdate INT
			,@FieldName varchar(255)
			,@MaxWidth Int
			,@SQL_All nVARCHAR(MAX)
			,@SQLUpdateFieldNameString nVARCHAR(MAX) 
			,@FieldNameWidth FLOAT
			,@MyMeasureNumberText VARCHAR(255) 
			
			SET @MyMeasureNumberText = RIGHT('000'+CAST(@MyMeasureNumber AS VARCHAR(3)),3)

	-- Delete existing rows in DQ_MeasureFields table for the measure @MyMeasureNumber
	DELETE FROM DataQuality.DQ_MeasureFields WHERE DQ_MeasureID = @MyMeasureNumber 
	
	-- Insert Rows From the associated measure view (DataQualityMeasures.DQ_vwSSRS_xxx) into DQ_MeasureFields table excluding core fields
	INSERT INTO DataQuality.DQ_MeasureFields (DQ_MeasureId,SortOrder,FieldName,GenericFieldName)
	SELECT		DQ_MeasureID = @MyMeasureNumber 
				,SortOrder = NewColumnID
				,FieldName = c.name
				,GenericFieldName = 'Field'+CAST(NewColumnID as Varchar(255))
	FROM		(SELECT		SortOrder = column_id
							,NewColumnID = ROW_NUMBER() OVER(PARTITION BY 1 order by column_id)
							,sc.name
				FROM		sys.columns sc 
				WHERE		[object_id]  =   OBJECT_ID(N'DataQualityMeasures.DQ_vwSSRS_'+@MyMeasureNumberText) 
				AND			sc.name NOT IN ('DQ_MeasureRecordId','DQ_MeasureId','Confidence','UpdatedDate','PrimaryIdentityTypeId','PrimaryIdentityType_RecordId','DQ_DimensionGroupId','DQ_LinkedMeasures','DQ_SortOrder')
				)c
		
	-- Create a piece of dynamic SQL to iterate through each field in DQ_MeasureFields for the associated measure view (DataQualityMeasures.DQ_vwSSRS_xxx)
	-- and calculate the maximum length of the data returned by that field
	-- check the required field name length and update the MaxWidth is this is greater than the data within the field.
	SELECT @RecordsToUpdate = (select COUNT(*) FROM DataQuality.DQ_MeasureFields WHERE DQ_MeasureID = @MyMeasureNumber) -- use Mymeasurenumber here
	WHILE @RecordsToUpdate > 0
		BEGIN
			-- Retrieve the field name for this iteration of @RecordsToUpdate
			SELECT		@FieldName = FieldName
			FROM		DataQuality.DQ_MeasureFields mf
			WHERE		SortOrder = @RecordsToUpdate
			AND			DQ_MeasureId = @MyMeasureNumber	
			
			-- Create a piece of dynamic SQL to calculate the maximum length of the data returned by the field name for this iteration of @RecordsToUpdate
			SET			@SQL = 
						'UPDATE		mf
						SET			mf.MaxWidth = (SELECT		Max(len(ISNULL([' + @FieldName + '],'''')))
													FROM		DataQualityMeasures.DQ_vwSSRS_' + @MyMeasureNumberText -- Use @MyMeasureNumberText instead
													+ ')
						FROM		DataQuality.DQ_MeasureFields mf
						WHERE		FieldName = '''+@FieldName + ''''
						+ ' AND		DQ_MeasureId = '+@MyMeasureNumberText

			-- Capture the SQL code for debugging
			SET @SQL_All = @SQL

			-- Execute the code to update the maximum width in the DQ_MeasureFields table
			EXEC sp_executesql @sql

			-- Update the maximum field length where the name of the field requires it to be longer (allowing for text wrapping)
				
			-- Create temp table to insert separated field name words into
			IF object_id ('tempdb.dbo.#FieldNameWords','U') is not null DROP TABLE #FieldNameWords
			CREATE TABLE #FieldNameWords (FieldNameSeparate Varchar(255))

			-- Replace both ' '  and '-' with 'union all select' to seperate out the individual field name words into rows (to estimate the width required after SSRS has wrapped the field name text)
			SELECT @SQLUpdateFieldNameString = @FieldName
			SELECT @SQLUpdateFieldNameString = 
				REPLACE(@SQLUpdateFieldNameString,' ',''' union all select ''')
			SELECT @SQLUpdateFieldNameString = 
				REPLACE(@SQLUpdateFieldNameString,'-',''' union all select ''')
			SELECT @SQLUpdateFieldNameString  = 'insert into #FieldNameWords select '''+ @SQLUpdateFieldNameString +''''

			---- Load values from @SQLUpdateFieldNameString string into a table
			EXEC sp_executesql @SQLUpdateFieldNameString
			PRINT @SQLUpdateFieldNameString

			-- Set @FieldNameWidth variable for the required field name width
			SET @FieldNameWidth = 
						(SELECT		FieldNameWidth = (AverageWordLength + ((2 * StandardDeviationWordLength)) * TotalWords) / 2 -- allow for the field name text to wrap once (i.e. over 2 lines)
						FROM		(
									SELECT	AverageWordLength = Avg(CAST(Len(RTRIM(LTRIM(FieldNameSeparate))) as float))
											,StandardDeviationWordLength = STDEV(CAST(Len(RTRIM(LTRIM(FieldNameSeparate))) as float))
											,TotalWords = Count(*)
									FROM	#FieldNameWords
									) c
						)
						
			-- Update measure fields table where the length required for the field name is longer than the maximum field width required 
			-- for the values within the field
			UPDATE		mf
			SET			mf.MaxWidth = CEILING(@FieldNameWidth)
			FROM		DataQuality.DQ_MeasureFields mf
			WHERE		FieldName = @FieldName
			AND			DQ_MeasureId = @MyMeasureNumberText
			AND			@FieldNameWidth > isnull(mf.MaxWidth,0)

			-- Iterate to the next row in DQ_MeasureFields
			SET @RecordsToUpdate = @RecordsToUpdate - 1
		END
GO
