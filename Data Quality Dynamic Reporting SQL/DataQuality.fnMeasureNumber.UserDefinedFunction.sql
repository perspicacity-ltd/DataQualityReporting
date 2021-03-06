USE [DataQuality_DynamicReporting]
GO
/****** Object:  UserDefinedFunction [DataQuality].[fnMeasureNumber]    Script Date: 09/04/2019 10:41:48 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DataQuality].[fnMeasureNumber]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [DataQuality].[fnMeasureNumber]
GO
/****** Object:  UserDefinedFunction [DataQuality].[fnMeasureNumber]    Script Date: 09/04/2019 10:41:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DataQuality].[fnMeasureNumber]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
-- select dataQuality.fnMeasureNumber (''DQ_432'')

CREATE FUNCTION	[DataQuality].[fnMeasureNumber] (@DQ_MeasureObjectName varchar(255), @ReturnType Varchar(255))

/******************************************************** © Copyright & Licensing ****************************************************************
© 2018 Perspicacity Ltd

This code / file is part of Perspicacity''s DataQualityReporting suite.

Perspicacity''s DataQualityReporting suite is free software: you can 
redistribute it and/or modify it under the terms of the GNU Affero 
General Public License as published by the Free Software Foundation, 
either version 3 of the License, or (at your option) any later version.

Perspicacity''s DataQualityReporting suite is distributed in the hope 
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
Description:				This function converts a stored procedure name (e.g. uspDQ_001) to a measure ID, either as a number or text
**************************************************************************************************************************************************/

RETURNS sql_Variant
AS

BEGIN

		DECLARE @DQ_Measure sql_Variant

		IF @DQ_MeasureObjectName IS NOT NULL AND @ReturnType = ''Measure Number''
			
			BEGIN	
				
				SET @DQ_Measure = (SELECT cast((Substring(@DQ_MeasureObjectName,len(@DQ_MeasureObjectName)-2,3)) as int))

			END

		IF @DQ_MeasureObjectName IS NOT NULL AND @ReturnType = ''Measure object number''
			
			BEGIN	
				
				SET @DQ_Measure = (SELECT (Substring(@DQ_MeasureObjectName,len(@DQ_MeasureObjectName)-2,3)) )

			END

	Return @DQ_Measure

END


-- select dataQuality.fnMeasureNumber (''DQ_001'', ''Measure object number'')
-- select dataQuality.fnMeasureNumber (''DQ_001'', ''Measure number'')
' 
END

GO
