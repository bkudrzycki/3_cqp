######################################
## 0 - Load libraries and packages  ##
######################################

# Package names
packages <- c("haven", "tidyverse", "labelled")
#detach(package:here, unload=TRUE)

# Install packages not yet installed
installed_packages <- packages %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  install.packages(packages[!installed_packages], silent = TRUE)
}

# Packages loading
invisible(lapply(packages, library, character.only = TRUE))

rm(packages, installed_packages)

#load survey

fs <- read_sav("/Users/kudrzycb/polybox/Youth Employment/1a Youth Survey/Paper/Analysis/Data/Source/Enquête+auprès+des+patrons_February+10,+2020_13.28.sav", user_na = TRUE)
fs_labels <- haven::as_factor(fs)

fs_end <- read_sav("/Users/kudrzycb/polybox/Youth Employment/1a Youth Survey/Paper/Analysis/Data/Source/Enquête+auprès+des+patrons+-+endline_October+6,+2021_12.12.sav", user_na = TRUE)
fs_end_labels <- haven::as_factor(fs_end)

# we need IDs for every CQP apprentice



##############################
## 1 - Calculate  benefits  ##
##############################

# 1.1 PRODUCTIVITY #

#recode baseline wages
wages <- fs %>% select(tidyselect::vars_select(names(fs), matches("FS5.2_1"))) %>%
  mutate_at(vars(matches('FS5.2_1')), recode, `1` = 0, `2` = 2500, `3` = 7500, `4` = 15000, `5` = 27500, `6` = 45000, `7` = 67500, `8` = 95000, `9` = 130000, `10` = 175000, `11` = 225000) %>% 
  mutate_at(vars(matches('FS5.2_1')), na_if, 12) %>% 
  mutate_at(vars(matches('FS5.2_1')), na_if, 13)

#to minimize NAs we use coalesce (first non-NA option from left to right)
wages <- wages %>% mutate(app_wages_low = coalesce(FS5.2_1_5, FS5.2_1_4, FS5.2_1_6), #paid family workers, primary school only, occasional workers
                          app_wages_high = coalesce(FS5.2_1_2, FS5.2_1_1, FS5.2_1_3)) #completed apprenticeship at same workshop, other workshop, secondary or university education

#recode highs and lows
wages_lows <- fs %>% select(tidyselect::vars_select(names(fs), matches("FS5.2_1"))) %>%
  mutate_at(vars(matches('FS5.2_1')), recode, `1` = 0, `2` = 0, `3` = 5000, `4` = 10000, `5` = 20000, `6` = 35000, `7` = 55000, `8` = 80000, `9` = 110000, `10` = 150000, `11` = 200000) %>% 
  mutate_at(vars(matches('FS5.2_1')), na_if, 12) %>% 
  mutate_at(vars(matches('FS5.2_1')), na_if, 13)

wages_highs <- fs %>% select(tidyselect::vars_select(names(fs), matches("FS5.2_1"))) %>%
  mutate_at(vars(matches('FS5.2_1')), recode, `1` = 0, `2` = 5000, `3` = 10000, `4` = 20000, `5` = 35000, `6` = 55000, `7` = 80000, `8` = 110000, `9` = 150000, `10` = 200000, `11` = 250000) %>% 
  mutate_at(vars(matches('FS5.2_1')), na_if, 12) %>% 
  mutate_at(vars(matches('FS5.2_1')), na_if, 13)

# 1.2 FEES #

## recode baseline fees questions
df <- fs %>% 
  select(tidyselect::vars_select(names(fs), matches(c('FS7.9', 'FS7.10', 'FS8.7', 'FS8.8', 'FS9.7', 'FS9.8')))) %>% 
  mutate_at(vars(matches(c('FS7.9', 'FS8.7', 'FS9.7'))), recode, `1` = 0, `2` = 5000, `3` = 15000, `4` = 27500, `5` = 45000, `6` = 70000, `7` = 105000, `8` = 150000, `9` = 212500, `10` = 300000, `11` = 425000) %>% 
  mutate_at(vars(matches('FS7.9')), na_if, 12) %>% 
  mutate_at(vars(matches(c('FS7.10', 'FS8.8', 'FS9.8'))), recode, `1` = 0, `2` = 1500, `3` = 3750, `4` = 6000, `5` = 8500, `6` = 12500, `7` = 20000, `8` = 32500, `9` = 52500, `10` = 82500, `11` = 135000) %>% 
  mutate_at(vars(matches('FS7.10')), na_if, 12)

