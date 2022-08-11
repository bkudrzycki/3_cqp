## Master Script ##

setwd("~/polybox/Youth Employment/2 CQP/Paper")

#clean and reshape data
source("code/prep/cleaning.R")
source("code/prep/pivot_longer.R")
source("code/prep/recode.R")

# NOTES
# To save tables as .tex:
#to save as .tex: 
# as_gt() %>% 
  # gtsave("test.tex", path = "tables/")
  
# To include in RMarkdown:
# as_gt() %>% 
#  gt::as_latex() %>% 
#  as.character() %>%
#  cat()

# or
#as_kable_extra(caption = "Summary of fees (in FCFA)", 
               #booktabs = T)
