########################
## COSTS AND BENEFITS ##
########################

packages <- c("tidyverse", "labelled", "gtsummary", "ggplot2")

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

# net costs benefits (simple)

df %>% filter(wave == 0) %>% select(FS1.2, cb_simple, cb_complex) %>% 
  group_by(FS1.2) %>% summarise_all(mean, na.rm = T) %>% 
  tbl_summary(type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no",
              include = -FS1.2)

# by CQP status
df %>% filter(wave == 0) %>% select(FS1.2, cb_simple, cb_complex, SELECTED) %>% 
  group_by(FS1.2, SELECTED) %>% summarise_all(mean, na.rm = T) %>% 
  mutate(SELECTED = factor(SELECTED, levels = c(1, 0, 3),
                           labels = c('Selected', 'Not Selected', 'Did Not Apply'))) %>% 
  tbl_summary(by = SELECTED,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no",
              include = -FS1.2)

# table with simple components, baseline only
annual <- df %>% filter(wave == 0) %>% select(FS1.2, FS6.1, total_fees, wage_simple, all_allowances, total_training_costs, costs_per_app, cb_simple) %>% 
  group_by(FS1.2) %>% summarise_all(mean, na.rm = T) %>% ungroup() %>% 
  mutate(total_fees = total_fees / 4,
         wage_simple = wage_simple * 12,
         all_allowances = all_allowances * 12,
         costs_per_app = costs_per_app * 12,
         total_training_costs = total_training_costs * 12,
         ) %>% 
  tbl_summary(type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              digits = list(everything() ~ c(0, 0)),
              missing = "no",
              include = -c(FS1.2, FS6.1),
              label = list(total_fees ~ "Fees",
                           wage_simple ~ "Estimated apprentice wage",
                           all_allowances ~ "Allowances",
                           total_training_costs ~ "Training costs, total",
                           costs_per_app ~ "Training costs, per apprentice",
                           cb_simple ~ "Simple net benefits")) %>% 
  modify_footnote(
    all_stat_cols() ~ "Mean (SD). Costs and benefits in FCFA."
  ) %>% 
  modify_header(label = "")

monthly <- df %>% filter(wave == 0) %>% select(FS1.2, FS6.1, total_fees, wage_simple, all_allowances, total_training_costs, costs_per_app, cb_simple) %>% 
  group_by(FS1.2) %>% summarise_all(mean, na.rm = T) %>% ungroup() %>% 
  mutate(total_fees = total_fees / 4 / 12,
         cb_simple = cb_simple / 12,
  ) %>% 
  tbl_summary(type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              digits = list(everything() ~ c(0, 0)),
              missing = "no",
              include = -c(FS1.2, FS6.1),
              label = list(total_fees ~ "Fees",
                           wage_simple ~ "Estimated apprentice wage",
                           all_allowances ~ "Allowances",
                           total_training_costs ~ "Training costs, total",
                           costs_per_app ~ "Training costs, per apprentice",
                           cb_simple ~ "Simple net benefits")) %>% 
  modify_footnote(
    all_stat_cols() ~ "Mean (SD). Costs and benefits in FCFA."
  ) %>% 
  modify_header(label = "")

tbl_merge(list(monthly, annual), tab_spanner = c("**Monthly**", "**Annual**"))

