################
## ALLOWANCES ##
################

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

# firm-side allowances


df %>% select(contains("allow"), wave, -"allow_other", -"a_allow") %>% 
  mutate(wave = factor(wave, labels = c("Baseline", "Endline"))) %>% 
  tbl_summary(by=wave,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no") %>% 
  modify_footnote(
    all_stat_cols() ~ "Mean (SD). Allowances reported in FCFA by firm."
  )

df %>% select(contains("allow"), wave, IDYouth, -"allow_other", -"a_allow", -"allow_avg") %>% 
  mutate(wave = factor(wave, labels = c("Baseline", "Endline"))) %>% 
  tbl_summary(by=wave,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no",
              include = -IDYouth) %>% 
  modify_footnote(
    all_stat_cols() ~ "Mean (SD). Allowances reported in FCFA by firm owner."
  ) %>% 
  add_p(all_continuous() ~ "paired.t.test", group = IDYouth)
  

baseline <- df %>% filter(wave == 0) %>% select(contains("allow"), "SELECTED", -"allow_other", -"a_allow", -"allow_avg") %>% 
  mutate(SELECTED = factor(SELECTED, levels = c(1, 0, 3),
                           labels = c('Selected', 'Not Selected', 'Did Not Apply'))) %>% 
  tbl_summary(by=SELECTED,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no") %>% 
  add_n() %>% 
  modify_footnote(
    all_stat_cols() ~ "Mean (SD). Allowances reported in FCFA by firm at baseline."
  )

endline <- df %>% filter(wave == 1) %>% select(contains("allow"), "SELECTED", -"allow_other", -"a_allow", -"allow_avg") %>% 
  mutate(SELECTED = factor(SELECTED, levels = c(1, 0, 3),
                           labels = c('Selected', 'Not Selected', 'Did Not Apply'))) %>% 
  tbl_summary(by=SELECTED,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no") %>% 
  add_n() %>% 
  modify_footnote(
    all_stat_cols() ~ "Mean (SD). Allowances reported in FCFA by firm at endline."
  )

tbl_stack(list(baseline, endline), group_header = c("Baseline", "Endline"), quiet = TRUE)


# apprentice-side allowances (only total allowances reported in YS)

df %>% select(a_allow, wave) %>% 
  mutate(wave = factor(wave, labels = c("Baseline", "Endline"))) %>% 
  tbl_summary(by=wave,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no") %>% 
  add_n() %>% 
  modify_footnote(
    all_stat_cols() ~ "Mean (SD). Allowances reported in FCFA by apprentices."
  )

df %>% filter(wave==0) %>% select(a_allow, SELECTED) %>% filter(SELECTED != 3) %>% 
  mutate(SELECTED = factor(SELECTED, levels = c(1, 0),
                           labels = c('Selected', 'Not Selected'))) %>% 
  tbl_summary(by=SELECTED,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no") %>% 
  add_n() %>% 
  modify_footnote(
    all_stat_cols() ~ "Mean (SD). Allowances reported in FCFA by apprentices."
  ) %>% 
  add_p()

# comparing firm-side and apprentice-side fees

x <- df %>% filter(wave == 0, SELECTED != 3) %>% pivot_longer(cols = c(a_allow, all_allowances)) %>% mutate(name = ifelse(grepl("a_", name), "Apprentice", "Firm")) %>% select(c(SELECTED, name, value))

cqp <- x %>% filter(SELECTED == 1) %>% select(-SELECTED) %>% 
  rename("Selected" = value) %>% 
  tbl_summary(by=name,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no") %>% 
  modify_header(stat_by =  "**{level}**") %>%
  modify_footnote(
    all_stat_cols() ~ "Mean (SD). Allowances reported in FCFA at baseline.") %>% 
  add_p()


noncqp <- x %>% filter(SELECTED == 0) %>% select(-SELECTED) %>% 
  rename("Not Selected" = value) %>% 
  tbl_summary(by=name,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no") %>% 
  modify_header(update = all_stat_cols() ~ "**{level}**") %>% 
  modify_footnote(
    all_stat_cols() ~ "Mean (SD). Allowances reported in FCFA at baseline.") %>% 
  add_p()


all <- x %>% select(-SELECTED) %>% 
  rename("Total" = value) %>% 
  tbl_summary(by=name,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no") %>% 
  modify_header(stat_by =  "**{level}**") %>% 
  modify_footnote(
    all_stat_cols() ~ "Mean (SD). Allowances reported in FCFA at baseline.") %>% 
  add_p()

tbl_stack(list(cqp, noncqp, all), quiet = TRUE)

rm(list = ls())
