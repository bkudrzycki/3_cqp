##################
## Competencies ##
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

comp <- rbind(JoinCQP(c('FS9.12', 'FS9.13', 'FS9.14', 'FS9.15', 'FS9.16', 'IDYouth')), JoinTrad(c('FS7.14', 'FS7.15', 'FS7.16', 'FS7.17', 'FS7.18', 'IDYouth')) %>% setNames(names(JoinCQP(c('FS9.12', 'FS9.13', 'FS9.14', 'FS9.15', 'FS9.16', 'IDYouth'))))) %>% mutate_all(recode, `2` = 0)

comp <- comp %>% left_join(status, by = "IDYouth")

# pooled firm-level competency scores

comp_pooled <- comp %>% select(-'IDYouth') %>% group_by(FS1.2, wave) %>% summarise_all(mean, na.rm = T) %>% ungroup()

comp_pooled$all_trades <- comp_pooled %>% select(tidyselect::vars_select(names(comp_pooled), matches('FS9'))) %>% rowMeans(., na.rm = T)

comp_pooled$elec <- comp_pooled %>% select(tidyselect::vars_select(names(comp_pooled), matches('FS9.12_1'))) %>% 
  rowMeans(., na.rm = T)

comp_pooled$macon <- comp_pooled %>% select(tidyselect::vars_select(names(comp_pooled), matches('FS9.13_1'))) %>% 
  rowMeans(., na.rm = T)

comp_pooled$menuis<- comp_pooled %>% select(tidyselect::vars_select(names(comp_pooled), matches('FS9.14_1'))) %>% 
  rowMeans(., na.rm = T)

comp_pooled$plomb <- comp_pooled %>% select(tidyselect::vars_select(names(comp_pooled), matches('FS9.15_1'))) %>% 
  rowMeans(., na.rm = T)

comp_pooled$metal <- comp_pooled %>% select(tidyselect::vars_select(names(comp_pooled), matches('FS9.16_1'))) %>% 
  rowMeans(., na.rm = T)

comp_pooled %>%
  select(all_trades, elec, macon, menuis, plomb, metal, wave) %>% 
  mutate(wave = factor(wave, labels = c("Baseline", "Endline"))) %>% 
  tbl_summary(by=wave,
              type = everything() ~ "continuous2",
              statistic = all_continuous() ~ "{mean} ({N_nonmiss})",
              missing = "no") %>% 
  modify_header(update = all_stat_cols() ~ "**{level}**") %>% 
  modify_caption("**Apprentice Competencies Averaged at Firm Level**") %>% 
  add_difference(test = list(all_continuous() ~ "t.test")) 
#%>% add_p()



# competencies averaged at firm level, by apprenticeship type (CQP vs. non-CQP)

comp_by_status <- comp %>% group_by(FS1.2, status, wave) %>% summarise_all(mean, na.rm = T) %>% ungroup()

comp_by_status$all_trades <- comp_by_status %>% select(tidyselect::vars_select(names(comp_by_status), matches('FS9'))) %>% rowMeans(., na.rm = T)

comp_by_status$elec <- comp_by_status %>% select(tidyselect::vars_select(names(comp_by_status), matches('FS9.12_1'))) %>% 
  rowMeans(., na.rm = T)

comp_by_status$macon <- comp_by_status %>% select(tidyselect::vars_select(names(comp_by_status), matches('FS9.13_1'))) %>% 
  rowMeans(., na.rm = T)

comp_by_status$menuis<- comp_by_status %>% select(tidyselect::vars_select(names(comp_by_status), matches('FS9.14_1'))) %>% 
  rowMeans(., na.rm = T)

comp_by_status$plomb <- comp_by_status %>% select(tidyselect::vars_select(names(comp_by_status), matches('FS9.15_1'))) %>% 
  rowMeans(., na.rm = T)

comp_by_status$metal <- comp_by_status %>% select(tidyselect::vars_select(names(comp_by_status), matches('FS9.16_1'))) %>% 
  rowMeans(., na.rm = T)

