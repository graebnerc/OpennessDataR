source("R/setup_countrylist.R")
# WITS-Product-MFN.csv and WITS-Product-AHS.csv come from:
# https://wits.worldbank.org/CountryProfile/en/country/by-country/startyear/LTST/endyear/LTST/tradeFlow/Import/indicator/AHS-WGHTD-AVRG/partner/WLD/product/Total
# https://wits.worldbank.org/CountryProfile/en/country/by-country/startyear/LTST/endyear/LTST/tradeFlow/Import/indicator/MFN-WGHTD-AVRG/partner/WLD/product/Total

setup_wits <- function(countries_considered){
  # AHS
  wits_ahs <- data.table::fread("data-raw/WITS-Product-AHS.csv")
  obs_colums <- ncol(wits_ahs) - 5
  wits_ahs <- data.table::fread("data-raw/WITS-Product-AHS.csv",
                                header = T, sep = ";", dec = ",",
                                colClasses = c(rep("character", 5),
                                               rep("double", obs_colums)))
  removed_countries <- c("Ethiopia(excludes Eritrea)", "European Union",
                         "Occ.Pal.Terr", "Other Asia, nes",
                         "Serbia, FR(Serbia/Montenegro)", "Sudan", "Fm Sudan")
  wits_ahs <- wits_ahs[`Partner Name`=="World" &
                         `Trade Flow`=="Import" &
                         `Product Group`=="All Products" &
                         Indicator=="AHS Weighted Average (%)" &
                         !`Reporter Name` %in%removed_countries]
  wits_ahs[, iso3c:=countrycode::countrycode(`Reporter Name`,
                                             "country.name", "iso3c")]
  wits_ahs[, c("Partner Name", "Trade Flow",
               "Product Group", "Indicator", "Reporter Name"):=NULL]
  wits_ahs <- tidyr::pivot_longer(wits_ahs,
                                  cols = -c("iso3c"),
                                  names_to = "year",
                                  values_to = "ahs_weight_avg")

  # MFN
  wits_mfn <- data.table::fread("data-raw/WITS-Product-MFN.csv")
  obs_colums <- ncol(wits_mfn) - 5
  wits_mfn <- data.table::fread("data-raw/WITS-Product-MFN.csv",
                                header = T, sep = ";", dec = ",",
                                colClasses = c(rep("character", 5),
                                               rep("double", obs_colums)))


  wits_mfn <- wits_mfn[`Partner Name`=="World" &
                         `Trade Flow`=="Import" &
                         `Product Group`=="All Products" &
                         Indicator=="MFN Weighted Average (%)" &
                         !`Reporter Name` %in%removed_countries]
  wits_mfn[, iso3c:=countrycode::countrycode(`Reporter Name`,
                                             "country.name", "iso3c")]
  wits_mfn[, c("Partner Name", "Trade Flow",
               "Product Group", "Indicator", "Reporter Name"):=NULL]

  wits_mfn <- tidyr::pivot_longer(wits_mfn,
                                  cols = -c("iso3c"),
                                  names_to = "year",
                                  values_to = "mfn_weight_avg")

  # TOTAL
  data.table::setDT(wits_mfn)
  data.table::setDT(wits_ahs)
  wits_full <- data.table::merge.data.table(
    wits_ahs, wits_mfn, all = T,
    by.x = c("iso3c", "year"),
    by.y = c("iso3c", "year"))

  wits_full <- wits_full[iso3c %in%countries_considered]
  wits_full[, Tariff_WITS:=100 - ((ahs_weight_avg+mfn_weight_avg)/2)]
  wits_full[, year:=as.double(year)]
  wits_full[, c("ahs_weight_avg", "mfn_weight_avg"):=NULL]
  stopifnot(test_uniqueness(data_table = wits_full,
                            index_vars = c("iso3c", "year")))

  return(wits_full)
}

