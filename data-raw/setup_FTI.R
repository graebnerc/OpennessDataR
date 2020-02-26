setup_FTI <- function(countries_considered){
  warning(paste0("The FTI data cannot be downloaded automatically. ",
                 "It has to be updated manually via: ",
                 "https://www.fraserinstitute.org/economic-freedom/dataset ",
                 "Current version: 2019 from February 2020."))
  fti_orig <- data.table::fread(
    "data-raw/FTI_original.csv",
  dec = ",", sep = ";",
  select = c("Year", "ISO_Code", "Tariffs", "Regulatory trade barriers",
             "Black market exchange rates",
             "Controls of the movement of capital and people",
             "Freedom to Trade Internationally"),
  colClasses = c(
    "Year"="double",
    "ISO_Code"="character",
    "Tariffs"="double",
    "Regulatory trade barriers"="double",
    "Black market exchange rates"="double",
    "Controls of the movement of capital and people"="double",
    "Freedom to Trade Internationally"="double")

  )
  fti_orig$FTI_original <- round(rowMeans(fti_orig[, 3:6]), 2)
  fti_orig$FTI_reduced <- round(rowMeans(fti_orig[, 3:4]), 2)
  fti_orig <- fti_orig[, .(Year, ISO_Code, FTI_original, FTI_reduced)]

  fti_panel <- data.table::fread(
    "data-raw/FTI_panel.csv",
    skip = 2, dec = ",", sep = ";",
    select = c("Year", "ISO_Code",
               "4  Freedom to trade internationally"),
    colClasses = c(
      "Year"="double",
      "ISO_Code"="character",
      "4  Freedom to trade internationally"="double"),
    col.names = c("Year", "iso3c", "FTI_panel")
    )

  fti_full <- data.table::merge.data.table(
    fti_panel, fti_orig,
    by.x = c("iso3c", "Year"),
    by.y = c("ISO_Code", "Year"))
  fti_full <- fti_full[!is.na(Year)]

  return(fti_full)
}
