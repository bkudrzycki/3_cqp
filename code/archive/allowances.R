################
## Allowances ##
################

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

# load reshaped apprentice-level data
load("data/base_cqps.rda")
load("data/base_trad.rda")
load("data/end_cqps.rda")
load("data/end_trad.rda")

# load functions
source("functions/join_cqp_trad.R")

# apprenticeship status (CQP = 3, CQM, traditional, other) for each apprentice and status2 (CQP = 1, unsuccessful applicant = 2, traditional = 0)
status <- base_cqps %>% select(IDYouth, status = FS9.3, status2 = SELECTED) %>% 
  rbind(base_trad %>% select(IDYouth, status = FS7.4) %>% mutate(status2 = 0)) %>% 
  mutate(status = ifelse(status == 3, 1, 0))

benefits <- rbind(JoinCQP(c('FS9.6')) %>% rename(food = FS9.6_1,
                                                 transport = FS9.6_2,
                                                 pocket_money = FS9.6_3,
                                                 other = FS9.6_4) %>% select(-FS9.6_5),
                  JoinTrad(c('FS7.8')) %>% rename(food = FS7.8_1,
                                                  transport = FS7.8_2,
                                                  pocket_money = FS7.8_3,
                                                  other = FS7.8_4) %>% select(-FS7.8_5))

benefits <- benefits %>% left_join(status, by = "IDYouth")

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

benefits$all_allowances <- benefits %>% select(c("food", "transport", "pocket_money", "other")) %>% 
  rowMeans(., na.rm = T)


benefits_pooled <- benefits %>% group_by(FS1.2, wave) %>% summarise_all(mean, na.rm = T) %>% ungroup()

benefits_pooled %>% select(-c(FS1.2)) %>% 
  select(-c(IDYouth, status, status2)) %>% 
  mutate(wave = factor(wave, labels = c("Baseline", "Endline"))) %>% 
  tbl_summary(by=wave,
              type = everything() ~ "continuous2",
              statistic = all_continuous() ~ "{mean} ({N_nonmiss})",
              missing = "no") %>% 
  modify_header(update = all_stat_cols() ~ "**{level}**") %>% 
  modify_caption("**Apprentice Weekly Allowances Averaged at Firm Level (FCFA)**") %>% 
  add_difference(test = list(all_continuous() ~ "t.test")) 


# benefits averaged at firm level, by apprenticeship type (CQP vs. non-CQP)

benefits_by_type <- benefits %>% group_by(FS1.2, status, wave) %>% summarise_all(mean, na.rm = T) %>% ungroup()

cqp_table <- benefits_by_type %>% filter(status == 1) %>% 
  select(-c(IDYouth, status, status2, FS1.2)) %>% 
  mutate(wave = factor(wave, labels = c("Baseline", "Endline"))) %>% 
  tbl_summary(by=wave,
              type = everything() ~ "continuous2",
              statistic = all_continuous() ~ "{mean} ({N_nonmiss})",
              missing = "no") %>% 
  modify_header(update = all_stat_cols() ~ "**{level}**") %>% 
  modify_caption("**Weekly Benefits Averaged at Firm Level (FCFA)**") %>% 
  add_difference(test = list(all_continuous() ~ "t.test"))

non_cqp_table <- benefits_by_type %>% filter(status == 0) %>% 
  select(-c(IDYouth, status, status2, FS1.2)) %>% 
  mutate(wave = factor(wave, labels = c("Baseline", "Endline"))) %>% 
  tbl_summary(by=wave,
              type = everything() ~ "continuous2",
              statistic = all_continuous() ~ "{mean} ({N_nonmiss})",
              missing = "no") %>% 
  modify_header(update = all_stat_cols() ~ "**{level}**") %>% 
  add_difference(test = list(all_continuous() ~ "t.test"))

tbl_merge(list(cqp_table, non_cqp_table), tab_spanner = c("CQP Apprentices", "Non-CQP Apprentices")) %>% italicize_labels() %>% as_gt() %>%
  gt::tab_style(
    style = gt::cell_text(weight = "bold"),
    locations = gt::cells_row_groups(groups = everything())
  )

#differentiating between successful/unsuccessful CQP applicants and non-applicants

benefits_by_status <- benefits %>% group_by(FS1.2, status2, wave) %>% summarise_all(mean, na.rm = T) %>% ungroup()

benefits_tbl <- benefits_by_status %>% filter(status2 == 1) %>% 
  select(-c(IDYouth, status, status2, FS1.2)) %>% 
  mutate(wave = factor(wave, labels = c("Baseline", "Endline"))) %>% 
  tbl_summary(by=wave,
              type = everything() ~ "continuous2",
              statistic = all_continuous() ~ "{mean} ({N_nonmiss})",
              missing = "no") %>% 
  modify_header(update = all_stat_cols() ~ "**{level}**") %>% 
  modify_caption("**Weekly Benefits Averaged at Firm Level (FCFA)**") %>% 
  add_p()

benefits_tbl2 <- benefits_by_status %>% filter(status2 == 2) %>% 
  select(-c(IDYouth, status, status2, FS1.2)) %>% 
  mutate(wave = factor(wave, labels = c("Baseline", "Endline"))) %>% 
  tbl_summary(by=wave,
              type = everything() ~ "continuous2",
              statistic = all_continuous() ~ "{mean} ({N_nonmiss})",
              missing = "no") %>% 
  modify_header(update = all_stat_cols() ~ "**{level}**") %>% 
  add_p()

benefits_tbl3 <- benefits_by_status %>% filter(status2 == 0) %>% 
  select(-c(IDYouth, status, status2, FS1.2)) %>% 
  mutate(wave = factor(wave, labels = c("Baseline", "Endline"))) %>% 
  tbl_summary(by=wave,
              type = everything() ~ "continuous2",
              statistic = all_continuous() ~ "{mean} ({N_nonmiss})",
              missing = "no") %>% 
  modify_header(update = all_stat_cols() ~ "**{level}**") %>% 
  add_p()

tbl_merge(list(benefits_tbl, benefits_tbl2, benefits_tbl3), tab_spanner = c("Selected CQPs", "Unsuccessful CQP applicants", "Traditional (did not apply)")) %>% italicize_labels() %>% as_gt() %>%
  gt::tab_style(
    style = gt::cell_text(weight = "bold"),
    locations = gt::cells_row_groups(groups = everything())
  )



  
