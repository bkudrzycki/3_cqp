#############
##  Recode ##
#############

packages <- c("haven", "tidyverse", "labelled", "gtsummary")

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

# load all data
load("data/base_cqps.rda")
load("data/base_trad.rda")
load("data/end_cqps.rda")
load("data/end_trad.rda")

load("data/fs.rda")
load("data/fs_end.rda")

load("data/ys.rda")

# load functions
source("functions/join_cqp_trad.R")
source("functions/code_answers.R")

# join individual apprentices (base_cqp/trad and end_cqp/trad) to youth survey (ys)

# SELECT YOUTH (YS) VARIABLES OF INTEREST HERE
#time-invariant from youth survey
time_inv_ys <- ys %>% select("IDYouth", "baseline_age", "endline_age", "cqp", "birthdate", "sex", "DEPART", "NOTE_OBTENUE", "SELECTED", "DIPLOME", "YS3.16", "YS4.6")
#baseline
base_ys <- ys %>% select(tidyselect::vars_select(names(ys), -matches(c("baseline_age", "endline_age", "YE", "cqp", "birthdate", "sex", "DEPART", "NOTE_OBTENUE", "SELECTED", "DIPLOME", "YS3.16", "YS4.6")))) %>% mutate(wave = 0)
#endline
end_ys <- ys %>% select(tidyselect::vars_select(names(ys), matches(c('IDYouth', 'YE3', 'YE5')))) %>% mutate(wave = 1)

# SELECT FIRM (FS) VARIABLES OF INTEREST HERE
#time-invariant from firm survey
time_inv_fs <- fs %>% select("FS1.2", "FS1.11", "FS6.16", "dossier_apps", "dossier_reserves", "dossier_selected") %>% left_join(fs_end %>% select("FS1.2", contains("FE5.1")), by = "FS1.2")

df <- rbind(JoinCQP(c('FS1.2', 'FS3.1', 'FS3.2', 'FS3.3', 'FS3.4', 'FS3.5_1','FS3.5_2', 'FS3.5_3', 'FS3.5_4', 'FS3.5_5', 'FS4.1', 'FS4.7', 'FS5.1', 'FS5.3', 'FS5.4', 'FS6.1', 'FS6.2', 'FS6.8', 'FS6.9', 'FS6.10', 'FS6.13', 'FS6.14', matches('FS6.15'), 'FS6.17', 'FS9.3')) %>% rename(status = FS9.3), 
            JoinTrad(c('FS1.2', 'FS3.1', 'FS3.2', 'FS3.3', 'FS3.4', 'FS4.1', 'FS3.5_1', 'FS3.5_2', 'FS3.5_3', 'FS3.5_4', 'FS3.5_5', 'FS3.5_1',  'FS4.7', 'FS5.1', 'FS5.3', 'FS5.4', 'FS6.1', 'FS6.2', 'FS6.8', 'FS6.9', 'FS6.10', 'FS6.13', 'FS6.14', matches('FS6.15'), 'FS6.17', 'FS7.4')) %>% rename(status = FS7.4)) %>%
  left_join(base_ys, by = c("IDYouth", "wave")) %>%
  left_join(time_inv_ys, by = "IDYouth") %>%
  left_join(time_inv_fs, by = "FS1.2") %>%
  left_join(end_ys, by = c("IDYouth", "wave")) %>%
  mutate(SELECTED = ifelse(is.na(SELECTED), 3, SELECTED))

# drop firms in "other" trades
df <- df %>% filter(FS1.11 != 6) %>% filter(!is.na(FS1.11))
df$FS1.11 <- drop_unused_value_labels(df$FS1.11)

val_labels(df$FS1.11) <- c("Masonry" = 1, "Carpentry" = 2, "Plumbing" = 3, "Metalwork" = 4, "Electrical Inst." = 5)

# recode and apply labels to ensure correct order in tables and figures
df <- df %>% mutate(SELECTED = as.factor(recode(SELECTED, "Oui"= 1,
                                      "Non" = 0,
                                      `3` = 3)))

# subtract 1 from miscoded questions
df <- df %>% mutate(across(c(FS3.1, FS4.1, YE3.35, FS3.3, FS6.8, FS6.9, contains("FS3.5")), ~(.x-1)))

# code start year
df <- df %>% left_join(base_trad %>% select(IDYouth, FS7.5), by = "IDYouth")

