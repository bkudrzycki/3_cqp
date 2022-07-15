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

# load data
load("data/df.rda")

# load functions
source("functions/add_by_n.R")

df <- unlabelled(df)

## ---- test-i --------

apps <- df %>% mutate(N = 1) %>%  select(N, age, sex, FS1.11, duration, schooling, wave) %>%
  mutate(wave = factor(wave, levels = 0:1, labels = c('Baseline', 'Endline')),
         sex = factor(sex, levels = 0:1, labels = c("Female", "Male")),
         FS1.11 = factor(FS1.11, labels = c('Masonry', 'Carpentry', 'Plumbing', 'Metalworking', 'Electrical Inst.'))) %>% 
  rename("Age" = age, "Gender" = sex, "Trade" = FS1.11) %>% 
  tbl_summary(by=wave,
              type = list(Age ~ "continuous",
                          duration ~ "continuous",
                          Gender ~ "categorical"),
              statistic = list(all_continuous() ~ c("{mean} ({sd})"),
                               N ~ "{N}"),
              missing = "no",
              label = list(Trade ~ "Trade",
                           duration ~ "Years in training",
                           schooling ~ "Education")) %>% 
  modify_header(all_stat_cols() ~ "**{level}**")

workshops <- df %>% mutate(N_firms = 1) %>% mutate(not_selected = dossier_apps-dossier_selected,
                                             did_not_apply = FS6.1-dossier_apps,
                                             FS1.11 = as.numeric(FS1.11)) %>% 
  select(N_firms, FS1.2, FS6.1, dossier_selected, not_selected, did_not_apply, firm_size, FS3.4, contains("FS3.5"), FS1.11, wave) %>%
  group_by(FS1.2, wave) %>% summarise_all(mean, na.rm = T) %>% ungroup() %>%
  mutate(wave = factor(wave, labels = c("Baseline", "Endline")),
         FS1.11 = factor(FS1.11, labels = c('Masonry', 'Carpentry', 'Plumbing', 'Metalworking', 'Electrical Inst.'))) %>% 
  tbl_summary(by=wave,
              type = list(c(firm_size, FS3.4, FS6.1, FS3.5_2, FS3.5_3, FS3.5_4, FS3.5_5)  ~ "continuous",
                          FS1.11 ~ "categorical"),
              statistic = list(all_continuous() ~ "{mean} ({sd})",
                               N_firms ~ "{N}"),
              missing = "no",
              digits = list(firm_size ~ c(1, 1),
                            starts_with("FS3.5") ~ c(2, 1)),
              label = list(FS3.4 ~ "Total (reported)",
                           firm_size ~ "Total (calculated)",
                           dossier_selected ~ "Selected",
                           not_selected ~ "Not Selected",
                           did_not_apply ~ "Did Not Apply",
                           FS6.1 ~ "Total",
                           FS3.5_2 ~ "Permanent wage",
                           FS3.5_3 ~ "Paid family",
                           FS3.5_4 ~ "Unpaid family",
                           FS3.5_5 ~ "Occasional",
                           FS1.11 ~ "Trade",
                           N_firms ~ "N"),
              include = -c(FS1.2, FS3.5_1)) %>% 
  modify_header(all_stat_cols() ~ "**{level}**", label = "")

x <- tbl_stack(list(apps, workshops), quiet = T) 

y <- df %>% mutate(N = 1) %>% filter(wave == 0) %>% select(N, age, sex, SELECTED, FS1.11, duration, schooling) %>%
  mutate(SELECTED = factor(SELECTED, levels = c(1, 0, 3),
                           labels = c('Selected', 'Not Selected', 'Did Not Apply')),
         sex = factor(sex, levels = 0:1, labels = c("Female", "Male")),
         FS1.11 = factor(FS1.11, labels = c('Masonry', 'Carpentry', 'Plumbing', 'Metalworking', 'Electrical Inst.'))) %>% 
  rename("Age" = age, "Gender" = sex, "Trade" = FS1.11) %>% 
  tbl_summary(by=SELECTED,
              type = list(Age ~ "continuous",
                          duration ~ "continuous",
                          Gender ~ "categorical"),
              statistic = list(all_continuous() ~ c("{mean} ({sd})"),
                               N ~ "{N}"),
              missing = "no",
              label = list(Trade ~ "Trade",
                           duration ~ "Years in training",
                           schooling ~ "Education")) %>% 
  modify_header(all_stat_cols() ~ "**{level}**")

tbl_merge(list(x, y), tab_spanner = c("Overall", "By baseline status")) %>% 
  as_kable_extra(caption = "Descriptive Statistics",
                 booktabs = T,
                 linesep = "",
                 position = "H") %>%
  kableExtra::group_rows(start_row = 1,
                         end_row = 19,
                         group_label = "Apprentices") %>% 
  kableExtra::group_rows(start_row = 20,
                         end_row = 36,
                         group_label = "Firms",
                         hline_before = TRUE) %>% 
  kableExtra::group_rows(start_row = 21,
                         end_row = 24,
                         group_label = "\\hspace{1em}Apprentices trained",
                         escape = F,
                         indent = T,
                         bold = F) %>% 
  kableExtra::group_rows(start_row = 25,
                         end_row = 30,
                         group_label = "\\hspace{1em}Firm size",
                         escape = F,
                         indent = T,
                         bold = F) %>% 
  kableExtra::kable_styling(latex_options="scale_down")


