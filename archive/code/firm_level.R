#################################
## Firm-Level Baseline/Endline ##
#################################

packages <- c("haven", "tidyverse", "labelled", "gtsummary")

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

## 1 Load baseline and endline data

# re-run cleaning/reshape code if necessary
#source("code/pivot_longer.R")

load("data/fs.rda")
load("data/fs_end.rda")

fs_labels <- haven::as_factor(fs)
fs_end_labels <- haven::as_factor(fs_end)


## 1 Firm descriptive statistics (baseline only, generally)
round(prop.table(table(fs_labels$FS2.18)),3)

fs_labels %>% select(tidyselect::vars_select(names(fs_labels), matches(c('FS2.20')))) %>% 
  tbl_summary(missing = "no")


## 2 Comparing firm characteristics (modules 2-6) over time

# merge baseline and endline (wide)
joined_wide <- right_join(fs, fs_end, by = "FS1.2")

# merge baseline and endline (long)

fs <- fs %>% mutate(wave = 0)
fs_end <- fs_end %>% mutate(wave = 1)

fs_labels <- fs_labels %>% mutate(wave = 0)
fs_end_labels <- fs_end_labels %>% mutate(wave = 1)

#example: firm size (continuous) 

joined_long <- rbind(fs %>% select('FS3.4', 'FS6.1', 'FS6.2', 'FS6.3', 'FS6.5', 'FS6.8', 'FS6.9', 'wave'), zap_labels(fs_end %>% select('FS3.4', 'FS6.1', 'FS6.2', 'FS6.3', 'FS6.5', 'FS6.8', 'FS6.9', 'wave')))

joined_long %>% group_by(wave) %>% 
  summarise("Total Employees" = mean(FS3.4, na.rm = T))

joined_long %>% select('FS3.4', 'FS6.1', 'FS6.2', 'FS6.3', 'FS6.5', 'FS6.8', 'FS6.9', 'wave') %>% 
  mutate(wave = factor(wave, labels = c("Baseline", "Endline"))) %>% 
  tbl_summary(by=wave,
              type = everything() ~ "continuous2",
              statistic = all_continuous() ~ c("{mean} ({N_nonmiss}) [{sd}]"),
              missing = "no") %>% 
  modify_header(update = all_stat_cols() ~ "**{level}**") %>% 
  add_p()
  
#example: by employee type (continuous) 

JoinWaves <- function(vars) {
  joined_long <- rbind(fs %>% select(tidyselect::vars_select(names(fs), matches(c({{vars}}))), "FS1.2", "wave"), fs_end %>% select(tidyselect::vars_select(names(fs_end), matches(c({{vars}}))), "FS1.2", "wave"))
  return(joined_long)
}

JoinWavesLab <- function(vars) {
  joined_long <- rbind(fs_labels %>% select(tidyselect::vars_select(names(fs_labels), matches(c({{vars}}))), "FS1.2", "wave"), fs_end_labels %>% select(tidyselect::vars_select(names(fs_end_labels), matches(c({{vars}}))), "FS1.2", "wave"))
  return(joined_long)
}

joined_long <- JoinWaves('FS3.5')

joined_long %>% select(-FS1.2) %>% 
  mutate(wave = factor(wave, labels = c("Baseline", "Endline"))) %>% 
  tbl_summary(by=wave,
              type = everything() ~ "continuous2",
              statistic = all_continuous() ~ c("{N_nonmiss}",
                                               "{mean} ({sd})"),
              missing = "no") %>% 
  modify_header(update = all_stat_cols() ~ "**{level}**")


#example: wages (categorical) 

joined_long <- JoinWavesLab('FS5.2')

joined_long %>% 
  mutate(wave = factor(wave, labels = c("Baseline", "Endline"))) %>% 
  tbl_summary(by=wave,
              label = list(FS5.2_1_1 ~ "Paid worker with apprenticeship in other firm",
                       FS5.2_1_2 ~ "Paid worker with apprenticeship in same firm",
                       FS5.2_1_3 ~ "Paid worker with only upper education",
                       FS5.2_1_4 ~ "Paid worker with up to primary education only",
                       FS5.2_1_5 ~ "Paid family worker",
                       FS5.2_1_6 ~ "Occasional worker",
                       FS5.2_1_7 ~ "Yourself",
                       FS5.2_1_8 ~ "Traditional apprentice first year",
                       FS5.2_1_9 ~ "Traditional apprentice third year",
                       FS5.2_1_10 ~ "CQP apprentice first year",
                       FS5.2_1_11 ~ "CQP apprentice third year"),
              missing = "no") %>% 
  modify_header(update = all_stat_cols() ~ "**{level}**")


# allowances

benefits <- rbind(JoinCQP(c('FS9.6')) %>% rename(food = FS9.6_1,
                                                 transport = FS9.6_2,
                                                 pocket_money = FS9.6_3,
                                                 other = FS9.6_4) %>% select(-FS9.6_5),
                  JoinTrad(c('FS7.8')) %>% rename(food = FS7.8_1,
                                                  transport = FS7.8_2,
                                                  pocket_money = FS7.8_3,
                                                  other = FS7.8_4) %>% select(-FS7.8_5))

benefits <- benefits %>% group_by(FS1.2, wave) %>% summarise_all(mean, na.rm = T) %>% ungroup()

benefits <- benefits %>% mutate_at(c("food", "transport", "pocket_money", "other"), recode,
                                     `1` = 150,
                                     `2` = 325,
                                     `3` = 475,
                                     `4` = 875,
                                     `5` = 1225,
                                     `6` = 1775,
                                     `7` = 2425,
                                     `8` = 3425,
                                     `9` = 6225,
                                     `10` = 8725,
                                     `11` = 11725) %>% 
  mutate_at(c("food", "transport", "pocket_money", "other"), na_if, 12)


benefits %>% select(-c(FS1.2)) %>% 
  mutate(wave = factor(wave, labels = c("Baseline", "Endline"))) %>% 
  tbl_summary(by=wave,
              type = everything() ~ "continuous2",
              statistic = all_continuous() ~ c("{N_nonmiss}",
                                               "{mean} ({sd})"),
              missing = "no") %>% 
  modify_header(update = all_stat_cols() ~ "**{level}**")



# attempt to estimate productivity gains by multiplying the number of hours/days worked by the wage of a paid worker (first for all apprentices pooled, then by apprentice type)


# regressions - effect of # of (cqp) apprentices, their skills and competencies, and other factors on firm size (profits later if possible)






