USE [DataQuality_DynamicReporting]
GO
/****** Object:  View [DataQualityMeasures].[DQ_vwSSRS_xxx (template measure view)]    Script Date: 09/04/2019 10:41:48 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[DataQualityMeasures].[DQ_vwSSRS_xxx (template measure view)]'))
DROP VIEW [DataQualityMeasures].[DQ_vwSSRS_xxx (template measure view)]
GO
/****** Object:  View [DataQualityMeasures].[DQ_vwSSRS_xxx (template measure view)]    Script Date: 09/04/2019 10:41:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[DataQualityMeasures].[DQ_vwSSRS_xxx (template measure view)]'))
EXEC dbo.sp_executesql @statement = N'
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
Description:				A template view to use as a starting point to create 
							new DQ measures in Perspicacity''s DataQualityReporting suite
**************************************************************************************************************************************************/

CREATE VIEW [DataQualityMeasures].[DQ_vwSSRS_xxx (template measure view)] AS
SELECT		DQ_MeasureRecordId = CONVERT(VARCHAR(255),[DQ_MeasureRecordId])
			,[DQ_LinkedMeasures]
			,[DQ_MeasureId] = CONVERT(VARCHAR(255),[DQ_MeasureId])
			,[DQ_DimensionGroupId] = CONVERT(VARCHAR(255),[DQ_DimensionGroupId])
			,[UpdatedDate] = CONVERT(VARCHAR(255),[UpdatedDate],106)
			,[Confidence] = CONVERT(VARCHAR(255),[Confidence])
			,[PrimaryIdentityTypeId] = CONVERT(VARCHAR(255),[PrimaryIdentityTypeId])
			,[PrimaryIdentityType_RecordId] = CONVERT(VARCHAR(255),[PrimaryIdentityType_RecordId])
			,[<Enter Measure Fields Herein>]

FROM		DataQualityMeasures.[DQ_xxx (template measure table)]
WHERE		ResolvedDate IS NULL





' 
GO
