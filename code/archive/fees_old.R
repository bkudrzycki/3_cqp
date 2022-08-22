##########
## Fees ##
##########

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

# apprenticeship status (CQP = 3, CQM, traditional, other) for each apprentice and status2 (CQP = 1, unsuccessful applicant = 2, traditional = 0)
status <- base_cqps %>% select(IDYouth, status = FS9.3, status2 = SELECTED) %>% 
  rbind(base_trad %>% select(IDYouth, status = FS7.4) %>% mutate(status2 = 0)) %>% 
  mutate(status = ifelse(status == 3, 1, 0))

fees <- rbind(JoinCQP('FS9.7') %>% rename(entry = FS9.7_1,
                                          formation = FS9.7_2,
                                          liberation = FS9.7_3),
              JoinTrad('FS7.9') %>% rename(entry = FS7.9_1,
                                           formation = FS7.9_2,
                                           liberation = FS7.9_3))

fees <- fees %>% left_join(status, by = c("IDYouth"))

# recode fees using bin average

fees <- fees %>% mutate_at(c("entry", "formation", "liberation"), recode,
                           `1` = 0,
                           `2` = 5000,
                           `3` = 15000,
                           `4` = 27500,
                           `5` = 45000,
                           `6` = 70000,
                           `7` = 105000,
                           `8` = 150000,
                           `9` = 212500,
                           `10` = 300000,
                           `11` = 425000) %>%
  mutate_at(c("entry", "formation", "liberation"), na_if, 12)

fees2 <- rbind(JoinCQP('FS9.8') %>% rename(materials = FS9.8_1,
                                           contract = FS9.8_2,
                                           application = FS9.8_3),
               JoinTrad('FS7.10') %>% rename(materials = FS7.10_1,
                                             contract = FS7.10_2,
                                             application = FS7.10_3))

fees2 <- fees2 %>% mutate_at(c("materials", "contract", "application"), recode,
                             `1` = 0,
                             `2` = 5000,
                             `3` = 15000,
                             `4` = 27500,
                             `5` = 45000,
                             `6` = 70000,
                             `7` = 105000,
                             `8` = 150000,
                             `9` = 212500,
                             `10` = 300000,
                             `11` = 425000) %>%
  mutate_at(c("materials", "contract", "application"), na_if, 12)

fees <- left_join(fees, fees2, by = c("IDYouth", "wave", "FS1.2"))

fees$total_fees <- fees %>% select(c("entry", "formation", "liberation", "materials", "contract", "application")) %>% 
  rowSums(., na.rm = T)

# calculate average fees by firm

fees_pooled <- fees %>% group_by(FS1.2, wave) %>% summarise_all(mean, na.rm = T) %>% ungroup()

fees_pooled %>% select(c("total_fees", "entry", "formation", "liberation", "materials", "contract", "application", "wave")) %>% 
  mutate(wave = factor(wave, labels = c("Baseline", "Endline"))) %>% 
  tbl_summary(by=wave,
              type = everything() ~ "continuous2",
              statistic = all_continuous() ~ c("{mean} ({N_nonmiss})"),
              missing = "no") %>% 
  modify_header(update = all_stat_cols() ~ "**{level}**") %>% 
  modify_caption("**Fees Paid Averaged at Firm Level**") %>% 
  add_difference()

# fees averaged at firm level, by apprenticeship type (CQP vs. non-CQP)

fees_by_type <- fees %>% group_by(FS1.2, status, wave) %>% summarise_all(mean, na.rm = T) %>% ungroup()

fees_tbl <- fees_by_type %>% filter(status == 1) %>% 
  select(c("total_fees", "entry", "formation", "liberation", "materials", "contract", "application", "wave")) %>% 
  mutate(wave = factor(wave, labels = c("Baseline", "Endline"))) %>% 
  tbl_summary(by=wave,
              type = everything() ~ "continuous2",
              statistic = all_continuous() ~ "{mean} ({N_nonmiss})",
              missing = "no") %>% 
  modify_header(update = all_stat_cols() ~ "**{level}**") %>% 
  add_difference(test = list(all_continuous() ~ "t.test")) %>% 
  modify_caption("**Fees Averaged at Firm Level, by Apprenticeship Type**")

