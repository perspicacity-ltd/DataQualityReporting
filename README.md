# DataQualityReporting
A low-maintenance SQL stack reporting suite for Data Quality

## A little bit about the reporting suite
* This is data quality reporting suite is designed for _rapid development_ of Data Quality reporting
* Rapid development is achieved through the _zero-maintenance_ reporting
* It is built in SQL server (compatible from 2012 onwards) and SSRS
* Adding a measure simply requires a table to hold the Data Quality detail data, a view for the SSRS report, and a Stored Procedure to update the data

## Installation instructions
1. Install the DataQuality_DynamicReporting SQL database. You can do this either by:
	 1. Creating the database from the scripts in the 'Data Quality Dynamic Reporting SQL' folder and starting to create your own DQ measures
   1. Attaching the example SQL database mdf/ldf
1. In each RDL (SSRS) file, edit the _DataSource1_ data source connection string to point at your installed DataQuality_DynamicReporting SQL database
1. Upload the RDL (SSRS) files to your SQL Reporting Services environment (or open it in visual studio if you don't have one set up)
1. Open the DQ_Summary - clicking on the number of records next to each measure will drill-down to the detailed reporting

## A little bit about Perspicacity Ltd
Perspicacity provides decision support consultancy, coaching, & development to the NHS. They are passionate about reducing the cost of software development to the NHS and aspire to create an active community of NHS and commercial organisations. They all share a common goal of improving the quality and efficiency of patient care through better, and more informed, decision making.

Open source helps the healthcare community to do this by sharing software development, learning from each other, and help software meet the needs of every organisation without being constrained to a single solution or paying for the same piece of work over and again across different organisations.

Although these Data Quality open source products are suitable for any organisation, healthcare or not, they are here as a result of wanting to freely share Perspicacity's collective products and ideas across the NHS and to widen the benefit of good, but usually locally isolated, projects further

If you'd like to find out more, please contact Matthew Bishop on 07545 878906 or matthew.bishop@perspicacityltd.co.uk
