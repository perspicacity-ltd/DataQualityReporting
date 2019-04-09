USE [DataQuality_DynamicReporting]
GO
/****** Object:  UserDefinedFunction [DataQuality].[fnIdentityMeasures]    Script Date: 09/04/2019 10:41:48 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DataQuality].[fnIdentityMeasures]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [DataQuality].[fnIdentityMeasures]
GO
/****** Object:  UserDefinedFunction [DataQuality].[fnIdentityMeasures]    Script Date: 09/04/2019 10:41:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DataQuality].[fnIdentityMeasures]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
CREATE FUNCTION [DataQuality].[fnIdentityMeasures] (@DQ_IdentityTypeId INT, @IdentityTypeRecordId VARCHAR(255))

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

Original Work Created Date:	30/03/2018
Original Work Created By:	Perspicacity Ltd (Kelly Roberts & Matthew Bishop)
Original Work Contact:		07545 878906
Original Work Contact:		matthew.bishop@perspicacityltd.co.uk
Description:				This udf returns all related measure records in which the identity type and identity record, and all associated 
							identity types and identity records, feature
**************************************************************************************************************************************************/

RETURNS 
		@MeasuresAssociatedWithIdentity TABLE
			(DQ_MeasureId INT
			,DQ_MeasureRecordId INT
			)

AS 

	BEGIN

		IF @DQ_IdentityTypeId IS NOT NULL AND @IdentityTypeRecordId IS NOT NULL
		
		WITH MI_CTE AS (
		SELECT DQ_IdentityTypeId, IdentityType_RecordId, DQ_MeasureId, DQ_MeasureRecordId, 1 AS Iteration
		FROM		DataQuality.DQ_MeasureIdentities Mi 
		WHERE		IdentityType_RecordId = @IdentityTypeRecordId
		AND			DQ_IdentityTypeId = @DQ_IdentityTypeId
		UNION ALL
		SELECT		Mi.DQ_IdentityTypeId,Mi.IdentityType_RecordId, Mi.DQ_MeasureId, Mi.DQ_MeasureRecordId, ThisId.Iteration + 1 AS Iteration
		FROM		DataQuality.DQ_MeasureIdentities Mi 
		JOIN		(SELECT		Mi.DQ_MeasureRecordId, Mi.DQ_MeasureId, Mi.IdentityType_RecordId, mi.DQ_IdentityTypeId, MI_CTE.Iteration
					FROM		DataQuality.DQ_MeasureIdentities Mi 
					INNER JOIN	MI_CTE MI_CTE
					ON			Mi.IdentityType_RecordId = MI_CTE.IdentityType_RecordId
					AND			mi.DQ_IdentityTypeId = MI_CTE.DQ_IdentityTypeId
					AND			NOT(mi.DQ_MeasureId = MI_CTE.DQ_MeasureId
					AND			mi.DQ_MeasureRecordId = MI_CTE.DQ_MeasureRecordId)
					) ThisId
						on	mi.DQ_MeasureRecordId = ThisId.DQ_MeasureRecordId
						AND mi.DQ_MeasureId = ThisId.DQ_MeasureId
						AND	NOT(mi.IdentityType_RecordId = ThisId.IdentityType_RecordId
						AND	mi.DQ_IdentityTypeId = ThisId.DQ_IdentityTypeId)
		)
		INSERT INTO	@MeasuresAssociatedWithIdentity (DQ_MeasureId, DQ_MeasureRecordId)
		SELECT		DISTINCT
					Mi.DQ_MeasureId, Mi.DQ_MeasureRecordId
		FROM		DataQuality.DQ_MeasureIdentities Mi
		JOIN		MI_CTE
						ON mi.DQ_IdentityTypeId = MI_CTE.DQ_IdentityTypeId
						AND mi.IdentityType_RecordId = MI_CTE.IdentityType_RecordId

RETURN

	END
	
' 
END

GO
