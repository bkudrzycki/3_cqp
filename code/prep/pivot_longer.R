########################################
## Reshape data: 1 row, 1 apprentice  ##
########################################

## 0 - Load libraries, packages and data

# Package names
packages <- c("haven", "tidyverse", "labelled")

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

load("data/fs.rda")
load("data/fs_end.rda")

# Functions
source("functions/strip_tags.R")

## 1 - Reshape data for CQP applicants

# strip prefix identifying loop and combine data for apprentices (up to 3 per master)
df1 <- strip_tags("FS1.8_1", "A1_FS9", fs) %>% rename_all(~stringr::str_replace(., "^A1_", "")) %>% rename(IDYouth = FS1.8_1) %>% 
  select(tidyselect::vars_select(names(.), -matches(c('FS1.6', 'FS1.9'))))
df2 <- strip_tags("FS1.8_4", "A4_FS9", fs) %>% rename_all(~stringr::str_replace(., "^A4_", "")) %>% rename(IDYouth = FS1.8_4) %>% 
  select(tidyselect::vars_select(names(.), -matches(c('FS1.6', 'FS1.9'))))
df3 <- strip_tags("FS1.8_5", "A5_FS9", fs) %>% rename_all(~stringr::str_replace(., "^A5_", "")) %>% rename(IDYouth = FS1.8_5) %>% 
  select(tidyselect::vars_select(names(.), -matches(c('FS1.6', 'FS1.9'))))
df4 <- strip_tags("FS1.8_6", "A6_FS9", fs) %>% rename_all(~stringr::str_replace(., "^A6_", "")) %>% rename(IDYouth = FS1.8_6) %>% 
  select(tidyselect::vars_select(names(.), -matches(c('FS1.6', 'FS1.9'))))
suppressWarnings(df5 <- strip_tags("FS1.8_7", "A7_FS9", fs) %>% rename_all(~stringr::str_replace(., "^A7_", "")) %>% rename(IDYouth = FS1.8_7) %>% select(tidyselect::vars_select(names(.), -matches(c('FS1.6', 'FS1.9')))))

# combine with FS8 questions (when master only trained a single cqp apprentice)
df6 <- fs %>% select(tidyselect::vars_select(names(fs), matches(c('FS1.2', 'FS1.5', 'FS8', 'wave', 'FS1.6')), -matches('TEXT'))) %>% 
  rename(FS8.2x = FS8.3) %>%  #rename the two questions that were flipped for FS8 and FS9
  rename(FS8.3 = FS8.2) %>% 
  rename(FS8.2 = FS8.2x) %>% 
  rename_all(~stringr::str_replace(., "FS8", "FS9")) %>% 
  rename(IDYouth = FS1.5) %>% 
  select(tidyselect::vars_select(names(.), -matches(c('FS1.6', 'FS1.9')))) %>% 
  filter(FS9.1 == 4) # filter "I don't train an apprentice by this name" responses

# combine into single dataframe
base_cqps <- rbind(df1, df2, df3, df4, df5, df6) %>% filter(!is.na(FS9.1)) %>% filter(!is.na(IDYouth)) %>% 
  left_join(fs, by = c('FS1.2')) %>% 
  select(tidyselect::vars_select(names(.), -matches(c('A1', 'A3', 'A4', 'A5', 'A6', 'A7', 'FS8')))) %>% 
  mutate(wave = 0)

# repeat for endline data

# strip prefix identifying loop and combine data for apprentices (up to 2 per master)
df1 <- strip_tags("FE1.4_1_1_1", "A1_", fs_end) %>% rename_all(~stringr::str_replace(., "^A1_", "")) %>% rename(IDYouth = FE1.4_1_1_1)
df2 <- strip_tags("FE1.4_1_2_1", "A19_", fs_end) %>% rename_all(~stringr::str_replace(., "^A19_", "")) %>% rename(IDYouth = FE1.4_1_2_1)

# combine into single dataframe
end_cqps <- rbind(df1, df2) %>% filter(FE9.1 != 3, FE9.1 != 6, !is.na(IDYouth)) %>% 
  left_join(fs_end, by = 'FS1.2') %>% 
  select(tidyselect::vars_select(names(.), -matches(c('A1', 'A19')))) %>% 
  mutate(wave = 1)

## bit of cleaning: delete two doubles which Olayidé typed in twice (as cqp and non-cqp apprentice, both of which are wrong)
end_cqps <- end_cqps %>% filter(!(IDYouth == 392 & FS1.2 == 94)) %>% 
  filter(!(IDYouth == 430 & FS1.2 == 111)) # and a youth who showed up in two firms. keep obs. which matches firm from baseline

rm(df1, df2, df3, df4, df5, df6)


# 3 - Match apprentices who didn't apply for CQP (i.e. non-CQPs or traditional apprentices)

# slightly modified function that subsets data for one apprentice at a time
ToNumeric <- function(x) (as.numeric(as.character(x)))

strip_tags2 <- function(idvar, prefix, data) {
  df <- data %>% select(tidyselect::vars_select(names(data), matches(c('FS1.2', 'wave', {{idvar}}, {{prefix}})), -matches('TEXT'))) %>% 
    mutate_at(vars(-{{idvar}}), ToNumeric)
  return(df)
}