# trad apprentices
df <- df %>% mutate(FS7.5 = recode(FS7.5,
                        `1` = 2012,
                        `2` = 2013,
                        `3` = 2014,
                        `4` = 2015,
                        `5` = 2016,
                        `6` = 2017,
                        `7` = 2018,
                        `8` = 2019)) %>% 
  mutate_at("FS7.5",  na_if, 9)

# cqp apprentices

df <- df %>% mutate(YS4.6 = recode(YS4.6,
                                   `1` = 2019,
                                   `2` = 2019,
                                   `3` = 2018,
                                   `4` = 2017,
                                   `5` = 2016,
                                   `6` = 2015,
                                   `7` = 2014,
                                   `8` = 2013,
                                   `9` = 2012))

df <- df %>% mutate(start_year = as.numeric(coalesce(FS7.5, YS4.6)),
                    baseline_duration = 2019-start_year,
                    duration = ifelse(wave == 0, 2019-start_year, 2021-start_year),
                    projected_duration = ifelse(YS4.7 < 99, baseline_duration + YS4.7, NA))

# no firm with zero apprentices - recode FS6.1
df <- df %>% mutate(FS6.1 = ifelse(FS6.1 == 0, 1, FS6.1))

# recode number of trainers, hours trained on last day of training
df <- df %>% mutate_at("FS6.8",  na_if, 12) %>% 
  mutate_at("FS6.10", na_if, 11) %>% 
  mutate_at("FS6.10", na_if, 12)

# code gender and age at baseline for traditional apprentices (non-cqp applicants)
base_trad <- base_trad %>% mutate(FS7.2 = recode(FS7.2,
                                                 `1` = 14,
                                                 `2` = 15,
                                                 `3` = 16,
                                                 `4` = 17,
                                                 `5` = 18,
                                                 `6` = 19,
                                                 `7` = 20,
                                                 `8` = 21,
                                                 `9` = 22,
                                                 `10` = 23,
                                                 `11` = 24,
                                                 `12` = 24,
                                                 `13` = 25,
                                                 `14` = 26,
                                                 `15` = 27,
                                                 `16` = 28,
                                                 `17` = 29,
                                                 `18` = 30))

df <- df %>% left_join(base_trad %>% select(IDYouth, FS7.1, FS7.2), by = "IDYouth") %>% 
  mutate(baseline_age = as.numeric(coalesce(FS7.2, baseline_age)),
         endline_age = as.numeric(coalesce(FS7.2+2, endline_age))) %>% 
  mutate(FS7.1 = 2-FS7.1) %>% mutate(sex = as.numeric(coalesce(sex, FS7.1))) %>% 
  mutate(age = ifelse(wave == 0, baseline_age, endline_age))

# append highest level of schooling
df <- df %>% left_join(base_trad %>% select(IDYouth, FS7.3) %>% mutate(FS7.3 = recode(FS7.3, `11` = 0)), by = "IDYouth") %>% mutate(schooling = coalesce(FS7.3, YS3.16)) %>% mutate(schooling = case_when(
  schooling == 0 ~ "None",
  schooling == 1 ~ "<Primary",
  schooling == 2 ~ "<Primary",
  schooling == 3 ~ "Primary",
  schooling == 4 ~ "Secondary",
  schooling == 5 ~ "Secondary",
  schooling == 6 ~ "Technical",
  schooling == 7 ~ "Technical",
  schooling == 8 ~ "Tertiary",
  schooling == 9 ~ "Tertiary")) %>% 
  mutate(schooling=fct_relevel(schooling,c("None","<Primary")))

# recode revenues, costs, wages, and profits 

# revenues, profits
df <- df %>% mutate_at(c("FS4.7", "FS5.4"), recode,
                       `7` = 0,
                       `10` = 10000,
                       `11` = 30000,
                       `12` = 57500,
                       `13` = 100000,
                       `14` = 162500,
                       `15` = 250000,
                       `16` = 375000,
                       `17` = 550000,
                       `18` = 825000,
                       `19` = 1300000) %>% 
  mutate_at(c("FS4.7", "FS5.3", "FS5.4"), na_if, 20)

# costs
df <- df %>% mutate_at(c("FS5.1"), recode,
                       `4` = 0,
                       `7` = 10000,
                       `8` = 30000,
                       `9` = 57500,
                       `10` = 100000,
                       `11` = 162500,
                       `12` = 250000,
                       `13` = 375000,
                       `14` = 550000,
                       `15` = 825000,
                       `16` = 1300000) %>% 
  mutate_at(c("FS5.1"), na_if, 17)

