##################
## Productivity ##
##################

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

# load skills data from youth survey

merged <- read_sav("data/youth_survey_merged.sav") %>% 
  filter(YS1_2 == 1)

# calculate number of hours worked in past week (from apprentice data)

hours <- merged %>% 
  mutate_at(c('YS4_12', 'YE3_17'), na_if, 99) %>% 
  mutate(base_hours = YS4_10*YS4_12,
         end_hours = YE3_15*YE3_17)

# wrangle to get survey wave as a separate column

hours <- hours %>%  
  select(c('IDYouth', 'SELECTED', 'YS1_4', 'base_hours', 'end_hours')) %>% 
  pivot_longer(cols = -c("IDYouth", 'SELECTED', 'YS1_4'),
               values_to = "weekly_hours") %>% 
  mutate(wave = ifelse(name == "base_hours", 0, 1)) %>% 
  select(-name)
                 
# recode baseline wages (from firm side)

load("data/fs.rda")
load("data/fs_end.rda")

fs <- fs %>% mutate(wave = 0)
fs_end <- fs_end %>% mutate(wave = 1)

wages <- fs %>% select('FS1.2', 'wave', tidyselect::vars_select(names(fs), matches("FS5.2_1"))) %>% 
  rbind(fs_end %>% select('FS1.2', 'wave', tidyselect::vars_select(names(fs), matches("FS5.2_1")))) %>% 
  mutate_at(vars(matches('FS5.2_1')), recode, `1` = 0, `2` = 2500, `3` = 7500, `4` = 15000, `5` = 27500, `6` = 45000, `7` = 67500, `8` = 95000, `9` = 130000, `10` = 175000, `11` = 225000) %>% 
  mutate_at(vars(matches('FS5.2_1')), na_if, 12) %>% 
  mutate_at(vars(matches('FS5.2_1')), na_if, 13)

wages %>% zap_label() %>% 
  select("wave", "FS5.2_1_1", "FS5.2_1_2", "FS5.2_1_3", "FS5.2_1_4", "FS5.2_1_5", "FS5.2_1_6", "FS5.2_1_7") %>% 
  rename("paid worker, apprenticeship with other firm" = FS5.2_1_1,
         "paid worker, apprenticeship with same firm" = FS5.2_1_2,
         "paid worker, secondary or tertiary education" = FS5.2_1_3,
         "paid worker, primary education or less" = FS5.2_1_4,
         "paid family worker" = FS5.2_1_5,
         "occasional worker" = FS5.2_1_6,
         "patron (workshop owner)" = FS5.2_1_7) %>% 
  mutate(wave = factor(wave, labels = c("Baseline", "Endline"))) %>% 
  tbl_summary(by=wave,
              type = everything() ~ "continuous2",
              statistic = all_continuous() ~ c("{mean} ({N_nonmiss})"),
              missing = "no") %>% 
  modify_header(update = all_stat_cols() ~ "**{level}**") %>% 
  modify_caption("**Monthly Wages, Workers and Owner (FCFA)**") %>% 
  add_difference()

wages %>% zap_label() %>% 
  select("wave", "FS5.2_1_8", "FS5.2_1_9", "FS5.2_1_10", "FS5.2_1_11") %>% 
  rename("traditional apprentice, first year" = FS5.2_1_8,
         "traditional apprentice, third year" = FS5.2_1_9,
         "CQP apprentice, first year" = FS5.2_1_10,
         "CQP apprentice, third year" = FS5.2_1_11) %>% 
  mutate(wave = factor(wave, labels = c("Baseline", "Endline"))) %>% 
  tbl_summary(by=wave,
              type = everything() ~ "continuous2",
              statistic = all_continuous() ~ c("{mean} ({N_nonmiss})"),
              missing = "no") %>% 
  modify_header(update = all_stat_cols() ~ "**{level}**") %>% 
  modify_caption("**Monthly Wages, Apprentices (FCFA)**") %>% 
  add_difference()


# match hours to wages by firm ID

prod <- hours %>% left_join(wages %>% select(-wave), by = c("YS1_4" = "FS1.2"), "wave")

# calculate monthly wages: for baseline apprentices, multiply 4x weekly hours by wages for cqp/traditional apprentices, first year; for endline, third year, assuming 160 hours months

prod <- prod %>% mutate(monthly_wage = ifelse(SELECTED == "Oui" & wave == 0, weekly_hours/40*FS5.2_1_10,
                              ifelse(SELECTED == "Oui" & wave == 1, weekly_hours/40*FS5.2_1_11,
                                     ifelse(SELECTED == "Non" & wave == 0, weekly_hours/40*FS5.2_1_8,
                                            ifelse(SELECTED == "Non" & wave == 1, weekly_hours/40*FS5.2_1_9, NA)))))

prod_pooled <- prod %>% select(YS1_4, wave, weekly_hours, monthly_wage) %>% group_by(YS1_4, wave) %>% summarise_all(mean, na.rm = T) %>% ungroup()

prod_pooled %>% 
  select(-YS1_4) %>% 
  mutate(wave = factor(wave, labels = c("Baseline", "Endline"))) %>% 
  tbl_summary(by=wave,
              type = everything() ~ "continuous2",
              statistic = all_continuous() ~ "{mean} ({N_nonmiss})",
              missing = "no") %>% 
  modify_header(update = all_stat_cols() ~ "**{level}**") %>% 
  modify_caption("**Estimated Apprentice Work Hours and Wages (FCFA)**") %>% 
  add_difference(test = list(all_continuous() ~ "t.test")) 

# by apprenticeship type

prod_bystatus <- prod %>% select(YS1_4, SELECTED, wave, weekly_hours, monthly_wage) %>% group_by(YS1_4, SELECTED, wave) %>% summarise_all(mean, na.rm = T) %>% ungroup()

cqp_table <- prod_bystatus %>% filter(SELECTED == "Oui") %>% 
  select(-c(YS1_4, SELECTED)) %>% 
  mutate(wave = factor(wave, labels = c("Baseline", "Endline"))) %>% 
  tbl_summary(by=wave,
              type = everything() ~ "continuous2",
              statistic = all_continuous() ~ "{mean} ({N_nonmiss})",
              missing = "no") %>% 
  modify_header(update = all_stat_cols() ~ "**{level}**") %>% 
  add_difference(test = list(all_continuous() ~ "t.test")) %>% 
  modify_caption("**Estimated Apprentice Work Hours and Wages (FCFA)**")

non_cqp_table <- prod_bystatus %>% filter(SELECTED == "Non") %>% 
  select(-c(YS1_4, SELECTED)) %>% 
  mutate(wave = factor(wave, labels = c("Baseline", "Endline"))) %>% 
  tbl_summary(by=wave,
              type = everything() ~ "continuous2",
              statistic = all_continuous() ~ "{mean} ({N_nonmiss})",
              missing = "no") %>% 
  modify_header(update = all_stat_cols() ~ "**{level}**") %>% 
  add_difference(test = list(all_continuous() ~ "t.test"))

tbl_merge(list(cqp_table, non_cqp_table), tab_spanner = c("CQP Apprentices", "Not Selected CQP Applicants")) %>% italicize_labels() %>% as_gt() %>%
  gt::tab_style(
    style = gt::cell_text(weight = "bold"),
    locations = gt::cells_row_groups(groups = everything())
  )

