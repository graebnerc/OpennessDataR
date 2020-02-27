
load("data/openness_1y.rda")

full_data_5y <- dplyr::group_by(openness_1y, ccode, period)
full_data_5y <- dplyr::summarise_if(full_data_5y, is.numeric, mean, na.rm = T)
full_data_5y <- dplyr::ungroup(full_data_5y)
full_data_5y <- dplyr::mutate(
  full_data_5y,
  first_year = ifelse(Year == 1960, 1960,
                      ifelse(Year == 2016, 2016,
                             ifelse(Year == 1970, 1966, Year - 2)
                             )
                      )
  )

data.table::fwrite(full_data_5y, "data-raw/openness_5y.csv")
openness_5y <- full_data_5y

usethis::use_data(openness_5y, overwrite = T)
