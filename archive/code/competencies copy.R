##################
## COMPETENCIES ##
##################

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

# firm-side
comp <- df %>% select(contains("comp"), -contains("a_"), wave, IDYouth) %>%
  mutate(wave = factor(wave, labels = c("Baseline", "Endline"))) %>% 
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
    all_stat_cols() ~ "Mean (SD). Proportion of tasks reported by firm."
  )

df %>% filter(wave == 0) %>% select(contains("comp"), -contains("a_"), "SELECTED") %>% 
  mutate(SELECTED = factor(SELECTED, levels = c(1, 0, 3),
                           labels = c('Selected', 'Not Selected', 'Did Not Apply'))) %>% 
  tbl_summary(by=SELECTED,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no") %>% 
  add_n() %>% 
  modify_footnote(
    all_stat_cols() ~ "Mean (SD). Proportion of competencies reported by firm at baseline."
  ) %>% 
  add_p()

df %>% filter(wave == 1) %>% select(contains("comp"), -contains("a_"), "SELECTED") %>% 
  mutate(SELECTED = factor(SELECTED, levels = c(1, 0, 3),
                           labels = c('Selected', 'Not Selected', 'Did Not Apply'))) %>% 
  tbl_summary(by=SELECTED,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no") %>% 
  add_n() %>% 
  modify_footnote(
    all_stat_cols() ~ "Mean (SD). Proportion of competencies reported by firm at endline."
  ) %>% 
  add_p()

# apprentice-side self-reported competencies

df %>% filter(wave==1, SELECTED != 3) %>% select(contains("a_comp"), SELECTED) %>% 
  mutate(SELECTED = factor(SELECTED, levels = c(1, 0),
                           labels = c('Selected', 'Not Selected'))) %>% 
  tbl_summary(by=SELECTED,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no") %>% 
  add_n() %>% 
  add_overall() %>% 
  modify_footnote(
    all_stat_cols() ~ "Mean (SD). Proportion of competencies self-reported by apprentices at endline."
  )

# comparing firm-side and apprentice-side competencies (endline only)

x <- df %>% filter(wave == 1, SELECTED != 3) %>% pivot_longer(cols = contains("comp")) %>% mutate(side = ifelse(grepl("a_", name), "Apprentice", "Firm")) %>% mutate(name = str_remove_all(name, "a_")) %>% select(c(IDYouth, SELECTED, side, name, value)) %>% pivot_wider() %>% select(-IDYouth)

var_label(x$comp_elec) <- "Electrical Installation"
var_label(x$comp_macon) <- "Masonry"
var_label(x$comp_menuis) <- "Carpentry"
var_label(x$comp_plomb) <- "Plumbing"
var_label(x$comp_metal) <- "Metalwork"
var_label(x$comp_all_trades) <- "Overall"

cqp <- x %>% filter(SELECTED == 1) %>% select(-SELECTED) %>% 
  tbl_summary(by=side,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no") %>% 
  modify_header(update = all_stat_cols() ~ "**{level}**") %>% 
  modify_footnote(
    all_stat_cols() ~ "Mean (SD). Proportion of competencies reported at endline.")


noncqp <- x %>% filter(SELECTED == 0) %>% select(-SELECTED) %>% 
  tbl_summary(by=side,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no") %>% 
  modify_header(update = all_stat_cols() ~ "**{level}**") %>% 
  modify_footnote(
    all_stat_cols() ~ "Mean (SD). Proportion of competencies reported at endline.")


all <- x %>% select(-SELECTED) %>% 
  tbl_summary(by=side,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no") %>% 
  modify_header(update = all_stat_cols() ~ "**{level}**") %>% 
  modify_footnote(
    all_stat_cols() ~ "Mean (SD). Proportion of competencies reported at endline.")

tbl_stack(list(cqp, noncqp, all), quiet = TRUE)

tbl_merge(list(cqp, noncqp, all), tab_spanner = c("**Selected**", "**Not Selected**", "**Overall**"))


## comparing differences in scores over time

comp <- df %>% select(contains("comp"), -contains("a_"), wave, IDYouth, SELECTED) %>%
  pivot_wider(names_from = wave,
              values_from = contains("comp")) %>%
  mutate(comp_elec = comp_elec_1-comp_elec_0,
         comp_macon = comp_macon_1-comp_macon_0,
         comp_menuis = comp_menuis_1-comp_menuis_0,
         comp_plomb = comp_plomb_1-comp_plomb_0,
         comp_metal = comp_metal_1-comp_metal_0) %>%
  select(comp_elec, comp_macon, comp_menuis, comp_plomb, comp_metal, SELECTED) %>% 
  mutate(SELECTED = factor(SELECTED, levels = c(1, 0, 3),
                           labels = c('Selected', 'Not Selected', 'Did Not Apply'))) %>% 
  tbl_summary(by=SELECTED,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no") %>% 
  add_stat(
    fns = everything() ~ add_by_n
  ) %>% 
  modify_table_body(
    ~ .x %>%
      dplyr::relocate(add_n_stat_1, .before = stat_1) %>%
      dplyr::relocate(add_n_stat_2, .before = stat_2) %>% 
      dplyr::relocate(add_n_stat_3, .before = stat_3)
  ) %>%
  modify_header(stat_by =  "**{level}**",
                starts_with("add_n_stat") ~ "**N**",
                label = "**Trade**") %>% 
  modify_footnote(
    all_stat_cols() ~ "Mean (SD). Change in scores over time."
  ) %>% 
  add_p()

exp <- df %>% select(contains("exp"), -contains("a_"), wave, IDYouth, SELECTED) %>%
  pivot_wider(names_from = wave,
              values_from = contains("exp")) %>%
  mutate(exp_elec = exp_elec_1-exp_elec_0,
         exp_macon = exp_macon_1-exp_macon_0,
         exp_menuis = exp_menuis_1-exp_menuis_0,
         exp_plomb = exp_plomb_1-exp_plomb_0,
         exp_metal = exp_metal_1-exp_metal_0) %>%
  select(exp_elec, exp_macon, exp_menuis, exp_plomb, exp_metal, SELECTED) %>% 
  mutate(SELECTED = factor(SELECTED, levels = c(1, 0, 3),
                           labels = c('Selected', 'Not Selected', 'Did Not Apply'))) %>% 
  tbl_summary(by=SELECTED,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no") %>% 
  add_stat(
    fns = everything() ~ add_by_n
  ) %>% 
  modify_table_body(
    ~ .x %>%
      dplyr::relocate(add_n_stat_1, .before = stat_1) %>%
      dplyr::relocate(add_n_stat_2, .before = stat_2) %>% 
      dplyr::relocate(add_n_stat_3, .before = stat_3)
  ) %>%
  modify_header(stat_by =  "**{level}**",
                starts_with("add_n_stat") ~ "**N**",
                label = "**Trade**") %>% 
  modify_footnote(
    all_stat_cols() ~ "Mean (SD). Change in task scores over time."
  ) %>% 
  add_p()

tbl_stack(list(comp, exp), group_header = c("Competency", "Experience"), quiet = TRUE)

rm(list = ls())
