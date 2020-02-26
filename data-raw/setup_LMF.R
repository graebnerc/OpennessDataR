#' Get data from LMF
#'
#' Assembles relevant indicators from LMF database
#'
#' Assembles relevant indicators from the Lane-Milesi-Ferreti database. Because
#'  data is published only in Excel, the dataset as such must be downloaded
#'  manually and placed in the data-raw folder. It then can be processed using
#'  this function. This is done to avoid any functions that rely on JAVA, since
#'  this often becomes problematic in practice.
#' @param download_data If TRUE, data will be downloaded from the internet
#' @param countries_considered Vector of iso3c codes of the countries for
#'  which data should be assembled.
#' @family download_helpers
setup_lmf <- function(download_data, countries_considered){
  print("LMF data...")
  warning(paste0("LMF data is not updated automatically",
                 "Currently using 1970-2011 data (May 2019)."))

  lmf_file <- "data-raw/lmf.csv.gz"

  if (!file.exists(lmf_file)){
    warning("LMF data not available in data-raw. This data must be downloaded
            manually from http://www.philiplane.org/EWN.html")
  } else {
    lmf_cols <- c(
      "Year", "Country Name",
      "Portfolio equity assets (stock)",
      "Portfolio equity liabilities (stock)",
      "Portfolio debt assets", "Portfolio debt liabilities",
      "FDI assets (stock)",  "FDI assets (other)",
      "FDI liabilities (stock)", "FDI liabilities (other)",
      "Debt assets (stock)", "Debt liabilities (stock)",
      "NFA", "NFA/GDP",
      "Total assets", "Total liabilities"
    )
    lmf_new_names <- c(
      "year", "iso3c",
      "lmf_port_eq_asst_stock",
      "lmf_port_eq_liab_stock",
      "lmf_port_dbt_asst", "lmf_port_dbt_liab",
      "lmf_fdi_asst_stock", "lmf_fdi_asst_other",
      "lmf_fdi_liab_stock", "lmf_fdi_liab_other",
      "lmf_debt_asst_stock", "lmf_debt_liab_stock",
      "lmf_nfa", "lmf_nfa_gdp",
      "lmf_total_asst", "lmf_total_liab"
    )
    lmf_raw <- data.table::fread(lmf_file, na.strings = "")
    data.table::setDT(lmf_raw)
    data.table::setnames(lmf_raw, old = lmf_cols, new = lmf_new_names)
    lmf_raw[!iso3c%in%c("Central African Rep.", "Euro Area", "Kosovo"),
            iso3c:=countrycode::countrycode(iso3c, "country.name", "iso3c")]
    lmf <- lmf_raw[iso3c %in% countries_considered, ..lmf_new_names]
    lmf[, lmf_nfa_gdp:=gsub(pattern = "%",
                            replacement = "",
                            x = lmf_nfa_gdp)]


    #' Transforms cols with characters into doubles explicitly
    #'
    #' Conducts the following cleaning procedures:
    #'  1. NA values remain NA.
    #'  2. If the string contains the substring 'NA', set to NA
    #'  3. Remove points from strings
    #'  4. Convert to double
    clear_lmf_chars <- Vectorize(
      function(x_old){
        if (is.na(x_old) | (grepl("NA", x_old))){
          x_new <- NA
          return(x_new)
        }
        x_sub <- gsub(pattern = ",",
                      replacement = ".",
                      x = gsub(
                        pattern = "\\.",
                        replacement = "",
                        x = x_old)
        )
        x_new <- as.double(x_sub)
        return(x_sub)
      },
      SIMPLIFY = T, USE.NAMES = F
    )

    lmf[,
        (setdiff(lmf_new_names, "iso3c")):= lapply(.SD, clear_lmf_chars),
        .SDcols = setdiff(lmf_new_names, "iso3c")
        ]
  }
  lmf[, year:=as.integer(year)]

  lmf <- lmf[, lapply(.SD, as.double), by=iso3c]

  ###
  lmf_red <- lmf[, .(iso3c, year,
                     lmf_total_asst, lmf_total_liab,
                     lmf_port_eq_asst_stock, lmf_port_eq_liab_stock,
                     lmf_fdi_asst_stock, lmf_fdi_liab_stock)]

  lmf_red[, LMF_FDI_total_stocks_GDP:=lmf_fdi_asst_stock+lmf_fdi_liab_stock]
  lmf_red[, LMF_open:=lmf_port_eq_asst_stock+lmf_port_eq_liab_stock]
  lmf_red[, LMF_EQ:=lmf_total_asst+lmf_total_liab]
  lmf_final <- lmf_red[, .(iso3c, year,
                           LMF_FDI_total_stocks_GDP, LMF_open, LMF_EQ)]

  # Total assets + Total liabilities
  # FDI assets (stock) + FDI liabilities (stock)
  # gibt's nicht im LMF-Datensatz (da wird nicht zwischen inward und outward unterschieden); haben wir aber eh schon bei UNCTAD, kann man also rausnehmen mEn
  # Portfolio equity assets (stock) + Portfolio equity liabilities (stock)
  ###

  stopifnot(test_uniqueness(lmf_final, c("iso3c", "year")))
  print("finished.")
  return(lmf_final)
}
