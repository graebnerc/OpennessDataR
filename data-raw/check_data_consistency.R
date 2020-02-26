#' Check consistency of old and new trade data

# Final checks-----------------------------------------------------------------

only_old <- setdiff(names(old_data), names(full_data)) # only in old
eliminated <- c("Frankel", "ln_FTI_Index_ipo",
                "LMF_FDI_in", "LMF_FDI_out",
                "LMF_in_GDP", "LMF_out_GDP",
                "UNC_in_GDP",  "UNC_out_GDP")
from_florian <- c("CAPITAL", "FIN_CUR", "KA_Index")
renamed <- c("FTI_Index", "FTI_Index_ipo",
             "FTI_trade", "FTI_trade_ipo",
             "UNC_FDI_out", "UNC_FDI_in")
setdiff(only_old, c(renamed, eliminated, from_florian))

only_new <- setdiff(names(full_data), names(old_data)) # only in new
new_ones <- c("Exports_USD_current", "Exports_USD_constant",
              "Imports_USD_current",  "Imports_USD_constant",
              "chinn_ito_normed", "FTI_panel", "HF_econ")
renamed <- c("FTI_original", "FTI_reduced", "FTI_original_ipo",
             "FTI_reduced_ipo", "UNC_in_stock_GDP", "UNC_out_stock_GDP",
             "UNC_FDI_in_stock_GDP", "UNC_FDI_out_stock_GDP")
setdiff(only_new, c(new_ones, renamed))
# FIN_CUR ist nicht mehr öffentlich, wir nehmen den von Florian
# CAPITAL ist nicht mehr öffentlich, wir nehmen den von Florian
