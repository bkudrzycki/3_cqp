## Master Script ##

setwd("~/polybox/Youth Employment/2 CQP/Paper")

#clean and reshape data
source("code/prep/cleaning.R")
source("code/prep/pivot_longer.R")
source("code/prep/recode.R")
source("code/prep/costs_benefits_recode.R")

#tables

source("code/descriptives.R")
source("code/allowances.R")
source("code/competencies.R")
source("code/experience.R")
source("code/fees.R")
source("code/ratings.R")
source("code/productivity.R")
source("code/costs_benefits.R")


#figures

#regressions
source("code/regression.R")

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
