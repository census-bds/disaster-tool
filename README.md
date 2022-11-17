## Exploring Hurricane Ian's potential impact on the supply chain

This project visualizes the dominant industries and products in areas affected by Hurricane Ian. We aim to provide a reusable pipeline that can be re-applied for other natural disasters.

### Setup

- Clone repo.
- Install R package dependencies (**TK**)
- Download the 2017 NAPCS structure file from [here](https://www.census.gov/naics/napcs/?274456) to get 2017 NAPCS labels.
- Download [this file](https://www2.census.gov/programs-surveys/economic-census/data/2017/sector00) from the Census FTP site for the Econ Census-derived NAICS-NAPCS crosswalk.

### Data sources

**Quarterly Census of Employment and Wages (QCEW)**

QCEW is a BLS data product derived from unemployment insurance administrative data. Coverage includes essentially all private jobs as well as many civilian federal jobs. Data are released quarterly; currently, the most recent vintage is 2022 Q1. Data are available at the county level, albeit with some suppressions.

We use BLS-provided counts for the number of establishments by six-digit NAICS industry for all private jobs. 

**Economic Census (EC)**

The Economic Census is a survey-based data product that provides a wide range of estimates about U.S. businesses. We use this data source to understand which products are most significant in different NAICS sectors. 

Within a six-digit NAICS, EC publishes the total value of sales, shipments, or revenue by NAPCS-based product/service code. These data are available at the state level for a small number of industries, but coverage is poor enough that we use the national estimates for all geographies.

Table ID:EC1700NAPCSINDPRD
Dataset:ECNNAPCSIND2017

Outstanding questions:
- why isn't the data from the FTP site available via the API?
- how to think about suppression

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


### Other reading 

- https://arefiles.ucdavis.edu/uploads/filer_public/97/c2/97c2fab7-1d69-4754-b220-1aebe0fbe47f/cpc_uspc_working_paper.pdf
