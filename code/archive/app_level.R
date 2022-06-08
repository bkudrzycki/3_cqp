#######################################
## Apprentice-Level Baseline/Endline ##
#######################################

packages <- c("haven", "tidyverse", "labelled", "gtsummary", "tidyr", "kableExtra", "stargazer")

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

## 1 Load baseline and endline data

# re-run cleaning/reshape code if necessary
#source("code/pivot_longer.R")

# load reshaped apprentice-level data
load("data/base_cqps.rda")
load("data/base_trad.rda")
load("data/end_cqps.rda")
load("data/end_trad.rda")


## 2 Compare all apprentices before/after

# merge baseline and endline for variables of interest (example: fees)

JoinCQP <- function(vars) {
  joined_cqps <- rbind(base_cqps %>% select(tidyselect::vars_select(names(base_cqps), matches(c({{vars}}))), "IDYouth", "wave"), end_cqps %>% select(tidyselect::vars_select(names(end_cqps), matches(c({{vars}}))), "IDYouth", "wave"))
  return(joined_cqps)
}

JoinTrad <- function(vars) {
  joined_trad <- rbind(base_trad %>% select(tidyselect::vars_select(names(base_trad), matches(c({{vars}}))), "IDYouth", "wave"), end_trad %>% select(tidyselect::vars_select(names(end_trad), matches(c({{vars}}))), "IDYouth", "wave"))
return(joined_trad)
}

fees <- rbind(JoinCQP('FS9.7') %>% rename(entry = FS9.7_1,
                                            formation = FS9.7_2,
                                            liberation = FS9.7_3),
                JoinTrad('FS7.9') %>% rename(entry = FS7.9_1,
                                             formation = FS7.9_2,
                                             liberation = FS7.9_3))

# recode fee amounts