# wage bill
df <- df %>% mutate_at(c("FS5.3"), recode,
                       `1` = 0,
                       `2` = 10000,
                       `3` = 30000,
                       `4` = 57500,
                       `5` = 100000,
                       `6` = 162500,
                       `7` = 250000,
                       `8` = 375000,
                       `9` = 550000,
                       `10` = 825000,
                       `11` = 1300000) %>% 
  mutate_at(c("FS5.3"), na_if, 12)

df <- df %>% rowwise() %>% mutate(profits = sum(c(FS4.7-FS5.1-FS5.3))) %>% ungroup()

# recode training costs (ENDLINE ONLY!)
df <- df %>% mutate_at(c("FE5.1_1", "FE5.1_2", "FE5.1_3", "FE5.1_4"), recode,
                           `1` = 0,
                           `2` = 1500,
                           `3` = 4000,
                           `4` = 6000,
                           `5` = 8500,
                           `6` = 12500,
                           `7` = 20000,
                           `8` = 32500,
                           `9` = 52500,
                           `10` = 82500,
                           `11` = 125000) %>%
  mutate_at(c("FE5.1_1", "FE5.1_2", "FE5.1_3", "FE5.1_4"), na_if, 12)

df$total_training_costs <- df %>% select(tidyselect::vars_select(names(df), matches('FE5.1'))) %>% rowMeans(., na.rm = T)

df <- df %>% mutate(costs_per_app = total_training_costs / FS6.1)

# join and rename apprentices' ratings of firm
df <- df %>% mutate(YS4.40_1 = coalesce(YS4.40_1, YE3.26_1),
                    YS4.40_2 = coalesce(YS4.40_2, YE3.26_2),
                    YS4.40_3 = coalesce(YS4.40_3, YE3.26_3),
                    YS4.40_4 = coalesce(YS4.40_4, YE3.26_4),
                    YS4.40_5 = coalesce(YS4.40_5, YE3.26_5),
                    YS4.40_6 = coalesce(YS4.40_6, YE3.26_6),
                    YS4.40_7 = coalesce(YS4.40_7, YE3.26_7),
                    YS4.40_8 = coalesce(YS4.40_8, YE3.26_8),
                    YS4.41 = coalesce(YS4.41, YE3.27))

var_label(df$YS4.40_1) <- "Physical Safety"
var_label(df$YS4.40_2) <- "Master's Knowledge"
var_label(df$YS4.40_3) <- "Treatment by Master"
var_label(df$YS4.40_4) <- "Salary"
var_label(df$YS4.40_5) <- "Working Hours"
var_label(df$YS4.40_6) <- "Quality of Training"
var_label(df$YS4.40_7) <- "Equipment and Machinery"
var_label(df$YS4.40_8) <- "Work Colleagues"


#allowances

df <- df %>% left_join(rbind(JoinCQPMatch(c('FS9.6')) %>% rename(allow_food = FS9.6_1,
                                                      allow_transport = FS9.6_2,
                                                      allow_pocket_money = FS9.6_3,
                                                      allow_other = FS9.6_4) %>% select(-FS9.6_5),
                       JoinTradMatch(c('FS7.8')) %>% rename(allow_food = FS7.8_1,
                                                       allow_transport = FS7.8_2,
                                                       allow_pocket_money = FS7.8_3,
                                                       allow_other = FS7.8_4) %>% select(-FS7.8_5)), by = c("IDYouth", "wave"))


df <- df %>% mutate_at(c("allow_food", "allow_transport", "allow_pocket_money", "allow_other"), recode,
                       `1` = 150,
                       `2` = 325,
                       `3` = 525,
                       `4` = 875,
                       `5` = 1225,
                       `6` = 1775,
                       `7` = 2425,
                       `8` = 3425,
                       `9` = 6225,
                       `10` = 8725,
                       `11` = 11725) %>% 
  mutate_at(c("allow_food", "allow_transport", "allow_pocket_money", "allow_other"), na_if, 12) %>% 
  mutate_at(c("allow_food", "allow_transport", "allow_pocket_money", "allow_other"), replace_na, 0)

df$all_allowances <- df %>% select(c("allow_food", "allow_transport", "allow_pocket_money", "allow_other")) %>% 
  rowSums(., na.rm = T)

df <- df %>% mutate_at(c("allow_food", "allow_transport", "allow_pocket_money", "allow_other", "all_allowances"), ~replace(., all_allowances == 0, NA))

var_label(df$allow_food) <- "Food"
var_label(df$allow_transport) <- "Transportation"
var_label(df$allow_pocket_money) <- "Pocket Money"
var_label(df$allow_other) <- "Other"
var_label(df$all_allowances) <- "Total"

