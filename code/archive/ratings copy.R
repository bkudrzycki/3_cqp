#############
## RATINGS ##
#############

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

load("data/df.rda")

# patron ratings of apprentices

df %>% select(contains("rating"), wave) %>%
  mutate(wave = factor(wave, labels = c("Baseline", "Endline"))) %>% 
  tbl_summary(by=wave,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no") %>% 
  add_p() %>% 
  modify_footnote(
    all_stat_cols() ~ "Mean (SD). Apprentice qualities ranked by firm owner on a scale of 1-5."
  )

df %>% filter(wave == 0) %>% select(contains("rating"), "SELECTED") %>% 
  mutate(SELECTED = factor(SELECTED, levels = c(1, 0, 3),
                           labels = c('Selected', 'Not Selected', 'Did Not Apply'))) %>% 
  tbl_summary(by=SELECTED,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no") %>% 
  modify_footnote(
    all_stat_cols() ~ "Mean (SD). Proportion of experienced tasks as reported by firm at baseline."
  ) %>% 
  add_p()

df %>% filter(wave == 1) %>% select(contains("rating"), -contains("a_"), "SELECTED") %>% 
  mutate(SELECTED = factor(SELECTED, levels = c(1, 0, 3),
                           labels = c('Selected', 'Not Selected', 'Did Not Apply'))) %>% 
  tbl_summary(by=SELECTED,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no") %>% 
  modify_footnote(
    all_stat_cols() ~ "Mean (SD). Proportion of experienced tasks as reported by firm at endline."
  ) %>% 
  add_p()


# comparing changes over time for cqp/noncqp/nonselected apprentices

cqp <- df %>% filter(SELECTED == 1) %>% select(contains("rating"), wave) %>%
  mutate(wave = factor(wave, labels = c("Baseline", "Endline"))) %>% 
  tbl_summary(by=wave,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no") %>% 
  add_difference() %>%  
  modify_footnote(
    all_stat_cols() ~ "Mean (SD). Apprentice qualities ranked by firm owner on a scale of 1-5."
  )

noncqp <- df %>% filter(SELECTED == 0) %>% select(contains("rating"), wave) %>%
  mutate(wave = factor(wave, labels = c("Baseline", "Endline"))) %>% 
  tbl_summary(by=wave,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no") %>% 
  add_difference() %>% 
  modify_footnote(
    all_stat_cols() ~ "Mean (SD). Apprentice qualities ranked by firm owner on a scale of 1-5."
  )

trad <- df %>% filter(SELECTED == 3) %>% select(contains("rating"), wave) %>%
  mutate(wave = factor(wave, labels = c("Baseline", "Endline"))) %>% 
  tbl_summary(by=wave,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no") %>% 
  add_difference() %>%  
  modify_footnote(
    all_stat_cols() ~ "Mean (SD). Apprentice qualities ranked by firm owner on a scale of 1-5."
  )

all <- df %>% select(contains("rating"), wave) %>%
  mutate(wave = factor(wave, labels = c("Baseline", "Endline"))) %>% 
  tbl_summary(by=wave,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no") %>% 
  add_difference() %>% 
  modify_footnote(
    all_stat_cols() ~ "Mean (SD). Apprentice qualities ranked by firm owner on a scale of 1-5."
  )

tbl_stack(list(cqp, noncqp, trad, all), group_header = c("CQP", "Non-CQP", "Traditional", "Overall"), quiet = TRUE) 
tbl_merge(list(cqp, noncqp, trad, all), tab_spanner = c("**Selected**", "**Not Selected**", "**Did Not Apply**", "**Overall**"))
  

# apprentice ratings of firms (YS4.40/YE3.26) and satisfaction with firm (YS4.41/YE3.27) and external training (YS4.51)

df %>% filter(wave == 0) %>% select(contains("YS4.40"), contains("YS4.41"), contains("YS4.51"), "SELECTED") %>% 
  mutate(SELECTED = factor(SELECTED, levels = c(1, 0, 3),
                           labels = c('Selected', 'Not Selected', 'Did Not Apply'))) %>% 
  tbl_summary(by=SELECTED,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no") %>% 
  modify_footnote(
    all_stat_cols() ~ "Mean (SD). Proportion of experienced tasks as reported by firm at baseline."
  ) %>% 
  add_p() %>% add_overall()

df %>% filter(wave == 1) %>% select(contains("YS4.40"), contains("YS4.41"), contains("YS4.51"), "SELECTED") %>% 
  mutate(SELECTED = factor(SELECTED, levels = c(1, 0, 3),
                           labels = c('Selected', 'Not Selected', 'Did Not Apply'))) %>% 
  tbl_summary(by=SELECTED,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no") %>% 
  modify_footnote(
    all_stat_cols() ~ "Mean (SD). Proportion of experienced tasks as reported by firm at baseline."
  ) %>% 
  add_p() %>% add_overall()

df %>% select(contains("YS4.40"), contains("YS4.41"), "wave") %>% 
  mutate(wave = factor(wave, labels = c("Baseline", "Endline"))) %>% 
  tbl_summary(by=wave,
              type = everything() ~ "continuous",
              label = YS4.41 ~ "Overall Satisfaction",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no") %>% 
  modify_footnote(
    all_stat_cols() ~ "Mean (SD). Proportion of experienced tasks as reported by firm at baseline."
  ) %>% 
  add_p() %>% add_overall()


x <- df %>% filter(SELECTED != 3)
x$SELECTED <- factor(x$SELECTED, levels = c(1, 0))
                 
x %>% select("IDYouth", contains("YS4.40"), contains("YS4.41"), "SELECTED", "wave") %>% pivot_wider(names_from = wave, values_from = contains("YS4.4")) %>% ungroup() %>% mutate(diff_safety = YS4.40_1_1-YS4.40_1_0, diff_knowledge = YS4.40_2_1-YS4.40_2_0, diff_treatment = YS4.40_3_1-YS4.40_3_0, diff_salary = YS4.40_4_1-YS4.40_4_0, diff_workhours = YS4.40_5_1-YS4.40_5_0, diff_trainingquality = YS4.40_6_1-YS4.40_6_0, diff_equip = YS4.40_7_1-YS4.40_7_0, diff_colleagues = YS4.40_8_1-YS4.40_8_0, diff_satisfaction = YS4.41_1-YS4.41_0) %>% select("SELECTED", contains("diff")) %>% tbl_summary(by = SELECTED, missing = "no", type = everything() ~ "continuous", statistic = all_continuous() ~ c("{mean} ({sd})")) %>% add_p()

rm(list = ls())