fees <- data.frame("entry_fee" = matrix(NA, nrow = nrow(df), ncol = 1))
                   
fees$entry_fee <- df %>% select(tidyselect::vars_select(names(df), matches(c('9_1', '7_1')))) %>% 
  rowMeans(., na.rm = T)

fees$training_fee <- df %>% select(tidyselect::vars_select(names(df), matches(c('9_2', '7_2')))) %>% 
  rowMeans(., na.rm = T)

fees$graduation_fee <- df %>% select(tidyselect::vars_select(names(df), matches(c('9_3', '7_3')))) %>% 
  rowMeans(., na.rm = T)

fees$materials_fee <- df %>% select(tidyselect::vars_select(names(df), matches(c('10_1', '8_1')))) %>% 
  rowMeans(., na.rm = T)

fees$contract_fee <- df %>% select(tidyselect::vars_select(names(df), matches(c('10_2', '8_2')))) %>% 
  rowMeans(., na.rm = T)

fees$dossier_fee <- df %>% select(tidyselect::vars_select(names(df), matches(c('10_3', '8_3')))) %>% 
  rowMeans(., na.rm = T)

#recode lows

df <- fs %>% 
  select(tidyselect::vars_select(names(fs), matches(c('FS7.9', 'FS7.10', 'FS8.7', 'FS8.8', 'FS9.7', 'FS9.8')))) %>% 
  mutate_at(vars(matches(c('FS7.9', 'FS8.7', 'FS9.7'))), recode, `1` = 0, `2` = 0, `3` = 10000, `4` = 20000, `5` = 35000, `6` = 55000, `7` = 85000, `8` = 125000, `9` = 175000, `10` = 250000, `11` = 350000) %>% 
  mutate_at(vars(matches('FS7.9')), na_if, 12) %>% 
  mutate_at(vars(matches(c('FS7.10', 'FS8.8', 'FS9.8'))), recode, `1` = 0, `2` = 0, `3` = 3000, `4` = 5000, `5` = 7000, `6` = 10000, `7` = 15000, `8` = 25000, `9` = 40000, `10` = 65000, `11` = 100000) %>% 
  mutate_at(vars(matches('FS7.10')), na_if, 12)

fees_low <- data.frame("entry_fee" = matrix(NA, nrow = nrow(df), ncol = 1))

fees_low$entry_fee <- df %>% select(tidyselect::vars_select(names(df), matches(c('9_1', '7_1')))) %>% 
  rowMeans(., na.rm = T)

fees_low$training_fee <- df %>% select(tidyselect::vars_select(names(df), matches(c('9_2', '7_2')))) %>% 
  rowMeans(., na.rm = T)

fees_low$graduation_fee <- df %>% select(tidyselect::vars_select(names(df), matches(c('9_3', '7_3')))) %>% 
  rowMeans(., na.rm = T)

fees_low$materials_fee <- df %>% select(tidyselect::vars_select(names(df), matches(c('10_1', '8_1')))) %>% 
  rowMeans(., na.rm = T)

fees_low$contract_fee <- df %>% select(tidyselect::vars_select(names(df), matches(c('10_2', '8_2')))) %>% 
  rowMeans(., na.rm = T)

fees_low$dossier_fee <- df %>% select(tidyselect::vars_select(names(df), matches(c('10_3', '8_3')))) %>% 
  rowMeans(., na.rm = T)

# recode highs

df <- fs %>% 
  select(tidyselect::vars_select(names(fs), matches(c('FS7.9', 'FS7.10', 'FS8.7', 'FS8.8', 'FS9.7', 'FS9.8')))) %>% 
  mutate_at(vars(matches(c('FS7.9', 'FS8.7', 'FS9.7'))), recode, `1` = 0, `2` = 10000, `3` = 20000, `4` = 35000, `5` = 55000, `6` = 85000, `7` = 125000, `8` = 175000, `9` = 250000, `10` = 350000, `11` = 500000) %>%
  mutate_at(vars(matches('FS7.9')), na_if, 11) %>% 
  mutate_at(vars(matches('FS7.9')), na_if, 12) %>% 
  mutate_at(vars(matches(c('FS7.10', 'FS8.8', 'FS9.8'))), recode, `1` = 0, `2` = 3000, `3` = 5000, `4` = 7000, `5` = 10000, `6` = 15000, `7` = 25000, `8` = 40000, `9` = 65000, `10` = 100000, `11` = 170000) %>% 
  mutate_at(vars(matches('FS7.10')), na_if, 12)

