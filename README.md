ncaahoopsscraper
================
A tool to easily scrape NCAA basketball game results from [Sports Reference](https://www.sports-reference.com/cbb/).

Install
-------

Install from GitHub with the following code:

``` r
if (!requireNamespace("devtools", quietly = TRUE)) {
  install.packages("devtools")
}
devtools::install_github("kurtawirth/ncaahoopsscraper")
```

Included in this package as dependents are [dplyr](https://github.com/tidyverse/dplyr) and [rvest](https://github.com/hadley/rvest).

Usage
-----

There is currently only one function currently live for ncaahoopsscraper.

Simply input the beginning date of the season desired in quotes followed by the end date. Importantly, these dates must be in YYYY/MM/DD format.

``` scrape
ncaahoopsscraper("2017/11/10", "2018/04/02")
```

The tool will output a tidy object that includes the games' dates, home team and its score, and the visiting team and its score. If you choose, you may then ouput this object as you wish (write.csv, for example). The package also includes files for each season from 2010 (the earliest this tool currently works for) until 2018 as well as a consolidated version with all seasons during that timespan.
