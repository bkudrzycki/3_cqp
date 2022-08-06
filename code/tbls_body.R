## ---- tbl-desc --------

apps <- df %>% mutate(N = 1) %>%  select(N, age, sex, FS1.11, duration, grad, schooling, wave) %>%
  mutate(wave = factor(wave, levels = 0:1, labels = c('Baseline', 'Endline')),
         sex = factor(sex, levels = 0:1, labels = c("Female", "Male")),
         FS1.11 = factor(FS1.11, labels = c('Masonry', 'Carpentry', 'Plumbing', 'Metalworking', 'Electrical Inst.')),
         grad = ifelse(wave == "Baseline", NA, grad)) %>% 
  mutate(grad = factor(grad, labels = c("Still training", "Graduated", "Dropped out", "Unknown"))) %>% 
  rename("Age" = age, "Male" = sex, "Trade" = FS1.11) %>% 
  tbl_summary(by=wave,
              type = list(Age ~ "continuous",
                          duration ~ "continuous",
                          Male ~ "dichotomous"),
              value = Male ~ "Male",
              statistic = list(all_continuous() ~ c("{mean} ({sd})"),
                               all_categorical() ~ c("{p}%"),
                               N ~ "{N}"),
              missing = "no",
              label = list(Trade ~ "Trade",
                           duration ~ "Years in training",
                           schooling ~ "Education",
                           grad ~ "Status at endline")) %>% 
  modify_header(all_stat_cols() ~ "**{level}**")

workshops <- df %>% mutate(N_firms = 1) %>% mutate(apps = FS6.1,
                                                   FS1.11 = as.numeric(FS1.11)) %>% 
  select(N_firms, FS1.2, FS6.1, selected, not_selected, did_not_apply, firm_size, FS3.4, apps, contains("FS3.5"), FS1.11, wave) %>%
  group_by(FS1.2, wave) %>% summarise_all(mean, na.rm = T) %>% ungroup() %>%
  mutate(wave = factor(wave, labels = c("Baseline", "Endline")),
         FS1.11 = factor(FS1.11, labels = c('Masonry', 'Carpentry', 'Plumbing', 'Metalworking', 'Electrical Inst.'))) %>% 
  tbl_summary(by=wave,
              type = list(c(firm_size, FS3.4, FS6.1, FS3.5_2, FS3.5_3, FS3.5_4, FS3.5_5)  ~ "continuous",
                          FS1.11 ~ "categorical"),
              statistic = list(all_continuous() ~ "{mean} ({sd})",
                               all_categorical() ~ c("{p}%"),
                               N_firms ~ "{N}"),
              missing = "no",
              digits = list(firm_size ~ c(1, 1),
                            starts_with("FS3.5") ~ c(2, 1)),
              label = list(FS3.4 ~ "Total (reported)",
                           firm_size ~ "Total (calculated)",
                           selected ~ "Selected",
                           not_selected ~ "Not Selected",
                           did_not_apply ~ "Did Not Apply",
                           FS6.1 ~ "Total",
                           apps ~ "Apprentices",
                           FS3.5_2 ~ "Permanent wage",
                           FS3.5_3 ~ "Paid family",
                           FS3.5_4 ~ "Unpaid family",
                           FS3.5_5 ~ "Occasional",
                           FS1.11 ~ "Trade",
                           N_firms ~ "N"),
              include = -c(FS1.2, FS3.5_1)) %>% 
  modify_header(all_stat_cols() ~ "**{level}**", label = "")

x <- tbl_stack(list(apps, workshops), quiet = T) 

y <- df %>% mutate(N = 1) %>% filter(wave == 0) %>% select(N, age, sex, SELECTED, FS1.11, duration, grad, schooling) %>%
  mutate(SELECTED = factor(SELECTED, levels = c(1, 0, 3),
                           labels = c('Selected', 'Not Selected', 'Did Not Apply')),
         sex = factor(sex, levels = 0:1, labels = c("Female", "Male")),
         FS1.11 = factor(FS1.11, labels = c('Masonry', 'Carpentry', 'Plumbing', 'Metalworking', 'Electrical Inst.'))) %>% 
  rename("Age" = age, "Male" = sex, "Trade" = FS1.11) %>% 
  tbl_summary(by=SELECTED,
              type = list(Age ~ "continuous",
                          duration ~ "continuous",
                          Male ~ "dichotomous"),
              value = Male ~ "Male",
              statistic = list(all_continuous() ~ c("{mean} ({sd})"),
                               all_categorical() ~ c("{p}%"),
                               N ~ "{N}"),
              missing = "no",
              label = list(Trade ~ "Trade",
                           duration ~ "Years in training",
                           schooling ~ "Education",
                           grad ~ "Status at endline")) %>% 
  modify_header(all_stat_cols() ~ "**{level}**")