fees_high <- data.frame("entry_fee" = matrix(NA, nrow = nrow(df), ncol = 1))

fees_high$entry_fee <- df %>% select(tidyselect::vars_select(names(df), matches(c('9_1', '7_1')))) %>% 
  rowMeans(., na.rm = T)

fees_high$training_fee <- df %>% select(tidyselect::vars_select(names(df), matches(c('9_2', '7_2')))) %>% 
  rowMeans(., na.rm = T)

fees_high$graduation_fee <- df %>% select(tidyselect::vars_select(names(df), matches(c('9_3', '7_3')))) %>% 
  rowMeans(., na.rm = T)

fees_high$materials_fee <- df %>% select(tidyselect::vars_select(names(df), matches(c('10_1', '8_1')))) %>% 
  rowMeans(., na.rm = T)

fees_high$contract_fee <- df %>% select(tidyselect::vars_select(names(df), matches(c('10_2', '8_2')))) %>% 
  rowMeans(., na.rm = T)

fees_high$dossier_fee <- df %>% select(tidyselect::vars_select(names(df), matches(c('10_3', '8_3')))) %>% 
  rowMeans(., na.rm = T)

# 1.3 Skills #

# 1.3.1 Change in competencies between baseline and endline from Masters' perspective #

# baseline competencies

df <- fs %>% 
  select(tidyselect::vars_select(names(fs), matches(c('FS7.14', 'FS7.15', 'FS7.16', 'FS7.17', 'FS7.18', 'FS8.12', 'FS8.13', 'FS8.14', 'FS8.15', 'FS8.16', 'FS9.12', 'FS9.13', 'FS9.14', 'FS9.15', 'FS9.16')))) %>% 
  mutate_all(recode, `2` = 0)

competencies <- data.frame(elec = rep(NA, nrow(df)))

competencies$elec <- df %>% select(tidyselect::vars_select(names(df), matches('FS7.14_1', 'FS8.12_1', 'FS9.12_1'))) %>% 
  rowMeans(., na.rm = T)

competencies$macon <- df %>% select(tidyselect::vars_select(names(df), matches('FS7.15_1', 'FS8.13_1', 'FS9.13_1'))) %>% 
  rowMeans(., na.rm = T)

competencies$menuis<- df %>% select(tidyselect::vars_select(names(df), matches('FS7.16_1', 'FS8.14_1', 'FS9.14_1'))) %>% 
  rowMeans(., na.rm = T)

competencies$plomb <- df %>% select(tidyselect::vars_select(names(df), matches('FS7.17_1', 'FS8.15_1', 'FS9.15_1'))) %>% 
  rowMeans(., na.rm = T)

competencies$metal <- df %>% select(tidyselect::vars_select(names(df), matches('FS7.18_1', 'FS8.16_1', 'FS9.16_1'))) %>% 
  rowMeans(., na.rm = T)


# baseline experience (has done task at least once)

experience <- data.frame(elec = rep(NA, nrow(df)))

experience$elec <- df %>% select(tidyselect::vars_select(names(df), matches('FS7.14_2', 'FS8.12_2', 'FS9.12_2'))) %>% 
  rowMeans(., na.rm = T)

experience$macon <- df %>% select(tidyselect::vars_select(names(df), matches('FS7.15_2', 'FS8.13_2', 'FS9.13_2'))) %>% 
  rowMeans(., na.rm = T)

experience$menuis<- df %>% select(tidyselect::vars_select(names(df), matches('FS7.16_2', 'FS8.14_2', 'FS9.14_2'))) %>% 
  rowMeans(., na.rm = T)

experience$plomb <- df %>% select(tidyselect::vars_select(names(df), matches('FS7.17_2', 'FS8.15_2', 'FS9.15_2'))) %>% 
  rowMeans(., na.rm = T)

