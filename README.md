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


### Other reading 

- https://arefiles.ucdavis.edu/uploads/filer_public/97/c2/97c2fab7-1d69-4754-b220-1aebe0fbe47f/cpc_uspc_working_paper.pdf
