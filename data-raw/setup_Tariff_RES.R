#' Get Tariff_RES
#'
#' Downloads Tariff_RES measure from Chris Papageorgiou's website.
#'
#' DESCRIPTION.
#'
#' @param download_data If TRUE, data will be downloaded from the internet
#' @param countries_considered Vector of iso3c codes of the countries for
#'  which data should be assembled.
#' @family download_helpers
setup_tariff_res <- function(download_data, countries_considered){
  data_link <- "http://www.chrispapageorgiou.com/papers/data%20request_ilo.dta"
  res_file <- "data-raw/Tariff_RES.csv"
  if (!download_data & file.exists(res_file)){
    res_data <- data.table::fread(
      res_file,
      colClasses = c("double", "double", "character")
      )
  } else {
    tmp <- tempfile(fileext = ".dta")
    download.file(data_link, tmp,
                  quiet = FALSE)
    raw_file <- haven::read_dta(tmp)
    data.table::setDT(raw_file)
    res_data <- raw_file[, .(country, year, ifscode, tariff)]
    res_data[, iso3c:=countrycode(ifscode, "imf", "iso3c")]
    res_data[, country:=NULL]
    res_data[, ifscode:=NULL]
    res_data <- res_data[iso3c %in% countries_considered]
    data.table::setnames(res_data, old ="tariff", new="Tariff_RES")
    data.table::fwrite(res_data, res_file)
  }
  return(res_data)
}
