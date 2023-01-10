# Exploring Hurricane Ian's potential impact on the supply chain

This project visualizes the dominant industries and products in areas affected by Hurricane Ian, based on information from the Bureau of Labor Statistics (BLS) Quarterly Census of Employment and Wages (QCEW) and the Census Bureau's Foreign Trade estimates. 

We aim to provide a reusable pipeline that can be easily modified and re-run for natural disasters that occur in different geographic areas. We want to make it easier for users to find and explore data that are already published so they can more easily understand potential supply chain impacts. We use only public data and we avoid making derived estimates or model-like decisions, leaving those to user discretion. 
  
### Setup

1. Clone repo.
2. Register for API keys for Census and BLS.
3. Open the project (.Rproj file) in RStudio to set working directories appropriately, or use `setwd()` instead.
4. Run `setup.R` to install R package dependencies and API keys.
5. If not using TIGER/LINE shapefile, save the appropriate shapefile in the `data/` directory. 

### Running the data pipeline 

1. If needed, update the list of counties specified in `affected_counties.csv`: the current list contains the counties eligible for FEMA's highest level of disaster assistance for Hurricane Ian. Counties should be listed with their name only, e.g. Miami-Dade County FL should be listed as Miami-Dade.
2. Run the scripts in the `etl/` subdirectory in ascending order, beginning with 0. Note that `7_tests.R` contains tests for invalid values *and* tests for key values in the final viz product, so this script would need to be modified for an alternative set of counties or updated data.
3. The .csv and .shp files for Tableau will be saved in the `tableau/` subdirectory and can be used to build the dashboard.

### Tableau views

1. Affected county map
   - show affected areas in orange
   - action: click on county/group of counties and go to bar chart 2 for that county
   - action: click somewhere and go to bar chart 2 for affected area 

2. Bar chart: share of national establishments within NAICS, top 10
  - each bar represents a NAICS
  - height of the bar is the share of establishments in this industry in this geographic area out of all establishments in this industry
  - bars are ranked in descending order and cut off at 10
  - action: click on the bar and go to products list

3 Bar chart: top NAPCS products associated with a given NAICS, based on % of estabs producing those products 
  - based on 2017 EC data on total estabs producing a product, what are the top 10 products produced in this NAICS?
  
4. Imports map
  - show the ports on a map, sized by total year to date value
  - action: click to see top products in that port based on share of that commodity's total year to date import value.

### Data cleaning choices + anomalies + outstanding questions

1. Why is there more Econ Census data available from the FTP site than from the API? We have greater industry coverage in the file from the FTP site, so we use that. 

2. BLS QCEW NAICS may not match Census NAICS, especially in subsector 238. BLS QCEW uses 2022 NAICS, while the 2017 Econ Census used 2017 NAICS. In addition, BLS sometimes specifies distinctions (e.g. residential vs non-residential/commercial) that are not present in the Econ Census data. Since we use establishment counts from BLS, we stick as closely to their taxonomy as possible.

3. We use the list of counties from BLS QCEW and a custom shapefile from GEO division (2021 Albers projected counties with territories etc repositioned). External users could use the 2021 TIGER-line shapefile, as we did in a previous iteration. Notably, BLS QCEW combines two county equivalent geographies in Hawaii and does not include the US Virgin Islands, American Samoa, the Northern Mariana Islands, or Guam. 

4. In the imports API, the HS6 product code long description field contains some strange characters that prevented these descriptions from being parsed out of JSON. Future work could address this.

5. We do not have a shapefile or canonical geocoded address list for CBP ports. As an interim measure, we split the city and state in the port name and use Tableau to geocode those. There were about 100 ports we had to correct to get Tableau to recognize the location; we manually entered these

  
### Data sources

**Quarterly Census of Employment and Wages (QCEW)**

QCEW is a BLS data product derived from unemployment insurance administrative data. Coverage includes essentially all private jobs as well as many civilian federal jobs. Data are released quarterly; currently, the most recent vintage is 2022 Q1. Data are available at the county level, though small cell counts are suppressed.

We use BLS-provided counts for the number of establishments by six-digit NAICS industry for all private jobs nationally and in each county.

**Economic Census (EC)**

The Economic Census is a survey-based data product that provides a wide range of estimates about U.S. businesses. We use this data source to understand which products are most significant in different NAICS sectors. 

Within a six-digit NAICS, EC publishes the total value of sales, shipments, or revenue by NAPCS-based product/service code. These data are available at the state level for a small number of industries, but coverage is poor enough that we use the national estimates for all geographies.

Table ID:EC1700NAPCSINDPRD
Dataset:ECNNAPCSIND2017

Outstanding questions:
- why isn't the data from the FTP site available via the API?
- how to think about suppression

