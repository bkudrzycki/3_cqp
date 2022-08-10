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