experience$metal <- df %>% select(tidyselect::vars_select(names(df), matches('FS7.18_2', 'FS8.16_2', 'FS9.16_2'))) %>% 
  rowMeans(., na.rm = T)

as.data.frame(cbind(comp = colMeans(competencies, na.rm = T), exp = colMeans(experience, na.rm = T))) %>% 
  rownames_to_column(., "trade") %>% 
  pivot_longer(cols = c("comp", "exp")) %>% group_by(name, trade) %>% ggplot(aes(x = trade, fill = name)) + geom_bar(aes(y = value),  stat = "identity", position = "dodge") + labs(x = "", y = "% of apprentices")

# endline competencies

df <- fs_end %>% 
  select(tidyselect::vars_select(names(fs_end), matches(c('FS7.14', 'FS7.15', 'FS7.16', 'FS7.17', 'FS7.18', 'FS9.12', 'FS9.13', 'FS9.14', 'FS9.15', 'FS9.16')))) %>% 
  mutate_all(recode, `2` = 0)

end_competencies <- data.frame(elec = rep(NA, nrow(df)))

end_competencies$elec <- df %>% select(tidyselect::vars_select(names(df), matches('FS7.14_1', 'FS9.12_1'))) %>% 
  rowMeans(., na.rm = T)

end_competencies$macon <- df %>% select(tidyselect::vars_select(names(df), matches('FS7.15_1', 'FS9.13_1'))) %>% 
  rowMeans(., na.rm = T)

end_competencies$menuis<- df %>% select(tidyselect::vars_select(names(df), matches('FS7.16_1', 'FS9.14_1'))) %>% 
  rowMeans(., na.rm = T)

end_competencies$plomb <- df %>% select(tidyselect::vars_select(names(df), matches('FS7.17_1', 'FS9.15_1'))) %>% 
  rowMeans(., na.rm = T)

end_competencies$metal <- df %>% select(tidyselect::vars_select(names(df), matches('FS7.18_1', 'FS9.16_1'))) %>% 
  rowMeans(., na.rm = T)

# endline experience

end_experience <- data.frame(elec = rep(NA, nrow(df)))

end_experience$elec <- df %>% select(tidyselect::vars_select(names(df), matches('FS7.14_2', 'FS9.12_2'))) %>% 
  rowMeans(., na.rm = T)

end_experience$macon <- df %>% select(tidyselect::vars_select(names(df), matches('FS7.15_2', 'FS9.13_2'))) %>% 
  rowMeans(., na.rm = T)

end_experience$menuis<- df %>% select(tidyselect::vars_select(names(df), matches('FS7.16_2', 'FS9.14_2'))) %>% 
  rowMeans(., na.rm = T)

end_experience$plomb <- df %>% select(tidyselect::vars_select(names(df), matches('FS7.17_2', 'FS9.15_2'))) %>% 
  rowMeans(., na.rm = T)

end_experience$metal <- df %>% select(tidyselect::vars_select(names(df), matches('FS7.18_2', 'FS9.16_2'))) %>% 
  rowMeans(., na.rm = T)


# 1.3.2 changes in skills by apprenticeship type

y <- fs %>% select(tidyselect::vars_select(names(fs), matches(c('FS1_2', 'FS8.2','FS8.12', 'FS8.13', 'FS8.14', 'FS8.15', 'FS8.16')))) 

df <- fs %>% select(tidyselect::vars_select(names(fs), matches(c('FS1_2', 'FS7.4', 'FS7.14', 'FS7.15', 'FS7.16', 'FS7.17', 'FS7.18')))) 

A1 <- df %>% 
  select(tidyselect::vars_select(names(.), matches(c('A1'))))
names(A1) <- sub('^A1_', '', names(A1))
A3 <- df %>% 
  select(tidyselect::vars_select(names(.), matches(c('A3'))))
names(A3) <- sub('^A3_', '', names(A3))
A4 <- df %>% 
  select(tidyselect::vars_select(names(.), matches(c('A4'))))
names(A4) <- sub('^A4_', '', names(A4))
A5 <- df %>% 
  select(tidyselect::vars_select(names(.), matches(c('A5'))))
names(A5) <- sub('^A5_', '', names(A5))
A6 <- df %>% 
  select(tidyselect::vars_select(names(.), matches(c('A6'))))
names(A6) <- sub('^A6_', '', names(A6))


