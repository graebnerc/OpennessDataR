download_wb <- FALSE
pwt_version <- "91"
source("R/setup_countrylist.R") # defines countries_used
source("R/setup_WDI.R")
source("R/setup_PWT.R")

wdi <- setup_wdi(download_wb = download_wb)
data.table::setDT(wdi)
wdi <- wdi[, .(iso3c, year, Exports_USD_constant, Imports_USD_constant)]

pwt <- setup_pwt(version_pwt = pwt_version, countries_used = countries_used)
data.table::setDT(pwt)
pwt <- pwt[, .(country, year, Penn_GDP_PPP_total)] # in mil. 2011US$

total_tang <- data.table::merge.data.table(
  wdi, pwt, all = T,
  by.x = c("iso3c", "year"),
  by.y = c("country", "year"))

data.table::fwrite(total_tang,
                   "data-raw/tang_basedata.csv")
