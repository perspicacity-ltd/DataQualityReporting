USE [DataQuality_DynamicReporting]
GO
IF  EXISTS (SELECT * FROM ::fn_listextendedproperty(N'Copyright' , N'SCHEMA',N'DataQuality', N'TABLE',N'DQ_MeasureFields', NULL,NULL))
EXEC sys.sp_dropextendedproperty @name=N'Copyright' , @level0type=N'SCHEMA',@level0name=N'DataQuality', @level1type=N'TABLE',@level1name=N'DQ_MeasureFields'

GO
/****** Object:  Table [DataQuality].[DQ_MeasureFields]    Script Date: 09/04/2019 10:41:48 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DataQuality].[DQ_MeasureFields]') AND type in (N'U'))
DROP TABLE [DataQuality].[DQ_MeasureFields]
GO
/****** Object:  Table [DataQuality].[DQ_MeasureFields]    Script Date: 09/04/2019 10:41:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DataQuality].[DQ_MeasureFields]') AND type in (N'U'))
BEGIN
CREATE TABLE [DataQuality].[DQ_MeasureFields](
	[DQ_MeasureId] [int] NULL,
	[SortOrder] [int] NULL,
	[FieldName] [varchar](255) NULL,
	[MaxWidth] [int] NULL,
	[GenericFieldName] [varchar](255) NULL
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'Copyright' , N'SCHEMA',N'DataQuality', N'TABLE',N'DQ_MeasureFields', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'Copyright', @value=N'/******************************************************** © Copyright & Licensing ****************************************************************
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
Description:				A table to maintain the current field names,
							data value lengths (to allow for automatically 
							setting the widths of columns in the SSRS reporting), 
							and sort order of fields within the	view for each
							DQ measure. It also provides the generic field
							name mapping to allow the SSRS reporting to 
							automatically assign each column in the data to
							the table object in the reporting.
							NB: this table is maintained by the stored 
							procedures and does not require manual maintenance
**************************************************************************************************************************************************/
' , @level0type=N'SCHEMA',@level0name=N'DataQuality', @level1type=N'TABLE',@level1name=N'DQ_MeasureFields'
GO