cqp_table <- comp_by_status %>% filter(status == 1) %>% 
  select(all_trades, elec, macon, menuis, plomb, metal, wave) %>% 
  mutate(wave = factor(wave, labels = c("Baseline", "Endline"))) %>% 
  tbl_summary(by=wave,
              type = everything() ~ "continuous2",
              statistic = all_continuous() ~ "{mean} ({N_nonmiss})",
              missing = "no") %>% 
  modify_header(update = all_stat_cols() ~ "**{level}**") %>% 
  add_difference(test = list(all_continuous() ~ "t.test")) %>% 
  modify_caption("**Apprentice Competencies Averaged at Firm Level**")

non_cqp_table <- comp_by_status %>% filter(status == 0) %>% 
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


comp_by_status2 <- comp %>% group_by(FS1.2, status2, wave) %>% summarise_all(mean, na.rm = T) %>% ungroup()

comp_by_status2$all_trades <- comp_by_status2 %>% select(tidyselect::vars_select(names(comp_by_status2), matches('FS9'))) %>% rowMeans(., na.rm = T)

comp_by_status2$elec <- comp_by_status2 %>% select(tidyselect::vars_select(names(comp_by_status2), matches('FS9.12_1'))) %>% 
  rowMeans(., na.rm = T)

comp_by_status2$macon <- comp_by_status2 %>% select(tidyselect::vars_select(names(comp_by_status2), matches('FS9.13_1'))) %>% 
  rowMeans(., na.rm = T)

comp_by_status2$menuis<- comp_by_status2 %>% select(tidyselect::vars_select(names(comp_by_status2), matches('FS9.14_1'))) %>% 
  rowMeans(., na.rm = T)

comp_by_status2$plomb <- comp_by_status2 %>% select(tidyselect::vars_select(names(comp_by_status2), matches('FS9.15_1'))) %>% 
  rowMeans(., na.rm = T)

comp_by_status2$metal <- comp_by_status2 %>% select(tidyselect::vars_select(names(comp_by_status2), matches('FS9.16_1'))) %>% 
  rowMeans(., na.rm = T)

comp_tbl <- comp_by_status2 %>% filter(status2 == 1) %>% 
  select(all_trades, elec, macon, menuis, plomb, metal, wave) %>% 
  mutate(wave = factor(wave, labels = c("Baseline", "Endline"))) %>% 
  tbl_summary(by=wave,
              type = everything() ~ "continuous2",
              statistic = all_continuous() ~ "{mean} ({N_nonmiss})",
              missing = "no") %>% 
  modify_header(update = all_stat_cols() ~ "**{level}**") %>% 
  add_difference(test = list(all_continuous() ~ "t.test")) %>% 
  modify_caption("**Apprentice Competencies Averaged at Firm Level**")

comp_tbl2 <- comp_by_status2 %>% filter(status2 == 2) %>% 
  select(all_trades, elec, macon, menuis, plomb, metal, wave) %>% 
  mutate(wave = factor(wave, labels = c("Baseline", "Endline"))) %>% 
  tbl_summary(by=wave,
              type = everything() ~ "continuous2",
              statistic = all_continuous() ~ "{mean} ({N_nonmiss})",
              missing = "no") %>% 
  modify_header(update = all_stat_cols() ~ "**{level}**") %>% 
  add_difference(test = list(all_continuous() ~ "t.test"))

comp_tbl3 <- comp_by_status2 %>% filter(status2 == 0) %>% 
  select(all_trades, elec, macon, menuis, plomb, metal, wave) %>% 
  mutate(wave = factor(wave, labels = c("Baseline", "Endline"))) %>% 
  tbl_summary(by=wave,
              type = everything() ~ "continuous2",
              statistic = all_continuous() ~ "{mean} ({N_nonmiss})",
              missing = "no") %>% 
  modify_header(update = all_stat_cols() ~ "**{level}**") %>% 
  add_difference(test = list(all_continuous() ~ "t.test"))

tbl_merge(list(comp_tbl, comp_tbl2, comp_tbl3), tab_spanner = c("Selected CQPs", "Unsuccessful CQP applicants", "Traditional (did not apply)")) %>% italicize_labels() %>% as_gt() %>%
  gt::tab_style(
    style = gt::cell_text(weight = "bold"),
    locations = gt::cells_row_groups(groups = everything())
  )