x <- rbind(A1, A3, A4, A5, A6) %>% filter(!is.na(FS7.4))


df <- fs %>% select(tidyselect::vars_select(names(fs), matches(c('FS1_2', 'FS9.3', 'FS9.12', 'FS9.13', 'FS9.14', 'FS9.15', 'FS9.16')))) 

A1 <- df %>% 
  select(tidyselect::vars_select(names(.), matches(c('A1'))))
names(A1) <- sub('^A1_', '', names(A1))
A4 <- df %>% 
  select(tidyselect::vars_select(names(.), matches(c('A4'))))
names(A4) <- sub('^A4_', '', names(A4))
A5 <- df %>% 
  select(tidyselect::vars_select(names(.), matches(c('A5'))))
names(A5) <- sub('^A5_', '', names(A5))
A6 <- df %>% 
  select(tidyselect::vars_select(names(.), matches(c('A6'))))
names(A6) <- sub('^A6_', '', names(A6))
A7 <- df %>% 
  select(tidyselect::vars_select(names(.), matches(c('A7'))))
names(A7) <- sub('^A7_', '', names(A7))

z <- rbind(A1, A4, A5, A6, A7) %>% filter(!is.na(FS9.3))

apps <- as.data.frame(rbind(as.matrix(x), as.matrix(y), as.matrix(z))) %>%
  select(!contains("TEXT")) %>% 
  mutate_all(., function(x) as.numeric(as.character(x)))


apps$elec_score <- apps %>% select(tidyselect::vars_select(names(.), matches(c('7.14')))) %>% mutate_all(recode, `2` = 0) %>% rowMeans(., na.rm = T)
apps$macon_score <- apps %>% select(tidyselect::vars_select(names(.), matches(c('7.15')))) %>% mutate_all(recode, `2` = 0) %>% rowMeans(., na.rm = T)
apps$menuis_score <- apps %>% select(tidyselect::vars_select(names(.), matches(c('7.16')))) %>% mutate_all(recode, `2` = 0) %>% rowMeans(., na.rm = T)
apps$plomb_score <- apps %>% select(tidyselect::vars_select(names(.), matches(c('7.17')))) %>% mutate_all(recode, `2` = 0) %>% rowMeans(., na.rm = T)
apps$metal_score <- apps %>% select(tidyselect::vars_select(names(.), matches(c('7.18')))) %>% mutate_all(recode, `2` = 0) %>% rowMeans(., na.rm = T)



x <- fs_end %>% select(tidyselect::vars_select(names(fs_end), matches(c('FS1.2', 'FS7.4', 'FS7.14', 'FS7.15', 'FS7.16', 'FS7.17', 'FS7.18')))) 

df <- fs_end %>% select(tidyselect::vars_select(names(fs_end), matches(c('FS1.2', 'FS9.3', 'FS9.12', 'FS9.13', 'FS9.14', 'FS9.15', 'FS9.16')))) 

A1 <- df %>% 
  select('FS1.2', tidyselect::vars_select(names(.), matches(c('A1_'))))
names(A1) <- sub('^A1_', '', names(A1))
A19 <- df %>% 
  select('FS1.2', tidyselect::vars_select(names(.), matches(c('A19'))))
names(A19) <- sub('^A19_', '', names(A19))

y <- rbind(A1, A19) %>% filter(!is.na(FS9.3))

apps_end <- as.data.frame(rbind(as.matrix(x), as.matrix(y))) %>%
  select(!contains("TEXT")) %>% 
  mutate_all(., function(x) as.numeric(as.character(x)))


apps_end$elec_score <- apps_end %>% select(tidyselect::vars_select(names(.), matches(c('7.14')))) %>% mutate_all(recode, `2` = 0) %>% rowMeans(., na.rm = T)
apps_end$macon_score <- apps_end %>% select(tidyselect::vars_select(names(.), matches(c('7.15')))) %>% mutate_all(recode, `2` = 0) %>% rowMeans(., na.rm = T)
apps_end$menuis_score <- apps_end %>% select(tidyselect::vars_select(names(.), matches(c('7.16')))) %>% mutate_all(recode, `2` = 0) %>% rowMeans(., na.rm = T)
apps_end$plomb_score <- apps_end %>% select(tidyselect::vars_select(names(.), matches(c('7.17')))) %>% mutate_all(recode, `2` = 0) %>% rowMeans(., na.rm = T)
apps_end$metal_score <- apps_end %>% select(tidyselect::vars_select(names(.), matches(c('7.18')))) %>% mutate_all(recode, `2` = 0) %>% rowMeans(., na.rm = T)