fees <- fees %>% mutate_at(c("entry", "formation", "liberation"), recode,
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
  mutate_at(c("entry", "formation", "liberation"), na_if, 12)

fees %>% select(c("entry", "formation", "liberation", "wave")) %>% 
  mutate(wave = factor(wave, labels = c("Baseline", "Endline"))) %>% 
  tbl_summary(by=wave,
              type = everything() ~ "continuous2",
              statistic = all_continuous() ~ c("{N_nonmiss}",
                                               "{mean} ({sd})"),
              missing = "no") %>% 
  modify_header(update = all_stat_cols() ~ "**{level}**")



## 2 Compare cqp apprentices to non-cqp apprentices before/after

# two ways to define apprenticeship status

# 2.1 by patron-reported CQP status at baseline (FS8.2/FS9.3)
# (Which training program or what type of apprenticeship is he/she participating in? 1 = Traditional, 2 = CQM, 3 = CQP, 4 = Other)

benefits <- rbind(JoinCQP(c('FS9.6')) %>% rename(food = FS9.6_1,
                                                          transport = FS9.6_2,
                                                          pocket_money = FS9.6_3,
                                                          other = FS9.6_4) %>% select(-FS9.6_5),
                  JoinTrad(c('FS7.8')) %>% rename(food = FS7.8_1,
                                                           transport = FS7.8_2,
                                                           pocket_money = FS7.8_3,
                                                           other = FS7.8_4) %>% select(-FS7.8_5))

status <- base_cqps %>% select(IDYouth, status = FS9.3) %>% 
  rbind(base_trad %>% select(IDYouth, status = FS7.4))

benefits1 <- benefits %>% left_join(status, by = "IDYouth")

benefits1 <- benefits1 %>% mutate_at(c("food", "transport", "pocket_money", "other"), recode,
                           `1` = 150,
                           `2` = 325,
                           `3` = 475,
                           `4` = 875,
                           `5` = 1225,
                           `6` = 1775,
                           `7` = 2425,
                           `8` = 3425,
                           `9` = 6225,
                           `10` = 8725,
                           `11` = 11725) %>% 
  mutate_at(c("food", "transport", "pocket_money", "other"), na_if, 12)
  
benefits1 %>% select(-c(IDYouth, status)) %>% 
  mutate(wave = factor(wave, labels = c("Baseline", "Endline"))) %>% 
  tbl_summary(by=wave,
              type = everything() ~ "continuous2",
              statistic = all_continuous() ~ c("{N_nonmiss}",
                                               "{mean} ({sd})"),
              missing = "no") %>% 
  modify_header(update = all_stat_cols() ~ "**{level}**")

benefits1 %>% select(-c(IDYouth, wave)) %>% 
  mutate(status = factor(status, labels = c("Traditional", "CQM", "CQP", "Other"))) %>% 
  tbl_summary(by=status,
              type = everything() ~ "continuous2",
              statistic = all_continuous() ~ c("{N_nonmiss}",
                                               "{mean} ({sd})"),
              missing = "no") %>% 
  modify_header(update = all_stat_cols() ~ "**{level}**")

cqp_table <- benefits1 %>% filter(status == 3) %>% 
  select(-c(IDYouth, status, other)) %>% 
  mutate(wave = factor(wave, labels = c("Baseline", "Endline"))) %>% 
  tbl_summary(by=wave,
              type = everything() ~ "continuous2",
              statistic = all_continuous() ~ "{mean} ({N_nonmiss})",
              missing = "no") %>% 
  modify_header(update = all_stat_cols() ~ "**{level}**") %>% 
  modify_caption("**Apprentice Benefits**")

non_cqp_table <- benefits1 %>% filter(status != 3) %>% 
    select(-c(IDYouth, status, other)) %>% 
    mutate(wave = factor(wave, labels = c("Baseline", "Endline"))) %>% 
    tbl_summary(by=wave,
                type = everything() ~ "continuous2",
                statistic = all_continuous() ~ "{mean} ({N_nonmiss})",
                missing = "no") %>% 
  modify_header(update = all_stat_cols() ~ "**{level}**")
  

tbl_stack(list(cqp_table, non_cqp_table), group_header = c("CQP Apprentices", "Non-CQP Apprentices")) %>% italicize_labels() %>% as_gt() %>%
  gt::tab_style(
    style = gt::cell_text(weight = "bold"),
    locations = gt::cells_row_groups(groups = everything())
  )
  
# 2.2 by dossier status (Was this apprentice *selected* for the CQP: 1 = Yes, 2 = No, 0 = Never applied)

status2 <- base_cqps %>% select(IDYouth, SELECTED) %>% 
  rbind(base_trad %>% select(IDYouth, SELECTED))

benefits2 <- benefits %>% left_join(status2, by = "IDYouth")


## 3 Apprentices rated by master


ratings <- rbind(JoinCQP(c('FS9.11')) %>% rename(discipline = FS9.11_1,
                                                teamwork = FS9.11_2,
                                                efficiency = FS9.11_3,
                                                work_quality = FS9.11_4,
                                                learning_speed = FS9.11_5,
                                                respect = FS9.11_6),
                             JoinTrad(c('FS7.13')) %>% rename(discipline = FS7.13_1,
                                                              teamwork = FS7.13_2,
                                                              efficiency = FS7.13_3,
                                                              work_quality = FS7.13_4,
                                                              learning_speed = FS7.13_5,
                                                              respect = FS7.13_6))

ratings <- ratings %>% left_join(status, by = "IDYouth")


cqp_table <- ratings %>% filter(status == 3) %>% 
  select(-c(IDYouth, status)) %>% 
  mutate(wave = factor(wave, labels = c("Baseline", "Endline"))) %>% 
  tbl_summary(by=wave,
              type = everything() ~ "continuous2",
              statistic = all_continuous() ~ "{mean} ({N_nonmiss})",
              missing = "no") %>% 
  modify_header(update = all_stat_cols() ~ "**{level}**") %>% 
  modify_caption("**Apprentice Ratings**")

non_cqp_table <- ratings %>% filter(status != 3) %>% 
  select(-c(IDYouth, status)) %>% 
  mutate(wave = factor(wave, labels = c("Baseline", "Endline"))) %>% 
  tbl_summary(by=wave,
              type = everything() ~ "continuous2",
              statistic = all_continuous() ~ "{mean} ({N_nonmiss})",
              missing = "no") %>% 
  modify_header(update = all_stat_cols() ~ "**{level}**")

tbl_merge(list(cqp_table, non_cqp_table), tab_spanner = c("CQP Apprentices", "Non-CQP Apprentices")) %>% italicize_labels() %>% as_gt() %>%
  gt::tab_style(
    style = gt::cell_text(weight = "bold"),
    locations = gt::cells_row_groups(groups = everything())
  )

ratings_wide <- ratings %>% filter(!is.na(IDYouth)) %>% pivot_wider(id_cols = IDYouth, names_from = wave, values_from = c(discipline, teamwork, efficiency, work_quality, learning_speed, respect)) %>%  left_join(status, by = "IDYouth")

ratings_wide <- ratings_wide %>% mutate(discipline = discipline_1-discipline_0,
                                    teamwork = teamwork_1-teamwork_0,
                                    efficiency = efficiency_1-efficiency_0,
                                    work_quality = work_quality_1-work_quality_0,
                                    learning_speed = learning_speed_1-learning_speed_0,
                                    respect = respect_1-respect_0)

ratings_wide %>% select(c("status", "discipline", "teamwork", "efficiency", "work_quality", "learning_speed", "respect")) %>% 
  mutate(status = ifelse(status == 3, 0, 1),
         status = factor(status, labels = c("CQP", "Non-CQP"))) %>% 
  tbl_summary(by=status,
              type = everything() ~ "continuous2",
              statistic = all_continuous() ~ c("{mean} ({N_nonmiss})"),
              missing = "no") %>% 
  modify_header(update = all_stat_cols() ~ "**{level}**") %>% 
  modify_caption("**Changes in Master Appraisal**") %>% 
  add_p()

ratings_long <- ratings_wide %>% select("status", "discipline", "teamwork", "efficiency", "work_quality", "learning_speed", "respect") %>% 
  pivot_longer(cols = (c("discipline", "teamwork", "efficiency", "work_quality", "learning_speed", "respect")))


ratings_long <- ratings_wide %>% select("status", "discipline", "teamwork", "efficiency", "work_quality", "learning_speed", "respect") %>% 
  mutate(status = ifelse(status == 3, 0, 1),
         status = factor(status, labels = c("CQP", "Non-CQP"))) %>% 
  filter(!is.na(status)) %>% 
  group_by(status) %>% summarise_all(mean, na.rm = T) %>% 
  pivot_longer(cols = (c("discipline", "teamwork", "efficiency", "work_quality", "learning_speed", "respect")))




# competencies

comp <- rbind(JoinCQP(c('FS9.12', 'FS9.13', 'FS9.14', 'FS9.15', 'FS9.16')), JoinTrad(c('FS7.14', 'FS7.15', 'FS7.16', 'FS7.17', 'FS7.18')) %>% setNames(names(JoinCQP(c('FS9.12', 'FS9.13', 'FS9.14', 'FS9.15', 'FS9.16'))))) %>% mutate_all(recode, `2` = 0)

comp$all_trades <- comp %>% select(tidyselect::vars_select(names(comp), matches('FS'))) %>% rowMeans(., na.rm = T)

comp$elec <- comp %>% select(tidyselect::vars_select(names(comp), matches('FS9.12_1'))) %>% 
  rowMeans(., na.rm = T)

comp$macon <- comp %>% select(tidyselect::vars_select(names(comp), matches('FS9.13_1'))) %>% 
  rowMeans(., na.rm = T)

comp$menuis<- comp %>% select(tidyselect::vars_select(names(comp), matches('FS9.14_1'))) %>% 
  rowMeans(., na.rm = T)

comp$plomb <- comp %>% select(tidyselect::vars_select(names(comp), matches('FS9.15_1'))) %>% 
  rowMeans(., na.rm = T)

comp$metal <- comp %>% select(tidyselect::vars_select(names(comp), matches('FS9.16_1'))) %>% 
  rowMeans(., na.rm = T)
  
comp <- comp %>% left_join(status, by = "IDYouth")

cqp_table <- comp %>% filter(status == 3) %>% 
  select(all_trades, elec, macon, menuis, plomb, metal, wave) %>% 
  mutate(wave = factor(wave, labels = c("Baseline", "Endline"))) %>% 
  tbl_summary(by=wave,
              type = everything() ~ "continuous2",
              statistic = all_continuous() ~ "{mean} ({N_nonmiss})",
              missing = "no") %>% 
  modify_header(update = all_stat_cols() ~ "**{level}**") %>% 
  modify_caption("**Apprentice Competencies**") %>% 
  add_difference(test = list(all_continuous() ~ "t.test")) 
#%>% add_p()

non_cqp_table <- comp %>% filter(status != 3) %>% 
  select(all_trades, elec, macon, menuis, plomb, metal, wave) %>% 
  mutate(wave = factor(wave, labels = c("Baseline", "Endline"))) %>% 
  tbl_summary(by=wave,
              type = everything() ~ "continuous2",
              statistic = all_continuous() ~ "{mean} ({N_nonmiss})",
              missing = "no") %>% 
  modify_header(update = all_stat_cols() ~ "**{level}**") %>% 
  add_difference(test = list(all_continuous() ~ "t.test"))
# %>% add_p()

tbl_merge(list(cqp_table, non_cqp_table), tab_spanner = c("CQP Apprentices", "Non-CQP Apprentices")) %>% italicize_labels() %>% as_gt() %>%
  gt::tab_style(
    style = gt::cell_text(weight = "bold"),
    locations = gt::cells_row_groups(groups = everything())
  )



# skills

merged <- read_sav("data/youth_survey_merged.sav") %>% 
  filter(YS1_2 == 1)

merged_labels <- haven::as_factor(merged) %>% filter(YS1_2=="Yes")


skills <- JoinCQP('FS1.11') %>% select(-matches('TEXT')) %>% left_join(status, by = "IDYouth")

skills$IDYouth <- paste0('CQP', skills$IDYouth)

skills <- left_join(skills, merged, by = "IDYouth") %>% select(matches(c('IDYouth', 'wave', 'status', 'YS5', 'YE4')))


# code 1 if answer is correct for each skills question

CodeAnswers <- function(data, base_q, end_q, correct_answer) {
  x <- data %>% 
    mutate(x = ifelse({{base_q}} == correct_answer & wave == 0, 1, 0)) %>% 
    mutate(y = ifelse({{end_q}} == correct_answer & wave == 1, 1, 0)) %>% 
    mutate(var = ifelse(wave == 0, x, y)) %>% 
    select(-c(x, y)) %>% 
    rename("correct_{{base_q}}" := "var")
  return(x)
}

# code correct answers

skills <- skills %>% 
  CodeAnswers(YS5_1, YE4_1, 2) %>% 
  CodeAnswers(YS5_2, YE4_2, 1) %>% 
  CodeAnswers(YS5_3, YE4_3, 3) %>% 
  CodeAnswers(YS5_4, YE4_4, 1) %>% 
  CodeAnswers(YS5_5, YE4_5, 2) %>% 
  CodeAnswers(YS5_6, YE4_6, 2) %>% 
  CodeAnswers(YS5_7, YE4_7, 1) %>% 
  CodeAnswers(YS5_8, YE4_8, 2) %>% 
  CodeAnswers(YS5_9, YE4_9, 2) %>% 
  CodeAnswers(YS5_10, YE4_10, 3) %>% 
  CodeAnswers(YS5_11, YE4_11, 1) %>% 
  CodeAnswers(YS5_12, YE4_12, 4) %>% 
  CodeAnswers(YS5_13, YE4_13, 1) %>% 
  CodeAnswers(YS5_14, YE4_14, 4) %>% 
  CodeAnswers(YS5_15, YE4_15, 1) %>% 
  CodeAnswers(YS5_16, YE4_16, 2) %>% 
  CodeAnswers(YS5_18, YE4_18, 2) %>% 
  CodeAnswers(YS5_19, YE4_19, 2) %>% 
  CodeAnswers(YS5_20, YE4_20, 3) %>% 
  CodeAnswers(YS5_21, YE4_21, 2) %>% 
  CodeAnswers(YS5_22, YE4_22, 1) %>% 
  CodeAnswers(YS5_23, YE4_23, 1)
  


skills$all_trades <- skills %>% select(tidyselect::vars_select(names(skills), matches('correct'))) %>% rowMeans(., na.rm = T)

skills$elec <- skills %>% select(tidyselect::vars_select(names(skills), matches(c('correct_YS5_19', 'correct_YS5_20', 'correct_YS5_21', 'correct_YS5_22', 'correct_YS5_23')))) %>% 
  rowMeans(., na.rm = T)

skills$macon <- skills %>% select(tidyselect::vars_select(names(skills), matches(c('correct_YS5_14', 'correct_YS5_15', 'correct_YS5_16', 'correct_YS5_18')))) %>% 
  rowMeans(., na.rm = T)

skills$menuis<- skills %>% select(tidyselect::vars_select(names(skills), matches(c('correct_YS5_10', 'correct_YS5_11', 'correct_YS5_12', 'correct_YS5_13')))) %>% 
  rowMeans(., na.rm = T)

skills$plomb <- skills %>% select(tidyselect::vars_select(names(skills), matches(c('correct_YS5_6', 'correct_YS5_7', 'correct_YS5_8', 'correct_YS5_9')))) %>% 
  rowMeans(., na.rm = T)

skills$metal <- skills %>% select(tidyselect::vars_select(names(skills), matches(c('correct_YS5_1', 'correct_YS5_2', 'correct_YS5_3', 'correct_YS5_4', 'correct_YS5_5')))) %>% 
  rowMeans(., na.rm = T)


cqp_table <- skills %>% filter(status == 3) %>% 
  select(all_trades, elec, macon, menuis, plomb, metal, wave) %>% 
  mutate(wave = factor(wave, labels = c("Baseline", "Endline"))) %>% 
  tbl_summary(by=wave,
              type = everything() ~ "continuous2",
              statistic = all_continuous() ~ "{mean} ({N_nonmiss})",
              missing = "no") %>% 
  modify_header(update = all_stat_cols() ~ "**{level}**") %>% 
  modify_caption("**Apprentice skills**") %>% 
  add_difference()

non_cqp_table <- skills %>% filter(status != 3) %>% 
  select(all_trades, elec, macon, menuis, plomb, metal, wave) %>% 
  mutate(wave = factor(wave, labels = c("Baseline", "Endline"))) %>% 
  tbl_summary(by=wave,
              type = everything() ~ "continuous2",
              statistic = all_continuous() ~ "{mean} ({N_nonmiss})",
              missing = "no") %>% 
  modify_header(update = all_stat_cols() ~ "**{level}**") %>% 
  add_difference()

tbl_merge(list(cqp_table, non_cqp_table), tab_spanner = c("CQP Apprentices", "Non-CQP Apprentices")) %>% italicize_labels() %>% as_gt() %>%
  gt::tab_style(
    style = gt::cell_text(weight = "bold"),
    locations = gt::cells_row_groups(groups = everything())
  )


# regressions - changes over time in apprentice skill, competency, (what else?) on cqp status and other factors


# pivot to wide format to take differences of average scores over time
skills_reg <- skills %>% select(c(IDYouth, wave, status, all_trades)) %>% pivot_wider(names_from = "wave", values_from = "all_trades", names_prefix = "all_trades_")

skills_reg <- skills_reg %>% mutate(skills_diff = all_trades_1-all_trades_0)

skills_reg$IDYouth <- str_replace(skills_reg$IDYouth, "CQP", "") %>% as.numeric()

skills_reg <- left_join(base_cqps, skills_reg, by="IDYouth") %>% 
  mutate(cqp = ifelse(status == 3, 1, 0),
         app_ratio = ifelse(FS6.1 != 0, FS6.1/FS3.4, NA), # apprentices divided by total employees
         trainer_ratio = ifelse(FS6.9 > 1, (FS6.8-1)/FS3.4, NA)) %>% 
  mutate(FS6.10 = recode(FS6.10, `12` = 0)) %>% 
  mutate(FS6.10 = na_if(FS6.10, 13))

# skill change on number of employees

m1 <- lm(skills_diff ~ cqp +  as.numeric(FS3.4), data = skills_reg)

# skill change on apprentice-to-employee ratio

m2 <- lm(skills_diff ~ cqp + as.numeric(FS3.4) + app_ratio, data = skills_reg)

# skill change on days per week trained, trainer-to-employee ratio, duration of training

m3 <- lm(skills_diff ~ cqp + as.numeric(FS3.4) + trainer_ratio + FS6.9 + FS6.10, data = skills_reg)

# skill change on days a week workshop trains and duration of training

m4 <- lm(skills_diff ~ FS6.9 + FS6.10, data = skills_reg)

m1 %>% tidy() %>% 
  mutate(term = c("(Intercept)", "CQP", "# Employees at training firm at baseline")) %>% 
  kable(caption = "LM Estimating Change in Apprentice Skill (at the firm level) over three years") %>%
  kableExtra::kable_styling()

m2 %>% tidy() %>% 
  mutate(term = c("(Intercept)", "CQP", "# Employees at training firm at baseline", "Apprentice-to-employee ratio at baseline")) %>% 
  kable(caption = "LM Estimating Change in Apprentice Skill (at the firm level) over three years") %>%
  kableExtra::kable_styling()

m3 %>% tidy() %>% 
  mutate(term = c("(Intercept)", "CQP", "# Employees at training firm at baseline", "Trainer-to-employee ratio at baseline", "Days trained (last week) at baseline", "Hours trained (last day trained) at baseline")) %>% 
  kable(caption = "LM Estimating Change in Apprentice Skill (at the firm level) over three years") %>%
  kableExtra::kable_styling()


stargazer(m1, m2, m3,
          covariate.labels = c("cqp",
                               "employees",
                               "apprentice-to-employee ratio",
                               "trainer-to-employee ratio",
                               "days trained (last week)",
                               "hours trained (last day trained)"))