# apprentice level (total only)

df <- df %>% mutate_at("YS4.38", recode,
                       `1` = 750,
                       `2` = 2000,
                       `3` = 3000,
                       `4` = 4250,
                       `5` = 6000,
                       `6` = 8500,
                       `7` = 12500,
                       `8` = 20000,
                       `9` = 37500,
                       `10` = 75000) %>% 
  mutate_at("YS4.38", na_if, 99)

df <- df %>% mutate_at("YE3.22", recode,
                       `1` = 250,
                       `2` = 750,
                       `3` = 1500,
                       `4` = 2500,
                       `5` = 4000,
                       `6` = 6000,
                       `7` = 8500,
                       `8` = 12500,
                       `9` = 20000,
                       `10` = 37500) %>% 
  mutate_at("YE3.22", na_if, 99)
                      
df$a_allow <- coalesce(df$YS4.38, df$YE3.22)

df <- df %>% rowwise() %>% mutate(allow_avg = mean(c(all_allowances, a_allow), na.rm = T)) %>% ungroup()

# skills 

# wrangle to get survey wave as a separate column, replace in df
skills <- ys %>% 
  select(c('YS1.3', matches(c('YS5', 'YE4')))) %>% 
  pivot_longer(cols = -c("YS1.3")) %>% 
  mutate(wave = ifelse(substr(name, 1, 2) == "YS", 0, 1),
         name = paste0("YS5", substr(name,4,nchar(name)))) %>% 
  pivot_wider(names_from = name, values_from = value) %>% rename('IDYouth' = 'YS1.3')

df <- df %>% select(-matches(c('YS5', 'YE4'))) %>% left_join(., skills, by = c('IDYouth', 'wave'))

# code correct answers
df <- df %>% 
  code_answers(YS5.1, 2) %>% 
  code_answers(YS5.2, 1) %>% 
  code_answers(YS5.3, 3) %>% 
  code_answers(YS5.4, 1) %>% 
  code_answers(YS5.5, 2) %>% 
  code_answers(YS5.6, 2) %>% 
  code_answers(YS5.7, 1) %>% 
  code_answers(YS5.8, 2) %>% 
  code_answers(YS5.9, 2) %>% 
  code_answers(YS5.10, 3) %>% 
  code_answers(YS5.11, 1) %>% 
  code_answers(YS5.12, 4) %>% 
  code_answers(YS5.13, 1) %>% 
  code_answers(YS5.14, 4) %>% 
  code_answers(YS5.15, 1) %>% 
  code_answers(YS5.16, 2) %>% 
  code_answers(YS5.18, 2) %>% 
  code_answers(YS5.19, 2) %>% 
  code_answers(YS5.20, 3) %>% 
  code_answers(YS5.21, 2) %>% 
  code_answers(YS5.22, 1) %>% 
  code_answers(YS5.23, 1)

df$skills_elec <- df %>% select(tidyselect::vars_select(names(df), matches(c('correct_YS5.19', 'correct_YS5.20', 'correct_YS5.21', 'correct_YS5.22', 'correct_YS5.23')))) %>% 
  rowMeans(., na.rm = T)

df$skills_macon <- df %>% select(tidyselect::vars_select(names(df), matches(c('correct_YS5.14', 'correct_YS5.15', 'correct_YS5.16', 'correct_YS5.18')))) %>% 
  rowMeans(., na.rm = T)

df$skills_menuis<- df %>% select(tidyselect::vars_select(names(df), matches(c('correct_YS5.10', 'correct_YS5.11', 'correct_YS5.12', 'correct_YS5.13')))) %>% 
  rowMeans(., na.rm = T)

df$skills_plomb <- df %>% select(tidyselect::vars_select(names(df), matches(c('correct_YS5.6', 'correct_YS5.7', 'correct_YS5.8', 'correct_YS5.9')))) %>% 
  rowMeans(., na.rm = T)

df$skills_metal <- df %>% select(tidyselect::vars_select(names(df), matches(c('correct_YS5.1', 'correct_YS5.2', 'correct_YS5.3', 'correct_YS5_4', 'correct_YS5.5')))) %>% 
  rowMeans(., na.rm = T)

df$skills_all_trades <- df %>% select(tidyselect::vars_select(names(df), matches('correct'))) %>% rowMeans(., na.rm = T)

var_label(df$skills_elec) <- "Electrical Installation"
var_label(df$skills_macon) <- "Masonry"
var_label(df$skills_menuis) <- "Carpentry"
var_label(df$skills_plomb) <- "Plumbing"
var_label(df$skills_metal) <- "Metalwork"
var_label(df$skills_all_trades) <- "Overall"