# strip baseline data
suppressWarnings(df1 <- strip_tags2("FS6.19_1", "A1_FS7",  fs) %>% rename_all(~stringr::str_replace(., "^A1_", "")) %>% rename(Name = FS6.19_1) %>% select(-"FS6.19_1___Topics"))
df2 <- strip_tags2("FS6.19_3", "A3_FS7", fs) %>% rename_all(~stringr::str_replace(., "^A3_", "")) %>% rename(Name = FS6.19_3)
df3 <- strip_tags2("FS6.19_4", "A4_FS7", fs) %>% rename_all(~stringr::str_replace(., "^A4_", "")) %>% rename(Name = FS6.19_4)
df4 <- strip_tags2("FS6.19_5", "A5_FS7", fs) %>% rename_all(~stringr::str_replace(., "^A5_", "")) %>% rename(Name = FS6.19_5)
df5 <- strip_tags2("FS6.19_6", "A6_FS7", fs) %>% rename_all(~stringr::str_replace(., "^A6_", "")) %>% rename(Name = FS6.19_6)

# combine
base_trad <- rbind(df1, df2, df3, df4, df5) %>% filter(!is.na(FS7.1) & Name != "" & Name != 9999) %>% 
  left_join(fs, by = c('FS1.2')) %>% 
  select(tidyselect::vars_select(names(.), -matches(c('A1', 'A3', 'A4', 'A5', 'A6', 'A7')))) %>% 
  mutate(IDYouth = row_number()+1000) %>%
  select(IDYouth, Name, everything()) %>% 
  mutate(wave = 0,
         SELECTED = 3)

# strip endline data (single row - questions were asked for a single traditional apprentice only at endline)
df <- fs_end %>% select(tidyselect::vars_select(names(fs_end), matches(c('FS1.2', 'FE1.5', 'FE7', 'FS7')), -matches('TEXT'))) %>% rename(Name = FE1.5) %>% 
  filter(Name != "" & Name != 9999 & Name != "Aucun" & Name != "Aucune")

end_trad <- df %>% mutate(IDYouth = as.numeric(NA)) %>%
  filter(FE7.2 != 3, FE7.2 != 6) %>% 
  left_join(fs_end %>% select(tidyselect::vars_select(names(fs_end), -matches(c('TEXT', 'FE7', 'FS7')))), by = c('FS1.2')) %>% 
  select(tidyselect::vars_select(names(.), -matches(c('A1', 'A19')))) %>% 
  select(IDYouth, Name, everything()) %>% 
  mutate(wave = 1,
         SELECTED = 3)

# match to baseline manually (similar name / same trainer)
end_trad <- end_trad %>% mutate(
  IDYouth = IDYouth %>% recode_if(FS1.2 == 3, 1010),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 5, 1007),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 8, 1111),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 11, 1084),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 15, 1056),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 25, 1116),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 27, 1143),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 28, 1083),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 30, 1132),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 33, 1027),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 35, 1005),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 40, 1136),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 43, 1080),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 44, 1024),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 48, 1023),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 51, 1093),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 57, 1094),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 58, 1062),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 72, 1152),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 75, 1128),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 87, 1021),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 117, 1022),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 123, 1114),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 125, 1051),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 128, 1053),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 129, 1052),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 130, 1045),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 131, 1015),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 132, 1115),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 138, 1058),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 139, 1144),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 140, 1044),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 142, 1090), 
  IDYouth = IDYouth %>% recode_if(FS1.2 == 145, 1145),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 146, 1043),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 147, 1122),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 148, 1146),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 149, 1100),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 150, 1135),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 154, 1059),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 155, 1121),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 158, 1042),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 160, 1134),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 161, 1049),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 162, 1050),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 163, 1120),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 164, 1065),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 165, 1060),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 170, 1099),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 171, 1048),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 172, 1103),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 177, 1101),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 178, 1148),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 179, 1133),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 181, 1147),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 184, 1070),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 188, 1066),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 192, 1068),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 194, 1142),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 196, 1127),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 198, 1112),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 199, 1014),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 201, 1012),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 202, 1087),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 206, 1130),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 207, 1141),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 212, 1067),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 215, 1013),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 219, 1159),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 1000, 1113),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 2000, 1123),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 2001, 1063),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 4002, 1071),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 4003, 1072),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 4004, 1129),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 4006, 1073),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 5000, 1138),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 5006, 1055),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 5007, 1054),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 6004, 1109),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 7007, 1149),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 7008, 1061),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 8000, 1004),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 8001, 1057),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 8002, 1064),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 9005, 1105),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 9008, 1076),
  IDYouth = IDYouth %>% recode_if(FS1.2 == 9012, 1108)
)

base_cqps <- base_cqps %>% zap_labels()
base_trad <- base_trad %>% zap_labels()
end_cqps <- end_cqps %>% zap_labels()
end_trad <- end_trad %>% zap_labels()

save(base_cqps, file = "data/base_cqps.rda")
save(base_trad, file = "data/base_trad.rda")
save(end_cqps, file = "data/end_cqps.rda")
save(end_trad, file = "data/end_trad.rda")

rm(list = ls())