fees_tbl2 <- fees_by_type %>% filter(status == 0) %>% 
  select(c("total_fees", "entry", "formation", "liberation", "materials", "contract", "application", "wave")) %>% 
  mutate(wave = factor(wave, labels = c("Baseline", "Endline"))) %>% 
  tbl_summary(by=wave,
              type = everything() ~ "continuous2",
              statistic = all_continuous() ~ "{mean} ({N_nonmiss})",
              missing = "no") %>% 
  modify_header(update = all_stat_cols() ~ "**{level}**") %>% 
  add_difference(test = list(all_continuous() ~ "t.test"))

tbl_merge(list(fees_tbl, fees_tbl2), tab_spanner = c("CQP Apprentices", "Non-CQP Apprentices")) %>% italicize_labels() %>% as_gt() %>%
  gt::tab_style(
    style = gt::cell_text(weight = "bold"),
    locations = gt::cells_row_groups(groups = everything())
  )

# fees averaged at firm level, by apprenticeship type (selected vs not selected vs traditional)

fees_by_type2 <- fees %>% group_by(FS1.2, status2, wave) %>% summarise_all(mean, na.rm = T) %>% ungroup()

fees_tbl <- fees_by_type2 %>% filter(status2 == 1) %>% 
  select(c("total_fees", "entry", "formation", "liberation", "materials", "contract", "application", "wave")) %>% 
  mutate(wave = factor(wave, labels = c("Baseline", "Endline"))) %>% 
  tbl_summary(by=wave,
              type = everything() ~ "continuous2",
              statistic = all_continuous() ~ "{mean} ({N_nonmiss})",
              missing = "no") %>% 
  modify_header(update = all_stat_cols() ~ "**{level}**") %>% 
  add_difference(test = list(all_continuous() ~ "t.test")) %>% 
  modify_caption("**Fees Averaged at Firm Level, by Apprenticeship Type II**")

fees_tbl2 <- fees_by_type2 %>% filter(status2 == 2) %>% 
  select(c("total_fees", "entry", "formation", "liberation", "materials", "contract", "application", "wave")) %>% 
  mutate(wave = factor(wave, labels = c("Baseline", "Endline"))) %>% 
  tbl_summary(by=wave,
              type = everything() ~ "continuous2",
              statistic = all_continuous() ~ "{mean} ({N_nonmiss})",
              missing = "no") %>% 
  modify_header(update = all_stat_cols() ~ "**{level}**") %>% 
  add_difference(test = list(all_continuous() ~ "t.test"))

fees_tbl3 <- fees_by_type2 %>% filter(status2 == 0) %>% 
  select(c("total_fees", "entry", "formation", "liberation", "materials", "contract", "application", "wave")) %>% 
  mutate(wave = factor(wave, labels = c("Baseline", "Endline"))) %>% 
  tbl_summary(by=wave,
              type = everything() ~ "continuous2",
              statistic = all_continuous() ~ "{mean} ({N_nonmiss})",
              missing = "no") %>% 
  modify_header(update = all_stat_cols() ~ "**{level}**") %>% 
  add_difference(test = list(all_continuous() ~ "t.test"))

tbl_merge(list(fees_tbl, fees_tbl2, fees_tbl3), tab_spanner = c("Selected CQPs", "Unsuccessful CQP applicants", "Traditional (did not apply)")) %>% italicize_labels() %>% as_gt() %>%
  gt::tab_style(
    style = gt::cell_text(weight = "bold"),
    locations = gt::cells_row_groups(groups = everything())
  )

## ---- tbl-fees --------

x <- df %>% mutate_at(c("fee_entry", "fee_formation", "fee_liberation", "fee_materials", "fee_contract", "fee_application", "total_fees", "a_fee_entry", "a_fee_formation", "a_fee_liberation", "a_fee_materials", "a_fee_contract", "a_fee_application", "a_total_fees"), ~./605) %>% select(-"fees_avg", -"annual_fees") %>% pivot_longer(cols = contains("fee")) %>% mutate(side = ifelse(grepl("a_", name), "Apprentice", "Firm")) %>% mutate(name = str_remove_all(name, "a_")) %>% select(c(IDYouth, wave, side, name, value)) %>% pivot_wider() 

