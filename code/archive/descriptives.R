############################
## DESCRIPTIVE STATISTICS ##
############################

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

df %>% select(age, sex, SELECTED, wave) %>%
  mutate(SELECTED = factor(SELECTED, levels = c(1, 0, 3),
                           labels = c('Selected', 'Not Selected', 'Did Not Apply')),
         sex = factor(sex, labels = c("Female", "Male")),
         wave = factor(wave, labels = c("Baseline", "Endline"))) %>% 
  rename("CQP Status" = SELECTED, "Age" = age, "Gender" = sex) %>% 
  tbl_summary(by=wave,
              type = list(Age ~ "continuous",
                          Gender ~ "categorical"),
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no") %>% 
  modify_header(label = "**Characteristic**")


## firm

#time invariant
df %>% filter(wave == 0) %>% 
  select(FS1.2, dossier_selected, dossier_apps, FS1.11) %>% 
  group_by(FS1.2) %>% 
  summarise_all(mean, na.rm = T) %>% ungroup() %>% select(-FS1.2) %>%
  mutate(FS1.11 = factor(FS1.11, levels = c(1:5),
                         labels = c('Masonry', 'Carpentry', 'Plumbing', 'Metalwork', 'Electrical Inst.'))) %>% 
  rename("Trade" = FS1.11,
         "CQP Selections" = dossier_selected,
         "CQP Applications" = dossier_apps) %>%
  tbl_summary(type = Trade ~ "categorical",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no") %>% 
  modify_header(label = "**Characteristic**")

# time-varying
df %>% select(FS1.2, wave, FS4.1, firm_size, FS3.4, FS6.1, tidyselect::vars_select(names(df), matches("FS3.5"))) %>% 
  group_by(FS1.2, wave) %>% 
  summarise_all(mean, na.rm = T) %>% ungroup() %>% select(-FS1.2) %>% 
  mutate(wave = factor(wave, labels = c("Baseline", "Endline"))) %>% 
  rename("Firm size (computed)" = firm_size,
         "Firm size (reported)" = FS3.4,
         "Months operational (past year)" = FS4.1,
         "Apprentices hired" = FS6.1,
         "Partners (incl. owner)" = FS3.5_1,
         "Permanent employees" = FS3.5_2,
         "Paid family workers" = FS3.5_3,
         "Unpaid family workers"  = FS3.5_4,
         "Occasional workers" = FS3.5_5) %>% 
  tbl_summary(by=wave,
              type = everything() ~ "continuous",
              digits = all_continuous() ~ 1,
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no") %>% 
  modify_header(label = "**Characteristic**")


# days worked by duration
df %>% filter(!is.na(duration), !is.na(YS4.10), duration < 6) %>% select(duration, YS4.10, SELECTED) %>% 
  mutate(SELECTED = factor(SELECTED, levels = c(1, 0, 3),
                           labels = c('Selected', 'Not Selected', 'Did Not Apply'))) %>% 
  group_by(duration, SELECTED) %>% summarise_all(mean, na.rm = T) %>% ungroup() %>%
  ggplot(aes(x = duration, y = YS4.10, fill = as.factor(SELECTED))) +
  geom_bar(stat = "identity", width=.5, position = "dodge") +
  scale_x_discrete(limits = c(0:5)) +
  xlab("Year of apprenticeship") +
  ylab("Days worked in past week") +
  guides(fill = guide_legend(title = "CQP Status"))

# hours worked by duration
df %>% filter(!is.na(duration), !is.na(YS4.12), duration < 6) %>% select(duration, YS4.12, SELECTED) %>% 
  mutate(SELECTED = factor(SELECTED, levels = c(1, 0, 3),
                           labels = c('Selected', 'Not Selected', 'Did Not Apply'))) %>% 
  group_by(duration, SELECTED) %>% summarise_all(mean, na.rm = T) %>% ungroup() %>%
  ggplot(aes(x = duration, y = YS4.12, fill = as.factor(SELECTED))) +
  geom_bar(stat = "identity", width=.5, position = "dodge") +
  scale_x_discrete(limits = c(0:5)) +
  xlab("Year of apprenticeship") +
  ylab("Hours worked on last day") +
  guides(fill = guide_legend(title = "CQP Status"))


  geom_point( color="orange", size=4) +
  scale_x_discrete(0,7) +
  theme(axis.text.y=element_blank()) +
  xlab("Year of apprenticeship") +
  ylab("Days Worked") +
  scale_x_discrete(limits = c(0:6)) %>% suppressWarnings()
  
rm(list = ls())