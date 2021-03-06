USE [DataQuality_DynamicReporting]
GO
/****** Object:  View [DataQuality].[vwMeasuresSQLComplete]    Script Date: 09/04/2019 10:41:48 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[DataQuality].[vwMeasuresSQLComplete]'))
DROP VIEW [DataQuality].[vwMeasuresSQLComplete]
GO
/****** Object:  View [DataQuality].[vwMeasuresSQLComplete]    Script Date: 09/04/2019 10:41:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[DataQuality].[vwMeasuresSQLComplete]'))
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
Description:				This function will return all related measure records in which the identity type and 
							identity record, and all associated identity types and identity records, feature
**************************************************************************************************************************************************/

CREATE VIEW [DataQuality].[vwMeasuresSQLComplete] as
 
		SELECT		p.DQ_MeasureId
					,[NewId]
		FROM		(SELECT		m.DQ_MeasureId
								,[NewId] = ROW_NUMBER() OVER(PARTITION BY 1 ORDER BY DQ_MeasureId)
					FROM		DataQuality.DQ_Measures m
					JOIN		(SELECT		MeasureProcedureNumber = CAST(SUBSTRING(p.name,len(p.name)-2,3) as int)
								FROM		sys.procedures p
								JOIN		sys.schemas s
											ON	p.schema_id = s.schema_id
								WHERE		s.name = ''DataQualityMeasures''
								AND			ISNUMERIC(SUBSTRING(p.name,len(p.name)-2,3)) = 1
								) procs
									on m.DQ_MeasureId = procs.MeasureProcedureNumber
					-- Should there be a field in the measures table which indicates that the measure is live
					) p
		JOIN		(SELECT		m.DQ_MeasureId
					FROM		DataQuality.DQ_Measures m
					JOIN		(SELECT		MeasureProcedureNumber = CAST(SUBSTRING(v.name,len(v.name)-2,3) as int)
								FROM		sys.views v
								JOIN		sys.schemas s
											ON	v.schema_id = s.schema_id
								WHERE		s.name = ''DataQualityMeasures''
								AND			ISNUMERIC(SUBSTRING(v.name,len(v.name)-2,3)) = 1
								) procs
									on m.DQ_MeasureId = procs.MeasureProcedureNumber
					) v
						ON p.DQ_MeasureId = v.DQ_MeasureId



' 
GO