## ---- test-j --------

x <- df %>% filter(wave == 0) %>% 
  mutate(baseline_status = SELECTED,
         baseline_exp = duration,
         baseline_trade = FS1.11,
  ) %>% select(IDYouth, baseline_status, baseline_exp, baseline_trade)

y <- df %>% left_join(x, by = "IDYouth")

y %>% select(wave, baseline_age, sex, schooling, baseline_status, baseline_exp, baseline_trade) %>%
  mutate(baseline_trade = factor(baseline_trade, levels = 1:5, labels = c('Masonry', 'Carpentry', 'Plumbing', 'Metalworking', 'Electrical Inst.')),
         baseline_status = factor(baseline_status, levels = c(1, 0, 3),
                                  labels = c('Selected', 'Not Selected', 'Did Not Apply')),
         wave = factor(wave, levels = 0:1, labels = c('Baseline', 'Endline'))) %>% 
  tbl_summary(by = wave,
              missing = "no",
              type = baseline_exp ~ "continuous",
              label = list(baseline_trade ~ "Trade",
                           sex ~ "Male",
                           baseline_age ~ "Age",
                           schooling ~ "Education",
                           baseline_status ~ "CQP status",
                           baseline_exp ~ "Training experience, years"),
              statistic = list(all_continuous() ~ "{mean} ({sd})",
                               all_categorical() ~ "{n} ({p}%)",
                               sex ~ "{p}%")) %>% add_p() %>% 
  as_kable_extra(caption = "Apprentice Attrition",
                 booktabs = T,
                 linesep = "",
                 position = "H")

## ---- test-k --------

x <- df %>% filter(wave == 0) %>% 
  mutate(baseline_size = firm_size,
         baseline_calcsize = FS3.4,
         baseline_apps = FS6.1,
         baseline_sel = dossier_selected,
         baseline_notsel = dossier_apps-dossier_selected,
         baseline_dna = FS6.1-dossier_apps,
         baseline_wage = FS3.5_2,
         baseline_paid_fam = FS3.5_3,
         baseline_unpaid_fam = FS3.5_4,
         baseline_occ = FS3.5_5,
         baseline_trade = as.numeric(FS1.11),
  ) %>% select(FS1.2, contains("baseline"))

y <- df %>% left_join(x, by = "FS1.2")

y %>% select(FS1.2, wave, baseline_apps, baseline_sel, baseline_notsel, baseline_dna, baseline_size, baseline_calcsize, baseline_wage, baseline_paid_fam, baseline_unpaid_fam, baseline_occ, baseline_trade) %>%
  group_by(FS1.2, wave) %>% summarise_all(mean, na.rm = T) %>% ungroup() %>%
  mutate(wave = factor(wave, labels = c("Baseline", "Endline")),
         baseline_trade = factor(baseline_trade, levels = 1:5, labels = c('Masonry', 'Carpentry', 'Plumbing', 'Metalworking', 'Electrical Inst.'))) %>% 
  tbl_summary(by=wave,
              type = list(c(baseline_size, baseline_calcsize, baseline_apps, baseline_sel, baseline_notsel, baseline_dna, baseline_wage, baseline_paid_fam, baseline_unpaid_fam, baseline_occ)  ~ "continuous",
                          baseline_trade ~ "categorical"),
              statistic = list(all_continuous() ~ "{mean} ({sd})"),
              missing = "no",
              label = list(baseline_size ~ "Total (calculated)",
                           baseline_calcsize ~ "Total (reported)",
                           baseline_sel ~ "Selected",
                           baseline_notsel ~ "Not Selected",
                           baseline_dna ~ "Did Not Apply",
                           baseline_apps ~ "Total",
                           baseline_wage ~ "Permanent employees",
                           baseline_paid_fam ~ "Paid family workers",
                           baseline_unpaid_fam ~ "Unpaid family workers",
                           baseline_occ ~ "Occasional workers",
                           baseline_trade ~ "Trade"),
              include = -FS1.2) %>% 
  add_p() %>% 
  as_kable_extra(caption = "Firm Attrition",
                 booktabs = T,
                 linesep = "",
                 position = "H") %>% 
  kableExtra::group_rows(start_row = 1,
                         end_row = 4,
                         group_label = "Apprentices trained",
                         escape = F,
                         indent = T,
                         bold = F) %>% 
  kableExtra::group_rows(start_row = 5,
                         end_row = 10,
                         group_label = "Firm size",
                         escape = F,
                         indent = T,
                         bold = F)