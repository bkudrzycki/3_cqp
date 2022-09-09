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
if(is.na(path)){
  setwd("~/polybox/Youth Employment/2 CQP/Paper")
}else{
  setwd(path)
}

# load all data
load("data/R/base_cqps.rda")
load("data/R/base_trad.rda")
load("data/R/end_cqps.rda")
load("data/R/end_trad.rda")

load("data/R/fs.rda")
load("data/R/fs_end.rda")

load("data/R/ys.rda")

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
end_ys <- ys %>% select(tidyselect::vars_select(names(ys), matches(c('IDYouth', 'YE3', 'YE5', 'YE7')))) %>% mutate(wave = 1)

# SELECT FIRM (FS) VARIABLES OF INTEREST HERE
#time-invariant from firm survey
time_inv_fs <- fs %>% select("FS1.2", "FS1.6", "FS1.11", contains("FS2"), "FS6.16", "dossier_apps", "dossier_reserves", "dossier_selected") %>% left_join(fs_end %>% select("FS1.2", contains(c("FE5.1", "FE7.2", "FE9.1"))), by = "FS1.2")

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
df <- df %>% mutate(across(c(FS3.1, FS4.1, YE3.35, FS3.3, YS3.8, FS6.8, FS6.9, contains("FS3.5")), ~(.x-1)))

# remove FS6.1 for firms with over 50 apprentices, because (i) real number unknown, (ii) probably lycées and not firms
df <- df %>% mutate(FS6.1 = replace(FS6.1, FS6.1>50, NA))

# dummy if cqp participant at baseline
df <- df %>% mutate(cqp = ifelse(SELECTED == 1, 1, 0),
                    cqp2 = ifelse(SELECTED == 1, 1,
                                  ifelse(SELECTED == 0, 0, NA)))

# code number of cqp apprentices by status who were actually interviewed per firm
interviewed <- df %>% filter(wave == 0) %>% select(FS1.2, SELECTED) %>% 
  mutate(selected_interviewed = ifelse(SELECTED == 1, 1, 0),
         not_selected_interviewed = ifelse(SELECTED == 0, 1, 0),
         did_not_apply_interviewed = ifelse(SELECTED == 3, 1, 0)) %>% select(-SELECTED) %>% 
  group_by(FS1.2) %>% summarise_all(sum, na.rm = T) %>% ungroup()

df <- left_join(df, interviewed, by = "FS1.2")

# types of apprentices working in firm at baseline, roughly deduced from FS6.1 and dossier data (caution! in a few cases inconsistent)
status <- df %>% filter(wave == 0) %>% select(IDYouth, FS6.1, FS6.2, contains(c("dossier", "interviewed"))) %>%
  mutate(selected = case_when(dossier_selected<=FS6.1 ~ dossier_selected,
                              FS6.1 == FS6.2 ~ 0),
         not_selected = case_when(dossier_apps<=FS6.1 & dossier_apps-dossier_selected <= FS6.1 ~ dossier_apps-dossier_selected,
                                  selected + FS6.2 <= FS6.1 ~ FS6.2,
                                  selected == FS6.1 ~ 0,
                                  FS6.1 == FS6.2 ~ 0),
         did_not_apply = case_when(selected+not_selected <= FS6.1 ~ FS6.1-selected-not_selected,
                                   FS6.2 <= FS6.1 ~ FS6.2),
         selected = ifelse(is.na(selected) & FS6.1-did_not_apply == selected_interviewed-not_selected_interviewed, selected_interviewed, selected),
         not_selected = ifelse(is.na(not_selected) & FS6.1-did_not_apply == selected_interviewed-not_selected_interviewed, not_selected_interviewed, not_selected)) %>% select(IDYouth, selected, not_selected, did_not_apply)
           
df <- left_join(df, status, by = "IDYouth") %>% select(-contains("interviewed"))

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
                    projected_duration = ifelse(YS4.7 < 99, baseline_duration + YS4.7, NA),
                    FE9.1 = coalesce(A1_FE9.1, A19_FE9.1),
                    end_still_training = ifelse(YE3.7 == 1 | YE3.29 == 1, 1, 0))

# no firm with zero apprentices - recode FS6.1
df <- df %>% rowwise() %>% mutate(FS6.1 = ifelse(FS6.1 == 0, sum(selected, not_selected, did_not_apply, na.rm = T), FS6.1))

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

# generate and append graduation statistics
grads <- df %>% filter(wave == 1) %>% select(IDYouth, wave, YE3.3, YE3.5, YE3.7, FE9.1, YE3.29) %>% zap_label()

