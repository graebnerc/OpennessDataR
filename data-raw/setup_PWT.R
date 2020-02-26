#' Prepares data from Penn World Table
#'
#' Prepares the data from the Penn World Tables. Assumes that the raw data
#'  has already been downloaded and is present in the `data` directory.
#' @param version_pwt A string with the version to be used; should be present
#'  in the `data` directory. Example: "91" for the 9.1 version.
#' @param countries_used The iso3c codes of the countries to be included.
#' @return A data.table.
setup_pwt <- function(version_pwt, countries_used){
  variables_used <- c("countrycode", "year", "rgdpo", "pop", "hc", "csh_i")
  pwt_datafile <- paste0("data-raw/pwt", version_pwt, ".dta")
  pwt_raw <- data.table::as.data.table(haven::read_dta(pwt_datafile))
  pwt <- pwt_raw[countrycode %in% countries_used, ..variables_used]
  pwt[, inv_share := csh_i * 100]
  pwt[, csh_i := NULL]
  pwt[, Penn_GDP_PPP := rgdpo / (pop * 1000)] # GDP per capita at PPP
  pwt[, Penn_GDP_PPP_log := log(Penn_GDP_PPP)] # log of GDP per capita at PPP
  pwt[, pop_log := log(pop)] # log of population

  pwt[, GDP_pc_growth := (Penn_GDP_PPP_log - data.table::shift(
    Penn_GDP_PPP_log))*100,
    by = .(countrycode)]
  pwt[, pop_growth := (pop_log - data.table::shift(pop_log))*100,
      by = .(countrycode)]

  pwt[, GDP_pc_growth := ifelse(abs(GDP_pc_growth) < 30, GDP_pc_growth, NA)]

  data.table::setnames(pwt,
                       old = c("countrycode", "rgdpo"),
                       new = c("country", "Penn_GDP_PPP_total")
                       )
  return(pwt)
}
