USE [DataQuality_DynamicReporting]
GO
IF  EXISTS (SELECT * FROM ::fn_listextendedproperty(N'Copyright' , N'SCHEMA',N'DataQuality', N'TABLE',N'DQ_MeasureDimensionHistory', NULL,NULL))
EXEC sys.sp_dropextendedproperty @name=N'Copyright' , @level0type=N'SCHEMA',@level0name=N'DataQuality', @level1type=N'TABLE',@level1name=N'DQ_MeasureDimensionHistory'

GO
/****** Object:  Table [DataQuality].[DQ_MeasureDimensionHistory]    Script Date: 09/04/2019 10:41:48 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DataQuality].[DQ_MeasureDimensionHistory]') AND type in (N'U'))
DROP TABLE [DataQuality].[DQ_MeasureDimensionHistory]
GO
/****** Object:  Table [DataQuality].[DQ_MeasureDimensionHistory]    Script Date: 09/04/2019 10:41:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DataQuality].[DQ_MeasureDimensionHistory]') AND type in (N'U'))
BEGIN
CREATE TABLE [DataQuality].[DQ_MeasureDimensionHistory](
	[DQ_MeasureId] [int] NOT NULL,
	[DQ_DimensionGroupId] [int] NOT NULL,
	[NumeratorRowcount] [int] NULL,
	[DenominatorRowCount] [int] NULL,
	[ConfidenceTotal] [decimal](10, 3) NULL,
	[RedRAGRowcount] [int] NULL,
	[AmberRAGRowcount] [int] NULL,
	[GreenRAGRowcount] [int] NULL,
	[RAG_Rating] [varchar](1) NULL,
	[LastRun] [int] NULL,
	[MeasureUpdated] [datetime] NOT NULL,
 CONSTRAINT [PK_DQ_MeasureDimensionHistory] PRIMARY KEY CLUSTERED 
(
	[DQ_MeasureId] ASC,
	[DQ_DimensionGroupId] ASC,
	[MeasureUpdated] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'Copyright' , N'SCHEMA',N'DataQuality', N'TABLE',N'DQ_MeasureDimensionHistory', NULL,NULL))
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
Description:				A table to store a historical record of
							the measured prevalence of each DQ measure,
							broken down by the DimensionGroups 
**************************************************************************************************************************************************/
' , @level0type=N'SCHEMA',@level0name=N'DataQuality', @level1type=N'TABLE',@level1name=N'DQ_MeasureDimensionHistory'
GO
