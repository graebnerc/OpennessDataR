kof_version <- "2019"
pwt_version <- "91"
download_wb <- FALSE
download_lmf <- FALSE
download_chinn_ito <- FALSE
download_tariff_res <- FALSE
source("data-raw/setup_countrylist.R") # defines countries_used
source("R/helper_functions.R")
source("data-raw/setup_PWT.R")
source("data-raw/setup_KOF.R")
source("data-raw/setup_WDI.R")
source("data-raw/setup_LMF.R")
source("data-raw/setup_UNCTAD.R")
source("data-raw/setup_ChinnIto.R")
source("data-raw/setup_Tariff_RES.R")
source("data-raw/setup_INDICATORS.R")
source("data-raw/setup_FTI.R")
source("data-raw/setup_WITS.R")
source("data-raw/setup_HF.R")

# Setup variables and merge into full_data-------------------------------------
pwt <- setup_pwt(version_pwt = pwt_version, countries_used = countries_used)
kof <- setup_kof(version_kof = kof_version, countries_used = countries_used)

full_data <- data.table::merge.data.table(pwt, kof, all = T,
                                          by.x = c("country", "year"),
                                          by.y = c("code", "year"))

wdi <- setup_wdi(download_wb = download_wb)

full_data <- data.table::merge.data.table(full_data, wdi, all = T,
                                          by.x = c("country", "year"),
                                          by.y = c("iso3c", "year"))
source("data-raw/setup_TANG.R")

tang_data <- setup_tang(countries_considered = countries_used)

full_data <- data.table::merge.data.table(full_data, tang_data, all = T,
                                          by.x = c("country", "year"),
                                          by.y = c("iso3c", "year"))

indicators <- setup_indicators()

full_data <- data.table::merge.data.table(full_data, indicators, all = T,
                                          by.x = c("country", "year"),
                                          by.y = c("ccode", "year"))

chinn_ito_data <- setup_chinn_ito(download_chinn_ito, countries_used,
                                  version_nb="2017")

full_data <- data.table::merge.data.table(full_data, chinn_ito_data, all = T,
                                          by.x = c("country", "year"),
                                          by.y = c("iso3c", "year"))

lmf_data <- setup_lmf(download_data = download_lmf,
                      countries_considered = countries_used)

full_data <- data.table::merge.data.table(full_data, lmf_data, all = T,
                                          by.x = c("country", "year"),
                                          by.y = c("iso3c", "year"))

unctad_data <- setup_unctad(countries_considered = countries_used)

full_data <- data.table::merge.data.table(full_data, unctad_data, all = T,
                                          by.x = c("country", "year"),
                                          by.y = c("iso3c", "Year"))

fti_data <- setup_FTI(countries_considered = countries_used)

full_data <- data.table::merge.data.table(full_data, fti_data, all = T,
                                          by.x = c("country", "year"),
                                          by.y = c("iso3c", "Year"))

tariff_RES <- setup_tariff_res(download_data = download_tariff_res,
                               countries_considered = countries_used)

full_data <- data.table::merge.data.table(full_data, tariff_RES, all = T,
                                          by.x = c("country", "year"),
                                          by.y = c("iso3c", "year"))

wits_data <- setup_wits(countries_considered = countries_used)

full_data <- data.table::merge.data.table(full_data, wits_data, all = T,
                                          by.x = c("country", "year"),
                                          by.y = c("iso3c", "year"))

hf_data <- setup_hf(countries_considered = countries_used)

full_data <- data.table::merge.data.table(full_data, hf_data, all = T,
                                          by.x = c("country", "year"),
                                          by.y = c("iso3c", "year"))

# Interpolation of missings----------------------------------------------------
full_data <- dplyr::group_by(full_data, country)
full_data <- dplyr::mutate(
  full_data,
  FTI_original_ipo=zoo::na.approx(FTI_original, na.rm=FALSE),
  FTI_reduced_ipo=zoo::na.approx(FTI_reduced, na.rm=FALSE),
  Tariff_WITS_ipo=zoo::na.approx(Tariff_WITS, na.rm=FALSE)
  )
full_data <- dplyr::ungroup(full_data)

data.table::setDT(full_data)

full_data <- full_data[year>1959]

# Add manually collected data--------------------------------------------------
old_data <- data.table::fread("data-raw/final_openness_data_1y.csv")
manual_data_names <- c(
  "ComplexityGroup",
  "LMF_open_pv", "FIN_CUR", "CAPITAL",
  "ccode", "Year")
manual_data <- dplyr::select(old_data, dplyr::one_of(manual_data_names))
manual_data <- dplyr::mutate(manual_data, Year=as.double(Year))
full_data <- dplyr::left_join(full_data, manual_data,
                              by=c("country"="ccode", "year"="Year"))

# Make periods-----------------------------------------------------------------
full_data$period <- cut(full_data$year, seq(1900, 2100, 5)) # set 5 year periods

# Check for duplicates---------------------------------------------------------
data.table::setDT(full_data)
test_uniqueness(data_table = full_data,
                index_vars = c("country", "year"))
full_data[, c("pop"):=NULL]

# Translate into old column names----------------------------------------------

translation <- c(# original data = this data
  "ccode"="country", "Year"="year", "hc"="hc", "rgdpo"="Penn_GDP_PPP_total",
  "KOF_econ"="KOF_econ", "KOF_defacto"="KOF_defacto", "KOF_dejure"="KOF_dejure",
  "KOF_trade"="KOF_trade", "KOF_trade_df"="KOF_trade_df",
  "KOF_trade_dj"="KOF_trade_dj", "KOF_finance"="KOF_finance",
  "KOF_finance_df"="KOF_finance_df", "KOF_finance_dj"="KOF_finance_dj",
  "KAOPEN"="chinn_ito", # "KA_Index"="chinn_ito_normed",
  "pop_log"="pop_log", "pop_growth"="pop_growth",  "population"="pop",
  "Trade_to_GDP"="Trade_to_GDP", "EXP_to_GDP"="Exports_to_GDP",
  "IMP_to_GDP"="Imports_to_GDP", "Alcala"="Alcala", "CTS"="CTS",
  "Lietal"="Lietal", "inflation"="inflation", "period"="period",
  "Penn_GDP_PPP"="Penn_GDP_PPP", "Penn_GDP_PPP_log"="Penn_GDP_PPP_log",
  "GDP_pc_growth"="GDP_pc_growth", "inv_share"="inv_share",
  "ComplexityGroup"="ComplexityGroup",
  "IncomeGroup"="IncomeGroup", "Tariff_RES"="Tariff_RES",
  "UNC_in_stock_GDP"="UNC_in_stock_GDP",
  "UNC_out_stock_GDP"="UNC_out_stock_GDP",
  "UNC_FDI_total_stocks_GDP"="UNC_FDI_total_stocks_GDP"
)

data.table::setnames(full_data,
                     old = unname(translation),
                     new = names(translation),
                     skip_absent = TRUE)

# Save 1-year version----------------------------------------------------------
data.table::fwrite(full_data, "data-raw/openness_1y.csv")
openness_1y <- full_data

# usethis::use_data_raw("openness_1y.csv")
usethis::use_data(openness_1y, overwrite = T)

# Call 5-year version----------------------------------------------------------

source("data-raw/openness_5y-csv.R")
