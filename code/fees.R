##########
## FEES ##
##########

packages <- c("tidyverse", "labelled", "gtsummary", "gt")

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

# firm-side fees
df %>% select(contains("fee"), -contains("a_"), "wave") %>%
  mutate(wave = factor(wave, labels = c("Baseline", "Endline"))) %>% 
  tbl_summary(by=wave,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no") %>% 
  modify_footnote(
    all_stat_cols() ~ "Mean (SD). Fees reported in FCFA by firm."
  )

df %>% filter(wave == 0) %>% select(c("fee_entry", "fee_formation", "fee_liberation", "fee_materials", "fee_contract", "fee_application", "total_fees", "SELECTED")) %>% 
  mutate(SELECTED = factor(SELECTED, levels = c(1, 0, 3),
                        labels = c('Selected', 'Not Selected', 'Did Not Apply'))) %>% 
  tbl_summary(by=SELECTED,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no") %>% 
  modify_footnote(
    all_stat_cols() ~ "Mean (SD). Fees reported in FCFA by firm at baseline."
  ) %>% 
  add_p()

df %>% filter(wave == 1) %>% select(c("fee_entry", "fee_formation", "fee_liberation", "fee_materials", "fee_contract", "fee_application", "total_fees", "SELECTED")) %>% 
  mutate(SELECTED = factor(SELECTED, levels = c(1, 0, 3),
                           labels = c('Selected', 'Not Selected', 'Did Not Apply'))) %>% 
  tbl_summary(by=SELECTED,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no") %>% 
  modify_footnote(
    all_stat_cols() ~ "Mean (SD). Fees reported in FCFA by firm at endline."
  ) %>% 
  add_p()

# apprentice-side fees

df <- unlabelled(df)

df %>% filter(wave == 0) %>% filter(SELECTED != 3) %>% select(contains("a_fee")) %>% 
  tbl_summary(type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no") %>% 
  modify_footnote(
    all_stat_cols() ~ "Mean (SD). Fees reported in FCFA by apprentices at baseline."
  )

df %>% select(contains("a_fee"), "SELECTED") %>% filter(SELECTED != 3) %>% 
  mutate(SELECTED = factor(SELECTED, levels = c(1, 0),
                           labels = c('Selected', 'Not Selected'))) %>% 
  tbl_summary(by=SELECTED,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no") %>% 
  modify_footnote(
    all_stat_cols() ~ "Mean (SD). Fees reported in FCFA by apprentices at baseline."
  ) %>% 
  add_p()

# comparing firm-side and apprentice-side fees

x <- df %>% filter(wave == 0, SELECTED != 3) %>% select(-fees_avg) %>%  pivot_longer(cols = contains("fee")) %>% mutate(side = ifelse(grepl("a_", name), "Apprentice", "Firm")) %>% mutate(name = str_remove_all(name, "a_")) %>% mutate(value = replace_na(value, 0)) %>% select(c(IDYouth, SELECTED, side, name, value)) %>% pivot_wider() %>% select(-IDYouth)

var_label(x$fee_entry) <- "Initiation"
var_label(x$fee_formation) <- "Training"
var_label(x$fee_liberation) <- "Graduation"
var_label(x$fee_materials) <- "Materials"
var_label(x$fee_contract) <- "Contract"
var_label(x$fee_application) <- "Application"
var_label(x$total_fees) <- "Total"

cqp <- x %>% filter(SELECTED == 1) %>% select(-SELECTED) %>% 
  tbl_summary(by=side,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no") %>% 
  modify_footnote(
    all_stat_cols() ~ "Mean (SD). Fees reported in FCFA at baseline. Only cases in which both apprentice and firm reported fees are shown."
  ) %>% 
  add_p()

noncqp <- x %>% filter(SELECTED == 0) %>% select(-SELECTED) %>% 
  tbl_summary(by=side,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no") %>% 
  modify_footnote(
    all_stat_cols() ~ "Mean (SD). Fees reported in FCFA at baseline. Only cases in which both apprentice and firm reported fees are shown."
  ) %>% 
  add_p()

all <- x %>% select(-SELECTED) %>% 
  tbl_summary(by=side,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no") %>% 
  modify_footnote(
    all_stat_cols() ~ "Mean (SD). Fees reported in FCFA at baseline. Only cases in which both apprentice and firm reported fees are shown."
  ) %>% 
  add_p()

tbl_stack(list(cqp, noncqp, all), group_header = c("CQP", "Non-CQP", "Overall"), quiet = TRUE)
tbl_merge(list(cqp, noncqp, all), tab_spanner = c("**Selected**", "**Not Selected**", "**Overall**"))

rm(list = ls())
