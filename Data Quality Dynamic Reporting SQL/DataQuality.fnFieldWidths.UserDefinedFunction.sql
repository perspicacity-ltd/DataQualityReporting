USE [DataQuality_DynamicReporting]
GO
/****** Object:  UserDefinedFunction [DataQuality].[fnFieldWidths]    Script Date: 09/04/2019 10:41:48 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DataQuality].[fnFieldWidths]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [DataQuality].[fnFieldWidths]
GO
/****** Object:  UserDefinedFunction [DataQuality].[fnFieldWidths]    Script Date: 09/04/2019 10:41:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DataQuality].[fnFieldWidths]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
CREATE FUNCTION	[DataQuality].[fnFieldWidths] (@FieldWidth INT)

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
Description:				This function converts a field width to a descriptive output so SSRS knows which tablix column to use 
							(i.e. narrow / normal / wide etc) for each field
							This is based on the dynamic design for SSRS where the same tablix works for all measures - In order for this to 
							render reasonably on the screen, a tablix is created where each field in the data appears in multiple columns
							with each column having a different width. The data is then best fit to one of the columns.
**************************************************************************************************************************************************/

RETURNS VARCHAR(255)
AS

BEGIN

		DECLARE @FieldWidthOutput VARCHAR(255)

		IF @FieldWidth IS NOT NULL
			
			BEGIN	
				
				SET @FieldWidthOutput = (SELECT CASE WHEN @FieldWidth <5 THEN ''Narrow''
													 WHEN @FieldWidth >=5 AND @FieldWidth < 10 THEN ''Normal''
													 WHEN @FieldWidth >= 10 THEN ''Wide''
													 ELSE ''''
												END)

			END
			
	Return @FieldWidthOutput

END

' 
END

GO
