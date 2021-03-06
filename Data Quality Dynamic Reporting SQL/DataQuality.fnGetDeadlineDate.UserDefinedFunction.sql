USE [DataQuality_DynamicReporting]
GO
/****** Object:  UserDefinedFunction [DataQuality].[fnGetDeadlineDate]    Script Date: 09/04/2019 10:41:48 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DataQuality].[fnGetDeadlineDate]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [DataQuality].[fnGetDeadlineDate]
GO
/****** Object:  UserDefinedFunction [DataQuality].[fnGetDeadlineDate]    Script Date: 09/04/2019 10:41:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DataQuality].[fnGetDeadlineDate]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
CREATE FUNCTION [DataQuality].[fnGetDeadlineDate] (@DQ_MeasureId Int)

RETURNS Date
AS

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
Description:				This function returns the next deadline date for a measure (if the measure is a type that needs to be corrected
							to a schedule of deadline dates, usually for national returns such as SUS or regular events such as payroll)
**************************************************************************************************************************************************/

BEGIN
	-- Declare the return variable
	DECLARE @Date Date

	

	-- Error handing if incorrect values not passed to function
	IF @DQ_MeasureId IS NULL
	BEGIN
		SET @Date = NULL
	END
	
	-- 
	IF @DQ_MeasureId IS NOT NULL
	BEGIN
		SET @Date = 
					(SELECT CONVERT(DATE,DATEADD(MM, DATEDIFF(MM, 0, (
							SELECT		Min(DeadlineDate) 
							FROM		DataQuality.DQ_DeadlineDates dd 
							WHERE		DeadlineDate > CAST(Getdate() as date) 
							AND			DQ_DeadlineTypeID = (SELECT DQ_DeadlineTypeId FROM DataQuality.DQ_Measures WHERE DQ_MeasureId = @DQ_MeasureId))
									)-2, 0)) 
					)

					
	END
	
	-- Return the result of the function
	RETURN @Date	
	
	
END 

' 
END

GO
