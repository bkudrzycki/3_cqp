############
## SKILLS ##
############

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

# load functions
source("functions/functions.R")

# wrangle to get survey wave as a separate column
skills <- merged %>% 
  select(c('IDYouth', 'SELECTED', 'YS1_4', 'YS4_2', matches(c('YS5', 'YE4')))) %>% 
  pivot_longer(cols = -c("IDYouth", 'SELECTED', 'YS1_4', 'YS4_2')) %>% 
  mutate(wave = ifelse(substr(name, 1, 2) == "YS", 0, 1),
         name = paste0("YS5", substr(name,4,nchar(name)))) %>% 
  pivot_wider(names_from = name, values_from = value)

# code correct answers
skills <- skills %>% 
  CodeAnswers(YS5_1, 2) %>% 
  CodeAnswers(YS5_2, 1) %>% 
  CodeAnswers(YS5_3, 3) %>% 
  CodeAnswers(YS5_4, 1) %>% 
  CodeAnswers(YS5_5, 2) %>% 
  CodeAnswers(YS5_6, 2) %>% 
  CodeAnswers(YS5_7, 1) %>% 
  CodeAnswers(YS5_8, 2) %>% 
  CodeAnswers(YS5_9, 2) %>% 
  CodeAnswers(YS5_10, 3) %>% 
  CodeAnswers(YS5_11, 1) %>% 
  CodeAnswers(YS5_12, 4) %>% 
  CodeAnswers(YS5_13, 1) %>% 
  CodeAnswers(YS5_14, 4) %>% 
  CodeAnswers(YS5_15, 1) %>% 
  CodeAnswers(YS5_16, 2) %>% 
  CodeAnswers(YS5_18, 2) %>% 
  CodeAnswers(YS5_19, 2) %>% 
  CodeAnswers(YS5_20, 3) %>% 
  CodeAnswers(YS5_21, 2) %>% 
  CodeAnswers(YS5_22, 1) %>% 
  CodeAnswers(YS5_23, 1)

skills_pooled <- skills %>% select(-'IDYouth') %>% group_by(YS1_4, wave) %>% summarise_all(mean, na.rm = T) %>% ungroup()

skills_pooled$all_trades <- skills_pooled %>% select(tidyselect::vars_select(names(skills_pooled), matches('correct'))) %>% rowMeans(., na.rm = T)

skills_pooled$elec <- skills_pooled %>% select(tidyselect::vars_select(names(skills_pooled), matches(c('correct_YS5_19', 'correct_YS5_20', 'correct_YS5_21', 'correct_YS5_22', 'correct_YS5_23')))) %>% 
  rowMeans(., na.rm = T)

skills_pooled$macon <- skills_pooled %>% select(tidyselect::vars_select(names(skills_pooled), matches(c('correct_YS5_14', 'correct_YS5_15', 'correct_YS5_16', 'correct_YS5_18')))) %>% 
  rowMeans(., na.rm = T)

skills_pooled$menuis<- skills_pooled %>% select(tidyselect::vars_select(names(skills_pooled), matches(c('correct_YS5_10', 'correct_YS5_11', 'correct_YS5_12', 'correct_YS5_13')))) %>% 
  rowMeans(., na.rm = T)

skills_pooled$plomb <- skills_pooled %>% select(tidyselect::vars_select(names(skills_pooled), matches(c('correct_YS5_6', 'correct_YS5_7', 'correct_YS5_8', 'correct_YS5_9')))) %>% 
  rowMeans(., na.rm = T)

skills_pooled$metal <- skills_pooled %>% select(tidyselect::vars_select(names(skills_pooled), matches(c('correct_YS5_1', 'correct_YS5_2', 'correct_YS5_3', 'correct_YS5_4', 'correct_YS5_5')))) %>% 
  rowMeans(., na.rm = T)

skills_pooled %>%
  select(all_trades, elec, macon, menuis, plomb, metal, wave) %>% 
  mutate(wave = factor(wave, labels = c("Baseline", "Endline"))) %>% 
  tbl_summary(by=wave,
              type = everything() ~ "continuous2",
              statistic = all_continuous() ~ "{mean} ({N_nonmiss})",
              missing = "no") %>% 
  modify_header(update = all_stat_cols() ~ "**{level}**") %>% 
  modify_caption("**Apprentice Skills Averaged at Firm Level**") %>% 
  add_difference(test = list(all_continuous() ~ "t.test")) 

skills_by_status <- skills %>% group_by(YS1_4, SELECTED, wave) %>% summarise_all(mean, na.rm = T) %>% ungroup()

skills_by_status$all_trades <- skills_by_status %>% select(tidyselect::vars_select(names(skills_by_status), matches('correct'))) %>% rowMeans(., na.rm = T)

skills_by_status$elec <- skills_by_status %>% select(tidyselect::vars_select(names(skills_by_status), matches(c('correct_YS5_19', 'correct_YS5_20', 'correct_YS5_21', 'correct_YS5_22', 'correct_YS5_23')))) %>% 
  rowMeans(., na.rm = T)

skills_by_status$macon <- skills_by_status %>% select(tidyselect::vars_select(names(skills_by_status), matches(c('correct_YS5_14', 'correct_YS5_15', 'correct_YS5_16', 'correct_YS5_18')))) %>% 
  rowMeans(., na.rm = T)

skills_by_status$menuis<- skills_by_status %>% select(tidyselect::vars_select(names(skills_by_status), matches(c('correct_YS5_10', 'correct_YS5_11', 'correct_YS5_12', 'correct_YS5_13')))) %>% 
  rowMeans(., na.rm = T)

skills_by_status$plomb <- skills_by_status %>% select(tidyselect::vars_select(names(skills_by_status), matches(c('correct_YS5_6', 'correct_YS5_7', 'correct_YS5_8', 'correct_YS5_9')))) %>% 
  rowMeans(., na.rm = T)

skills_by_status$metal <- skills_by_status %>% select(tidyselect::vars_select(names(skills_by_status), matches(c('correct_YS5_1', 'correct_YS5_2', 'correct_YS5_3', 'correct_YS5_4', 'correct_YS5_5')))) %>% 
  rowMeans(., na.rm = T)

cqp_table <- skills_by_status %>% filter(SELECTED == "Oui") %>% 
  select(all_trades, elec, macon, menuis, plomb, metal, wave) %>% 
  mutate(wave = factor(wave, labels = c("Baseline", "Endline"))) %>% 
  tbl_summary(by=wave,
              type = everything() ~ "continuous2",
              statistic = all_continuous() ~ "{mean} ({N_nonmiss})",
              missing = "no") %>% 
  modify_header(update = all_stat_cols() ~ "**{level}**") %>% 
  add_difference(test = list(all_continuous() ~ "t.test")) %>% 
  modify_caption("**Apprentice Skills Averaged at Firm Level**")

non_cqp_table <- skills_by_status %>% filter(SELECTED == "Non") %>% 
  select(all_trades, elec, macon, menuis, plomb, metal, wave) %>% 
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

