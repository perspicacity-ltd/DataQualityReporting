USE [DataQuality_DynamicReporting]
GO
IF  EXISTS (SELECT * FROM ::fn_listextendedproperty(N'Copyright' , N'SCHEMA',N'DataQualityMeasures', N'TABLE',N'DQ_xxx (template measure table)', NULL,NULL))
EXEC sys.sp_dropextendedproperty @name=N'Copyright' , @level0type=N'SCHEMA',@level0name=N'DataQualityMeasures', @level1type=N'TABLE',@level1name=N'DQ_xxx (template measure table)'

GO
IF  EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DataQualityMeasures', N'TABLE',N'DQ_xxx (template measure table)', N'COLUMN',N'<Enter Measure Fields Herein>'))
EXEC sys.sp_dropextendedproperty @name=N'MS_Description' , @level0type=N'SCHEMA',@level0name=N'DataQualityMeasures', @level1type=N'TABLE',@level1name=N'DQ_xxx (template measure table)', @level2type=N'COLUMN',@level2name=N'<Enter Measure Fields Herein>'

GO
IF  EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DataQualityMeasures', N'TABLE',N'DQ_xxx (template measure table)', N'COLUMN',N'PrimaryIdentityType_RecordId'))
EXEC sys.sp_dropextendedproperty @name=N'MS_Description' , @level0type=N'SCHEMA',@level0name=N'DataQualityMeasures', @level1type=N'TABLE',@level1name=N'DQ_xxx (template measure table)', @level2type=N'COLUMN',@level2name=N'PrimaryIdentityType_RecordId'

GO
IF  EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DataQualityMeasures', N'TABLE',N'DQ_xxx (template measure table)', N'COLUMN',N'PrimaryIdentityTypeId'))
EXEC sys.sp_dropextendedproperty @name=N'MS_Description' , @level0type=N'SCHEMA',@level0name=N'DataQualityMeasures', @level1type=N'TABLE',@level1name=N'DQ_xxx (template measure table)', @level2type=N'COLUMN',@level2name=N'PrimaryIdentityTypeId'

GO
IF  EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DataQualityMeasures', N'TABLE',N'DQ_xxx (template measure table)', N'COLUMN',N'UpdatedDate'))
EXEC sys.sp_dropextendedproperty @name=N'MS_Description' , @level0type=N'SCHEMA',@level0name=N'DataQualityMeasures', @level1type=N'TABLE',@level1name=N'DQ_xxx (template measure table)', @level2type=N'COLUMN',@level2name=N'UpdatedDate'

GO
IF  EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DataQualityMeasures', N'TABLE',N'DQ_xxx (template measure table)', N'COLUMN',N'Confidence'))
EXEC sys.sp_dropextendedproperty @name=N'MS_Description' , @level0type=N'SCHEMA',@level0name=N'DataQualityMeasures', @level1type=N'TABLE',@level1name=N'DQ_xxx (template measure table)', @level2type=N'COLUMN',@level2name=N'Confidence'

GO
IF  EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DataQualityMeasures', N'TABLE',N'DQ_xxx (template measure table)', N'COLUMN',N'DQ_LinkedMeasures'))
EXEC sys.sp_dropextendedproperty @name=N'MS_Description' , @level0type=N'SCHEMA',@level0name=N'DataQualityMeasures', @level1type=N'TABLE',@level1name=N'DQ_xxx (template measure table)', @level2type=N'COLUMN',@level2name=N'DQ_LinkedMeasures'

GO
IF  EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DataQualityMeasures', N'TABLE',N'DQ_xxx (template measure table)', N'COLUMN',N'DQ_DimensionGroupId'))
EXEC sys.sp_dropextendedproperty @name=N'MS_Description' , @level0type=N'SCHEMA',@level0name=N'DataQualityMeasures', @level1type=N'TABLE',@level1name=N'DQ_xxx (template measure table)', @level2type=N'COLUMN',@level2name=N'DQ_DimensionGroupId'

GO
IF  EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DataQualityMeasures', N'TABLE',N'DQ_xxx (template measure table)', N'COLUMN',N'DQ_MeasureId'))
EXEC sys.sp_dropextendedproperty @name=N'MS_Description' , @level0type=N'SCHEMA',@level0name=N'DataQualityMeasures', @level1type=N'TABLE',@level1name=N'DQ_xxx (template measure table)', @level2type=N'COLUMN',@level2name=N'DQ_MeasureId'