x <- apps_end %>% select(FS7.4, elec_score, macon_score, menuis_score, plomb_score, metal_score) %>% mutate(app_type = ifelse(FS7.4 == 3, "CQP", "CQM/Traditional"))




rm(A1, A3, A4, A5, A6, A7, A19, x, y, z)

# Skills #

merged <- read_sav("/Users/kudrzycb/Desktop/Endline_analysis_new/endline_merged.sav", user_na = TRUE) %>% 
  filter(YS1_2 == 1)
endline_labels <- haven::as_factor(merged) %>% filter(YS1_2=="Yes")

# metalworkers

df <- merged %>% 
  select(YE4_1, YS5_1, SELECTED) %>% 
  pivot_longer(cols = YE4_1:YS5_1, names_to = "Year") %>% 
  filter(!is.na(value))

df$Year <- recode(df$Year, "YS5_1" = "2018", "YE4_1" = "2021")
df$correct <- ifelse(df$value == 2, 1, 0)

df$question <- "YS5_1"
df$trade <- "metal"

df2 <- merged %>% 
  select(YE4_2, YS5_2, SELECTED) %>% 
  pivot_longer(cols = YE4_2:YS5_2, names_to = "Year") %>% 
  filter(!is.na(value))

df2$Year <- recode(df2$Year, "YS5_2" = "2018", "YE4_2" = "2021")
df2$correct <- ifelse(df2$value == 1, 1, 0)

df2$question <- "YS5_2"
df2$trade <- "metal"

df <- rbind(df, df2)

df2 <- merged %>% 
  select(YE4_3, YS5_3, SELECTED) %>% 
  pivot_longer(cols = YE4_3:YS5_3, names_to = "Year") %>% 
  filter(!is.na(value))

df2$Year <- recode(df2$Year, "YS5_3" = "2018", "YE4_3" = "2021")
df2$correct <- ifelse(df2$value == 3, 1, 0)

df2$question <- "YS5_3"
df2$trade <- "metal"

df <- rbind(df, df2)

df2 <- merged %>% 
  select(YE4_4, YS5_4, SELECTED) %>% 
  pivot_longer(cols = YE4_4:YS5_4, names_to = "Year") %>% 
  filter(!is.na(value))

df2$Year <- recode(df2$Year, "YS5_4" = "2018", "YE4_4" = "2021")
df2$correct <- ifelse(df2$value == 2, 1, 0)

df2$question <- "YS5_4"
df2$trade <- "metal"

df <- rbind(df, df2)

df2 <- merged %>% 
  select(YE4_5, YS5_5, SELECTED) %>% 
  pivot_longer(cols = YE4_5:YS5_5, names_to = "Year") %>% 
  filter(!is.na(value))

df2$Year <- recode(df2$Year, "YS5_5" = "2018", "YE4_5" = "2021")
df2$correct <- ifelse(df2$value == 2, 1, 0)

df2$question <- "YS5_5"
df2$trade <- "metal"

skills_metal <- rbind(df, df2)

# plumbers

df <- merged %>% 
  select(YE4_6, YS5_6, SELECTED) %>% 
  pivot_longer(cols = YE4_6:YS5_6, names_to = "Year") %>% 
  filter(!is.na(value))

df$Year <- recode(df$Year, "YS5_6" = "2018", "YE4_6" = "2021")
df$correct <- ifelse(df$value == 2, 1, 0)

df$question <- "YS5_6"
df$trade <- "plumb"

df2 <- merged %>% 
  select(YE4_7, YS5_7, SELECTED) %>% 
  pivot_longer(cols = YE4_7:YS5_7, names_to = "Year") %>% 
  filter(!is.na(value))

df2$Year <- recode(df2$Year, "YS5_7" = "2018", "YE4_7" = "2021")
df2$correct <- ifelse(df2$value == 1, 1, 0)

df2$question <- "YS5_7"
df2$trade <- "plumb"

df <- rbind(df, df2)

