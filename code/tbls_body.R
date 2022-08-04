## ---- test-g --------

x <- df %>% rowwise() %>% mutate_at(c("total_fees", "fee_entry", "fee_formation", "fee_liberation", "fee_materials", "fee_contract", "fee_application"), ~./4) %>% mutate_at(vars(contains("allow")), ~.*5*4*FS4.1) %>% 
  mutate_at(c(vars(contains(("FE5.1")), "total_training_costs")), ~.*FS4.1/FS6.1) %>% 
  mutate(apprentice_prod = sum(FS5.2_1_2*6, FS5.2_1_4*6, na.rm = T)) %>% ungroup() %>% 
  select("FS1.2", "wave", "SELECTED", "total_fees", "fee_entry", "fee_formation", "fee_liberation", "fee_materials", "fee_contract", "fee_application", "apprentice_prod", "total_benefits", "all_allowances", "allow_food", "allow_transport", "allow_pocket_money", "allow_other", "total_training_costs", contains("FE5.1"), "annual_foregone_prod", "total_costs", contains("cb")) %>%
  mutate_at(c("FS1.2", "wave", "total_fees", "fee_entry", "fee_formation", "fee_liberation", "fee_materials", "fee_contract", "fee_application", "apprentice_prod", "total_benefits", "all_allowances", "allow_food", "allow_transport", "allow_pocket_money", "allow_other", "total_training_costs", "FE5.1_1", "FE5.1_2", "FE5.1_3", "FE5.1_4", "annual_foregone_prod", "total_costs", "cb_I", "cb_II", "cb_III", "cb_IV", "cb_V"), ~./605) %>% ungroup() %>% 
  mutate(wave = factor(wave, labels = c("Baseline", "Endline")))

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

tbl_wave <- tbl_summary(x, by = wave,
                        type = everything() ~ "continuous",
                        statistic = all_continuous() ~ c("{mean} ({sd})"),
                        include = -c(FS1.2, SELECTED),
                        missing = "no",
                        digits = everything() ~ 2) %>% 
  modify_header(all_stat_cols() ~ "**{level}**") %>% 
  modify_footnote(update = everything() ~ NA)

y <- x %>% filter(wave == "Baseline") %>% mutate(SELECTED = factor(SELECTED, levels = c(1, 0, 3),
                                                                   labels = c('Selected', 'Not Selected', 'Did Not Apply')))

tbl_sel <- tbl_summary(y, by = SELECTED,
                       type = everything() ~ "continuous",
                       statistic = all_continuous() ~ c("{mean} ({sd})"),
                       include = -c(FS1.2, wave),
                       missing = "no",
                       digits = everything() ~ 2) %>% 
  modify_header(all_stat_cols() ~ "**{level}**") %>% 
  modify_footnote(update = everything() ~ NA)

tbl_merge(list(tbl_wave, tbl_sel), tab_spanner = c("Overall", "By status, at baseline")) %>% 
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
  footnote(general = "Mean (SD). Annual net benefits per apprentice per year. Amounts in \\\\$US.",
           number = "Annual fees assuming four-year apprenticeship duration.",
           threeparttable = T,
           escape = F,
           fixed_small_size = T,
           general_title = "") 

# \\\\ Total apprenticeship fees reported by apprentices \\\\ and firm owners at baseline. \\\\ Amounts in \\$US.
  
