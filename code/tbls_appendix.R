## ---- tbl-cbend --------

z <- x %>% filter(wave == "Endline") %>% mutate(SELECTED = factor(SELECTED, levels = c(1, 0, 3),
                                                                  labels = c('Selected', 'Not Selected', 'Did Not Apply')))
tbl_summary(z, by = SELECTED,
            type = everything() ~ "continuous",
            statistic = all_continuous() ~ c("{mean} ({sd})"),
            include = -c(FS1.2, wave),
            missing = "no",
            digits = everything() ~ 2) %>% 
  modify_header(all_stat_cols() ~ "**{level}**") %>%
  as_kable_extra(caption = "Net Benefits by status, at endline",
                 booktabs = T,
                 linesep = "",
                 position = "H") %>%
  kableExtra::group_rows(start_row = 1,
                         end_row = 8,
                         group_label = "Benefits") %>% 
  kableExtra::group_rows(start_row = 9,
                         end_row = 21,
                         group_label = "Costs") %>% 
  kableExtra::add_indent(c(2:7), level_of_indent = 1) %>% 
  kableExtra::add_indent(c(10:13), level_of_indent = 1) %>% 
  kableExtra::add_indent(c(15:18), level_of_indent = 1) %>% 
  kableExtra::row_spec(20,bold=T) %>% 
  kableExtra::row_spec(21,bold=T) %>% 
  kableExtra::kable_styling(latex_options="scale_down")

## ---- tbl-fees --------

x <- df %>% mutate_at(c("fee_entry", "fee_formation", "fee_liberation", "fee_materials", "fee_contract", "fee_application", "total_fees", "a_fee_entry", "a_fee_formation", "a_fee_liberation", "a_fee_materials", "a_fee_contract", "a_fee_application", "a_total_fees"), ~./605) %>% select(-"fees_avg", -"annual_fees") %>% pivot_longer(cols = contains("fee")) %>% mutate(side = ifelse(grepl("a_", name), "Apprentice", "Firm")) %>% mutate(name = str_remove_all(name, "a_")) %>% select(c(IDYouth, wave, side, name, value)) %>% pivot_wider() 

var_label(x$fee_entry) <- "Initiation"
var_label(x$fee_formation) <- "Training"
var_label(x$fee_liberation) <- "Graduation"
var_label(x$fee_materials) <- "Materials"
var_label(x$fee_contract) <- "Contract"
var_label(x$fee_application) <- "Application"
var_label(x$total_fees) <- "Total"

y <- x %>% filter(wave == 0) %>% 
  tbl_summary(by=side,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no",
              digits = list(everything() ~ c(2, 2)),
              include = -c(IDYouth, wave)) %>% 
  modify_header(all_stat_cols() ~ "**{level}**",
                starts_with("add_n_stat") ~ "**N**",
                label = "**Fee Type**") %>% 
  add_p() %>% 
  modify_footnote(update = everything() ~ NA) 

z <- x %>% filter(wave == 1) %>% 
  tbl_summary(by=side,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no",
              digits = list(everything() ~ c(2, 2)),
              include = -c(IDYouth, wave)) %>% 
  modify_header(all_stat_cols() ~ "**{level}**",
                starts_with("add_n_stat") ~ "**N**",
                label = "**Fee Type**") %>% 
  add_p() %>% 
  modify_footnote(update = everything() ~ NA)

tbl_merge(list(y, z), tab_spanner = c("**Baseline**", "**Endline**")) %>%
  as_kable_extra(caption = "Apprenticeship Fees",
                 escape = F,
                 booktabs = T,
                 linesep = "",
                 position = "H",
                 addtl_fmt = F) %>%
  add_footnote("\\scriptsize Mean (SD). All fees are total amounts to be paid over the course of the apprenticeship. Amounts in \\$US.", notation = "none", threeparttable = T, escape = F) %>% 
  kableExtra::kable_styling(latex_options="scale_down")

## ---- tbl-cblongbycqp --------

firms <- df %>% filter(wave == 0) %>% select(FS1.2, SELECTED, firm_size_bins, dossier_selected, dossier_apps, FS3.4, FS4.1, FS4.7, annual_app_prod, FS5.4, FS6.1, FS6.2, firm_size, profits, expenses, annual_fees, total_benefits, annual_allowances, annual_training_costs, annual_foregone_prod, total_costs, contains("cb")) %>%
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

firms %>% select(firm_size_bins, annual_revenues, annual_expenses, annual_rep_profits, annual_profits, annual_fees_extrap, apprentice_prod_extrap, total_benefits_extrap, annual_allowances_extrap, annual_training_costs_extrap, annual_foregone_prod_extrap, total_costs_extrap, contains("extrap")) %>% 
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
  add_overall()