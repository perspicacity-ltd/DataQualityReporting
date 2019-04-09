USE [DataQuality_DynamicReporting]
GO
/****** Object:  Schema [DataQualityMeasures]    Script Date: 09/04/2019 10:41:48 ******/
IF  EXISTS (SELECT * FROM sys.schemas WHERE name = N'DataQualityMeasures')
DROP SCHEMA [DataQualityMeasures]
GO
/****** Object:  Schema [DataQualityMeasures]    Script Date: 09/04/2019 10:41:48 ******/
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'DataQualityMeasures')
EXEC sys.sp_executesql N'CREATE SCHEMA [DataQualityMeasures]'

GO
