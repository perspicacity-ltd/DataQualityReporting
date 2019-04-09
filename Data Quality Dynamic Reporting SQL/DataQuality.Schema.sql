USE [DataQuality_DynamicReporting]
GO
/****** Object:  Schema [DataQuality]    Script Date: 09/04/2019 10:41:48 ******/
IF  EXISTS (SELECT * FROM sys.schemas WHERE name = N'DataQuality')
DROP SCHEMA [DataQuality]
GO
/****** Object:  Schema [DataQuality]    Script Date: 09/04/2019 10:41:48 ******/
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'DataQuality')
EXEC sys.sp_executesql N'CREATE SCHEMA [DataQuality]'

GO
