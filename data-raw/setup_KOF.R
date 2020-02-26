#' Prepares KOF data
#'
#' Prepares the data for the KOF Globalization Index. Assumes that the raw data
#'  has already been downloaded and is present in the `data` directory.
#' @param version_kof A string with the version to be used; should be present
#'  in the `data` directory. Example: "2018" for the 2018 version.
#' @param countries_used The iso3c codes of the countries to be included.
#' @return A data.table.
setup_kof <- function(version_kof, countries_used){

  variables_used <- c(
    "code", "year",
    "KOFEcGI", # KOF_econ
    "KOFEcGIdf", # KOF_defacto
    "KOFEcGIdj", # KOF_dejure
    "KOFTrGI", # KOF_trade
    "KOFTrGIdf", # KOF_trade_df
    "KOFTrGIdj", # KOF_trade_dj
    "KOFFiGI", # KOF_finance
    "KOFFiGIdf", # KOF_finance_df
    "KOFFiGIdj" # KOF_finance_dj
  )

  kof <- haven::read_stata(paste0("data-raw/KOFGI_", version_kof, "_data.dta"))
  data.table::setDT(kof)
  kof <- kof[code %in% countries_used, ..variables_used]

  data.table::setnames(
    kof,
    new = c("KOF_econ", "KOF_defacto", "KOF_dejure",
            "KOF_trade", "KOF_trade_df", "KOF_trade_dj",
            "KOF_finance", "KOF_finance_df", "KOF_finance_dj"),
    old = c("KOFEcGI", "KOFEcGIdf", "KOFEcGIdj", "KOFTrGI",
            "KOFTrGIdf", "KOFTrGIdj", "KOFFiGI", "KOFFiGIdf",
            "KOFFiGIdj")
  )
  return(kof)
}
