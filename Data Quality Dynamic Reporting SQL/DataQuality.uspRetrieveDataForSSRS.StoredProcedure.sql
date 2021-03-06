USE [DataQuality_DynamicReporting]
GO
/****** Object:  StoredProcedure [DataQuality].[uspRetrieveDataForSSRS]    Script Date: 23/04/2020 19:47:02 ******/
IF OBJECT_ID('[DataQuality].[uspRetrieveDataForSSRS]') IS NOT NULL
DROP PROCEDURE [DataQuality].[uspRetrieveDataForSSRS]
GO
/****** Object:  StoredProcedure [DataQuality].[uspRetrieveDataForSSRS]    Script Date: 23/04/2020 19:47:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [DataQuality].[uspRetrieveDataForSSRS] (@DQ_MeasureID INT, @UpdateDQ int = null, @ReturnDataSet INT, @DimensionGroupIds Varchar(3000) = Null, @IdentityId Varchar(255) = Null, @IdentityTypeId INT = Null) as -- = NULL, @IdentityTypeId INT = NULL, @Identity INT= NULL) as

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
Description:				This SP allows SSRS to call for the data from any of the measure stored procedures using a parameter which
							determines which measure ID it is asking for the data for.
							This allows the SSRS reports to pull the data for any measure into the dynamic report, which allows the 
							reporting to scale without any development
**************************************************************************************************************************************************/

DECLARE @MeasureNumberText Varchar(255) = RIGHT('000'+CAST(@DQ_MeasureID AS VARCHAR(3)),3)

	DECLARE @SQL nVARCHAR(Max)
	
	SET @SQL = 'exec DataQualityMeasures.uspDQ_' + @MeasureNumberText 
				+ ' @UpdateDQ = ' + ISNULL(CAST(@UpdateDQ as Varchar(255)), ' Null')
				+ ', @ReturnDataSet = ' + CAST(@ReturnDataSet as Varchar(255))
				+ ', @DimensionGroupIds =' + ISNULL('''' + CAST(@DimensionGroupIds as Varchar(3000)) + '''', ' Null') -- need to pass the @DimensionGroupIds as a varchar surrounded with '''' otherwise not passed as text to DataQualityMeasures.uspDQ_xxx SProc
				+ ', @IdentityId =' + ISNULL('''' + CAST(@IdentityId as Varchar(3000)) + '''', ' Null')
				+ ', @IdentityTypeId =' + ISNULL(CAST(@IdentityTypeId as Varchar(3000)), ' Null')
	PRINT @SQL

	EXEC sp_executesql @SQL
	
	RETURN


GO