# competencies

comp <- rbind(JoinCQPMatch(c('FS9.12', 'FS9.13', 'FS9.14', 'FS9.15', 'FS9.16')), JoinTradMatch(c('FS7.14', 'FS7.15', 'FS7.16', 'FS7.17', 'FS7.18')) %>% setNames(names(JoinCQPMatch(c('FS9.12', 'FS9.13', 'FS9.14', 'FS9.15', 'FS9.16'))))) %>% mutate_all(recode, `2` = 0)

df <- left_join(df, comp, by = c('IDYouth', 'wave'))

# pooled firm-level competency scores
df$comp_elec <- df %>% select(tidyselect::vars_select(names(df), matches('FS9.12_1'))) %>% 
  rowMeans(., na.rm = T)

df$comp_macon <- df %>% select(tidyselect::vars_select(names(df), matches('FS9.13_1'))) %>% 
  rowMeans(., na.rm = T)

df$comp_menuis<- df %>% select(tidyselect::vars_select(names(df), matches('FS9.14_1'))) %>% 
  rowMeans(., na.rm = T)

df$comp_plomb <- df %>% select(tidyselect::vars_select(names(df), matches('FS9.15_1'))) %>% 
  rowMeans(., na.rm = T)

df$comp_metal <- df %>% select(tidyselect::vars_select(names(df), matches('FS9.16_1'))) %>% 
  rowMeans(., na.rm = T)

df$comp_all_trades <- df %>% select(tidyselect::vars_select(names(df), matches(c('FS9.12_1', 'FS9.13_1', 'FS9.14_1', 'FS9.15_1', 'FS9.16_1')))) %>% rowMeans(., na.rm = T)

var_label(df$comp_elec) <- "Electrical Installation"
var_label(df$comp_macon) <- "Masonry"
var_label(df$comp_menuis) <- "Carpentry"
var_label(df$comp_plomb) <- "Plumbing"
var_label(df$comp_metal) <- "Metalwork"
var_label(df$comp_all_trades) <- "Overall"

# pooled apprentice-level self-reported competency scores (endline only)
df$a_comp_elec <- df %>% select(tidyselect::vars_select(names(df), matches('YE5.1_1'))) %>% 
  rowMeans(., na.rm = T)

df$a_comp_macon <- df %>% select(tidyselect::vars_select(names(df), matches('YE5.2_1'))) %>% 
  rowMeans(., na.rm = T)

df$a_comp_menuis<- df %>% select(tidyselect::vars_select(names(df), matches('YE5.3_1'))) %>% 
  rowMeans(., na.rm = T)

df$a_comp_plomb <- df %>% select(tidyselect::vars_select(names(df), matches('YE5.4_1'))) %>% 
  rowMeans(., na.rm = T)

df$a_comp_metal <- df %>% select(tidyselect::vars_select(names(df), matches('YE5.5_1'))) %>% 
  rowMeans(., na.rm = T)

df$a_comp_all_trades <- df %>% select(tidyselect::vars_select(names(df), matches(c('YE5.1_1', 'YE5.2_1', 'YE5.3_1', 'YE5.4_1', 'YE5.5_1')))) %>% rowMeans(., na.rm = T)

var_label(df$a_comp_elec) <- "Electrical Installation"
var_label(df$a_comp_macon) <- "Masonry"
var_label(df$a_comp_menuis) <- "Carpentry"
var_label(df$a_comp_plomb) <- "Plumbing"
var_label(df$a_comp_metal) <- "Metalwork"
var_label(df$a_comp_all_trades) <- "Overall"

# experience

# pooled firm-level experience scores
df$exp_elec <- df %>% select(tidyselect::vars_select(names(df), matches('FS9.12_2'))) %>% 
  rowMeans(., na.rm = T)

df$exp_macon <- df %>% select(tidyselect::vars_select(names(df), matches('FS9.13_2'))) %>% 
  rowMeans(., na.rm = T)

df$exp_menuis<- df %>% select(tidyselect::vars_select(names(df), matches('FS9.14_2'))) %>% 
  rowMeans(., na.rm = T)

df$exp_plomb <- df %>% select(tidyselect::vars_select(names(df), matches('FS9.15_2'))) %>% 
  rowMeans(., na.rm = T)

df$exp_metal <- df %>% select(tidyselect::vars_select(names(df), matches('FS9.16_2'))) %>% 
  rowMeans(., na.rm = T)

