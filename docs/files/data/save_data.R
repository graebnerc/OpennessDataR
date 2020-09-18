library(haven)
library(data.table)

openness_y1 <- fread("openness_1y.csv")
openness_y5 <- fread("openness_5y.csv")

haven::write_dta(openness_y1, path = "openness_1y.dta")
haven::write_dta(openness_y5, path = "openness_5y.dta")

saveRDS(openness_y1, "openness_1y.rds")
saveRDS(openness_y5, "openness_5y.rds")
