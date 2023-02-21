####################
## Patron ratings ##
####################

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
source("functions/functions.R")

# apprenticeship status (CQP = 3, CQM, traditional, other) for each apprentice
status <- base_cqps %>% select(IDYouth, status = FS9.3, status2 = SELECTED) %>% 
  rbind(base_trad %>% select(IDYouth, status = FS7.4) %>% mutate(status2 = 0)) %>% 
  mutate(status = ifelse(status == 3, 1, 0))

ratings <- rbind(JoinCQP(c('FS9.11')) %>% rename(discipline = FS9.11_1,
                                                 teamwork = FS9.11_2,
                                                 efficiency = FS9.11_3,
                                                 work_quality = FS9.11_4,
                                                 learning_speed = FS9.11_5,
                                                 respect = FS9.11_6),
                 JoinTrad(c('FS7.13')) %>% rename(discipline = FS7.13_1,
                                                  teamwork = FS7.13_2,
                                                  efficiency = FS7.13_3,
                                                  work_quality = FS7.13_4,
                                                  learning_speed = FS7.13_5,
                                                  respect = FS7.13_6))

ratings <- ratings %>% left_join(status, by = "IDYouth")

ratings$all_ratings <- ratings %>% select(c("discipline", "teamwork", "efficiency", "work_quality", "learning_speed", "respect")) %>% 
  rowMeans(., na.rm = T)

# calculate rating averages at the firm level

ratings_pooled <- ratings %>% group_by(FS1.2, wave) %>% summarise_all(mean, na.rm = T) %>% ungroup()

ratings_pooled %>% select(c("all_ratings", "discipline", "teamwork", "efficiency", "work_quality", "learning_speed", "respect", "wave")) %>% 
  mutate(wave = factor(wave, labels = c("Baseline", "Endline"))) %>% 
  tbl_summary(by=wave,
              type = everything() ~ "continuous2",
              statistic = all_continuous() ~ c("{mean} ({N_nonmiss})"),
              missing = "no") %>% 
  modify_header(update = all_stat_cols() ~ "**{level}**") %>% 
  modify_caption("**Apprentice Ratings Averaged at Firm Level**") %>% 
  add_difference()

# ratings averaged at firm level, by apprenticeship type (CQP vs. non-CQP)

ratings_by_type <- ratings %>% group_by(FS1.2, status, wave) %>% summarise_all(mean, na.rm = T) %>% ungroup()

cqp_table <- ratings_by_type %>% filter(status == 1) %>% 
  select(-c(IDYouth, status, status2, FS1.2)) %>% 
  mutate(wave = factor(wave, labels = c("Baseline", "Endline"))) %>% 
  tbl_summary(by=wave,
              type = everything() ~ "continuous2",
              statistic = all_continuous() ~ "{mean} ({N_nonmiss})",
              missing = "no") %>% 
  modify_header(update = all_stat_cols() ~ "**{level}**") %>% 
  modify_caption("**Apprentice Ratings Averaged at Firm Level**") %>% 
  add_difference(test = list(all_continuous() ~ "t.test"))

non_cqp_table <- ratings_by_type %>% filter(status == 0) %>% 
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

ratings_by_status <- ratings %>% group_by(FS1.2, status2, wave) %>% summarise_all(mean, na.rm = T) %>% ungroup()

ratings_tbl <- ratings_by_status %>% filter(status2 == 1) %>% 
  select(-c(IDYouth, status, status2, FS1.2)) %>% 
  mutate(wave = factor(wave, labels = c("Baseline", "Endline"))) %>% 
  tbl_summary(by=wave,
              type = everything() ~ "continuous2",
              statistic = all_continuous() ~ "{mean} ({N_nonmiss})",
              missing = "no") %>% 
  modify_header(update = all_stat_cols() ~ "**{level}**") %>% 
  modify_caption("**Apprentice Ratings Averaged at Firm Level**") %>% 
  add_p()

ratings_tbl2 <- ratings_by_status %>% filter(status2 == 2) %>% 
  select(-c(IDYouth, status, status2, FS1.2)) %>% 
  mutate(wave = factor(wave, labels = c("Baseline", "Endline"))) %>% 
  tbl_summary(by=wave,
              type = everything() ~ "continuous2",
              statistic = all_continuous() ~ "{mean} ({N_nonmiss})",
              missing = "no") %>% 
  modify_header(update = all_stat_cols() ~ "**{level}**") %>% 
  add_p()

ratings_tbl3 <- ratings_by_status %>% filter(status2 == 0) %>% 
  select(-c(IDYouth, status, status2, FS1.2)) %>% 
  mutate(wave = factor(wave, labels = c("Baseline", "Endline"))) %>% 
  tbl_summary(by=wave,
              type = everything() ~ "continuous2",
              statistic = all_continuous() ~ "{mean} ({N_nonmiss})",
              missing = "no") %>% 
  modify_header(update = all_stat_cols() ~ "**{level}**") %>% 
  add_p()

tbl_merge(list(ratings_tbl, ratings_tbl2, ratings_tbl3), tab_spanner = c("Selected CQPs", "Unsuccessful CQP applicants", "Traditional (did not apply)")) %>% italicize_labels() %>% as_gt() %>%
  gt::tab_style(
    style = gt::cell_text(weight = "bold"),
    locations = gt::cells_row_groups(groups = everything())
  )
