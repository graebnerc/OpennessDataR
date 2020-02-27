# Assumes that the file gets evaluated from within data construction script

data.table::setDT(wdi)
wdi_tang <- wdi[, .(iso3c, year, Exports_USD_constant, Imports_USD_constant)]

data.table::setDT(pwt)
pwt_tang <- pwt[, .(country, year, Penn_GDP_PPP_total)] # in mil. 2011US$

total_tang <- data.table::merge.data.table(
  wdi_tang, pwt_tang, all = T,
  by.x = c("iso3c", "year"),
  by.y = c("country", "year"))

data.table::fwrite(total_tang,
                   "data-raw/aquamaninput/tang_basedata.csv")

#' Sets up the TPO indicator from Tang
#'
#' Reads output from Mathematica file that constructs the TOI indicator of Tang
#'
#' @param countries_considered A list of iso3c codes with countries to be used
#' @return A data.table with three columns: iso3c, year and TOI.
setup_tang <- function(countries_considered){
  tang_raw <- data.table::fread(
    "data-raw/aquamanoutput/tang-new.csv",
    header = F,
    colClasses = c("character", "double", "double"))

  data.table::setnames(tang_raw,
                       old=c("V1", "V2", "V3"),
                       new = c("iso3c", "year", "TOI"))
  tang <- tang_raw[iso3c %in% countries_considered]
  return(tang)
}
