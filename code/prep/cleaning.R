####################
## Data Cleaning  ##
####################

if(is.na(path)){
  setwd("~/polybox/Youth Employment/2 CQP/Paper")
}else{
  setwd(path)
}

## Dependencies

# Package names
packages <- c("haven", "tidyverse", "labelled", "readxl")

# Install packages not yet installed
installed_packages <- packages %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  install.packages(packages[!installed_packages], silent = TRUE)
}

# Load packages
invisible(lapply(packages, library, character.only = TRUE))

rm(packages, installed_packages)

# Functions
source("functions/coalesce_join.R")

## Data
fs <- read_sav("data/source/Enquête+auprès+des+patrons_February+10,+2020_13.28.sav", user_na = TRUE)

## Baseline Cleaning
fs <- fs %>% filter(!(FS2.1 == 90 & FS1.1 == 10)) # Two surveyors interviewed firm 90 (with different apprentices) so we are forced to drop one
fs <- fs %>% filter(FS2.1 == 1) %>% # not available for interview
  filter(!(ResponseId %in% c('R_dFFOYWTJpZOXC9i', "R_hyakfjosgUhPpiE", "R_gJd9V4L9g97AxQy", "R_iOfqtFybU4olYI5", "R_nbzhLY05d1u5kJT", 'R_ij6WUVJtQYIuTLU'))) # firm 4000 was interviewed twice by Serge; drop version in which apprentices don't match master from dossiers
fs <- fs %>% filter(!is.na(FS1.2))
fs$FS1.2 <- ifelse(fs$ResponseId == 'R_g6CvEE99F02nSCb', 30, fs$FS1.2)     # correct patron's ID
fs$FS1.8_1 <- ifelse(fs$FS1.8_1 == 23 & fs$FS1.2 == 48, 215, fs$FS1.8_1) # according to youth survey, apprentice Sylvain TOFFODJI in workshop 49 is number CQP215 not CQP23
fs$FS1.8_4 <- ifelse(fs$FS1.8_4 == 21 & fs$FS1.2 == 48, 206, fs$FS1.8_4) # according to youth survey, apprentice Gislain KOUNI in workshop 48 is number CQP206 not CQP21

fs <- fs %>% mutate(ifelse(FS3.5_1 == 0, 1, FS3.5_1))

# Endline cleaning
fs_end <- read_sav("data/source/Enquête+auprès+des+patrons+-+endline_October+6,+2021_12.12.sav", user_na = TRUE)

fs_end$FS1.2 <- ifelse(fs_end$FS1.2 == 800, 8000, fs_end$FS1.2) 

fs_end <- fs_end %>% mutate(FS7.9_1 = coalesce(FS7.9_1, FS7.9_1.0),
                            FS7.9_2 = coalesce(FS7.9_2, FS7.9_2.0),
                            FS7.9_3 = coalesce(FS7.9_3, FS7.9_3.0)) %>% 
  select(-c(FS7.9_1.0, FS7.9_2.0, FS7.9_3.0))

fs_end <- fs_end %>% mutate(FS7.10_1 = coalesce(FS7.10_1, FS7.10_1.0),
                            FS7.10_2 = coalesce(FS7.10_2, FS7.10_2.0),
                            FS7.10_3 = coalesce(FS7.10_3, FS7.10_3.0)) %>% 
  select(-c(FS7.10_1.0, FS7.10_2.0, FS7.10_3.0))

fs_end <- fs_end %>% mutate(A1_FS9.7_1 = coalesce(A1_FS9.7_1, A1_FE9.9_1),
                            A1_FS9.7_2 = coalesce(A1_FS9.7_2, A1_FE9.9_2),
                            A1_FS9.7_3 = coalesce(A1_FS9.7_3, A1_FE9.9_3),
                            A19_FS9.7_1 = coalesce(A19_FS9.7_1, A19_FE9.9_1),
                            A19_FS9.7_2 = coalesce(A19_FS9.7_2, A19_FE9.9_2),
                            A19_FS9.7_3 = coalesce(A19_FS9.7_3, A19_FE9.9_3))