df$exp_all_trades <- df %>% select(tidyselect::vars_select(names(df), matches(c('FS9.12_2', 'FS9.13_2', 'FS9.14_2', 'FS9.15_2', 'FS9.16_2')))) %>% rowMeans(., na.rm = T)

var_label(df$exp_elec) <- "Electrical Installation"
var_label(df$exp_macon) <- "Masonry"
var_label(df$exp_menuis) <- "Carpentry"
var_label(df$exp_plomb) <- "Plumbing"
var_label(df$exp_metal) <- "Metalwork"
var_label(df$exp_all_trades) <- "Overall"

# pooled apprentice-level self-reported experience scores (endline only)
df$a_exp_elec <- df %>% select(tidyselect::vars_select(names(df), matches('YE5.1_2'))) %>% 
  rowMeans(., na.rm = T)

df$a_exp_macon <- df %>% select(tidyselect::vars_select(names(df), matches('YE5.2_2'))) %>% 
  rowMeans(., na.rm = T)

df$a_exp_menuis<- df %>% select(tidyselect::vars_select(names(df), matches('YE5.3_2'))) %>% 
  rowMeans(., na.rm = T)

df$a_exp_plomb <- df %>% select(tidyselect::vars_select(names(df), matches('YE5.4_2'))) %>% 
  rowMeans(., na.rm = T)

df$a_exp_metal <- df %>% select(tidyselect::vars_select(names(df), matches('YE5.5_2'))) %>% 
  rowMeans(., na.rm = T)

df$a_exp_all_trades <- df %>% select(tidyselect::vars_select(names(df), matches(c('YE5.1_2', 'YE5.2_2', 'YE5.3_2', 'YE5.4_2', 'YE5.5_2')))) %>% rowMeans(., na.rm = T)

var_label(df$a_exp_elec) <- "Electrical Installation"
var_label(df$a_exp_macon) <- "Masonry"
var_label(df$a_exp_menuis) <- "Carpentry"
var_label(df$a_exp_plomb) <- "Plumbing"
var_label(df$a_exp_metal) <- "Metalwork"
var_label(df$a_exp_all_trades) <- "Overall"

# master ratings of apprentices

ratings <- rbind(JoinCQPMatch(c('FS9.11')) %>% rename(rating_discipline = FS9.11_1,
                                                 rating_teamwork = FS9.11_2,
                                                 rating_efficiency = FS9.11_3,
                                                 rating_work_quality = FS9.11_4,
                                                 rating_learning_speed = FS9.11_5,
                                                 rating_respect = FS9.11_6),
                 JoinTradMatch(c('FS7.13')) %>% rename(rating_discipline = FS7.13_1,
                                                  rating_teamwork = FS7.13_2,
                                                  rating_efficiency = FS7.13_3,
                                                  rating_work_quality = FS7.13_4,
                                                  rating_learning_speed = FS7.13_5,
                                                  rating_respect = FS7.13_6))

ratings$all_ratings <- ratings %>% select(c("rating_discipline", "rating_teamwork", "rating_efficiency", "rating_work_quality", "rating_learning_speed", "rating_respect")) %>% 
  rowMeans(., na.rm = T)

df <- left_join(df, ratings, by = c('IDYouth', 'wave'))

var_label(df$rating_discipline) <- "Discipline"
var_label(df$rating_teamwork) <- "Teamwork"
var_label(df$rating_efficiency) <- "Efficiency"
var_label(df$rating_work_quality) <- "Work Quality"
var_label(df$rating_learning_speed) <- "Learning Speed"
var_label(df$rating_respect) <- "Respect"
var_label(df$all_ratings) <- "Overall"

# firm-level fees

fees <- rbind(JoinCQPMatch(c('FS9.7', 'FS9.8')) %>% rename(fee_entry = FS9.7_1,
                                                      fee_formation = FS9.7_2,
                                                      fee_liberation = FS9.7_3,
                                                      fee_materials = FS9.8_1,
                                                      fee_contract = FS9.8_2,
                                                      fee_application = FS9.8_3),
              JoinTradMatch(c('FS7.9', 'FS7.10')) %>% rename(fee_entry = FS7.9_1,
                                                        fee_formation = FS7.9_2,
                                                        fee_liberation = FS7.9_3,
                                                        fee_materials = FS7.10_1,
                                                        fee_contract = FS7.10_2,
                                                        fee_application = FS7.10_3))

# recode fees

