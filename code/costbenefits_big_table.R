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

## ---- test-g --------

df <- unlabelled(df)

x <- df %>% rowwise() %>% mutate_at(c("total_fees", "fee_entry", "fee_formation", "fee_liberation", "fee_materials", "fee_contract", "fee_application"), ~./4) %>% mutate_at(vars(contains("allow")), ~.*5*4*FS4.1) %>% 
  mutate_at(c(vars(contains(("FE5.1")), "total_training_costs")), ~.*FS4.1/FS6.1) %>% 
  mutate(apprentice_prod = sum(FS5.2_1_2*6, FS5.2_1_4*6, na.rm = T),
         trainer_prod = monthly_time_trained*FS6.8*FS5.2_1_2/FS3.1/FS3.2/4/FS6.1*FS4.1) %>% ungroup() %>% 
  select("FS1.2", "wave", "total_fees", "fee_entry", "fee_formation", "fee_liberation", "fee_materials", "fee_contract", "fee_application", "apprentice_prod", "all_allowances", "allow_food", "allow_transport", "allow_pocket_money", "allow_other", "total_training_costs", contains("FE5.1"), "trainer_prod", "cb_2", "cb_3") %>%
  mutate_at(c("FS1.2", "wave", "total_fees", "fee_entry", "fee_formation", "fee_liberation", "fee_materials", "fee_contract", "fee_application", "apprentice_prod", "all_allowances", "allow_food", "allow_transport", "allow_pocket_money", "allow_other", "total_training_costs", "FE5.1_1", "FE5.1_2", "FE5.1_3", "FE5.1_4", "trainer_prod", "cb_2", "cb_3"), ~./605) %>% ungroup() %>% 
  mutate(wave = factor(wave, labels = c("Baseline", "Endline")))

x <- x %>% replace(is.na(.), 0)

var_label(x$total_fees) <- "Fees"
var_label(x$fee_entry) <- "Entry"
var_label(x$fee_formation) <- "Formation"
var_label(x$fee_liberation) <- "Liberation"
var_label(x$fee_materials) <- "Materials"
var_label(x$fee_contract) <- "Contract"
var_label(x$fee_application) <- "Application"
var_label(x$apprentice_prod) <- "Apprentice productivity"
var_label(x$all_allowances) <- "Allowances"
var_label(x$allow_food) <- "Food"
var_label(x$allow_transport) <- "Transport"
var_label(x$allow_pocket_money) <- "Pocket money"
var_label(x$allow_other) <- "Other"
var_label(x$total_training_costs) <- "Training costs"
var_label(x$FE5.1_1) <- "Rent"
var_label(x$FE5.1_2) <- "Equipment"
var_label(x$FE5.1_3) <- "Books and teaching materials"
var_label(x$FE5.1_4) <- "Raw materials"
var_label(x$trainer_prod) <- "Foregone trainer productivity"
var_label(x$cb_2) <- "Net Benefits (Model I)"
var_label(x$cb_3) <- "Net Benefits (Model II)"

tbl_summary(x, by = wave,
            type = everything() ~ "continuous",
            statistic = all_continuous() ~ c("{mean} ({sd})"),
            include = -FS1.2,
            missing = "no",
            digits = everything() ~ 2) %>% 
  as_kable_extra(caption = "Net Benefits",
                 booktabs = T,
                 linesep = "",
                 position = "H") %>%
  kableExtra::group_rows(start_row = 1,
                         end_row = 8,
                         group_label = "Benefits") %>% 
  kableExtra::group_rows(start_row = 9,
                         end_row = 19,
                         group_label = "Costs") %>% 
  kableExtra::add_indent(c(2:7), level_of_indent = 1) %>% 
  kableExtra::add_indent(c(10:13), level_of_indent = 1) %>% 
  kableExtra::add_indent(c(15:18), level_of_indent = 1)
  


## ---- test-h --------

y <- df %>% rowwise() %>% mutate_at(c("total_fees", "fee_entry", "fee_formation", "fee_liberation", "fee_materials", "fee_contract", "fee_application"), ~./4) %>% mutate_at(vars(contains("allow")), ~.*5*4*FS4.1) %>% 
  mutate_at(c(vars(contains(("FE5.1")), "total_training_costs")), ~.*FS4.1/FS6.1) %>% 
  mutate(apprentice_prod = sum(FS5.2_1_2*6, FS5.2_1_4*6, na.rm = T),
         trainer_prod = monthly_time_trained*FS6.8*FS5.2_1_2/FS3.1/FS3.2/4/FS6.1*FS4.1) %>% ungroup() %>% 
  select("FS1.2", "wave", "FS6.1", "total_fees", "fee_entry", "fee_formation", "fee_liberation", "fee_materials", "fee_contract", "fee_application", "apprentice_prod", "all_allowances", "allow_food", "allow_transport", "allow_pocket_money", "allow_other", "total_training_costs", contains("FE5.1"), "trainer_prod", "cb_2", "cb_3") %>% group_by(FS1.2, wave) %>% summarise_all(mean, na.rm = T) %>% ungroup() %>% mutate(wave = factor(wave, labels = c("Baseline", "Endline"))) %>%
  mutate_at(c("total_fees", "fee_entry", "fee_formation", "fee_liberation", "fee_materials", "fee_contract", "fee_application", "apprentice_prod", "all_allowances", "allow_food", "allow_transport", "allow_pocket_money", "allow_other", "total_training_costs", "FE5.1_1", "FE5.1_2", "FE5.1_3", "FE5.1_4", "trainer_prod", "cb_2", "cb_3"), ~./605*FS6.1)

y <- y %>% replace(is.na(.), 0)

var_label(y$total_fees) <- "Fees"
var_label(y$fee_entry) <- "Entry"
var_label(y$fee_formation) <- "Formation"
var_label(y$fee_liberation) <- "Liberation"
var_label(y$fee_materials) <- "Materials"
var_label(y$fee_contract) <- "Contract"
var_label(y$fee_application) <- "Application"
var_label(y$apprentice_prod) <- "Apprentice productivity"
var_label(y$all_allowances) <- "Allowances"
var_label(y$allow_food) <- "Food"
var_label(y$allow_transport) <- "Transport"
var_label(y$allow_pocket_money) <- "Pocket money"
var_label(y$allow_other) <- "Other"
var_label(y$total_training_costs) <- "Training costs"
var_label(y$FE5.1_1) <- "Rent"
var_label(y$FE5.1_2) <- "Equipment"
var_label(y$FE5.1_3) <- "Books and teaching materials"
var_label(y$FE5.1_4) <- "Raw materials"
var_label(y$trainer_prod) <- "Foregone trainer productivity"
var_label(y$cb_2) <- "Net Benefits (Model I)"
var_label(y$cb_3) <- "Net Benefits (Model II)"

tbl_summary(y, by = wave,
            type = everything() ~ "continuous",
            statistic = all_continuous() ~ c("{mean} ({sd})"),
            include = -c(FS1.2,FS6.1),
            missing = "no",
            digits = everything() ~ 2)  


tbl_merge(list(baseline, endline), tab_spanner = c("**Baseline**", "**Endline**")) %>% 
  as_kable_extra(caption = "Total apprenticeship fees reported by apprentices and firm owners", 
                 booktabs = T,
                 linesep = "",
                 position = "H")