var_label(x$fee_entry) <- "Initiation"
var_label(x$fee_formation) <- "Training"
var_label(x$fee_liberation) <- "Graduation"
var_label(x$fee_materials) <- "Materials"
var_label(x$fee_contract) <- "Contract"
var_label(x$fee_application) <- "Application"
var_label(x$total_fees) <- "Total"

x %>% filter(wave == 0) %>% 
  tbl_summary(by=side,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no",
              digits = list(everything() ~ c(2, 2)),
              include = -c(IDYouth, wave)) %>% 
  add_stat(
    fns = everything() ~ add_by_n
  ) %>% 
  add_difference(test = everything() ~ "paired.t.test", group = IDYouth) %>% 
  modify_table_body(
    ~ .x %>%
      dplyr::relocate(add_n_stat_1, .before = stat_1) %>%
      dplyr::relocate(add_n_stat_2, .before = stat_2) %>% 
      dplyr::mutate(estimate = -1 * estimate)
  ) %>%
  modify_column_hide(ci) %>%
  modify_header(all_stat_cols() ~ "**{level}**",
                starts_with("add_n_stat") ~ "**N**",
                label = "**Fee**",
                p.value = "**p-value¹**") %>% 
  modify_footnote(update = everything() ~ NA) %>% 
  as_kable_extra(caption = "Apprenticeship fees, MC vs. apprentice responses",
                 escape = F,
                 booktabs = T,
                 linesep = "",
                 position = "H",
                 addtl_fmt = F) %>%
  kableExtra::row_spec(7,bold=T) %>% 
  footnote(general = "Mean (SD). Based on responses from baseline survey. All fees are total amounts to be paid over the course of the apprenticeship. Amounts in \\\\$US.",
           number = "Paired t-test.",
           threeparttable = T,
           escape = F,
           fixed_small_size = T,
           general_title = "") %>% 
  kableExtra::kable_styling(latex_options="scale_down")

## ---- tbl-fees2 --------

baseline <- df %>% filter(wave == 0) %>% select(c("fee_entry", "fee_formation", "fee_liberation", "fee_materials", "fee_contract", "fee_application", "total_fees", "SELECTED")) %>% 
  mutate(across(contains("fee"), ~./605)) %>% 
  mutate(SELECTED = factor(SELECTED, levels = c(1, 0, 3),
                           labels = c('CQP Selected', 'CQP Not Selected', 'Did Not Apply'))) %>% 
  tbl_summary(by=SELECTED,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no",
              digits = all_continuous() ~ 2) %>% 
  modify_footnote(update = everything() ~ NA)

endline <- df %>% filter(wave == 1) %>% select(c("fee_entry", "fee_formation", "fee_liberation", "fee_materials", "fee_contract", "fee_application", "total_fees", "SELECTED")) %>% 
  mutate(across(contains("fee"), ~./605)) %>% 
  mutate(SELECTED = factor(SELECTED, levels = c(1, 0, 3),
                           labels = c('CQP Selected', 'CQP Not Selected', 'Did Not Apply'))) %>% 
  tbl_summary(by=SELECTED,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no",
              digits = all_continuous() ~ 2) %>% 
  modify_footnote(update = everything() ~ NA)

overall <- df %>% select(c("fee_entry", "fee_formation", "fee_liberation", "fee_materials", "fee_contract", "fee_application", "total_fees", "SELECTED")) %>% 
  mutate(SELECTED = factor(SELECTED, levels = c(1, 0, 3),
                           labels = c('CQP Selected', 'CQP Not Selected', 'Did Not Apply'))) %>% 
  mutate(across(contains("fee"), ~./605)) %>% 
  tbl_summary(by=SELECTED,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no",
              digits = all_continuous() ~ 2) %>% 
  modify_footnote(update = everything() ~ NA)

tbl_stack(list(baseline, endline, overall), group_header = c("Baseline", "Endline", "Overall"), quiet = TRUE) %>% 
  as_kable_extra(caption = "Fees reported by firm", 
                 booktabs = T,
                 linesep = "",
                 position = "H") %>% 
  kableExtra::kable_styling(latex_options="scale_down") %>% 
  footnote(general = "Mean (SD). All fees are total amounts to be paid over the course of the apprenticeship. Amounts in \\\\$US.",
           threeparttable = T,
           escape = F,
           fixed_small_size = T,
           general_title = "")