fees <- fees %>% mutate_at(c("fee_entry", "fee_formation", "fee_liberation"), recode,
                           `1` = 0,
                           `2` = 5000,
                           `3` = 15000,
                           `4` = 27500,
                           `5` = 45000,
                           `6` = 70000,
                           `7` = 105000,
                           `8` = 150000,
                           `9` = 212500,
                           `10` = 300000,
                           `11` = 425000) %>%
  mutate_at(c("fee_entry", "fee_formation", "fee_liberation"), na_if, 12)

fees <- fees %>% mutate_at(c("fee_materials", "fee_contract", "fee_application"), recode,
                           `1` = 0,
                           `2` = 1500,
                           `3` = 4000,
                           `4` = 6000,
                           `5` = 8500,
                           `6` = 12500,
                           `7` = 20000,
                           `8` = 32500,
                           `9` = 52500,
                           `10` = 82500,
                           `11` = 125000) %>%
  mutate_at(c("fee_materials", "fee_contract", "fee_application"), na_if, 12)

fees$total_fees <- fees %>% select(c("fee_entry", "fee_formation", "fee_liberation", "fee_materials", "fee_contract", "fee_application")) %>% 
  rowSums(., na.rm = T)

fees <- fees %>% mutate(total_fees = ifelse(total_fees == 0 & is.na(fee_entry), 99, total_fees)) %>% filter(total_fees != 99)

df <- left_join(df, fees, by = c('IDYouth', 'wave'))

df <- df %>% mutate_at(c("fee_entry", "fee_formation", "fee_liberation", "fee_materials", "fee_contract", "fee_application"), ~replace(., total_fees == 0, NA))

var_label(df$fee_entry) <- "Initiation"
var_label(df$fee_formation) <- "Training"
var_label(df$fee_liberation) <- "Graduation"
var_label(df$fee_materials) <- "Materials"
var_label(df$fee_contract) <- "Contract"
var_label(df$fee_application) <- "Application"
var_label(df$total_fees) <- "Total"

# app-level fees

a_fees <- ys %>% select(c(IDYouth, YS4.15, YS4.17, YS4.19, YS4.21, YS4.23, YS4.24)) %>% 
  rename(a_fee_entry = YS4.15,
         a_fee_formation = YS4.21,
         a_fee_liberation = YS4.24,
         a_fee_materials = YS4.17,
         a_fee_contract = YS4.19,
         a_fee_application = YS4.23)

a_fees <- a_fees %>% 
  mutate_at(c("a_fee_entry", "a_fee_formation", "a_fee_liberation"), recode,
          `1` = 5000,
          `2` = 15000,
          `3` = 27500,
          `4` = 45000,
          `5` = 70000,
          `6` = 105000,
          `7` = 150000,
          `8` = 212500,
          `9` = 300000,
          `10` = 425000) %>% 
  mutate_at(c("a_fee_entry", "a_fee_formation", "a_fee_liberation"), na_if, 99)

a_fees <- a_fees %>% 
  mutate_at(c("a_fee_materials", "a_fee_contract", "a_fee_application"), recode,
            `1` = 1500,
            `2` = 4000,
            `3` = 6000,
            `4` = 8500,
            `5` = 12500,
            `6` = 20000,
            `7` = 32500,
            `8` = 52500,
            `9` = 82500,
            `10` = 125000) %>% 
  mutate_at(c("a_fee_materials", "a_fee_contract", "a_fee_application"), na_if, 99)

a_fees$a_total_fees <- a_fees %>% select(c("a_fee_entry", "a_fee_formation", "a_fee_liberation", "a_fee_materials", "a_fee_contract", "a_fee_application")) %>% 
  rowSums(., na.rm = T)

a_fees <- a_fees %>% filter(a_total_fees != 0) %>% replace(is.na(.), 0)

df <- left_join(df, a_fees, by = c('IDYouth'))

df <- df %>% mutate_at(c("a_fee_entry", "a_fee_formation", "a_fee_liberation", "a_fee_materials", "a_fee_contract", "a_fee_application"), ~replace(., a_total_fees == 0, NA))

var_label(df$a_fee_entry) <- "Initiation"
var_label(df$a_fee_formation) <- "Training"
var_label(df$a_fee_liberation) <- "Graduation"
var_label(df$a_fee_materials) <- "Materials"
var_label(df$a_fee_contract) <- "Contract"
var_label(df$a_fee_application) <- "Application"
var_label(df$a_total_fees) <- "Total"

df <- df %>% rowwise() %>% mutate(fees_avg = mean(c(total_fees, a_total_fees), na.rm = T)) %>% ungroup()

