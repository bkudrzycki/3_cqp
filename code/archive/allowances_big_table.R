## ---- test-a --------

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

# load data
load("data/df.rda")

# load functions
source("functions/add_by_n.R")

df <- unlabelled(df)

## ---- test-a --------
# code upper and lower bounds

df <- df %>% mutate("allow_food_low" = allow_food, "allow_transport_low" = allow_transport, "allow_pocket_money_low" = allow_pocket_money, "allow_other_low" = allow_other,
                    "allow_food_high" = allow_food, "allow_transport_high" = allow_transport, "allow_pocket_money_high" = allow_pocket_money, "allow_other_high" = allow_other)

df <- df %>% mutate_at(c("allow_food_low", "allow_transport_low", "allow_pocket_money_low", "allow_other_low"), recode,
                       `150` = 0,
                       `325` = 300,
                       `525` = 400,
                       `875` = 700,
                       `1225` = 1000,
                       `1775` = 1500,
                       `2425` = 2000,
                       `3425` = 3000,
                       `6225` = 5000,
                       `8725` = 7500,
                       `11725` = 10000)

df <- df %>% mutate_at(c("allow_food_high", "allow_transport_high", "allow_pocket_money_high", "allow_other_high"), recode,
                       `150` = 300,
                       `325` = 350,
                       `525` = 650,
                       `875` = 950,
                       `1225` = 1450,
                       `1775` = 1950,
                       `2425` = 2950,
                       `3425` = 4950,
                       `6225` = 7450,
                       `8725` = 9950,
                       `11725` = 13450)



df$all_allowances_high <- df %>% select(c("allow_food_high", "allow_transport_high", "allow_pocket_money_high", "allow_other_high")) %>% 
  rowSums(., na.rm = T)

df$all_allowances_low <- df %>% select(c("allow_food_low", "allow_transport_low", "allow_pocket_money_low", "allow_other_low")) %>% 
  rowSums(., na.rm = T)


df <- df %>% mutate_at(c("allow_food_high", "allow_transport_high", "allow_pocket_money_high", "allow_other_high", "all_allowances_high"), ~replace(., all_allowances_high == 0, NA))
df <- df %>% mutate_at(c("allow_food_low", "allow_transport_low", "allow_pocket_money_low", "allow_other_low", "all_allowances_low"), ~replace(., all_allowances_low == 0, NA))


df <- df %>% mutate("YS4.38_low" = YS4.38, "YS4.38_high" = YS4.38, "YE3.22_low" = YE3.22, "YE3.22_high" = YE3.22)

df <- df %>% mutate_at("YS4.38_low", recode,
                       `750` = 0,
                       `2000` = 1500,
                       `3000` = 2500,
                       `4250` = 3500,
                       `6000` = 5000,
                       `8500` = 7000,
                       `12500` = 10000,
                       `20000` = 15000,
                       `37500` = 25000,
                       `75000` = 50000)

df <- df %>% mutate_at("YE3.22_low", recode,
                       `250` = 0,
                       `750` = 500,
                       `1500` = 1000,
                       `2500` = 2000,
                       `4000` = 3000,
                       `6000` = 5000,
                       `8500` = 7000,
                       `12500` = 10000,
                       `20000` = 15000,
                       `37500` = 25000) 

df <- df %>% mutate_at("YS4.38_high", recode,
                       `750` = 1500,
                       `2000` = 2499,
                       `3000` = 3499,
                       `4250` = 4999,
                       `6000` = 6999,
                       `8500` = 9999,
                       `12500` = 14999,
                       `20000` = 24999,
                       `37500` = 49999,
                       `75000` = 10000)

df <- df %>% mutate_at("YE3.22_high", recode,
                       `250` = 499,
                       `750` = 999,
                       `1500` = 1999,
                       `2500` = 2999,
                       `4000` = 4999,
                       `6000` = 6999,
                       `8500` = 9999,
                       `12500` = 14999,
                       `20000` = 24999,
                       `37500` = 49999) 

df$a_allow_low <- coalesce(df$YS4.38_low, df$YE3.22_low)

df$a_allow_high <- coalesce(df$YS4.38_high, df$YE3.22_high)

#coalesce days/week reported by apprentices

df <- df %>% mutate(YS4.10 = as.numeric(coalesce(YS4.10, YE3.15)))

x <- df %>% mutate(YS4.10 = as.double(YS4.10)) %>% select(wave, contains(c("all_allowances", "a_allow")), FS1.2, FS3.1, FS4.1, YS4.10) %>% rename(all_allowances_mid = all_allowances, a_allow_mid = a_allow) %>% 
  group_by(FS1.2, wave) %>% summarise_all(mean, na.rm = T) %>% ungroup()
x <- x[,c(2,5,3,4,7,6,8:11)] %>% mutate(wave = factor(wave, labels = c("Baseline", "Endline")))

