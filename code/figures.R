#############
## Figures ##
#############

packages <- c("ggplot2", "tidyverse", "labelled", "gtsummary")

# Install packages not yet installed
installed_packages <- packages %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  install.packages(packages[!installed_packages], silent = TRUE)
}

# Load packages
invisible(lapply(packages, library, character.only = TRUE))
suppressMessages(library(stargazer))

rm(packages, installed_packages)

# Set working directory
setwd("~/polybox/Youth Employment/2 CQP/Paper")

#load data
load("data/df.rda")




x <- df %>% select(firm_size_bins, cb_simple, cb_complex) %>% filter(!is.na(firm_size_bins)) %>% group_by(firm_size_bins) %>% summarise_all(mean, na.rm = T) %>% ungroup()

ggplot(data=x, aes(x=firm_size_bins, y=cb_simple)) +
  geom_bar(stat="identity", color="black", position=position_dodge())+
  theme_minimal()

ggplot(data=x, aes(x=firm_size_bins, y=cb_complex)) +
  geom_bar(stat="identity", color="black", position=position_dodge())+
  theme_minimal()

# together, relative to profits, endline
x <- df %>% filter(!is.na(firm_size_bins), !is.na(FS5.4), wave == 1, FS5.4 != 0) %>% select(FS1.2, firm_size_bins, cb_simple, cb_complex, FS5.4) %>%
  group_by(FS1.2,firm_size_bins) %>% summarise_all(mean, na.rm = T) %>% 
  mutate(cb_simple = cb_simple / FS5.4*100,
         cb_complex = cb_complex / FS5.4*100) %>% ungroup() %>% 
  select(-FS1.2) %>% 
  group_by(firm_size_bins) %>% summarise_all(mean, na.rm = T) %>% ungroup() %>% pivot_longer(cols = c("cb_simple", "cb_complex"))

ggplot(data=x, aes(x=firm_size_bins, y=value, fill=name)) +
  geom_bar(stat="identity", color="black", position=position_dodge())+
  theme_minimal() + scale_fill_manual(values=c('#999999','#E69F00'))

# together, relative to profits, endline, calculated profits
x <- df %>% filter(!is.na(firm_size_bins), !is.na(profits), wave == 0, profits != 0) %>% select(FS1.2, firm_size_bins, cb_simple, cb_complex, profits) %>%
  group_by(FS1.2,firm_size_bins) %>% summarise_all(mean, na.rm = T) %>% 
  mutate(cb_simple = cb_simple / profits*100,
         cb_complex = cb_complex / profits*100) %>% ungroup() %>% 
  select(-FS1.2) %>% 
  group_by(firm_size_bins) %>% summarise_all(mean, na.rm = T) %>% ungroup() %>% pivot_longer(cols = c("cb_simple", "cb_complex"))

ggplot(data=x, aes(x=firm_size_bins, y=value, fill=name)) +
  geom_bar(stat="identity", color="black", position=position_dodge())+
  theme_minimal() + scale_fill_manual(values=c('#999999','#E69F00'))




