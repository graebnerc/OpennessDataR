#' Get data from the UNCTAD database
#'
#' Downloads data directly from the UNCTAD database
#'
#' @param countries_considered Vector of iso3c codes of the countries for
#'  which data should be assembled.
#' @family download_helpers
setup_unctad <- function(countries_considered){
  print("UNCTAD data...")
  unctad_url <- "https://unctadstat.unctad.org/7zip/US_FdiFlowsStock.csv.7z"
  unctad_file <- "data-raw/UNCTAD_FDI.csv"
  unctad_names <- "data-raw/UNCTAD_CODES.csv"
  unctad_7z <- "data-raw/UNCTAD_FDI.7z"
  warning(paste0("UNCTAD data must be downloaded by hand since no ",
                 "7zip cross-platform package exists. ",
                 "Current version from Feb 2020."))

  if (!file.exists(unctad_file)){
    stop("UNCTAD FILE NOT AVAILABLE. PLS DOWNLOAD MANUALLY!")
  }
  unctad_codes <- data.table::fread(unctad_names,
                                    colClasses = c(rep("character", 2),
                                                   rep("double", 2)))
  print(paste0(
    "We remove the following countries due to data ambiguity: ",
    "Switzerland, Liechtenstein, Czechoslovakia, Eswatini, ",
    "Netherlands Antilles, 'Pacific Islands, Trust Territory', ",
    "Serbia and Montenegro,",
    "Socialist Federal Republic of Yugoslavia, as well as",
    "'Yemen, Arab Republic' and 'Yemen, Democratic' (both until 1989)"))
  unctad_codes <- unctad_codes[!Country %in% c(
    "Switzerland, Liechtenstein", "Czechoslovakia", "Eswatini",
    "Netherlands Antilles", "Pacific Islands, Trust Territory",
    "Serbia and Montenegro", "Socialist Federal Republic of Yugoslavia",
    "Yemen, Arab Republic", "Yemen, Democratic", "")]
  unctad_codes[, iso3c:=countrycode::countrycode(
    Country, "country.name", "iso3c")]
  data.table::setDF(unctad_codes)
  unctad_raw <- data.table::fread(unctad_file,
                                  colClasses = c("double",
                                                 rep("character", 6),
                                                 rep(c("double", "character"), 5)
                                                 )
                                  )
  unctad_raw[, country:=countrycode::countrycode(Economy,
                                                 "Code", "Country",
                                                 custom_dict = unctad_codes,
                                                 warn = FALSE)]
  unctad_raw <- unctad_raw[!is.na(country)]
  unctad_raw[, iso3c:=countrycode::countrycode(country,
                                               "country.name", "iso3c")]
  unctad <- unctad_raw[iso3c %in% countries_considered]
  unctad[, c("Economy", "Economy Label", "Mode", "Direction", "country",
             "US dollars at current prices in millions Footnote",
             "US dollars at current prices per capita Footnote",
             "Percentage of total world Footnote",
             "Percentage of Gross Domestic Product Footnote",
             "Percentage of Gross Fixed Capital Formation Footnote"
             ):=NULL]
  col_names_translation <- c(# TODO Brauchen wir um eindeutige Werte zu finden
    "Year"="Year",
    "Mode Label"="mode",
    "Direction Label"="direction",
    "US dollars at current prices in millions"="USD_current_millions",
    "US dollars at current prices per capita"="USD_current_pc",
    "Percentage of total world"="perc_total_world",
    "Percentage of Gross Domestic Product"="perc_GDP",
    "Percentage of Gross Fixed Capital Formation"="perc_GFCF",
    "iso3c"="iso3c"
  )
  data.table::setnames(unctad,
                       old = names(col_names_translation),
                       new = unname(col_names_translation))
  unctad <- tidyr::pivot_longer(
    data = unctad,
    cols = setdiff(unname(col_names_translation),
                   c("Year", "iso3c", "direction", "mode")),
    names_to = "unit",
    values_to = "value")
  unctad <- tidyr::unite(data = unctad,
                         "variable", "direction", "mode", "unit", sep="_")
  data.table::setDT(unctad)
  unctad <- unctad[, variable:=paste0("FDI_", variable)]
  unctad <- tidyr::pivot_wider(data = unctad,
                               id_cols = c("Year", "iso3c"),
                               names_from = "variable",
                               values_from = "value")
  data.table::setDT(unctad)

  unctad_red <- unctad[, .(Year, iso3c,
                           FDI_Inward_Stock_perc_GDP,
                           FDI_Outward_Stock_perc_GDP)]
  unctad_red[, UNC_FDI_total_stocks_GDP :=
               FDI_Inward_Stock_perc_GDP+FDI_Outward_Stock_perc_GDP]
  data.table::setnames(unctad_red,
                       old=c("FDI_Inward_Stock_perc_GDP",
                             "FDI_Outward_Stock_perc_GDP"),
                       new=c("UNC_FDI_in_stock_GDP",
                             "UNC_FDI_out_stock_GDP"))
  test_uniqueness(data_table = unctad_red,
                  index_vars = c("Year", "iso3c"))
  print("finished.")

  return(unctad_red)
}