var_label(x$all_allowances_low) <- "lower"
var_label(x$all_allowances_mid) <- "mid"
var_label(x$all_allowances_high) <- "upper"
var_label(x$a_allow_low) <- "lower"
var_label(x$a_allow_mid) <- "mid"
var_label(x$a_allow_high) <- "upper"

tbl1 <- x %>% select(wave, contains("all_allow")) %>% mutate(across(contains("all_allow"), ~(.x*20*12))) %>% 
  tbl_summary(by = wave,
              statistic = all_continuous() ~ c("{mean} ({median})"),
              missing = "no") %>%
  modify_header(label = "Bound") %>% 
  add_overall()

tbl2 <- x %>% select(wave, contains("all_allow"), FS4.1) %>% mutate(across(contains("all_allow"), ~(.x*20*FS4.1))) %>% 
  tbl_summary(by = wave,
              statistic = all_continuous() ~ c("{mean} ({median})"),
              include = -FS4.1,
              missing = "no") %>%
  modify_header(label = "Bound") %>% 
  add_overall()

tbl3 <- x %>% select(wave, contains("all_allow"), FS3.1) %>% mutate(across(contains("all_allow"), ~(.x*4*FS3.1*12))) %>% 
  tbl_summary(by = wave,
              statistic = all_continuous() ~ c("{mean} ({median})"),
              include = -FS3.1,
              missing = "no") %>%
  modify_header(label = "Bound") %>% 
  add_overall()

tbl4 <- x %>% select(wave, contains("all_allow"), FS3.1, FS4.1) %>% mutate(across(contains("all_allow"), ~(.x*4*FS3.1*FS4.1))) %>% 
  tbl_summary(by = wave,
              statistic = all_continuous() ~ c("{mean} ({median})"),
              include = -c(FS3.1, FS4.1),
              missing = "no") %>%
  modify_header(label = "Bound") %>% 
  add_overall()

tbl5 <- x %>% select(wave, contains("all_allow"), YS4.10) %>% mutate(across(contains("all_allow"), ~(.x*4*YS4.10*12))) %>% 
  tbl_summary(by = wave,
              statistic = all_continuous() ~ c("{mean} ({median})"),
              include = -YS4.10,
              missing = "no") %>%
  modify_header(label = "Bound") %>% 
  add_overall()

tbl6 <- x %>% select(wave, contains("all_allow"), FS4.1, YS4.10) %>% mutate(across(contains("all_allow"), ~(.x*4*YS4.10*FS4.1))) %>% 
  tbl_summary(by = wave,
              statistic = all_continuous() ~ c("{mean} ({median})"),
              include = -c(FS4.1, YS4.10),
              missing = "no") %>%
  modify_header(label = "Bound") %>% 
  add_overall()

tbl_stack(list(tbl1, tbl2, tbl3, tbl4, tbl5, tbl6), group_header = c("12 months/year |\n 20 days/month", "(F) months/year |\n 20 days/month", "12 months/year |\n 4 x (F) weeks/month", "(F) months/year |\n 4 x (F) weeks/month", "12 months/year |\n 4 x (A) weeks/month", "firm months |\n 4 x (A) weeks/month")) %>%
  modify_header(groupname_col = "Assumption") %>% 
  modify_footnote(
    all_stat_cols() ~ "Mean (Median). (F): reported by firm; (A): reported by apprentices.") %>%
  as_kable_extra(caption = "Allowances per apprentice per year, reported by firm",
                 booktabs = T,
                 linesep = "",
                 position = "H") #cost per apprentice per year



## ---- test-b -------- 

tbl7 <- x %>% select(wave, contains("a_allow")) %>% mutate(across(contains("a_allow"), ~(.x*4*12))) %>%
  tbl_summary(by = wave,
              statistic = all_continuous() ~ c("{mean} ({median})"),
              missing = "no") %>%
  modify_header(label = "Bound") %>%
  add_overall()

tbl8 <- x %>% select(wave, contains("a_allow"), FS4.1) %>% mutate(across(contains("a_allow"), ~(.x*4*FS4.1))) %>%
  tbl_summary(by = wave,
              statistic = all_continuous() ~ c("{mean} ({median})"),
              include = -FS4.1,
              missing = "no") %>%
  modify_header(label = "Bound") %>%
  add_overall()

tbl_stack(list(tbl7, tbl8), group_header = c("12 months/year |\n 4 weeks/month", "(F) months/year |\n 4 weeks/month")) %>%
  modify_header(groupname_col = "Assumption") %>% 
  modify_footnote(
    all_stat_cols() ~ "Mean (Median). (F): reported by firm; (A): reported by apprentices.") %>% 
  as_kable_extra(caption = "Allowances per apprentice per year, reported by apprentice", 
                 booktabs = T,
                 linesep = "",
                 position = "H")


