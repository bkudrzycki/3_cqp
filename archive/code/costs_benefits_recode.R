###############################
## COSTS AND BENEFITS CODING ##
###############################

packages <- c("tidyverse", "labelled", "gtsummary", "ggplot2")

# Install packages not yet installed
installed_packages <- packages %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  install.packages(packages[!installed_packages], silent = TRUE)
}

# Load packages
invisible(lapply(packages, library, character.only = TRUE))

rm(packages, installed_packages)

# Set working directory
setwd("~/polybox/Youth Employment/2 CQP/Paper")

#load data
load("data/df.rda")


## SIMPLEST

df <- df %>% rowwise() %>% mutate(cb_simplest0 = sum(total_fees/4, -all_allowances*12, na.rm = T))
x <- df %>% filter(wave == 0) %>% rowwise() %>% mutate(cb_simplest0_baseline = sum(total_fees/4, -all_allowances*12, na.rm = T)) %>% select(IDYouth, cb_simplest0_baseline)
df <- df %>% left_join(x, by = "IDYouth")

df <- df %>% rowwise() %>% mutate(cb_simplest = sum(total_fees/4, -benefits_simple*12, na.rm = T))
x <- df %>% filter(wave == 0) %>% rowwise() %>% mutate(cb_simplest_baseline = sum(total_fees/4, -benefits_simple*12, na.rm = T)) %>% select(IDYouth, cb_simplest_baseline)
df <- df %>% left_join(x, by = "IDYouth")

df <- df %>% rowwise() %>% mutate(cb_simplest1 = sum(total_fees/4, -monthly_benefits*12, na.rm = T))
x <- df %>% filter(wave == 0) %>% rowwise() %>% mutate(cb_simplest1_baseline = sum(total_fees/4, -monthly_benefits*12, na.rm = T)) %>% select(IDYouth, cb_simplest1_baseline)
df <- df %>% left_join(x, by = "IDYouth")



## SIMPLER

df <- df %>% rowwise() %>% mutate(cb_simpler = sum(total_fees/4, -benefits_simple*12, total_training_costs*12/FS6.1, na.rm = T))
x <- df %>% filter(wave == 0) %>% rowwise() %>% mutate(cb_simpler_baseline = sum(total_fees/4, -benefits_simple*12, total_training_costs*12/FS6.1, na.rm = T)) %>% select(IDYouth, cb_simpler_baseline)
df <- df %>% left_join(x, by = "IDYouth")

df <- df %>% rowwise() %>% mutate(cb_simpler1 = sum(total_fees/4, -monthly_benefits*12, -total_training_costs*12/FS6.1, na.rm = T))
x <- df %>% filter(wave == 0) %>% rowwise() %>% mutate(cb_simpler1_baseline = sum(total_fees/4, -monthly_benefits*12, -total_training_costs*12/FS6.1, na.rm = T)) %>% select(IDYouth, cb_simpler1_baseline)
df <- df %>% left_join(x, by = "IDYouth")

# estimated trainer hours of training per month: days per week (FS6.9) * hours on last day (FS6.10) * 4 * number of trainers instructing apps (FS6.8)
# trainer hourly wage: monthly wage of skilled employee (FS5.2_1_2) / 40 hours per week / 4 weeks

df <- df %>% mutate(monthly_time_trained = FS6.9*FS6.10*4)

df <- df %>% rowwise() %>% mutate(cb_simpler2 = sum(total_fees/4, -benefits_simple*12, -total_training_costs*12/FS6.1, -monthly_time_trained*FS6.8*FS5.2_1_2/40/4/FS6.1, na.rm = T))
x <- df %>% filter(wave == 0) %>% rowwise() %>% mutate(cb_simpler2_baseline = sum(total_fees/4, -benefits_simple*12, total_training_costs*12/FS6.1-monthly_time_trained*FS6.8*FS5.2_1_2/40/4/FS6.1, na.rm = T)) %>% select(IDYouth, cb_simpler2_baseline)
df <- df %>% left_join(x, by = "IDYouth")

