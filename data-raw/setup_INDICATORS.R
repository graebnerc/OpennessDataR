#' Prepares data from the self-produced indicator file
#'
#' Prepares the data from the indicators colleceted manually. Assumes that the
#'  raw data has already been downloaded and is present in the `data` directory.
#' @param version_pwt A string with the version to be used; should be present
#'  in the `data` directory. Example: "91" for the 9.1 version.
#' @param countries_used The iso3c codes of the countries to be included.
#' @return A data.table.
setup_indicators <- function(){
  indicators <- data.table::fread("data-raw/Tang_CES_data.csv")
  variables_used <- c("year", "ccode", "CTS", "Lietal", "Alcala")
  indicators <- indicators[, ..variables_used]
  return(indicators)
}
