
load("data/openness_1y.rda")

full_data_5y <- openness_1y %>%
  dplyr::group_by(ccode, period) %>%
  dplyr::summarise_if(is.numeric, mean, na.rm = T) %>%
  dplyr::ungroup() %>%
  dplyr::mutate(first_year = ifelse(Year == 1960, 1960,
                                    ifelse(Year == 2016, 2016,
                                           ifelse(Year == 1970, 1966, Year - 2)
                                    )
  ))

data.table::fwrite(full_data_5y, "data-raw/openness_5y.csv")
openness_5y <- full_data_5y

usethis::use_data(openness_5y, overwrite = T)