df <- df %>% rowwise() %>% mutate(cb_simpler3 = sum(total_fees/4, -monthly_benefits*12, -total_training_costs*12/FS6.1, -monthly_time_trained*FS6.8*FS5.2_1_2/40/4/FS6.1, na.rm = T))
x <- df %>% filter(wave == 0) %>% rowwise() %>% mutate(cb_simpler3_baseline = sum(total_fees/4, -monthly_benefits*12, -total_training_costs*12/FS6.1, -monthly_time_trained*FS6.8*FS5.2_1_2/40/4/FS6.1, na.rm = T)) %>% select(IDYouth, cb_simpler3_baseline)
df <- df %>% left_join(x, by = "IDYouth")

## SIMPLE/COMPLEX

df <- df %>% rowwise() %>% mutate(cb_simple1 = sum(total_fees/4, FS5.2_1_2*6+FS5.2_1_4*6, -benefits_simple*12, -total_training_costs*12/FS6.1, na.rm = T))
x <- df %>% filter(wave == 0) %>% rowwise() %>% mutate(cb_simple1_baseline = sum(total_fees/4, FS5.2_1_2*6+FS5.2_1_4*6, -benefits_simple*12, -total_training_costs*12/FS6.1, na.rm = T)) %>% select(IDYouth, cb_simple1_baseline)
df <- df %>% left_join(x, by = "IDYouth")

df <- df %>% rowwise() %>% mutate(cb_complex1 = sum(total_fees/4, FS5.2_1_2*6+FS5.2_1_4*6, -benefits_simple*12, -total_training_costs*12/FS6.1, -monthly_time_trained*FS6.8*FS5.2_1_2/40/4/FS6.1, na.rm = T))
x <- df %>% filter(wave == 0) %>% rowwise() %>% mutate(cb_complex1_baseline = sum(total_fees/4, FS5.2_1_2*6+FS5.2_1_4*6, -benefits_simple*12, -total_training_costs*12/FS6.1, -monthly_time_trained*FS6.8*FS5.2_1_2/40/4/FS6.1, na.rm = T)) %>% select(IDYouth, cb_complex1_baseline)
df <- df %>% left_join(x, by = "IDYouth")

df <- df %>% rowwise() %>% mutate(cb_simple2 = sum(total_fees/4, FS5.2_1_2*6+FS5.2_1_4*6, -monthly_benefits*12, -total_training_costs*12/FS6.1, na.rm = T))
x <- df %>% filter(wave == 0) %>% rowwise() %>% mutate(cb_simple2_baseline = sum(total_fees/4, FS5.2_1_2*6+FS5.2_1_4*6, -monthly_benefits*12, -total_training_costs*12/FS6.1, na.rm = T)) %>% select(IDYouth, cb_simple2_baseline)
df <- df %>% left_join(x, by = "IDYouth")

df <- df %>% rowwise() %>% mutate(cb_complex2 = sum(total_fees/4, FS5.2_1_2*6+FS5.2_1_4*6, -monthly_benefits*12, -total_training_costs*12/FS6.1, -monthly_time_trained*FS6.8*FS5.2_1_2/40/4/FS6.1, na.rm = T))
x <- df %>% filter(wave == 0) %>% rowwise() %>% mutate(cb_complex2_baseline = sum(total_fees/4, FS5.2_1_2*6+FS5.2_1_4*6, -monthly_benefits*12, -total_training_costs*12/FS6.1, -monthly_time_trained*FS6.8*FS5.2_1_2/40/4/FS6.1, na.rm = T)) %>% select(IDYouth, cb_complex2_baseline)
df <- df %>% left_join(x, by = "IDYouth")

df <- df %>% ungroup()

save(df, file = "data/df.rda")

rm(list = ls())