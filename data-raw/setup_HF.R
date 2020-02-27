#' Reads data from Heritage Foundation
setup_hf <- function(countries_considered){
  warning(paste0("The data from the Heritage foundation cannot be downloaded ",
                 "automatically. ",
                 "It has to be updated manually via: ",
                 "https://www.heritage.org/index/explore ",
                 "Current version: 2019 from February 2020."))
  hf <- data.table::fread(
    "data-raw/hf_data.csv", sep = ",", dec = ".", na.strings = "N/A",
    select = c("Overall Score", "Investment Freedom", "Trade Freedom",
               "Name", "Index Year"),
    col.names = c("Overall Score"="HF_econ", "Investment Freedom"="HF_fin",
                  "Trade Freedom"="HF_trade", "Name"="country",
                  "Index Year"="year"),
    colClasses = c("character", rep("double", 14)))
  countries_removed <- c("Eswatini", "Kosovo", "Micronesia")
  hf[!country %in% countries_removed, iso3c:=countrycode::countrycode(
    country, "country.name", "iso3c")]
  hf[, country:=NULL]
  hf <- hf[iso3c %in% countries_considered]
  test_uniqueness(data_table = hf,
                  index_vars = c("iso3c", "year"))
  return(hf)
}
