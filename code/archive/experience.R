################
## EXPERIENCE ##
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

# firm-side
df %>% select(contains("exp"), -contains("a_"), wave, IDYouth) %>%
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

df %>% filter(wave == 0) %>% select(contains("exp"), -contains("a_"), "SELECTED") %>% 
  mutate(SELECTED = factor(SELECTED, levels = c(1, 0, 3),
                           labels = c('Selected', 'Not Selected', 'Did Not Apply'))) %>% 
  tbl_summary(by=SELECTED,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no") %>% 
  add_n() %>% 
  modify_footnote(
    all_stat_cols() ~ "Mean (SD). Proportion of experienced tasks as reported by firm at baseline."
  ) %>% 
  add_p()

df %>% filter(wave == 1) %>% select(contains("exp"), -contains("a_"), "SELECTED") %>% 
  mutate(SELECTED = factor(SELECTED, levels = c(1, 0, 3),
                           labels = c('Selected', 'Not Selected', 'Did Not Apply'))) %>% 
  tbl_summary(by=SELECTED,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no") %>% 
  add_n() %>% 
  modify_footnote(
    all_stat_cols() ~ "Mean (SD). Proportion of experienced tasks as reported by firm at endline."
  ) %>% 
  add_p()

# apprentice-side self-reported expetencies

df %>% filter(wave==1, SELECTED != 3) %>% select(contains("a_exp"), SELECTED) %>% 
  mutate(SELECTED = factor(SELECTED, levels = c(1, 0),
                           labels = c('Selected', 'Not Selected'))) %>% 
  tbl_summary(by=SELECTED,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no") %>% 
  add_n() %>% 
  add_overall() %>% 
  add_p(all_continuous() ~ "t.test") %>% 
  modify_footnote(
    all_stat_cols() ~ "Mean (SD). Proportion of experienced tasks as self-reported by apprentices at endline."
  )

# exparing firm-side and apprentice-side expetencies (endline only)

x <- df %>% filter(wave == 1, SELECTED != 3) %>% pivot_longer(cols = contains("exp")) %>% mutate(side = ifelse(grepl("a_", name), "Apprentice", "Firm")) %>% mutate(name = str_remove_all(name, "a_")) %>% select(c(IDYouth, SELECTED, side, name, value)) %>% pivot_wider() %>% select(-IDYouth)

var_label(x$exp_elec) <- "Electrical Installation"
var_label(x$exp_macon) <- "Masonry"
var_label(x$exp_menuis) <- "Carpentry"
var_label(x$exp_plomb) <- "Plumbing"
var_label(x$exp_metal) <- "Metalwork"
var_label(x$exp_all_trades) <- "Overall"

cqp <- x %>% filter(SELECTED == 1) %>% select(-SELECTED) %>% 
  tbl_summary(by=side,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no") %>% 
  modify_header(stat_by =  "**{level}**") %>% 
  modify_footnote(
    all_stat_cols() ~ "Mean (SD). Proportion of experienced tasks reported at endline.") %>% 
  add_p(all_continuous() ~ "t.test") 


noncqp <- x %>% filter(SELECTED == 0) %>% select(-SELECTED) %>% 
  tbl_summary(by=side,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no") %>% 
  modify_header(stat_by =  "**{level}**") %>% 
  modify_footnote(
    all_stat_cols() ~ "Mean (SD). Proportion of experienced tasks reported at endline.") %>% 
  add_p(all_continuous() ~ "t.test") 


all <- x %>% select(-SELECTED) %>% 
  tbl_summary(by=side,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no") %>% 
  modify_header(stat_by =  "**{level}**") %>% 
  modify_footnote(
    all_stat_cols() ~ "Mean (SD). Proportion of experienced tasks reported at endline.") %>% 
  add_p(all_continuous() ~ "t.test") 

tbl_stack(list(cqp, noncqp, all), group_header = c("CQP", "Non-CQP", "Overall"), quiet = TRUE)
tbl_merge(list(cqp, noncqp, all), tab_spanner = c("**Selected**", "**Not Selected**", "**Overall**"))

rm(list = ls())