GO
IF  EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DataQualityMeasures', N'TABLE',N'DQ_xxx (template measure table)', N'COLUMN',N'DQ_MeasureRecordId'))
EXEC sys.sp_dropextendedproperty @name=N'MS_Description' , @level0type=N'SCHEMA',@level0name=N'DataQualityMeasures', @level1type=N'TABLE',@level1name=N'DQ_xxx (template measure table)', @level2type=N'COLUMN',@level2name=N'DQ_MeasureRecordId'

GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DataQualityMeasures].[CK_DQ_xxx_Confidence]') AND parent_object_id = OBJECT_ID(N'[DataQualityMeasures].[DQ_xxx (template measure table)]'))
ALTER TABLE [DataQualityMeasures].[DQ_xxx (template measure table)] DROP CONSTRAINT [CK_DQ_xxx_Confidence]
GO
/****** Object:  Table [DataQualityMeasures].[DQ_xxx (template measure table)]    Script Date: 09/04/2019 10:41:48 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DataQualityMeasures].[DQ_xxx (template measure table)]') AND type in (N'U'))
DROP TABLE [DataQualityMeasures].[DQ_xxx (template measure table)]
GO
/****** Object:  Table [DataQualityMeasures].[DQ_xxx (template measure table)]    Script Date: 09/04/2019 10:41:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DataQualityMeasures].[DQ_xxx (template measure table)]') AND type in (N'U'))
BEGIN
CREATE TABLE [DataQualityMeasures].[DQ_xxx (template measure table)](
	[DQ_MeasureRecordId] [int] IDENTITY(1,1) NOT NULL,
	[DQ_MeasureId] [int] NOT NULL,
	[DQ_DimensionGroupId] [int] NULL,
	[DQ_LinkedMeasures] [varchar](max) NULL,
	[Confidence] [decimal](4, 3) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[UpdatedDate] [datetime] NULL,
	[ResolvedDate] [datetime] NULL,
	[PrimaryIdentityTypeId] [int] NOT NULL,
	[PrimaryIdentityType_RecordId] [varchar](255) NOT NULL,
	[<Enter Measure Fields Herein>] [varchar](255) NULL,
 CONSTRAINT [PK__DQ_xxx (__CE02FD6BDE519B2E] PRIMARY KEY CLUSTERED 
(
	[DQ_MeasureRecordId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DataQualityMeasures].[CK_DQ_xxx_Confidence]') AND parent_object_id = OBJECT_ID(N'[DataQualityMeasures].[DQ_xxx (template measure table)]'))
ALTER TABLE [DataQualityMeasures].[DQ_xxx (template measure table)]  WITH CHECK ADD  CONSTRAINT [CK_DQ_xxx_Confidence] CHECK  (([Confidence]>=(0) AND [Confidence]<=(1)))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DataQualityMeasures].[CK_DQ_xxx_Confidence]') AND parent_object_id = OBJECT_ID(N'[DataQualityMeasures].[DQ_xxx (template measure table)]'))
ALTER TABLE [DataQualityMeasures].[DQ_xxx (template measure table)] CHECK CONSTRAINT [CK_DQ_xxx_Confidence]
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DataQualityMeasures', N'TABLE',N'DQ_xxx (template measure table)', N'COLUMN',N'DQ_MeasureRecordId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'This IDENTITY field is an auto-generated unique ID within the DQ measure table' , @level0type=N'SCHEMA',@level0name=N'DataQualityMeasures', @level1type=N'TABLE',@level1name=N'DQ_xxx (template measure table)', @level2type=N'COLUMN',@level2name=N'DQ_MeasureRecordId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DataQualityMeasures', N'TABLE',N'DQ_xxx (template measure table)', N'COLUMN',N'DQ_MeasureId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'This field represents the measure number (from DQ_Measures) that this data represents - this number should match the name of the table (DQ_xxx) and the associated SP (uspDQ_xxx) that populates the data' , @level0type=N'SCHEMA',@level0name=N'DataQualityMeasures', @level1type=N'TABLE',@level1name=N'DQ_xxx (template measure table)', @level2type=N'COLUMN',@level2name=N'DQ_MeasureId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DataQualityMeasures', N'TABLE',N'DQ_xxx (template measure table)', N'COLUMN',N'DQ_DimensionGroupId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'This field is a foreign key to the DQ_DimensionGroups table and represents the unique combination of dimensions that relates to this record. This field will initially be blank when records are inserted to the table and subsequently updated by uspUpdateRelatedTables_WithinMeasure' , @level0type=N'SCHEMA',@level0name=N'DataQualityMeasures', @level1type=N'TABLE',@level1name=N'DQ_xxx (template measure table)', @level2type=N'COLUMN',@level2name=N'DQ_DimensionGroupId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DataQualityMeasures', N'TABLE',N'DQ_xxx (template measure table)', N'COLUMN',N'DQ_LinkedMeasures'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'This is a pre-calculated, comma-delimited string of all the other DQ measures that this record appears on. The pre-calculation is to reduce the time taken to retrieve records for SSRS, where this information is used to identify linked DQ issues. This field will initially be blank when the data is updated by the measure SP and will be subsequently updated by uspUpdateRelatedTables_AcrossMeasures ' , @level0type=N'SCHEMA',@level0name=N'DataQualityMeasures', @level1type=N'TABLE',@level1name=N'DQ_xxx (template measure table)', @level2type=N'COLUMN',@level2name=N'DQ_LinkedMeasures'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DataQualityMeasures', N'TABLE',N'DQ_xxx (template measure table)', N'COLUMN',N'Confidence'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'This decimal allows us to denote the confidence that the record is correct. 1 = completely confident and 0 = no confidence. A lot of measures will have a value of 0 (we are sure the record is incorrect), but some measures will have a degree of questionable confidence in the data (i.e. names not matching between 2 systems). The value must be between 0 and 1, with a precision up to 3 decimal places' , @level0type=N'SCHEMA',@level0name=N'DataQualityMeasures', @level1type=N'TABLE',@level1name=N'DQ_xxx (template measure table)', @level2type=N'COLUMN',@level2name=N'Confidence'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DataQualityMeasures', N'TABLE',N'DQ_xxx (template measure table)', N'COLUMN',N'UpdatedDate'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'This field records the date the record was last updated. This is important for measures where there is an incremental load process to the DQ measure table, allowing us to understand when the record was last updated' , @level0type=N'SCHEMA',@level0name=N'DataQualityMeasures', @level1type=N'TABLE',@level1name=N'DQ_xxx (template measure table)', @level2type=N'COLUMN',@level2name=N'UpdatedDate'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DataQualityMeasures', N'TABLE',N'DQ_xxx (template measure table)', N'COLUMN',N'PrimaryIdentityTypeId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'This field is a foreign key to DQ_IdentityTypes and is the identity type id of the main identity for the record (the main identity is recorded in IdentityType_RecordId)' , @level0type=N'SCHEMA',@level0name=N'DataQualityMeasures', @level1type=N'TABLE',@level1name=N'DQ_xxx (template measure table)', @level2type=N'COLUMN',@level2name=N'PrimaryIdentityTypeId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DataQualityMeasures', N'TABLE',N'DQ_xxx (template measure table)', N'COLUMN',N'PrimaryIdentityType_RecordId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'This is the main identity for the record and will be populated from the source data (e.g. for a personnel record, we might have the ESR ID and their National Insurance number. Both are unique ID''s, but the ESR ID is the main identity for personnel). It is likely that this main identity is also represented further down in the dataset, but using the original field name, for inclusion in the SSRS reporting' , @level0type=N'SCHEMA',@level0name=N'DataQualityMeasures', @level1type=N'TABLE',@level1name=N'DQ_xxx (template measure table)', @level2type=N'COLUMN',@level2name=N'PrimaryIdentityType_RecordId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DataQualityMeasures', N'TABLE',N'DQ_xxx (template measure table)', N'COLUMN',N'<Enter Measure Fields Herein>'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'This is a dumy field, representing the start of where we add fields that are specific to each measure. These are the fields that will be presented in the SSRS reporting, or for another DQ analysis, but are not an essential to the way the DQ reporting framework operates' , @level0type=N'SCHEMA',@level0name=N'DataQualityMeasures', @level1type=N'TABLE',@level1name=N'DQ_xxx (template measure table)', @level2type=N'COLUMN',@level2name=N'<Enter Measure Fields Herein>'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'Copyright' , N'SCHEMA',N'DataQualityMeasures', N'TABLE',N'DQ_xxx (template measure table)', NULL,NULL))
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
Description:				A template DQ measure table to use as a starting point to create 
							new DQ measures in Perspicacity''s DataQualityReporting suite
**************************************************************************************************************************************************/
' , @level0type=N'SCHEMA',@level0name=N'DataQualityMeasures', @level1type=N'TABLE',@level1name=N'DQ_xxx (template measure table)'
GO