tbl_merge(list(x, y), tab_spanner = c("Overall", "By baseline status")) %>% 
  as_kable_extra(caption = "Descriptive Statistics",
                 booktabs = T,
                 linesep = "",
                 position = "H") %>%
  kableExtra::group_rows(start_row = 1,
                         end_row = 22,
                         group_label = "Apprentices") %>% 
  kableExtra::group_rows(start_row = 23,
                         end_row = 40,
                         group_label = "Firms",
                         hline_before = TRUE) %>% 
  kableExtra::group_rows(start_row = 24,
                         end_row = 27,
                         group_label = "\\hspace{1em}Apprentices trained",
                         escape = F,
                         indent = T,
                         bold = F) %>% 
  kableExtra::group_rows(start_row = 28,
                         end_row = 34,
                         group_label = "\\hspace{1em}Firm size",
                         escape = F,
                         indent = T,
                         bold = F) %>% 
  kableExtra::kable_styling(latex_options="scale_down")

## ---- tbl-netbenefits --------

x <- df %>% filter(wave == 0) %>% rowwise() %>% mutate_at(c("total_fees", "fee_entry", "fee_formation", "fee_liberation", "fee_materials", "fee_contract", "fee_application"), ~./4) %>% mutate_at(vars(contains("allow")), ~.*5*4*FS4.1) %>% 
  mutate_at(c(vars(contains(("FE5.1")), "total_training_costs")), ~.*FS4.1/FS6.1) %>% 
  mutate(apprentice_prod = sum(FS5.2_1_2*6, FS5.2_1_4*6, na.rm = T)) %>% ungroup() %>% 
  select("FS1.2", "SELECTED", "total_fees", "fee_entry", "fee_formation", "fee_liberation", "fee_materials", "fee_contract", "fee_application", "apprentice_prod", "total_benefits", "all_allowances", "allow_food", "allow_transport", "allow_pocket_money", "allow_other", "total_training_costs", contains("FE5.1"), "annual_foregone_prod", "total_costs", contains("cb")) %>%
  mutate_at(c("total_fees", "fee_entry", "fee_formation", "fee_liberation", "fee_materials", "fee_contract", "fee_application", "apprentice_prod", "total_benefits", "all_allowances", "allow_food", "allow_transport", "allow_pocket_money", "allow_other", "total_training_costs", "FE5.1_1", "FE5.1_2", "FE5.1_3", "FE5.1_4", "annual_foregone_prod", "total_costs", "cb_I", "cb_II", "cb_III", "cb_IV", "cb_V"), ~./605) %>% ungroup() %>% 
  mutate(SELECTED = factor(SELECTED, levels = c(1, 0, 3), labels = c('CQP Selected', 'CQP Not Selected', 'Did Not Apply')))

x <- x %>% replace(is.na(.), 0)

var_label(x$total_fees) <- "Fees¹"
var_label(x$fee_entry) <- "Entry"
var_label(x$fee_formation) <- "Formation"
var_label(x$fee_liberation) <- "Liberation"
var_label(x$fee_materials) <- "Materials"
var_label(x$fee_contract) <- "Contract"
var_label(x$fee_application) <- "Application"
var_label(x$apprentice_prod) <- "Apprentice productivity"
var_label(x$total_benefits) <- "Total"
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
var_label(x$annual_foregone_prod) <- "Foregone trainer productivity"
var_label(x$total_costs) <- "Total"
var_label(x$cb_I) <- "Model I"
var_label(x$cb_II) <- "Model II"
var_label(x$cb_III) <- "Model III"
var_label(x$cb_IV) <- "Model IV"
var_label(x$cb_V) <- "Model V"

