##################
## PRODUCTIVITY ##
##################

packages <- c("tidyverse", "labelled", "gtsummary")

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

# load functions
source("functions/add_by_n.R")

# finances
df %>% select(FS1.2, FS4.7, FS5.1, FS5.3, FS5.4, profits, wave) %>%
  group_by(FS1.2, wave) %>% summarise_at(c("FS4.7", "FS5.1", "FS5.3", "FS5.4", "profits"), mean, na.rm = T) %>% ungroup() %>% 
  mutate(wave = factor(wave, labels = c("Baseline", "Endline"))) %>% 
  tbl_summary(by=wave,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no",
              digits = list(everything() ~ c(0, 0)),
              include = -FS1.2,
              label = list(FS4.7 ~ "Revenues",
                           FS5.3 ~ "Total wages",
                           FS5.1 ~ "Non-wage expenses",
                           FS5.4 ~ "Profits (reported)",
                           profits ~ "Profits (calculated)"))  %>% 
  add_stat(
    fns = everything() ~ add_by_n
  ) %>% 
  modify_table_body(
    ~ .x %>%
      dplyr::relocate(add_n_stat_1, .before = stat_1) %>%
      dplyr::relocate(add_n_stat_2, .before = stat_2)
  ) %>%
  modify_header(stat_by =  "**{level}**",
                starts_with("add_n_stat") ~ "**N**",
                label = "") %>% 
  modify_footnote(
    all_stat_cols() ~ "Mean (SD). Firm annual accounts in reported in FCFA."
  ) %>% 
  add_p(all_continuous() ~ "paired.t.test", group = FS1.2) 

# firm employment statistics
df %>% select(FS1.2, firm_size, FS3.4, FS6.1, contains("FS3.5"), contains("hours"), wave) %>%
  group_by(FS1.2, wave) %>% summarise_all(mean, na.rm = T) %>% ungroup() %>%
  mutate(wave = factor(wave, labels = c("Baseline", "Endline"))) %>% 
  tbl_summary(by=wave,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no",
              digits = list(everything() ~ c(1, 1)),
              label = list(FS3.4 ~ "Firm size (reported)",
                           firm_size ~ "Firm size (calculated)",
                           FS6.1 ~ "Apprentices",
                           FS3.5_2 ~ "Permanent employees",
                           FS3.5_3 ~ "Paid family workers",
                           FS3.5_4 ~ "Unpaid family workers",
                           FS3.5_5 ~ "Occasional workers",
                           firm_weekly_hours ~ "Owner weekly hours",
                           a_weekly_hours ~ "Apprentice weekly hours"),
              include = -c(FS1.2, FS3.5_1)) %>% 
  modify_footnote(
    all_stat_cols() ~ "Mean (SD). Weekly hours refer to hours worked in previous week."
  )

                
  
# wages
df %>% select(contains("FS5.2"), wave, FS1.2) %>%
  mutate(wave = factor(wave, labels = c("Baseline", "Endline"))) %>% 
  group_by(FS1.2, wave) %>% summarise_all(mean, na.rm = T) %>% ungroup() %>% 
  tbl_summary(by=wave,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no",
              include = -FS1.2,
              digits = list(everything() ~ c(0, 0)),
              label = list(FS5.2_1_7 ~ "Firm owner",
                           FS5.2_1_1 ~ "Former apprentice (diff. workshop)",
                           FS5.2_1_2 ~ "Former apprentice (same workshop)",
                           FS5.2_1_3 ~ "Worker with secondary educ. or more",
                           FS5.2_1_4 ~ "Worker with primary educ. or less",
                           FS5.2_1_5 ~ "Paid family worker",
                           FS5.2_1_6 ~ "Occassional worker",
                           FS5.2_1_8 ~ "Traditional apprentice (first year)",
                           FS5.2_1_9 ~ "Traditional apprentice (third year)",
                           FS5.2_1_10 ~ "CQP apprentice (first year)",
                           FS5.2_1_11 ~ "CQP apprentice (third year)"))  %>% 
  add_p(all_continuous() ~ "paired.t.test", group = FS1.2) %>% 
  add_stat(
    fns = everything() ~ add_by_n
  ) %>% 
  modify_table_body(
    ~ .x %>%
      dplyr::relocate(add_n_stat_1, .before = stat_1) %>%
      dplyr::relocate(add_n_stat_2, .before = stat_2)
  ) %>%
  modify_header(stat_by =  "**{level}**",
                starts_with("add_n_stat") ~ "**N**",
                label = "") %>% 
  modify_footnote(
    all_stat_cols() ~ "Mean (SD). N = number of firms reporting. Monthly wages in FCFA."
  )




rm(list = ls())
