#######################################
## Apprentice-Level Baseline/Endline ##
#######################################

packages <- c("tidyverse", "labelled", "stargazer")

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


# Benefits for apprentices

m1 <- lm(skills_all_trades ~ duration, data = df)

m1 <- lm(skills_all_trades ~ 



# mean hours worked 
df %>% select(contains("hours"), wave) %>%
  mutate(wave = factor(wave, labels = c("Baseline", "Endline"))) %>% 
  tbl_summary(by=wave,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no",
              digits = list(everything() ~ c(1, 1)))  %>% 
  add_stat(
    fns = everything() ~ add_by_n
  ) %>% 
  modify_table_body(
    ~ .x %>%
      dplyr::relocate(add_n_stat_1, .before = stat_1) %>%
      dplyr::relocate(add_n_stat_2, .before = stat_2)
  ) %>%
  modify_header(stat_by =  "**{level}**",
                starts_with("add_n_stat") ~ "**N**",
                label = "") %>% 
  modify_footnote(
    all_stat_cols() ~ "Mean (SD). Hours worked in previous week."
  )

# wages
df %>% select(contains("FS5.2"), wave, FS1.2) %>%
  mutate(wave = factor(wave, labels = c("Baseline", "Endline"))) %>% 
  group_by(FS1.2, wave) %>% summarise_all(mean, na.rm = T) %>% 
  tbl_summary(by=wave,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no",
              include = -FS1.2,
              digits = list(everything() ~ c(0, 0)),
              label = list(FS5.2_1_7 ~ "Firm owner",
                           FS5.2_1_1 ~ "Former apprentice (diff. workshop)",
                           FS5.2_1_2 ~ "Former apprentice (same workshop)",
                           FS5.2_1_3 ~ "Worker with secondary educ. or more",
                           FS5.2_1_4 ~ "Worker with primary educ. or less",
                           FS5.2_1_5 ~ "Paid family worker",
                           FS5.2_1_6 ~ "Occassional worker",
                           FS5.2_1_8 ~ "Traditional apprentice (first year)",
                           FS5.2_1_9 ~ "Traditional apprentice (third year)",
                           FS5.2_1_10 ~ "CQP apprentice (first year)",
                           FS5.2_1_11 ~ "CQP apprentice (third year)"))  %>% 
  add_p(all_continuous() ~ "paired.t.test", group = FS1.2) %>% 
  add_stat(
    fns = everything() ~ add_by_n
  ) %>% 
  modify_table_body(
    ~ .x %>%
      dplyr::relocate(add_n_stat_1, .before = stat_1) %>%
      dplyr::relocate(add_n_stat_2, .before = stat_2)
  ) %>%
  modify_header(stat_by =  "**{level}**",
                starts_with("add_n_stat") ~ "**N firms**",
                label = "") %>% 
  modify_footnote(
    all_stat_cols() ~ "Mean (SD). Monthly wages in FCFA."
  )

df %>% filter(SELECTED !=3) %>% select("weekly_hours", SELECTED) %>%
  mutate(SELECTED = factor(SELECTED, levels = c(1, 0),
                           labels = c('Selected', 'Not Selected'))) %>% 
  tbl_summary(by=SELECTED,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no",
              digits = list(everything() ~ c(1, 1)))  %>% 
  add_stat(
    fns = everything() ~ add_by_n
  ) %>% 
  modify_table_body(
    ~ .x %>%
      dplyr::relocate(add_n_stat_1, .before = stat_1) %>%
      dplyr::relocate(add_n_stat_2, .before = stat_2)
  ) %>%
  modify_header(stat_by =  "**{level}**",
                starts_with("add_n_stat") ~ "**N**",
                label = "") %>% 
  add_difference() %>% 
  modify_footnote(
    all_stat_cols() ~ "Mean (SD). Hours worked in previous week."
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
  mutate(wave = factor(wave, labels = c("Baseline", "Endline"))) %>% 
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
  mutate(wave = factor(wave, labels = c("Baseline", "Endline"))) %>% 
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


tbl_stack(list(cqp, noncqp), group_header = c("CQP Apprentices", "Non-CQP Apprentices"), quiet = TRUE) 

rm(list = ls())
