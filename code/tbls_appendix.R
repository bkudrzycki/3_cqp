## ---- cbend --------

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