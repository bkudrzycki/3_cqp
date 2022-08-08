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
  add_p() %>% 
  modify_header(all_stat_cols() ~ "**{level}**",
                starts_with("add_n_stat") ~ "**N**",
                label = "**Fee Type**",
                p.value = "**p-value¹**") %>% 
  modify_footnote(update = everything() ~ NA) 

z <- x %>% filter(wave == 1) %>% 
  tbl_summary(by=side,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no",
              digits = list(everything() ~ c(2, 2)),
              include = -c(IDYouth, wave)) %>% 
  add_p() %>% 
  modify_header(all_stat_cols() ~ "**{level}**",
                starts_with("add_n_stat") ~ "**N**",
                label = "**Fee Type**",
                p.value = "**p-value¹**") %>% 
  modify_footnote(update = everything() ~ NA)

tbl_merge(list(y, z), tab_spanner = c("**Baseline**", "**Endline**")) %>%
  as_kable_extra(caption = "Apprenticeship Fees",
                 escape = F,
                 booktabs = T,
                 linesep = "",
                 position = "H",
                 addtl_fmt = F) %>%
  kableExtra::row_spec(7,bold=T) %>% 
  kableExtra::kable_styling(latex_options="scale_down") %>% 
  footnote(general = "Mean (SD). All fees are total amounts to be paid over the course of the apprenticeship. Amounts in \\\\$US.",
           number = "Paired t-test.",
           threeparttable = T,
           escape = F,
           fixed_small_size = T,
           general_title = "")

## ---- tbl-skillsbycqp --------

comp <- df %>% select(contains("comp"), -contains("a_"), SELECTED, IDYouth) %>%
  mutate(SELECTED = factor(SELECTED, levels = c(1, 0, 3),
                           labels = c('CQP Selected', 'CQP Not Selected', 'Did Not Apply'))) %>% 
  tbl_summary(by=SELECTED,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no",
              include = -IDYouth) %>% 
  add_stat(
    fns = everything() ~ add_by_n
  ) %>% 
  modify_table_body(
    ~ .x %>%
      dplyr::relocate(add_n_stat_1, .before = stat_1) %>%
      dplyr::relocate(add_n_stat_2, .before = stat_2) %>% 
      dplyr::relocate(add_n_stat_3, .before = stat_3)
  ) %>%
  add_p() %>% 
  modify_header(stat_by =  "**{level}**",
                starts_with("add_n_stat") ~ "**N**",
                label = "**Trade**") %>% 
  modify_footnote(update = everything() ~ NA)

exp <- df %>% select(contains("exp"), -contains("a_"), -expenses, SELECTED, IDYouth) %>%
  mutate(SELECTED = factor(SELECTED, levels = c(1, 0, 3),
                           labels = c('CQP Selected', 'CQP Not Selected', 'Did Not Apply'))) %>% 
  tbl_summary(by=SELECTED,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no",
              include = -IDYouth) %>% 
  add_stat(
    fns = everything() ~ add_by_n
  ) %>% 
  modify_table_body(
    ~ .x %>%
      dplyr::relocate(add_n_stat_1, .before = stat_1) %>%
      dplyr::relocate(add_n_stat_2, .before = stat_2) %>% 
      dplyr::relocate(add_n_stat_3, .before = stat_3)
  ) %>%
  add_p() %>%  
  modify_header(stat_by =  "**{level}**",
                starts_with("add_n_stat") ~ "**N**",
                label = "**Trade**") %>% 
  modify_footnote(update = everything() ~ NA)

skills <- df %>% select(contains("skills"), SELECTED, IDYouth) %>%
  mutate(SELECTED = factor(SELECTED, levels = c(1, 0, 3),
                           labels = c('CQP Selected', 'CQP Not Selected', 'Did Not Apply'))) %>% 
  tbl_summary(by=SELECTED,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no",
              include = -IDYouth) %>% 
  add_stat(
    fns = everything() ~ add_by_n
  ) %>% 
  modify_table_body(
    ~ .x %>%
      dplyr::relocate(add_n_stat_1, .before = stat_1) %>%
      dplyr::relocate(add_n_stat_2, .before = stat_2) %>% 
      dplyr::relocate(add_n_stat_3, .before = stat_3)
  ) %>%
  add_p() %>% 
  modify_header(stat_by =  "**{level}**",
                starts_with("add_n_stat") ~ "**N**",
                label = "**Trade**") %>% 
  modify_footnote(update = everything() ~ NA) %>% 
  modify_table_body(~.x %>% 
                      dplyr::mutate(stat_3 = "-",
                                    add_n_stat_3 = "-"))

tbl_stack(list(comp, exp, skills), quiet = TRUE) %>% 
  as_kable_extra(caption = "Change in apprentice human capital by CQP participation status", 
                 booktabs = T,
                 linesep = "",
                 position = "H") %>% 
  kableExtra::group_rows(start_row = 1,
                         end_row = 6,
                         group_label = "Competencies¹") %>% 
  kableExtra::group_rows(start_row = 7,
                         end_row = 12,
                         group_label = "Experience¹") %>% 
  kableExtra::group_rows(start_row = 13,
                         end_row = 18,
                         group_label = "Knowledge²") %>% 
  kableExtra::row_spec(c(6,12,18),bold=T) %>% 
  kableExtra::kable_styling(latex_options="scale_down") %>% 
  footnote(general = "Mean (SD).",
           number = c("Percent of trade-specific tasks apprentice is deemed competent in (competency) or has already successfully attempted (experience), as reported by MC. Total of 10-15 tasks, depending on trade.", "Percent of trade-specific knowledge questions answered correctly by apprentice. Total of 4 or 5 questions, depending on trade."),
           threeparttable = T,
           escape = F,
           general_title = "")
