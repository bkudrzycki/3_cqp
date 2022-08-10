############
## SKILLS ##
############

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

#load data
load("data/df.rda")

# load functions
source("functions/add_by_n.R")

df %>% select(contains("skills"), wave, IDYouth) %>%
  mutate(wave = factor(wave, levels = 0:1, labels = c('Baseline', 'Endline'))) %>% 
  tbl_summary(by=wave,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no",
              include = -IDYouth) %>% 
  add_stat(
    fns = everything() ~ add_by_n
  ) %>% 
  modify_table_body(
    ~ .x %>%
      dplyr::relocate(add_n_stat_1, .before = stat_1) %>%
      dplyr::relocate(add_n_stat_2, .before = stat_2)
  ) %>%
  add_p(all_continuous() ~ "paired.t.test", group = IDYouth) %>% 
  modify_header(stat_by =  "**{level}**",
                starts_with("add_n_stat") ~ "**N**",
                label = "**Trade**") %>% 
  modify_footnote(
    all_stat_cols() ~ "Mean (SD). Proportion of correct apprentice answers to knowledge questions."
  )

# comparing changes over time for cqp/noncqp apprentices

df %>% filter(wave == 0, SELECTED !=3) %>% select(contains("skills"), "SELECTED") %>% 
  mutate(SELECTED = factor(SELECTED, levels = c(1, 0),
                           labels = c('Selected', 'Not Selected'))) %>% 
  tbl_summary(by=SELECTED,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no") %>% 
  add_overall() %>% 
  modify_footnote(
    all_stat_cols() ~ "Mean (SD). Proportion of correct answers to skills questions at baseline."
  ) %>% 
  add_difference()

df %>% filter(wave == 1, SELECTED !=3) %>% select(contains("skills"), "SELECTED") %>% 
  mutate(SELECTED = factor(SELECTED, levels = c(1, 0),
                           labels = c('Selected', 'Not Selected'))) %>% 
  tbl_summary(by=SELECTED,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no") %>% 
  add_overall() %>% 
  modify_footnote(
    all_stat_cols() ~ "Mean (SD). Proportion of correct answers to skills questions at endline"
  ) %>% 
  add_difference()


cqp <- df %>% filter(SELECTED == 1) %>% select(contains("skills"), "wave") %>% 
  mutate(wave = factor(wave, levels = 0:1, labels = c('Baseline', 'Endline'))) %>% 
  tbl_summary(by=wave,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no") %>% 
  add_stat(
    fns = everything() ~ add_by_n
  ) %>% 
  modify_table_body(
    ~ .x %>%
      dplyr::relocate(add_n_stat_1, .before = stat_1) %>%
      dplyr::relocate(add_n_stat_2, .before = stat_2)
  ) %>%
  modify_footnote(
    all_stat_cols() ~ "Mean (SD). Proportion of correct answers to skills questions."
  ) %>% 
  modify_header(stat_by =  "**{level}**",
                starts_with("add_n_stat") ~ "**N**",
                label = "**Trade**") %>% 
  add_difference()

noncqp <- df %>% filter(SELECTED == 0) %>% select(contains("skills"), "wave") %>% 
  tbl_summary(by=wave,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no") %>% 
  add_stat(
    fns = everything() ~ add_by_n
  ) %>% 
  modify_table_body(
    ~ .x %>%
      dplyr::relocate(add_n_stat_1, .before = stat_1) %>%
      dplyr::relocate(add_n_stat_2, .before = stat_2)
  ) %>%
  modify_footnote(
    all_stat_cols() ~ "Mean (SD). Proportion of correct answers to skills questions."
  ) %>% 
  modify_header(stat_by =  "**{level}**",
                starts_with("add_n_stat") ~ "**N**",
                label = "**Trade**") %>% 
  add_difference()


tbl_stack(list(cqp, noncqp), group_header = c("CQP", "Non-CQP"), quiet = TRUE) 

rm(list = ls())