# still training in some form: with a master or CQP (line 1), according to trainer (line 2), 
grads <- grads %>% mutate(grad = ifelse(YE3.7 %in% 1 | YE3.29 %in% 1, 1, # with a master or in CQP
                                            ifelse(FE9.1 %in% 1, 1, # training according to master craftsman 
                                                   ifelse(YE3.3 %in% 1 & YE3.5 %in% 1, 2, # graduated and working for former master
                                                          ifelse(YE3.3 %in% 1 & YE3.29 %in% 2, 2, # graduated but still in CQP
                                                                 ifelse(FE9.1 %in% 2, 2, # graduated according to master craftsman
                                                                        ifelse(FE9.1 %in% 4, 3, # dropped out according to master craftsman
                                                                               ifelse(YE3.3 %in% 0 & YE3.7 %in% 0, 3, 4)))))))) # no grad, NOT training

grads <- grads %>% mutate(grad = factor(grad, levels = c(1:4), labels = c("Still training", "Graduated", "Dropped out", "Unknown")))

grads <- grads %>% mutate(grad_but_cqp = ifelse(YE3.3 %in% 1 & YE3.29 %in% 2, 1, 0)) %>% select(IDYouth, grad, grad_but_cqp)

df <- left_join(df, grads, by = "IDYouth")

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

df <- df %>% mutate(skills_cqp = case_when(SELECTED == 1 ~ skills_all_trades),
                    skills_notsel = case_when(SELECTED == 0 ~ skills_all_trades))

var_label(df$skills_elec) <- "Electrical Installation"
var_label(df$skills_macon) <- "Masonry"
var_label(df$skills_menuis) <- "Carpentry"
var_label(df$skills_plomb) <- "Plumbing"
var_label(df$skills_metal) <- "Metalwork"
var_label(df$skills_cqp) <- "CQP Selected"
var_label(df$skills_notsel) <- "CQP Not Selected"
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

df <- df %>% mutate(comp_cqp = case_when(SELECTED == 1 ~ comp_all_trades),
                    comp_notsel = case_when(SELECTED == 0 ~ comp_all_trades),
                    comp_dna = case_when(SELECTED == 3 ~ comp_all_trades))

var_label(df$comp_elec) <- "Electrical Installation"
var_label(df$comp_macon) <- "Masonry"
var_label(df$comp_menuis) <- "Carpentry"
var_label(df$comp_plomb) <- "Plumbing"
var_label(df$comp_metal) <- "Metalwork"
var_label(df$comp_cqp) <- "CQP Selected"
var_label(df$comp_notsel) <- "CQP Not Selected"
var_label(df$comp_dna) <- "Did Not Apply"
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

df <- df %>% mutate(a_comp_cqp = case_when(SELECTED == 1 ~ a_comp_all_trades),
                    a_comp_notsel = case_when(SELECTED == 0 ~ a_comp_all_trades),
                    a_comp_dna = case_when(SELECTED == 3 ~ a_comp_all_trades))

var_label(df$a_comp_elec) <- "Electrical Installation"
var_label(df$a_comp_macon) <- "Masonry"
var_label(df$a_comp_menuis) <- "Carpentry"
var_label(df$a_comp_plomb) <- "Plumbing"
var_label(df$a_comp_metal) <- "Metalwork"
var_label(df$a_comp_cqp) <- "CQP Selected"
var_label(df$a_comp_notsel) <- "CQP Not Selected"
var_label(df$a_comp_dna) <- "Did Not Apply"
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

df <- df %>% mutate(exp_cqp = case_when(SELECTED == 1 ~ exp_all_trades),
                    exp_notsel = case_when(SELECTED == 0 ~ exp_all_trades),
                    exp_dna = case_when(SELECTED == 3 ~ exp_all_trades))

var_label(df$exp_elec) <- "Electrical Installation"
var_label(df$exp_macon) <- "Masonry"
var_label(df$exp_menuis) <- "Carpentry"
var_label(df$exp_plomb) <- "Plumbing"
var_label(df$exp_metal) <- "Metalwork"
var_label(df$exp_cqp) <- "CQP Selected"
var_label(df$exp_notsel) <- "CQP Not Selected"
var_label(df$exp_dna) <- "Did Not Apply"
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

df <- df %>% mutate(a_exp_cqp = case_when(SELECTED == 1 ~ a_exp_all_trades),
                    a_exp_notsel = case_when(SELECTED == 0 ~ a_exp_all_trades),
                    a_exp_dna = case_when(SELECTED == 3 ~ a_exp_all_trades))