fs_end <- fs_end %>% mutate(A1_FS9.8_1 = coalesce(A1_FS9.8_1, A1_FE9.10_1),
                            A1_FS9.8_2 = coalesce(A1_FS9.8_2, A1_FE9.10_2),
                            A1_FS9.8_3 = coalesce(A1_FS9.8_3, A1_FE9.10_3),
                            A19_FS9.8_1 = coalesce(A19_FS9.8_1, A19_FE9.10_1),
                            A19_FS9.8_2 = coalesce(A19_FS9.8_2, A19_FE9.10_2),
                            A19_FS9.8_3 = coalesce(A19_FS9.8_3, A19_FE9.10_3))

## Load merged youth survey (merged with Stata), change _ to . after survey tag to match .sav formatting

ys <- read_sav("data/youth_survey_merged.sav") %>% 
  filter(cqp == 1) %>% 
  select(tidyselect::vars_select(names(.), -matches(c('A1', 'A4', 'A5', 'A6', 'A7', 'F1', 'F2', 'F3', 'FS')))) %>% 
  rename_all(~stringr::str_replace(., "^YS10_", "YS10.")) %>% 
  rename_all(~stringr::str_replace(., "^YS1_", "YS1.")) %>% 
  rename_all(~stringr::str_replace(., "^YS2_", "YS2.")) %>% 
  rename_all(~stringr::str_replace(., "^YS3_", "YS3.")) %>% 
  rename_all(~stringr::str_replace(., "^YS4_", "YS4.")) %>% 
  rename_all(~stringr::str_replace(., "^YS5_", "YS5.")) %>% 
  rename_all(~stringr::str_replace(., "^YS6_", "YS6.")) %>% 
  rename_all(~stringr::str_replace(., "^YS7_", "YS7.")) %>% 
  rename_all(~stringr::str_replace(., "^YS8_", "YS8.")) %>% 
  rename_all(~stringr::str_replace(., "^YS9_", "YS9.")) %>% 
  rename_all(~stringr::str_replace(., "^YE10_", "YE10.")) %>% 
  rename_all(~stringr::str_replace(., "^YE1_", "YE1.")) %>% 
  rename_all(~stringr::str_replace(., "^YE2_", "YE2.")) %>% 
  rename_all(~stringr::str_replace(., "^YE3_", "YE3.")) %>% 
  rename_all(~stringr::str_replace(., "^YE4_", "YE4.")) %>% 
  rename_all(~stringr::str_replace(., "^YE5_", "YE5.")) %>% 
  rename_all(~stringr::str_replace(., "^YE6_", "YE6.")) %>% 
  rename_all(~stringr::str_replace(., "^YE7_", "YE7.")) %>% 
  rename_all(~stringr::str_replace(., "^YE8_", "YE8.")) %>% 
  rename_all(~stringr::str_replace(., "^YE9_", "YE9.")) %>%
  mutate(IDYouth = as.numeric(str_remove(IDYouth, 'CQP')))

# append supplementary skills questions using custom coalesce function (coalesce_join)

ys_end_supp <- read_sav("data/source/Enquête+des+jeunes+-+endline+-+supplementaire_November+18,+2021_22.23.sav")

ys_end_supp <- ys_end_supp %>% 
  filter(YE1.2 == 1) %>% 
  rename("IDYouth"= YE1.3) %>% 
  select("IDYouth", tidyselect::vars_select(names(ys_end_supp), matches(c("YE4", "YE5"))))

ys <- suppressMessages(coalesce_join(ys, ys_end_supp, b = "IDYouth"))

# recode ys endline competency questions
ys <- ys %>% mutate_at(vars(matches('YE5')), recode, `2` = 0)

## match to tot_selected to add number of CQP applicants (from dossiers) and, most importantly, number of apprentices SELECTED

selected <- read_excel("data/selected_new.xls") %>% 
  rename("dossier_apps" = apps,
         "dossier_reserves" = res,
         "dossier_selected" = sel)

fs <- fs %>% left_join(selected, by = c("FS1.2" = "IDPatron"))

# save cleaned data
save(fs, file = "data/fs.rda")
save(fs_end, file = "data/fs_end.rda")
save(ys, file = "data/ys.rda")

rm(list = ls())