df2 <- merged %>% 
  select(YE4_8, YS5_8, SELECTED) %>% 
  pivot_longer(cols = YE4_8:YS5_8, names_to = "Year") %>% 
  filter(!is.na(value))

df2$Year <- recode(df2$Year, "YS5_8" = "2018", "YE4_8" = "2021")
df2$correct <- ifelse(df2$value == 2, 1, 0)

df2$question <- "YS5_8"
df2$trade <- "plumb"

df <- rbind(df, df2)


df2 <- merged %>% 
  select(YE4_9, YS5_9, SELECTED) %>% 
  pivot_longer(cols = YE4_9:YS5_9, names_to = "Year") %>% 
  filter(!is.na(value))

df2$Year <- recode(df2$Year, "YS5_9" = "2018", "YE4_9" = "2021")
df2$correct <- ifelse(df2$value == 2, 1, 0)

df2$question <- "YS5_9"
df2$trade <- "plumb"

skills_plumb <- rbind(df, df2)


# carpenters

df <- merged %>% 
  select(YE4_10, YS5_10, SELECTED) %>% 
  pivot_longer(cols = YE4_10:YS5_10, names_to = "Year") %>% 
  filter(!is.na(value))

df$Year <- recode(df$Year, "YS5_10" = "2018", "YE4_10" = "2021")
df$correct <- ifelse(df$value == 3, 1, 0)

df$question <- "YS5_10"
df$trade <- "carpenters"

df2 <- merged %>% 
  select(YE4_11, YS5_11, SELECTED) %>% 
  pivot_longer(cols = YE4_11:YS5_11, names_to = "Year") %>% 
  filter(!is.na(value))

df2$Year <- recode(df2$Year, "YS5_11" = "2018", "YE4_11" = "2021")
df2$correct <- ifelse(df2$value == 1, 1, 0)

df2$question <- "YS5_11"
df2$trade <- "carpenters"

df <- rbind(df, df2)

df2 <- merged %>% 
  select(YE4_12, YS5_12, SELECTED) %>% 
  pivot_longer(cols = YE4_12:YS5_12, names_to = "Year") %>% 
  filter(!is.na(value))

df2$Year <- recode(df2$Year, "YS5_12" = "2018", "YE4_12" = "2021")
df2$correct <- ifelse(df2$value == 4, 1, 0)

df2$question <- "YS5_12"
df2$trade <- "carpenters"

df <- rbind(df, df2)

df2 <- merged %>% 
  select(YE4_13, YS5_13, SELECTED) %>% 
  pivot_longer(cols = YE4_13:YS5_13, names_to = "Year") %>% 
  filter(!is.na(value))

df2$Year <- recode(df2$Year, "YS5_13" = "2018", "YE4_13" = "2021")
df2$correct <- ifelse(df2$value == 1, 1, 0)

df2$question <- "YS5_13"
df2$trade <- "carpenters"

skills_carpenters <- rbind(df, df2)

# masons

df <- merged %>% 
  select(YE4_14, YS5_14, SELECTED) %>% 
  pivot_longer(cols = YE4_14:YS5_14, names_to = "Year") %>% 
  filter(!is.na(value))

df$Year <- recode(df$Year, "YS5_14" = "2018", "YE4_14" = "2021")
df$correct <- ifelse(df$value == 4, 1, 0)

df$question <- "YS5_14"
df$trade <- "masons"

df2 <- merged %>% 
  select(YE4_15, YS5_15, SELECTED) %>% 
  pivot_longer(cols = YE4_15:YS5_15, names_to = "Year") %>% 
  filter(!is.na(value))

df2$Year <- recode(df2$Year, "YS5_15" = "2018", "YE4_15" = "2021")
df2$correct <- ifelse(df2$value == 1, 1, 0)

df2$question <- "YS5_15"
df2$trade <- "masons"

df <- rbind(df, df2)

df2 <- merged %>% 
  select(YE4_16, YS5_16, SELECTED) %>% 
  pivot_longer(cols = YE4_16:YS5_16, names_to = "Year") %>% 
  filter(!is.na(value))

df2$Year <- recode(df2$Year, "YS5_16" = "2018", "YE4_16" = "2021")
df2$correct <- ifelse(df2$value == 2, 1, 0)

df2$question <- "YS5_16"
df2$trade <- "masons"

df <- rbind(df, df2)