# table with detailed components, baseline only
df %>% filter(wave == 0) %>% select(FS1.2, FS6.1, total_fees, all_allowances, total_training_costs, costs_per_app, monthly_time_trained, FS5.2_1_2, FS5.2_1_4, FS5.2_1_8, FS5.2_1_9, FS5.2_1_10, FS5.2_1_11, cb_simple, cb_complex) %>% 
  group_by(FS1.2) %>% summarise_all(mean, na.rm = T) %>% ungroup() %>% 
  tbl_summary(type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              digits = list(everything() ~ c(0, 0),
                            FS6.1 ~ c(1,1)),
              missing = "no",
              include = -FS1.2,
              label = list(FS6.1 ~ "Number of apprentices",
                           total_fees ~ "Fees",
                           all_allowances ~ "Monthly allowances disbursed",
                           total_training_costs ~ "Monthly training costs, total",
                           costs_per_app ~ "Monthly training costs, per apprentice",
                           monthly_time_trained ~ "Hours trained in firm, past month", 
                           FS5.2_1_2 ~ "Wage (employee trained with firm)",
                           FS5.2_1_4 ~ "Wage (employee w/ primary educ. or less)",
                           FS5.2_1_8 ~ "Wage (first year trad. apprentice)",
                           FS5.2_1_9 ~ "Wage (third year trad. apprentice)",
                           FS5.2_1_10 ~ "Wage (first year CQP)",
                           FS5.2_1_11 ~ "Wage (third year CQP)",
                           cb_simple ~ "Simple net benefits",
                           cb_complex ~ "Complex net benefits")) %>% 
  modify_header(label = "")

# by cqp status

var_label(df$cb_simple) <- "Simple"
var_label(df$cb_complex) <- "Complex"

baseline <- df %>% filter(wave == 0) %>% select(cb_simple, cb_complex, IDYouth, SELECTED) %>% 
  mutate(SELECTED = factor(SELECTED, levels = c(1, 0, 3),
                           labels = c('Selected', 'Not Selected', 'Did Not Apply'))) %>% 
  tbl_summary(by=SELECTED,
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
      dplyr::relocate(add_n_stat_2, .before = stat_2) %>% 
      dplyr::relocate(add_n_stat_3, .before = stat_3)
  ) %>%
  modify_header(stat_by =  "**{level}**",
                starts_with("add_n_stat") ~ "**N**",
                label = "") %>% 
  modify_footnote(
    all_stat_cols() ~ "Mean (SD). Net benefits in FCFA of apprenticeship for training firm per apprentice per year."
  )

endline <- df %>% filter(wave == 1) %>% select(cb_simple, cb_complex, IDYouth, SELECTED) %>% 
  mutate(SELECTED = factor(SELECTED, levels = c(1, 0, 3),
                           labels = c('Selected', 'Not Selected', 'Did Not Apply'))) %>% 
  tbl_summary(by=SELECTED,
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
      dplyr::relocate(add_n_stat_2, .before = stat_2) %>% 
      dplyr::relocate(add_n_stat_3, .before = stat_3)
  ) %>%
  modify_header(stat_by =  "**{level}**",
                starts_with("add_n_stat") ~ "**N**",
                label = "") %>% 
  modify_footnote(
    all_stat_cols() ~ "Mean (SD). Net benefits in FCFA of apprenticeship for training firm per apprentice per year."
  )

tbl_stack(list(baseline, endline), group_header = c("Baseline", "Endline"), quiet = TRUE)

# by firm size
df %>% filter(wave == 0, !is.na(firm_size_bins)) %>% select(FS1.2, total_fees, wage_simple, all_allowances, total_training_costs, costs_per_app, cb_simple, cb_complex, firm_size_bins) %>% 
  group_by(FS1.2, firm_size_bins) %>% summarise_all(mean, na.rm = T) %>% ungroup() %>% 
  mutate(total_fees = total_fees / 4,
         wage_simple = wage_simple * 12,
         all_allowances = all_allowances * 12,
         total_training_costs = total_training_costs * 12,
         costs_per_app = costs_per_app * 12,
  ) %>% 
  tbl_summary(by = firm_size_bins,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              digits = list(everything() ~ c(0, 0)),
              missing = "no",
              include = -FS1.2,
              label = list(total_fees ~ "Fees",
                           wage_simple ~ "Estimated apprentice wage",
                           all_allowances ~ "Allowances disbursed",
                           total_training_costs ~ "Training costs, total",
                           costs_per_app ~ "Training costs, per apprentice",
                           cb_simple ~ "Simple net benefits",
                           cb_complex ~ "Complex net benefits")) %>% 
  modify_footnote(
    all_stat_cols() ~ "Mean (SD). Costs and benefits in FCFA."
  ) %>% 
  modify_header(label = "")