# firm size (calculated by adding up total number of all types of workers), as well as bins
df <- df %>% rowwise() %>% mutate(firm_size = sum(c(FS6.1, FS3.5_1, FS3.5_2, FS3.5_3, FS3.5_4, FS3.5_5)),
                                  firm_size_sans_app = sum(c(FS3.5_1, FS3.5_2, FS3.5_3, FS3.5_4, FS3.5_5)),
                    firm_size_bins = cut(firm_size, breaks = c(1,2,5,10,20,50,107)),
                    firm_size_bins_reported = cut(FS3.4, breaks = c(1,2,5,10,20,50))) %>% ungroup()

# firm weekly hours (more accurately: number of hours worked by patron)

df <- df %>% 
  mutate_at('FS3.2', na_if, 12) %>% 
  mutate(firm_weekly_hours = FS3.2*FS3.3)

var_label(df$firm_weekly_hours) <- "Patron Weekly Hours Worked"

# apprentices-level hours 

df <- df %>% 
  mutate_at(c('YS4.12', 'YE3.17'), na_if, 99) %>% 
  mutate(a_weekly_hours = ifelse(wave == 0, YS4.10*YS4.12, YE3.15*YE3.17))

var_label(df$a_weekly_hours) <- "Apprentice Weekly Hours Worked"

# firm-level wages paid for different types of workers

wages <- rbind(JoinCQPMatch(c('FS5.2')), JoinTradMatch(c('FS5.2'))) %>% 
  mutate_at(vars(matches('FS5.2_1')), recode, 
                       `1` = 0, 
                       `2` = 2500, 
                       `3` = 7500, 
                       `4` = 15000, 
                       `5` = 27500, 
                       `6` = 45000, 
                       `7` = 67500, 
                       `8` = 95000,
                       `9` = 130000, 
                       `10` = 175000, 
                       `11` = 225000) %>% 
  mutate_at(vars(matches('FS5.2_1')), na_if, 12) %>% 
  mutate_at(vars(matches('FS5.2_1')), na_if, 13)

df <- left_join(df, wages, by = c('IDYouth', 'wave'))

# training dummy
df <- df %>% mutate(ext_training = ifelse(wave == 0, YS4.43, YE3.35)) %>% 
  mutate(ext_training = ifelse(ext_training == 0, 0, 1))

# cost benefit models

# model I: fees - allowances
df <- df %>% rowwise() %>% mutate(cb_1 = sum(total_fees/4, -all_allowances*5*4*FS4.1, na.rm = T))

# model II: fees - allowances - training costs
df <- df %>% rowwise() %>% mutate(cb_2 = sum(total_fees/4, -all_allowances*5*4*FS4.1, -total_training_costs*FS4.1/FS6.1, na.rm = T))
x <- df %>% filter(wave == 0) %>% rowwise() %>% mutate(cb_2_baseline = sum(total_fees/4, -all_allowances*5*4*FS4.1, -total_training_costs*FS4.1/FS6.1, na.rm = T)) %>% select(IDYouth, cb_2_baseline)
df <- df %>% left_join(x, by = "IDYouth")

# model III: fees - allowances - training costs + apprentice productivity - trainer wages

df <- df %>% mutate(monthly_time_trained = FS6.9*FS6.10*4)
# estimated trainer hours of training per month: days per week (FS6.9) * hours on last day (FS6.10) * 4 * number of trainers instructing apps (FS6.8)
# trainer hourly wage: monthly wage of skilled employee (FS5.2_1_2) / 40 hours per week / 4 weeks

df <- df %>% rowwise() %>% mutate(cb_3 = sum(total_fees/4, FS5.2_1_2*6, FS5.2_1_4*6,  -all_allowances*5*4*FS4.1, -total_training_costs*FS4.1/FS6.1, -monthly_time_trained*FS6.8*FS5.2_1_2/40/4/FS6.1*FS4.1, na.rm = T))
x <- df %>% filter(wave == 0) %>% rowwise() %>% mutate(cb_3_baseline = sum(total_fees/4,  FS5.2_1_2*FS4.1/2, FS5.2_1_4*FS4.1/2, -all_allowances*5*4*FS4.1, -total_training_costs*FS4.1/FS6.1, -monthly_time_trained*FS6.8*FS5.2_1_2/40/4/FS6.1*FS4.1, na.rm = T)) %>% select(IDYouth, cb_3_baseline)
df <- df %>% left_join(x, by = "IDYouth")

df <- df %>% ungroup()

save(df, file = "data/df.rda")

rm(list = ls())