df2 <- merged %>% 
  select(YE4_18, YS5_18, SELECTED) %>% 
  pivot_longer(cols = YE4_18:YS5_18, names_to = "Year") %>% 
  filter(!is.na(value))

df2$Year <- recode(df2$Year, "YS5_18" = "2018", "YE4_18" = "2021")
df2$correct <- ifelse(df2$value == 2, 1, 0)

df2$question <- "YS5_18"
df2$trade <- "masons"

skills_masons <- rbind(df, df2)

# electricians

df <- merged %>% 
  select(YE4_19, YS5_19, SELECTED) %>% 
  pivot_longer(cols = YE4_19:YS5_19, names_to = "Year") %>% 
  filter(!is.na(value))

df$Year <- recode(df$Year, "YS5_19" = "2018", "YE4_19" = "2021")
df$correct <- ifelse(df$value == 2, 1, 0)

df$question <- "YS5_19"
df$trade <- "electr"

df2 <- merged %>% 
  select(YE4_20, YS5_20, SELECTED) %>% 
  pivot_longer(cols = YE4_20:YS5_20, names_to = "Year") %>% 
  filter(!is.na(value))

df2$Year <- recode(df2$Year, "YS5_20" = "2018", "YE4_20" = "2021")
df2$correct <- ifelse(df2$value == 3, 1, 0)

df2$question <- "YS5_20"
df2$trade <- "electr"

df <- rbind(df, df2)

df2 <- merged %>% 
  select(YE4_21, YS5_21, SELECTED) %>% 
  pivot_longer(cols = YE4_21:YS5_21, names_to = "Year") %>% 
  filter(!is.na(value))

df2$Year <- recode(df2$Year, "YS5_21" = "2018", "YE4_21" = "2021")
df2$correct <- ifelse(df2$value == 2, 1, 0)

df2$question <- "YS5_21"
df2$trade <- "electr"

df <- rbind(df, df2)

df2 <- merged %>% 
  select(YE4_22, YS5_22, SELECTED) %>% 
  pivot_longer(cols = YE4_22:YS5_22, names_to = "Year") %>% 
  filter(!is.na(value))

df2$Year <- recode(df2$Year, "YS5_22" = "2018", "YE4_22" = "2021")
df2$correct <- ifelse(df2$value == 1, 1, 0)

df2$question <- "YS5_22"
df2$trade <- "electr"

df <- rbind(df, df2)

df2 <- merged %>% 
  select(YE4_23, YS5_23, SELECTED) %>% 
  pivot_longer(cols = YE4_23:YS5_23, names_to = "Year") %>% 
  filter(!is.na(value))

df2$Year <- recode(df2$Year, "YS5_23" = "2018", "YE4_23" = "2021")
df2$correct <- ifelse(df2$value == 1, 1, 0)

df2$question <- "YS5_23"
df2$trade <- "electr"

skills_electr <- rbind(df, df2)

skills <- rbind(skills_electr, skills_metal, skills_masons, skills_plumb, skills_carpenters)

skills %>% tbl_cross(row = Year,
                     col = correct,
                     percent = "row") %>% add_p()

v <- skills_plumb %>%
  rename("Plumbers" = Year) %>%
  tbl_cross(
    row = Plumbers,
    col = correct,
    percent = "row"
  ) %>%
  add_p()

w <- skills_metal %>%
  rename("Metalworkers" = Year) %>%
  tbl_cross(
    row = Metalworkers,
    col = correct,
    percent = "row"
  ) %>%
  add_p()

x <- skills_carpenters %>%
  rename("Carpenters" = Year) %>%
  tbl_cross(
    row = Carpenters,
    col = correct,
    percent = "row"
  ) %>%
  add_p()

y <- skills_masons %>%
  rename("Masons" = Year) %>% 
  tbl_cross(
    row = Masons,
    col = correct,
    percent = "row"
  ) %>%
  add_p()

z <- skills_electr %>%
  rename("Electricians" = Year) %>% 
  tbl_cross(
    row = Electricians,
    col = correct,
    percent = "row"
  ) %>%
  add_p()


tbl_stack(list(v, w, x, y, z))


# df2 <- df %>% select(-value) %>% group_by(SELECTED, Year) %>% summarise_at("correct", mean, na.rm = T)





###########################
## 2 - Calculate  costs  ##
###########################