tbl_summary(x, by = SELECTED,
            type = everything() ~ "continuous",
            statistic = all_continuous() ~ c("{mean} ({sd})"),
            include = -c(FS1.2, SELECTED),
            missing = "no",
            digits = everything() ~ 2) %>% 
  add_overall() %>% 
  modify_footnote(update = everything() ~ NA) %>% 
  modify_header(update = list(all_stat_cols(FALSE) ~ "**{level}**",
                              stat_0 ~ "**Overall**")) %>% 
  as_kable_extra(caption = "Net Benefits",
                 booktabs = T,
                 linesep = "",
                 position = "H") %>%
  kableExtra::group_rows(start_row = 1,
                         end_row = 9,
                         group_label = "Benefits") %>% 
  kableExtra::group_rows(start_row = 10,
                         end_row = 21,
                         group_label = "Costs") %>% 
  kableExtra::group_rows(start_row = 22,
                         end_row = 26,
                         group_label = "Net Benefits") %>% 
  kableExtra::add_indent(c(2:7), level_of_indent = 1) %>% 
  kableExtra::add_indent(c(11:14), level_of_indent = 1) %>% 
  kableExtra::add_indent(c(16:19), level_of_indent = 1) %>% 
  kableExtra::row_spec(c(9,21:26),bold=T) %>% 
  kableExtra::kable_styling(latex_options="scale_down") %>% 
  footnote(general = "Mean (SD). Net benefits per apprentice per year, calculated using responses from baseline survey. Amounts in \\\\$US.",
           number = "Fees reported by firm owner. Annual fees assume apprenticeship duration of four years.",
           threeparttable = T,
           escape = F,
           fixed_small_size = T,
           general_title = "")

## ---- tbl-cblong --------

x <- df %>% filter(wave == 0) %>% select(FS1.2, SELECTED, firm_size_bins, dossier_selected, dossier_apps, FS3.4, FS4.1, FS4.7, annual_app_prod, FS5.4, FS6.1, FS6.2, firm_size, profits, expenses, annual_fees, total_benefits, annual_allowances, annual_training_costs, annual_foregone_prod, total_costs, contains("cb")) %>%
  group_by(FS1.2) %>% 
  summarise_all(mean, na.rm = T) %>% 
  ungroup() %>% 
  rowwise() %>% 
  mutate(annual_fees_extrap = FS6.1*annual_fees,
         apprentice_prod_extrap = FS6.1*annual_app_prod,
         total_benefits_extrap = FS6.1*total_benefits,
         annual_allowances_extrap = FS6.1*annual_allowances,
         annual_training_costs_extrap = FS6.1*annual_training_costs,
         annual_foregone_prod_extrap = FS6.1*annual_foregone_prod,
         total_costs_extrap = FS6.1*total_costs,
         cb_I_extrap = FS6.1*cb_I,
         cb_II_extrap = FS6.1*cb_II,
         cb_III_extrap = FS6.1*cb_III,
         cb_IV_extrap = FS6.1*cb_IV,
         cb_V_extrap = FS6.1*cb_V) %>% 
  mutate(annual_revenues = FS4.7 * FS4.1,
         annual_expenses = expenses * FS4.1,
         annual_rep_profits = FS5.4 * FS4.1,
         annual_profits = profits * FS4.1,
         firm_size_bins = cut(firm_size, breaks = c(1,2,5,10,20,50,107))) %>% 
  mutate_at(vars(contains(c('annual', 'extrap'))), ~./605)

x %>% select(firm_size_bins, annual_revenues, annual_expenses, annual_rep_profits, annual_profits, annual_fees_extrap, apprentice_prod_extrap, total_benefits_extrap, annual_allowances_extrap, annual_training_costs_extrap, annual_foregone_prod_extrap, total_costs_extrap, contains("extrap")) %>% 
  tbl_summary(by = firm_size_bins,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no",
              digits = list(everything() ~ c(0, 0)),
              label = list(annual_revenues ~ "Revenues",
                           annual_expenses ~ "Expenses",
                           annual_rep_profits ~ "Profits (reported)",
                           annual_profits ~ "Profits (calculated)",
                           annual_fees_extrap ~ "Extrapolated total fees",
                           apprentice_prod_extrap ~ "Extrapolated total apprentice productivity",
                           total_benefits_extrap ~ "Extrapolated total benefits",
                           annual_allowances_extrap ~ "Extrapolated allowances",
                           annual_training_costs_extrap ~ "Total reported training costs",
                           annual_foregone_prod_extrap ~ "Total foregone trainer productivity",
                           total_costs_extrap ~ "Extrapolated total costs",
                           cb_I_extrap ~ "Model I",
                           cb_II_extrap ~ "Model II",
                           cb_III_extrap ~ "Model III",
                           cb_IV_extrap ~ "Model IV",
                           cb_V_extrap ~ "Model V")) %>% 
  add_overall() %>% 
  as_kable_extra(caption = "Net Benefits by Firm",
                 booktabs = T,
                 linesep = "",
                 position = "H")
