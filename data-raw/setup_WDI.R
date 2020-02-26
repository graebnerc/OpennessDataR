#' Prepares World Bank data
#'
#' Prepares the data from the WDI database by the World Bank (inflation,
#'  population and trade-to-GDP ratio). Either downloads the data directly
#'  or uses the intermediate data stored in `data-raw`.
#' @param download_wb Logical; if TRUE then data gets downloaded using the
#'  `WDI` package, if FALSE the data stored in the `data-raw` directory is
#'  used.
#' @return A data.table.
setup_wdi <- function(download_wb){
  if (download_wb == TRUE) {
    wb_countries <- countrycode::countrycode(
      countries_used, "iso3c", "iso2c", warn = F)[!is.na(wb_countries)]

    world_bank <- WDI::WDI(
      country = wb_countries,
      indicator = c("FP.CPI.TOTL.ZG", "NE.TRD.GNFS.ZS", "NE.EXP.GNFS.ZS",
                    "NE.IMP.GNFS.ZS", "SP.POP.TOTL", "NE.EXP.GNFS.CD",
                    "NE.EXP.GNFS.KD", "NE.IMP.GNFS.CD", "NE.IMP.GNFS.KD"),
      extra = TRUE,
      start = 1950
    )
    data.table::setDT(world_bank)
    data.table::setnames(
      world_bank, # TODO Check code for FP.CPI.TOTL.ZG
      old = c("FP.CPI.TOTL.ZG", "NE.TRD.GNFS.ZS", "NE.EXP.GNFS.ZS",
              "NE.IMP.GNFS.ZS", "SP.POP.TOTL",
              "NE.EXP.GNFS.CD", "NE.EXP.GNFS.KD",
              "NE.IMP.GNFS.CD", "NE.IMP.GNFS.KD",
              "income"),
      new = c("inflation", "Trade_to_GDP", "Exports_to_GDP",
              "Imports_to_GDP", "population",
              "Exports_USD_current", "Exports_USD_constant",
              "Imports_USD_current", "Imports_USD_constant",
              "IncomeGroup"), skip_absent = T
    )
    world_bank[, iso3c:=countrycode::countrycode(iso2c, "iso2c", "iso3c")]
    world_bank[, year := as.double(year)]
    world_bank[, c("country", "iso2c", "region", "capital", "longitude",
                   "latitude", "lending") := NULL]
    data.table::fwrite(world_bank, "data-raw/wdi-data.csv")
  } else {
    world_bank <- data.table::fread("data-raw/wdi-data.csv",
                                    colClasses=c(rep("double", 10),
                                                 rep("character", 2)))
  }
  return(world_bank)
}