# training costs
df %>% filter(wave == 0) %>% select(FS1.2, contains("FE5.1"), FS6.9, FS6.10, FS5.2_1_2, FS6.1, FS6.8) %>%
  group_by(FS1.2) %>% summarise_all(mean, na.rm = T) %>% ungroup() %>% 
  mutate(trainers_per_app = FS6.8/FS6.1) %>% 
  tbl_summary(type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no",
              include = -FS1.2,
              digits = list(contains("FE") ~ c(0, 0)),
              label = list(FE5.1_1 ~ "Rent for premises for training",
                           FE5.1_2 ~ "Equipment and tools purchased for training",
                           FE5.1_3 ~ "Books and other training materials",
                           FE5.1_4 ~ "Raw materials that would have otherwise been used for production",
                           FS6.1 ~ "Total number of apprentices in workshop",
                           FS6.8 ~ "Total number of instructors in workshop",
                           FS6.9 ~ "Days a week trained",
                           FS6.10 ~ "Hours trained on last day of training",
                           trainers_per_app ~ "Instructors per apprentice",
                           FS5.2_1_2 ~ "Monthly wage for skilled worker (assumed trainer wage)")) %>% 
  modify_footnote(
    all_stat_cols() ~ "Firm mean (SD). N = number of firms reporting. Wages and training in FCFA."
  )

# training costs by firm size

df %>% filter(wave == 0) %>% dplyr::select(FS1.2, firm_size_bins, contains("FE5.1"), wage_simple, all_allowances, FS6.9, FS6.10, FS5.2_1_2, FS6.1, FS6.8) %>%
  mutate(wage_simple = wage_simple * 12,
         all_allowances = all_allowances * 12,
         FE5.1_1 = FE5.1_1 / FS6.1 * 12,
         FE5.1_2 = FE5.1_2 / FS6.1 * 12,
         FE5.1_3 = FE5.1_3 / FS6.1 * 12,
         FE5.1_4 = FE5.1_4 / FS6.1 * 12,
         trainers_wages = (FS6.9*FS6.10*4)*(FS5.2_1_2/4/40) / FS6.1 * 12) %>% 
  group_by(FS1.2, firm_size_bins) %>% summarise_all(mean, na.rm = T) %>% ungroup() %>% 
  mutate(trainers_per_app = FS6.8/FS6.1) %>% 
  tbl_summary(by = firm_size_bins,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no",
              include = -c(FS1.2, FS6.9, FS6.10),
              digits = list(contains("FE") ~ c(0, 0)),
              label = list(FE5.1_1 ~ "Rent for premises for training",
                           FE5.1_2 ~ "Equipment and tools purchased for training",
                           FE5.1_3 ~ "Books and other training materials",
                           FE5.1_4 ~ "Raw materials that would have otherwise been used for production",
                           FS6.1 ~ "Total number of apprentices in workshop",
                           FS6.8 ~ "Total number of instructors in workshop",
                           wage_simple ~ "Apprentices' monthly wages (estimated)",
                           all_allowances ~ "Apprentices' monthly benefits/allowances",
                           trainers_wages ~ "Trainers' monthly wages (estimated)",
                           trainers_per_app ~ "Instructors per apprentice",
                           FS5.2_1_2 ~ "Monthly wage for skilled worker (assumed trainer wage)")) %>% 
  add_overall() %>% 
  modify_footnote(
    all_stat_cols() ~ "Firm mean (SD). All figures in FCFA."
  )



# figure: training costs per apprentice, by firm size

