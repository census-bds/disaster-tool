## Exploring Hurricane Ian's potential impact on thee supply chain

This project visualizes the dominant industries and products in areas affected by Hurricane Ian. We aim to provide a reusable pipeline that can be re-applied for other natural disasters.

### Setup

One data file is not available via API: download the 2017 NAPCS structure file from [here](https://www.census.gov/naics/napcs/?274456) to get 2017 NAPCS labels.

### Data sources

**Quarterly Census of Employment and Wages (QCEW)**

QCEW is a BLS product derived from unemployment insurance administrative data. Coverage includes essentially all private jobs as well as many civilian federal jobs. Data are released quarterly; currently, the most recent vintage is 2022 Q1. Data are available at the county level, albeit with some suppressions.

We use BLS-provided location quotients for the number of establishments and total quarterly wages by six-digit NAICS industry. BLS also provides location quotients for employment within a six-digit NAICS for each month within the quarter; we average these. 

##### Outstanding questions
- which measure correlates best with product code crosswalk?
- take the top X (5?) industries by concentration within a region provided they are above a cutoff of, e.g., 4X concentration. 
- when to include related industries that don't quite make it?

##### Extensions:
- Getis-Ord or other spatial modeling approach
- sensitivity analysis:
  - add/subtract to the raw values
  - consider the size of the base generally

### Sources

- https://www.federalreserve.gov/econres/ifdp/files/ifdp1329.pdf

##### Notes from 2017 Econ Census table

All Sectors: Industry by Products for the U.S. and States: 2017
Survey/Program:Economic Census
Year:2017
Table ID:EC1700NAPCSINDPRD
Dataset:ECNNAPCSIND2017

Release Date: 2020-11-19

Release Schedule:
The data in this file are based on the 2017 Economic Census. For information about economic census planned data product releases, see Economic Census: About: 2017 Release Schedules.

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
Number of establishments
Total sales, value of shipments, or revenue of establishments with the NAPCS collection code ($1,000)
Quantity produced for the NAPCS collection code (sectors 21 and 31-33 only)
Quantity shipped for the NAPCS collection code (sectors 21 and 31-33 only)
Sales, value of shipments, or revenue of NAPCS collection code ($1,000)
NAPCS collection code sales, value of shipments, or revenue as % of industry sales, value of shipments, or revenue (%)
NAPCS collection code sales, value of shipments, or revenue as % of total sales, value of shipments, or revenue of establishments with the NAPCS collection code (%)
Number of establishments with NAPCS collection code as % of industry establishments (%)
Range indicating percent of total NAPCS collection code sales, value of shipments, or revenue imputed
Relative standard error of NAPCS collection code sales, value of shipments, or revenue (%)

Each record includes a code which represents various types of products produced or carried, or services rendered, by an establishment.

For Wholesale Trade (42), data are published by Type of Operation (All establishments).

Geography Coverage:
The data are shown for employer establishments at the U.S. level for all sectors and at the U.S. and state level for sectors 44-45, 61, 62, 71, 72, and 81. For information about economic census geographies, including changes for 2017, see Economic Census: Economic Geographies.

Industry Coverage:
The data are shown at the 2- through 6-digit 2017 NAICS code levels for all NAICS industries and selected 7 and 8 digit 2017 NAICS code levels for select industries. For information about NAICS, see Economic Census: Technical Documentation: Code Lists.

Footnotes:
Transportation and Warehousing (48-49): footnote 106- Railroad transportation and U.S. Postal Service are out of scope.

FTP Download:
Download the entire table at: https://www2.census.gov/programs-surveys/economic-census/data/2017/sector00

API Information:
Economic census data are housed in the Census Bureau API. For more information, see Explore Data: Developers: Available APIs: Economic Census.

Methodology:
To maintain confidentiality, the U.S. Census Bureau suppresses data to protect the identity of any business or individual. The census results in this file contain sampling and/or nonsampling error. Data users who create their own estimates using data from this file should cite the U.S. Census Bureau as the source of the original data only.

To comply with disclosure avoidance guidelines, data rows with fewer than three contributing establishments are not presented. Additionally, establishment counts are suppressed when other select statistics in the same row are suppressed. For detailed information about the methods used to collect and produce statistics, including sampling, eligibility, questions, data collection and processing, data quality, review, weighting, estimation, coding operations, confidentiality protection, sampling error, nonsampling error, and more, see Economic Census: Technical Documentation: Methodology.

Symbols:
D - Withheld to avoid disclosing data for individual companies; data are included in higher level totals
N - Not available or not comparable
S - Estimate does not meet publication standards because of high sampling variability, poor response quality, or other concerns about the estimate quality. Unpublished estimates derived from this table by subtraction are subject to these same limitations and should not be attributed to the U.S. Census Bureau. For a description of publication standards and the total quantity response rate, see link to program methodology page.
X - Not applicable
A - Relative standard error of 100% or more
r - Revised
s - Relative standard error exceeds 40%
For a complete list of symbols, see Economic Census: Technical Documentation: Data Dictionary.

Source:
U.S. Census Bureau, 2017 Economic Census
For information about the economic census, see Business and Economy: Economic Census.

Contact Information:
U.S. Census Bureau
For general inquiries:
 (800) 242-2184/ (301) 763-5154
 ewd.outreach@census.gov
For specific data questions:
 (800) 541-8345
For additional contacts, see Economic Census: About: Contact Us.


### Other reading 

- https://arefiles.ucdavis.edu/uploads/filer_public/97/c2/97c2fab7-1d69-4754-b220-1aebe0fbe47f/cpc_uspc_working_paper.pdf