**Foreign Trade Imports**

This data source provides monthly data on the value of shipments of detailed commodities imported into US ports. In cases where a disaster affects or damages port operations, these data can indicate which commodities might be affected.

Data reflect the release for the month of September 2022.

Outstanding question:
- Is year to date the right measure given seasonal adjustments?

### Data gaps

- There is no data source that provides geographically granular data with sufficient coverage about which industries produce which products. 

- There isn't a ports shapefile.

##### Notes from 2017 Econ Census table

All Sectors: Industry by Products for the U.S. and States: 2017
Survey/Program:Economic Census
Year:2017

Key Table Information:
Includes only establishments of firms with payroll.
Data may be subject to employment- and/or sales-size minimums that vary by industry.
Product lines are referenced by NAPCS collection codes in the table. For information about NAPCS, see North American Product Classification System.

For the 2017 Economic Census, there has been a change to how Units of Measure is published as compared to prior Census Years. Manufacturing and Mining sectors are now publishing these units as they were collected on the forms. There is no longer a conversion factor applied prior to their published figures. For example, in prior Census Years, Mining collected quantities in the unit of measure shorts tons; however, it was published as a unit of measure code of 250, which represented quantities of short tons with the display label of 1,000 s tons. For 2017, Mining collected quantities in the unit of measure short tons, and it is being published as a unit of measure code of 910, which represents the display label of quantities of short tons as short tons with no conversion factor.

The value displayed in the table is the percent of broad product sales, value of shipments, or revenue that was withheld due to additional protection requirements that were added from recently updated Census Bureau and IRS data confidentiality agreements, to avoid disclosing data for individual companies, or because the estimate does not meet publication standards for quality. The numerator is calculated as the sum of the broad product sales withheld from publication at the 6-digit NAICS level and then aggregated to the 2-digit NAICS level. The denominator is the published total sales, value of shipments, or revenue at the 2-digit NAICS level.
Sector (6-digit NAICS level)		Percent of total broad product sales, value of shipments, or revenue withheld from publication  
21 		4.9% 
22 		9.6% 
23 		2.6% 
31-33 		26.4% 
42 		12.5% 
44-45 		1.3% 
48-49 		12.5% 
51 		2.4% 
52 		15.9% 
53 		2.8% 
54 		3.3% 
55 		2.2% 
56 		0.6% 
61 		1.5% 
62 		0.6% 
71 		0.5% 
72 		0.0% 
81 		0.4% 

Data Items and Other Identifying Records:
- Number of establishments
- Total sales, value of shipments, or revenue of establishments with the NAPCS collection code ($1,000)
- Quantity produced for the NAPCS collection code (sectors 21 and 31-33 only)
- Quantity shipped for the NAPCS collection code (sectors 21 and 31-33 only)
- Sales, value of shipments, or revenue of NAPCS collection code ($1,000)
- NAPCS collection code sales, value of shipments, or revenue as % of industry sales, value of shipments, or revenue (%)
- NAPCS collection code sales, value of shipments, or revenue as % of total sales, value of shipments, or revenue of establishments with the NAPCS collection code (%)
- Number of establishments with NAPCS collection code as % of industry establishments (%)
- Range indicating percent of total NAPCS collection code sales, value of shipments, or revenue imputed
- Relative standard error of NAPCS collection code sales, value of shipments, or revenue (%)

Each record includes a code which represents various types of products produced or carried, or services rendered, by an establishment.

For Wholesale Trade (42), data are published by Type of Operation (All establishments).

Geography Coverage:
The data are shown for employer establishments at the U.S. level for all sectors and at the U.S. and state level for sectors 44-45, 61, 62, 71, 72, and 81. For information about economic census geographies, including changes for 2017, see Economic Census: Economic Geographies.

Industry Coverage:
The data are shown at the 2- through 6-digit 2017 NAICS code levels for all NAICS industries and selected 7 and 8 digit 2017 NAICS code levels for select industries. For information about NAICS, see Economic Census: Technical Documentation: Code Lists.

Footnotes:
Transportation and Warehousing (48-49): footnote 106- Railroad transportation and U.S. Postal Service are out of scope.


Symbols:
D - Withheld to avoid disclosing data for individual companies; data are included in higher level totals

N - Not available or not comparable

S - Estimate does not meet publication standards because of high sampling variability, poor response quality, or other concerns about the estimate quality. Unpublished estimates derived from this table by subtraction are subject to these same limitations and should not be attributed to the U.S. Census Bureau. For a description of publication standards and the total quantity response rate, see link to program methodology page.

X - Not applicable

A - Relative standard error of 100% or more

r - Revised

s - Relative standard error exceeds 40%

For a complete list of symbols, see Economic Census: Technical Documentation: Data Dictionary.