x <- df %>% filter(wave == 0, !is.na(firm_size_bins), !is.na(FS6.1)) %>% select(FS1.2, FS6.1, wage_simple, all_allowances, firm_size_bins, contains("FE5.1"), FS6.9, FS6.10, FS5.2_1_2, FS6.8) %>%
  group_by(FS1.2, firm_size_bins) %>% summarise_all(mean, na.rm = T) %>% ungroup() %>% 
  mutate(wage_simple = wage_simple * 12,
         all_allowances = all_allowances * 12,
         FE5.1_1 = FE5.1_1 / FS6.1 * 12,
         FE5.1_2 = FE5.1_2 / FS6.1 * 12,
         FE5.1_3 = FE5.1_3 / FS6.1 * 12,
         FE5.1_4 = FE5.1_4 / FS6.1 * 12,
         trainers_wages = (FS6.9*FS6.10*4)*(FS5.2_1_2/4/40) / FS6.1 * 12, #hours per month * hourly wage / number of apprentices
  ) %>% group_by(firm_size_bins) %>% summarise_all(mean, na.rm = T) %>% select(-FS1.2) %>% pivot_longer(cols = c(wage_simple, all_allowances, contains("FE5.1"), trainers_wages))

ggplot(data=x, aes(x=firm_size_bins, y=value, fill=name)) +
  geom_bar(stat="identity", color="black", position=position_dodge()) +
  labs(x = "Firm size", y = "FCFA per year") + theme_minimal() + scale_fill_discrete(name = "Costs", labels = c("Allowances", "Rent", "Equipment", "Books", "Raw materials", "Trainer wage", "Apprentice wage"))

# figure: training costs per apprentice, by trade
x <- df %>% filter(wave == 0, !is.na(FS1.11), !is.na(FS6.1)) %>% select(FS1.2, FS6.1, wage_simple, all_allowances, FS1.11, contains("FE5.1"), FS6.9, FS6.10, FS5.2_1_2, FS6.8) %>%
  group_by(FS1.2, FS1.11) %>% summarise_all(mean, na.rm = T) %>% ungroup() %>% 
  mutate(wage_simple = wage_simple * 12,
         all_allowances = all_allowances * 12,
         FE5.1_1 = FE5.1_1 / FS6.1 * 12,
         FE5.1_2 = FE5.1_2 / FS6.1 * 12,
         FE5.1_3 = FE5.1_3 / FS6.1 * 12,
         FE5.1_4 = FE5.1_4 / FS6.1 * 12,
         trainers_wages = (FS6.9*FS6.10*4)*(FS5.2_1_2/4/40) / FS6.1 * 12, #hours per month * hourly wage / number of apprentices
  ) %>% group_by(FS1.11) %>% summarise_all(mean, na.rm = T) %>% select(-FS1.2) %>% pivot_longer(cols = c(wage_simple, all_allowances, contains("FE5.1"), trainers_wages))

ggplot(data=x, aes(x=FS1.11, y=value, fill=name)) +
  geom_bar(stat="identity", color="black", position=position_dodge()) +
  labs(x = "Trade", y = "FCFA per year") + theme_minimal() + scale_fill_discrete(name = "Costs", labels = c("Allowances", "Rent", "Equipment", "Books", "Raw materials", "Trainer wage", "Apprentice wage")) + scale_x_discrete(limits = c("Masonry", "Carpentry", "Plumbing",  "Metalwork", "Electrical Inst."))


# simple net benefits by duration
df %>% filter(!is.na(duration), duration < 9) %>% select(duration, cb_simple, cb_complex) %>% 
  group_by(duration) %>% summarise_all(mean, na.rm = T) %>% 
  ggplot(aes(x = duration, y = cb_simple)) +
  geom_segment(aes(xend = duration, yend="cb_simple")) +
  geom_point( color="orange", size=4) +
  theme_minimal() +
  xlab("Year of apprenticeship") +
  ylab("Net benefits") +
  scale_x_discrete(limits = c(0:8)) %>% suppressWarnings()

# complex net benefits by duration
df %>% filter(!is.na(duration), duration < 7) %>% select(duration, cb_simple, cb_complex) %>% 
  group_by(duration) %>% summarise_all(mean, na.rm = T) %>% ungroup() %>% 
  ggplot(aes(x = duration, y = cb_complex)) +
  geom_segment(aes(xend = duration, yend="cb_complex")) +
  geom_point( color="orange", size=4) +
  theme(axis.text.y=element_blank()) +
  xlab("Year of apprenticeship") +
  ylab("Net benefits") +
  scale_x_discrete(limits = c(0:6)) %>% suppressWarnings()


rm(list = ls())