var_label(df$a_exp_elec) <- "Electrical Installation"
var_label(df$a_exp_macon) <- "Masonry"
var_label(df$a_exp_menuis) <- "Carpentry"
var_label(df$a_exp_plomb) <- "Plumbing"
var_label(df$a_exp_metal) <- "Metalwork"
var_label(df$a_exp_cqp) <- "CQP Selected"
var_label(df$a_exp_notsel) <- "CQP Not Selected"
var_label(df$a_exp_dna) <- "Did Not Apply"
var_label(df$a_exp_all_trades) <- "Overall"

# pca

pca_fit <- prcomp(~comp_all_trades+exp_all_trades, data=df, center = TRUE, scale = TRUE, na.action = na.omit)

pca_fit2 <- prcomp(~comp_all_trades+exp_all_trades+skills_all_trades, data=df, center = TRUE, scale = TRUE, na.action = na.omit)

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

df <- df %>% rowwise() %>% mutate(profits = sum(c(FS4.7, -FS5.1, -FS5.3), na.rm = F),
                                  expenses = sum(c(FS5.1, FS5.3), na.rm = F)) %>% ungroup()

# recode training costs (ENDLINE ONLY!)
training_costs <- df %>% filter(wave == 1) %>% select(IDYouth, contains("FE5.1")) %>% mutate_at(c("FE5.1_1", "FE5.1_2", "FE5.1_3", "FE5.1_4"), recode,
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

training_costs$total_training_costs <- training_costs %>% select(contains("FE5.1")) %>% rowSums(., na.rm = T)
training_costs$total_training_costs[is.na(training_costs$total_training_costs)]<-NA

df <- df %>% select(-contains("FE5.1"))
df <- left_join(df, training_costs, by = c('IDYouth'))

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
  mutate_at(c("allow_food", "allow_transport", "allow_pocket_money", "allow_other"), ~replace(., is.na(.), 0)) #replace NA with 0

df$all_allowances <- df %>% select(c("allow_food", "allow_transport", "allow_pocket_money", "allow_other")) %>% 
  rowSums(., na.rm = T)

# if no allowances are given whatsoever, change total allowances to NA
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

df$YS4.38 <- zap_labels(df$YS4.38)

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

df$YE3.22 <- zap_labels(df$YE3.22)
                      
df$a_allow <- coalesce(df$YS4.38, df$YE3.22)

df <- df %>% rowwise() %>% mutate(allow_avg = mean(c(all_allowances, a_allow), na.rm = T)) %>% ungroup()

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
df <- left_join(df, fees, by = c('IDYouth', 'wave'))

# recode fees

df <- df %>% mutate_at(c("fee_entry", "fee_formation", "fee_liberation"), recode,
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
  mutate_at(c("fee_entry", "fee_formation", "fee_liberation"), na_if, 12) %>% 
  mutate_at(c("fee_entry", "fee_formation", "fee_liberation"), ~replace(., is.na(.), 0)) #replace NA with 0

df <- df %>% mutate_at(c("fee_materials", "fee_contract", "fee_application"), recode,
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
  mutate_at(c("fee_materials", "fee_contract", "fee_application"), na_if, 12) %>% 
  mutate_at(c("fee_materials", "fee_contract", "fee_application"), ~replace(., is.na(.), 0)) #replace NA with 0

df$total_fees <- df %>% select(c("fee_entry", "fee_formation", "fee_liberation", "fee_materials", "fee_contract", "fee_application")) %>% 
  rowSums(., na.rm = T)

# if no allowances are given whatsoever, change total allowances to NA
df <- df %>% mutate_at(c("fee_entry", "fee_formation", "fee_liberation", "fee_materials", "fee_contract", "fee_application", "total_fees"), ~replace(., total_fees == 0, NA))

var_label(df$fee_entry) <- "Initiation"
var_label(df$fee_formation) <- "Training"
var_label(df$fee_liberation) <- "Graduation"
var_label(df$fee_materials) <- "Materials"
var_label(df$fee_contract) <- "Contract"
var_label(df$fee_application) <- "Application"
var_label(df$total_fees) <- "Total"

# app-level fees

df <- df %>%
  mutate(a_fee_entry = YS4.15,
         a_fee_formation = YS4.21,
         a_fee_liberation = YS4.24,
         a_fee_materials = YS4.17,
         a_fee_contract = YS4.19,
         a_fee_application = YS4.23)

df <- df %>% 
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
  mutate_at(c("a_fee_entry", "a_fee_formation", "a_fee_liberation"), na_if, 99) %>% 
  mutate_at(c("a_fee_entry", "a_fee_formation", "a_fee_liberation"), ~replace(., is.na(.), 0)) #replace NA with 0

df <- df %>% 
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
  mutate_at(c("a_fee_materials", "a_fee_contract", "a_fee_application"), na_if, 99) %>% 
  mutate_at(c("a_fee_materials", "a_fee_contract", "a_fee_application"), ~replace(., is.na(.), 0)) #replace NA with 0

df$a_total_fees <- df %>% select(c("a_fee_entry", "a_fee_formation", "a_fee_liberation", "a_fee_materials", "a_fee_contract", "a_fee_application")) %>% 
  rowSums(., na.rm = T)

# if no allowances are given whatsoever, change total allowances to NA
df <- df %>% mutate_at(c("a_fee_entry", "a_fee_formation", "a_fee_liberation", "a_fee_materials", "a_fee_contract", "a_fee_application", "a_total_fees"), ~replace(., a_total_fees == 0, NA))

var_label(df$a_fee_entry) <- "Initiation"
var_label(df$a_fee_formation) <- "Training"
var_label(df$a_fee_liberation) <- "Graduation"
var_label(df$a_fee_materials) <- "Materials"
var_label(df$a_fee_contract) <- "Contract"
var_label(df$a_fee_application) <- "Application"
var_label(df$a_total_fees) <- "Total"

df <- df %>% rowwise() %>% mutate(fees_avg = mean(c(total_fees, a_total_fees), na.rm = T)) %>% ungroup()

# firm size (calculated by adding up total number of all types of workers), as well as bins
df <- df %>% rowwise() %>% mutate(firm_size = sum(c(FS6.1, FS3.5_1, FS3.5_2, FS3.5_3, FS3.5_4, FS3.5_5), na.rm = T),
                                  firm_size_sans_app = sum(c(FS3.5_1, FS3.5_2, FS3.5_3, FS3.5_4, FS3.5_5), na.rm = T),
                    firm_size_bins = cut(firm_size, breaks = c(1,20,40,60,80,107)),
                    firm_size_bins_reported = cut(FS3.4, breaks = c(1,10,20,30,40,50))) %>% ungroup()

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

#estimating app productivity. use employee wages where available (average of mean trained and mean untrained monthly wage * months worked). otherwise use reported apprentive wage where available
app_prod <- df %>% select(IDYouth, wave, SELECTED, FS4.1, contains("FS5.2_1"))
app_prod <- app_prod %>% mutate_at(vars(contains("FS5.2_1")), na_if, 0)

app_prod <- app_prod %>% mutate(annual_app_prod = case_when(rowMeans(across(c(FS5.2_1_1, FS5.2_1_2)), na.rm = T)>0 & 
                                                              rowMeans(across(c(FS5.2_1_3, FS5.2_1_4)), na.rm = T)>0 ~ 
                                                              (rowMeans(across(c(FS5.2_1_1, FS5.2_1_2)), na.rm = T) + 
                                                                 rowMeans(across(c(FS5.2_1_3, FS5.2_1_4)), na.rm = T))/2*FS4.1,
                                                            rowMeans(across(c(FS5.2_1_1, FS5.2_1_2)), na.rm = T)>0 ~ 
                                                              rowMeans(across(c(FS5.2_1_1, FS5.2_1_2)), na.rm = T)*FS4.1,
                                                            rowMeans(across(c(FS5.2_1_3, FS5.2_1_4)), na.rm = T)>0 ~ 
                                                              rowMeans(across(c(FS5.2_1_3, FS5.2_1_4)), na.rm = T)*FS4.1,
                                                            rowMeans(across(c(FS5.2_1_10, FS5.2_1_11)), na.rm = T)>0 & SELECTED == 1 ~ 
                                                              rowMeans(across(c(FS5.2_1_10, FS5.2_1_11)), na.rm = T)/2*FS4.1,
                                                            rowMeans(across(c(FS5.2_1_8, FS5.2_1_9)), na.rm = T)>0 & SELECTED != 1 ~ 
                                                              rowMeans(across(c(FS5.2_1_8, FS5.2_1_9)), na.rm = T)/2*FS4.1,
                                                            rowMeans(across(c(FS5.2_1_8, FS5.2_1_9, FS5.2_1_10, FS5.2_1_11)), na.rm = T)>0 ~ 
                                                              rowMeans(across(c(FS5.2_1_8, FS5.2_1_9, FS5.2_1_10, FS5.2_1_11)), na.rm = T))) %>% 
  select(IDYouth, wave, annual_app_prod)

df <- left_join(df, app_prod, by = c('IDYouth', 'wave'))                                                        
  
# estimated trainer hours of training per year: days per week (FS6.9) * hours on last day (FS6.10) * 4 * months open last year (FS4.1)
# trainer hourly wage: monthly wage of skilled employee (FS5.2_1_2) / days open last week (FS3.1) / hours open on last day (FS3.2) / 4 weeks
# number of trainers per apprentice: FS6.8 / FS6.1

df <- df %>% mutate(annual_fees = ifelse(is.na(total_fees), a_total_fees/4, total_fees/4),
                    annual_allowances = ifelse(is.na(all_allowances), a_allow*5*4*FS4.1, all_allowances*5*4*FS4.1),
                    annual_training_costs = total_training_costs*FS4.1/FS6.1, 
                    annual_foregone_prod = case_when(FS5.2_1_2>0 & FS3.1 > 0 ~ FS6.9*FS6.10*4*FS4.1*FS5.2_1_2/FS3.1/FS3.2/4*FS6.8/FS6.1,
                                                     FS5.2_1_2>0 ~ FS6.9*FS6.10*4*FS4.1*FS5.2_1_2/6/FS3.2/4*FS6.8/FS6.1,
                                                     FS5.2_1_1>0 & FS3.1 > 0 ~ FS6.9*FS6.10*4*FS4.1*FS5.2_1_1/FS3.1/FS3.2/4*FS6.8/FS6.1,
                                                     FS5.2_1_1>0 ~ FS6.9*FS6.10*4*FS4.1*FS5.2_1_1/6/FS3.2/4*FS6.8/FS6.1,
                                                     FS5.2_1_3>0 & FS3.1 > 0 ~ FS6.9*FS6.10*4*FS4.1*FS5.2_1_3/FS3.1/FS3.2/4*FS6.8/FS6.1,
                                                     FS5.2_1_3>0 ~ FS6.9*FS6.10*4*FS4.1*FS5.2_1_3/6/FS3.2/4*FS6.8/FS6.1,
                                                     FS5.2_1_4>0 & FS3.1 > 0 ~ FS6.9*FS6.10*4*FS4.1*FS5.2_1_4/FS3.1/FS3.2/4*FS6.8/FS6.1,
                                                     FS5.2_1_4>0 ~ FS6.9*FS6.10*4*FS4.1*FS5.2_1_4/6/FS3.2/4*FS6.8/FS6.1,
                                                     FS5.2_1_7>0 & FS3.1 > 0 ~ FS6.9*FS6.10*4*FS4.1*FS5.2_1_7/FS3.1/FS3.2/4*FS6.8/FS6.1,
                                                     FS5.2_1_7>0 ~ FS6.9*FS6.10*4*FS4.1*FS5.2_1_7/6/FS3.2/4*FS6.8/FS6.1))
df <- df %>% 
  rowwise() %>% 
  mutate(total_benefits = sum(annual_fees, annual_app_prod, na.rm = F),
         total_costs = sum(annual_allowances, annual_training_costs, annual_foregone_prod, na.rm = F))

# model I: fees - allowances
df <- df %>% rowwise() %>% mutate(cb_I = sum(annual_fees, -annual_allowances, na.rm = F))

# model II: fees - allowances - training costs
df <- df %>% rowwise() %>% mutate(cb_II = sum(annual_fees, -annual_allowances, -annual_training_costs, na.rm = F))

# model III: fees + productivity - allowances
df <- df %>% rowwise() %>% mutate(cb_III = sum(annual_fees, annual_app_prod, -annual_allowances, na.rm = F))

# model IV: fees + productivity - training_costs - allowances
df <- df %>% rowwise() %>% mutate(cb_IV = sum(annual_fees, annual_app_prod, -annual_training_costs, -annual_allowances, na.rm = F))

# model V: fees + productivity - training_costs - allowances - foregone trainer productivity
df <- df %>% rowwise() %>% mutate(cb_V = sum(annual_fees, annual_app_prod, -annual_training_costs, -annual_allowances, -annual_foregone_prod, na.rm = F))

df <- df %>% ungroup()

df <- unlabelled(df)

save(df, file = "data/df.rda")

rm(list=setdiff(ls(), "path"))
