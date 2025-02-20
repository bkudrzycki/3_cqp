## ---- tbl-cqpdesc --------

apps <- df %>% mutate(N = 1) %>%  select(N, age, sex, FS1.11, duration, schooling, grad, wave) %>%
  mutate(wave = factor(wave, levels = 0:1, labels = c('Baseline', 'Endline')),
         schooling = factor(schooling, levels = c('None', '<Primary', 'Primary', 'Secondary', 'Technical', 'Tertiary')),
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
  modify_header(all_stat_cols() ~ "**{level}**") %>% 
  modify_table_body(~.x %>% 
                      dplyr::mutate(stat_1 = ifelse(stat_1 == "NA%", "-", stat_1))) %>% 
  modify_footnote(update = everything() ~ NA)

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
                           firm_size ~ "Total (calculated)¹",
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
  modify_header(all_stat_cols() ~ "**{level}**", label = "") %>% 
  modify_footnote(update = everything() ~ NA)

x <- tbl_stack(list(apps, workshops), quiet = T) 

y <- df %>% mutate(N = 1) %>% filter(wave == 0) %>% select(N, age, sex, SELECTED, FS1.11, duration, schooling, grad) %>%
  mutate(schooling = factor(schooling, levels = c('None', '<Primary', 'Primary', 'Secondary', 'Technical', 'Tertiary')),
         SELECTED = factor(SELECTED, levels = c(1, 0, 3),
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
  add_p() %>% 
  modify_header(all_stat_cols() ~ "**{level}**") %>% 
  modify_footnote(update = everything() ~ NA)

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
  kableExtra::kable_styling(latex_options="scale_down") %>% 
  kableExtra::footnote(general = "\\\\textit{Notes:} N; Mean (SD); %",
                       number = "Calculated by author by summing number of partners, permanent employees, paid and unpaid family workers, occasional workers, and apprentices reported to be working for MC (total firm size reported separately).",
                       threeparttable = T,
                       escape = F,
                       fixed_small_size = T,
                       general_title = "")

## ---- tbl-skills --------

comp <- df %>% select(contains("comp"), -comp_all_trades, comp_all_trades, -contains("a_"), wave, IDYouth) %>%
  mutate(wave = factor(wave, levels = c(0,1), labels = c('Baseline', 'Endline'))) %>% 
  tbl_summary(by=wave,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no",
              include = -IDYouth) %>% 
  add_stat(
    fns = everything() ~ add_by_n
  ) %>% 
  add_difference(test = everything() ~ "paired.t.test", group = IDYouth) %>% 
  modify_table_body(
    ~ .x %>%
      dplyr::relocate(add_n_stat_1, .before = stat_1) %>%
      dplyr::relocate(add_n_stat_2, .before = stat_2) %>% 
      dplyr::mutate(estimate = -1 * estimate)
  ) %>%
  modify_column_hide(ci) %>%
  modify_header(stat_by =  "**{level}**",
                starts_with("add_n_stat") ~ "**N**",
                label = "",
                p.value = "**p-value³**") %>% 
  modify_footnote(update = everything() ~ NA)

exp <- df %>% select(contains("exp"), -exp_all_trades, exp_all_trades, -contains("a_"), -expenses, wave, IDYouth) %>%
  mutate(wave = factor(wave, levels = 0:1, labels = c('Baseline', 'Endline'))) %>% 
  tbl_summary(by=wave,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no",
              include = -IDYouth) %>% 
  add_stat(
    fns = everything() ~ add_by_n
  ) %>% 
  add_difference(test = everything() ~ "paired.t.test", group = IDYouth) %>% 
  modify_table_body(
    ~ .x %>%
      dplyr::relocate(add_n_stat_1, .before = stat_1) %>%
      dplyr::relocate(add_n_stat_2, .before = stat_2) %>% 
      dplyr::mutate(estimate = -1 * estimate)
  ) %>%
  modify_column_hide(ci) %>%
  modify_header(stat_by =  "**{level}**",
                starts_with("add_n_stat") ~ "**N**",
                label = "**Trade**",
                p.value = "**p-value³**") %>% 
  modify_footnote(update = everything() ~ NA)

skills <- df %>% select(contains("skills"), -skills_all_trades, skills_all_trades, wave, IDYouth) %>%
  mutate(wave = factor(wave, levels = 0:1, labels = c('Baseline', 'Endline'))) %>% 
  tbl_summary(by=wave,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no",
              include = -IDYouth) %>% 
  add_stat(
    fns = everything() ~ add_by_n
  ) %>% 
  add_difference(test = everything() ~ "paired.t.test", group = IDYouth) %>% 
  modify_table_body(
    ~ .x %>%
      dplyr::relocate(add_n_stat_1, .before = stat_1) %>%
      dplyr::relocate(add_n_stat_2, .before = stat_2) %>% 
      dplyr::mutate(estimate = -1 * estimate)
  ) %>%
  modify_column_hide(ci) %>%
  modify_header(stat_by =  "**{level}**",
                starts_with("add_n_stat") ~ "**N**",
                label = "**Trade**",
                p.value = "**p-value³**") %>% 
  modify_footnote(update = everything() ~ NA)

tbl_stack(list(comp, exp, skills), quiet = TRUE) %>% 
  as_kable_extra(caption = "Change in apprentice human capital", 
                 booktabs = T,
                 linesep = "",
                 position = "H") %>% 
  kableExtra::group_rows(start_row = 1,
                         end_row = 9,
                         group_label = "Competence¹") %>% 
  kableExtra::group_rows(start_row = 10,
                         end_row = 18,
                         group_label = "Experience¹") %>% 
  kableExtra::group_rows(start_row = 19,
                         end_row = 26,
                         group_label = "Knowledge²") %>% 
  kableExtra::row_spec(c(9,18,26),bold=T) %>% 
  kable_styling(font_size = 10) %>% 
  kableExtra::kable_styling(latex_options="scale_down") %>%
  kableExtra::footnote(general = "\\\\footnotesize \\\\textit{Notes:} Mean (SD).",
           number = c("\\\\footnotesize Percent of trade-specific tasks apprentice is deemed competent in (competence) or has already successfully attempted (experience), as reported by MC. Total of 10-15 tasks, depending on trade.", "\\\\footnotesize Percent of trade-specific knowledge questions answered correctly by apprentice. Total of 4 or 5 questions, depending on trade. Not available for apprentices who did not apply to the CQP, as they were not interviewed personally.", "\\\\footnotesize Paired t-test."),
           threeparttable = T,
           escape = F,
           fixed_small_size = T,
           general_title = "")


## ---- tbl-appreg --------

# interaction term
df$did <- ifelse(df$SELECTED == 0, (as.numeric(df$SELECTED))*df$wave, 0)
df$did2 <- ifelse(df$SELECTED == 3, (as.numeric(df$SELECTED)-2)*df$wave, 0)

x <- df %>% mutate(total_apps = selected + not_selected + did_not_apply,
                   SELECTED = factor(SELECTED, levels = c(1, 0, 3), labels = c('CQP Selected', 'CQP Not Selected', 'Did Not Apply')))


m1 <- lm(exp_all_trades ~ as.factor(SELECTED) + as.factor(wave) + baseline_duration + firm_size_sans_app + total_apps, data = x)
m2 <- lm(exp_all_trades ~ as.factor(SELECTED) + as.factor(wave) + baseline_duration + firm_size_sans_app + total_apps + as.factor(FS1.2), data = x)
m3 <- lm(exp_all_trades ~ as.factor(SELECTED) + as.factor(wave) + did + did2 + baseline_duration + firm_size_sans_app + total_apps, data = x)
m4 <- lm(exp_all_trades ~ as.factor(SELECTED) + as.factor(wave) + did + did2 + baseline_duration + firm_size_sans_app + total_apps + as.factor(FS1.11), data = x)


m5 <- lm(comp_all_trades ~  as.factor(SELECTED) + as.factor(wave) + baseline_duration + firm_size_sans_app + total_apps, data = x)
m6 <- lm(comp_all_trades ~ as.factor(SELECTED) + as.factor(wave) + baseline_duration + firm_size_sans_app + total_apps + as.factor(FS1.2), data = x)
m7 <- lm(comp_all_trades ~ as.factor(SELECTED) + as.factor(wave) + did + did2 + baseline_duration + firm_size_sans_app + total_apps, data = x)
m8 <- lm(comp_all_trades ~ as.factor(SELECTED) + as.factor(wave) + did + did2 + baseline_duration + firm_size_sans_app + total_apps + as.factor(FS1.11), data = x)

m9 <- lm(skills_all_trades ~ as.factor(SELECTED) + as.factor(wave) + baseline_duration + firm_size_sans_app + total_apps, data = x)
m10 <- lm(skills_all_trades ~ as.factor(SELECTED) + as.factor(wave) + baseline_duration + firm_size_sans_app + total_apps + as.factor(FS1.2), data = x)
m11 <- lm(skills_all_trades ~ as.factor(SELECTED) + as.factor(wave) + did + baseline_duration + firm_size_sans_app + total_apps, data = x)
m12 <- lm(skills_all_trades ~ as.factor(SELECTED) + as.factor(wave) + did + baseline_duration + firm_size_sans_app + total_apps + as.factor(FS1.11), data = x)

stargazer(m1, m3, m4, m5, m7, m8, m9, m11, m12, df = FALSE, omit = "FS1.11", font.size= "scriptsize", column.sep.width = "-8pt",
          no.space = TRUE, digits = 2, header = F, table.placement = "H",
          notes = c("$^{*}$p$<$0.1; $^{**}$p$<$0.05; $^{***}$p$<$0.01",
                    "\\textit{Notes:} $^1$Prior to baseline survey.",
                    "$^2$Excluding apprentices."),
          notes.label = "", 
          notes.align = "l", 
          notes.append = F,
          covariate.labels = c("CQP Selected (reference) \\\\ \\\\ CQP Not Selected",
                               "CQP Did Not Apply",
                               "Endline",
                               "\\hl{CCQP Selected x Endline (reference)} \\\\ \\\\ \\hl{CCQP Not Selected x Endline}",
                               "CQP Did Not Apply x Endline",
                               "Baseline years of training$^1$",
                               "Firm Size$^2$",
                               "Total Apprentices in Firm"),
          title = "Effects of training on human capital development",
          omit.stat=c("aic", "bic", "adj.rsq", "ser"),
          dep.var.labels = c("Experience", "Competence", "Knowledge"),
          model.names = FALSE,
          dep.var.caption = "",
          label = "tab:tbl-appreg",
          add.lines = list(c("Trade FE", "NO", "NO", "YES", "NO", "NO", "YES", "NO", "NO", "YES")))

## ---- tbl-appreg2 --------

x <- df %>% filter(SELECTED != 3) %>% mutate(total_apps = selected + not_selected + did_not_apply,
                                             SELECTED = factor(SELECTED, levels = c(1, 0, 3), labels = c('CQP Selected', 'CQP Not Selected', 'Did Not Apply')))


m1 <- lm(exp_all_trades ~ as.factor(SELECTED) + as.factor(wave) + baseline_duration + firm_size_sans_app + total_apps, data = x)
m2 <- lm(exp_all_trades ~ as.factor(SELECTED) + as.factor(wave) + baseline_duration + firm_size_sans_app + total_apps + as.factor(FS1.2), data = x)
m3 <- lm(exp_all_trades ~ as.factor(SELECTED) + as.factor(wave) + did + baseline_duration + firm_size_sans_app + total_apps, data = x)
m4 <- lm(exp_all_trades ~ as.factor(SELECTED) + as.factor(wave) + did + baseline_duration + firm_size_sans_app + total_apps + as.factor(FS1.11), data = x)


m5 <- lm(comp_all_trades ~  as.factor(SELECTED) + as.factor(wave) + baseline_duration + firm_size_sans_app + total_apps, data = x)
m6 <- lm(comp_all_trades ~ as.factor(SELECTED) + as.factor(wave) + baseline_duration + firm_size_sans_app + total_apps + as.factor(FS1.2), data = x)
m7 <- lm(comp_all_trades ~ as.factor(SELECTED) + as.factor(wave) + did + baseline_duration + firm_size_sans_app + total_apps, data = x)
m8 <- lm(comp_all_trades ~ as.factor(SELECTED) + as.factor(wave) + did + baseline_duration + firm_size_sans_app + total_apps + as.factor(FS1.11), data = x)


stargazer(m1, m3, m4, m5, m7, m8, df = FALSE, omit = "FS1.11", font.size= "scriptsize", column.sep.width = "-4pt",
          no.space = TRUE, digits = 2, header = F, table.placement = "H",
          notes = c("$^{*}$p$<$0.1; $^{**}$p$<$0.05; $^{***}$p$<$0.01",
                    "\\textit{Notes:} Omitted category: CQP Selected.",
                    "$^1$Prior to 2019.",
                    "$^2$Excluding apprentices."),
          notes.label = "", 
          notes.align = "l", 
          notes.append = F,
          covariate.labels = c("CQP Selected (reference) \\\\ \\\\ CQP Not Selected",
                               "Endline",
                               "\\hl{CQP Selected x Endline (reference)} \\\\ \\\\ \\hl{CQP Not Selected x Endline}",
                               "Baseline years of training$^1$",
                               "Firm size$^2$",
                               "Total apprentices in firm"),
          title = "Effects of training on human capital, excluding CQP non-applicants",
          omit.stat=c("aic", "bic", "adj.rsq", "ser"),
          dep.var.labels = c("Experience", "Competence", "Knowledge"),
          model.names = FALSE,
          dep.var.caption = "",
          label = "tab:tbl-appreg2",
          add.lines = list(c("Trade FE", "NO", "NO", "YES", "NO", "NO", "YES")))

## ---- tbl-netappbenefits --------

x <- df %>% filter(wave == 0) %>% 
  mutate_at(c("a_fee_entry", "a_fee_formation", "a_fee_liberation", "a_fee_materials", "a_fee_contract", "a_fee_application", "total_fees", "fee_entry", "fee_formation", "fee_liberation", "fee_materials", "fee_contract", "fee_application", "a_total_fees"), ~./4/605) %>%
  mutate_at(c("allow_food", "allow_transport", "allow_pocket_money", "allow_other", "a_allow"), ~.*5*4*FS4.1/605) %>% mutate("a_allow" = a_allow/5) %>% mutate("annual_allowances" = annual_allowances/605) %>% 
  rowwise() %>% 
  mutate(a_net_benefits = sum(a_allow, -a_total_fees, na.rm = F),
         net_benefits = sum(annual_allowances, -total_fees, na.rm = F)) %>% ungroup() %>% 
  select("SELECTED",  "a_fee_entry", "a_fee_formation", "a_fee_liberation", "a_fee_materials", "a_fee_contract", "a_fee_application", "a_total_fees", "a_allow", "a_net_benefits", "fee_entry", "fee_formation", "fee_liberation", "fee_materials", "fee_contract", "fee_application", "total_fees", "allow_food", "allow_transport", "allow_pocket_money", "allow_other", "annual_allowances", "net_benefits") %>% 
  mutate(SELECTED = factor(SELECTED, levels = c(1, 0, 3), labels = c('CQP Selected', 'CQP Not Selected', 'Did Not Apply')))

#x <- x %>% replace(is.na(.), 0)

var_label(x$a_total_fees) <- "Total"
var_label(x$a_fee_entry) <- "Entry"
var_label(x$a_fee_formation) <- "Formation"
var_label(x$a_fee_liberation) <- "Liberation"
var_label(x$a_fee_materials) <- "Materials"
var_label(x$a_fee_contract) <- "Contract"
var_label(x$a_fee_application) <- "Application"
var_label(x$a_allow) <- "Allowances¹"
var_label(x$a_net_benefits) <- "Allowances net fees²"
var_label(x$total_fees) <- "Total"
var_label(x$fee_entry) <- "Entry"
var_label(x$fee_formation) <- "Formation"
var_label(x$fee_liberation) <- "Liberation"
var_label(x$fee_materials) <- "Materials"
var_label(x$fee_contract) <- "Contract"
var_label(x$fee_application) <- "Application"
var_label(x$annual_allowances) <- "Total"
var_label(x$allow_food) <- "Food"
var_label(x$allow_transport) <- "Transport"
var_label(x$allow_pocket_money) <- "Pocket money"
var_label(x$allow_other) <- "Other"
var_label(x$net_benefits) <- "Allowances net fees²"

tbl_summary(x, by = SELECTED,
            type = everything() ~ "continuous",
            statistic = all_continuous() ~ c("{mean} ({sd})"),
            missing = "no",
            digits = everything() ~ 2) %>% 
  add_overall() %>% 
  add_p(test = list(c("total_fees", "fee_entry", "fee_formation", "fee_liberation", "fee_materials", "fee_contract", "fee_application", "annual_allowances", "allow_food", "allow_transport", "allow_pocket_money", "allow_other", "net_benefits") ~ "aov",
                    c("a_total_fees", "a_fee_entry", "a_fee_formation", "a_fee_liberation", "a_fee_materials", "a_fee_contract", "a_fee_application", "a_allow", "a_net_benefits") ~ "t.test")) %>% 
  modify_footnote(update = everything() ~ NA) %>% 
  modify_header(update = list(all_stat_cols(FALSE) ~ "**{level}**",
                              stat_0 ~ "**Overall**",
                              p.value = "**p-value³**")) %>% 
  modify_table_body(~.x %>% 
                      dplyr::mutate(stat_3 = ifelse(stat_3 == "NA (NA)", "-", stat_3))) %>% 
  as_kable_extra(caption = "Annual costs and benefits accruing to apprentice",
                 booktabs = T,
                 linesep = "",
                 position = "H") %>% 
  kableExtra::group_rows(start_row = 1,
                         end_row = 9,
                         group_label = "Apprentice survey:") %>% 
  kableExtra::group_rows(start_row = 1,
                         end_row = 7,
                         group_label = "\\\\hspace{1em} Fees",
                         bold = F,
                         escape = F) %>%
  kableExtra::group_rows(start_row = 10,
                         end_row = 22,
                         group_label = "Firm survey:",
                         hline_before = T) %>% 
  kableExtra::group_rows(start_row = 10,
                         end_row = 16,
                         group_label = "\\\\hspace{1em} Fees",
                         bold = F,
                         escape = F) %>%
  kableExtra::group_rows(start_row = 17,
                         end_row = 21,
                         group_label = "\\\\hspace{1em} Allowances",
                         bold = F,
                         escape = F) %>%
  kableExtra::row_spec(c(9,22), bold=T) %>% 
  kableExtra::kable_styling(latex_options="scale_down") %>% 
  footnote(general = "\\\\textit{Notes:} Mean (SD). Amounts in \\\\$US per apprentice per year, calculated using responses from baseline survey. Annual fees assume apprenticeship duration of four years.",
           number = c("Apprentices were only asked about total allowances received.", "Rows missing all allowance or all fee data were excluded from net benefit calculation. Mean net benefit may deviate from difference in mean allowances and mean fees as a result.", "Student's t-test for apprentice survey data, analysis of variance for firm survey data"),
           threeparttable = T,
           escape = F,
           fixed_small_size = T,
           general_title = "")

## ---- tbl-netbenefits --------

x <- df %>% filter(wave == 0) %>% rowwise() %>% mutate_at(c("allow_food", "allow_transport", "allow_pocket_money", "allow_other"), ~.*5*4*FS4.1) %>% 
  mutate_at(c(vars(contains("FE5.1"))), ~.*FS4.1/FS6.1) %>% 
  select("FS1.2", "SELECTED", "annual_fees", "annual_app_prod", "total_benefits", "allow_food", "allow_transport", "allow_pocket_money", "allow_other", "annual_allowances", contains("FE5.1"), "annual_training_costs", "annual_foregone_prod", "total_costs", contains("cb")) %>%
  mutate_at(c("annual_fees", "annual_app_prod", "total_benefits", "allow_food", "allow_transport", "allow_pocket_money", "allow_other", "annual_allowances", "FE5.1_1", "FE5.1_2", "FE5.1_3", "FE5.1_4", "annual_training_costs", "annual_foregone_prod", "total_costs", "cb_I", "cb_II", "cb_III", "cb_IV", "cb_V"), ~./605) %>% ungroup() %>% 
  mutate(SELECTED = factor(SELECTED, levels = c(1, 0, 3), labels = c('CQP Selected', 'CQP Not Selected', 'Did Not Apply')))

var_label(x$annual_fees) <- "Fees¹"
var_label(x$annual_app_prod) <- "Apprentice prod."
var_label(x$total_benefits) <- "Total"
var_label(x$annual_allowances) <- "Total¹"
var_label(x$allow_food) <- "Food"
var_label(x$allow_transport) <- "Transport"
var_label(x$allow_pocket_money) <- "Pocket money"
var_label(x$allow_other) <- "Other"
var_label(x$annual_training_costs) <- "Total"
var_label(x$FE5.1_1) <- "Rent"
var_label(x$FE5.1_2) <- "Equipment"
var_label(x$FE5.1_3) <- "Books"
var_label(x$FE5.1_4) <- "Raw materials"
var_label(x$annual_foregone_prod) <- "Lost trainer prod."
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
  add_p(test = everything() ~ "aov") %>% 
  add_overall() %>% 
  add_n() %>% 
  modify_footnote(update = everything() ~ NA) %>% 
  modify_header(update = list(all_stat_cols(FALSE) ~ "**{level}**",
                              stat_0 ~ "**Overall**",
                              p.value = "**p-value²**")) %>% 
  as_kable_extra(caption = "Annual costs and benefits per apprentice accruing to firm",
                 booktabs = T,
                 linesep = "",
                 position = "H") %>%
  kableExtra::group_rows(start_row = 1,
                         end_row = 3,
                         group_label = "Benefits") %>% 
  kableExtra::group_rows(start_row = 4,
                         end_row = 15,
                         group_label = "Costs",
                         hline_before = T) %>% 
  kableExtra::group_rows(start_row = 4,
                         end_row = 8,
                         group_label = "\\\\hspace{1em} Allowances",
                         bold = F,
                         escape = F) %>% 
  kableExtra::group_rows(start_row = 9,
                         end_row = 13,
                         group_label = "\\\\hspace{1em} Training costs",
                         bold = F,
                         escape = F) %>% 
  kableExtra::group_rows(start_row = 16,
                         end_row = 20,
                         group_label = "Net Benefits",
                         hline_before = T) %>% 
  kableExtra::row_spec(c(3,15),bold=T) %>%

  kableExtra::kable_styling(latex_options="scale_down") %>% 
  footnote(general = "\\\\textit{Notes:} Mean (SD). Amounts in \\\\$US per apprentice per year. Calculated using responses from baseline survey, except training costs which were not elicited until endline. Net benefits are not computed for rows with missing data for any categories included in a given model. Mean net benefit estimates may deviate from sums of the relevant categories as a result.",
           number = c("Fees and allowances reported by firm owner. Annual fees assume apprenticeship duration of four years, annual allowances assume apprentices work 20 days a month.", "Analysis of variance"),
           threeparttable = T,
           escape = F,
           fixed_small_size = T,
           general_title = "")

## ---- tbl-cblong --------

x <- df %>% filter(wave == 0) %>% select(FS1.2, SELECTED, firm_size_bins, FS3.4, FS4.1, FS4.7, annual_app_prod, FS5.1, FS5.3, FS5.4, FS6.1, FS6.2, firm_size, profits, expenses, annual_fees, total_benefits, annual_allowances, total_training_costs, annual_foregone_prod, total_costs, contains("cb")) %>%
  group_by(FS1.2) %>% 
  summarise_all(mean, na.rm = T) %>% 
  ungroup() %>% 
  rowwise() %>% 
  mutate(annual_fees_extrap = FS6.1*annual_fees,
         apprentice_prod_extrap = FS6.1*annual_app_prod,
         total_benefits_extrap = FS6.1*total_benefits,
         annual_allowances_extrap = FS6.1*annual_allowances,
         total_training_costs = total_training_costs * FS4.1,
         annual_foregone_prod_extrap = FS6.1*annual_foregone_prod,
         total_costs_extrap = FS6.1*total_costs,
         cb_I_extrap = FS6.1*cb_I,
         cb_II_extrap = FS6.1*cb_II,
         cb_III_extrap = FS6.1*cb_III,
         cb_IV_extrap = FS6.1*cb_IV,
         cb_V_extrap = FS6.1*cb_V,
         annual_revenues = FS4.7 * FS4.1,
         annual_wage_bill = FS5.3 * FS4.1,
         annual_non_wage_exp = FS5.1 * FS4.1,
         annual_expenses = expenses * FS4.1,
         annual_rep_profits = FS5.4 * FS4.1,
         annual_profits = profits * FS4.1,
         # rep_profitsratio_I = ifelse(cb_I >=0 & FS4.1 > 0, cb_I/annual_rep_profits, NA),
         # rep_profitsratio_II = ifelse(cb_II >=0 & FS4.1 > 0, cb_II/annual_rep_profits, NA),
         # rep_profitsratio_III = ifelse(cb_III >=0 & FS4.1 > 0, cb_III/annual_rep_profits, NA),
         # rep_profitsratio_IV = ifelse(cb_IV >=0 & FS4.1 > 0, cb_IV/annual_rep_profits, NA),
         # rep_profitsratio_V = ifelse(cb_V >=0 & FS4.1 > 0, cb_V/annual_rep_profits, NA),
         # profitsratio_I = ifelse(cb_I >=0 & FS4.1 > 0, cb_I/annual_profits, NA),
         # profitsratio_II = ifelse(cb_II >=0 & FS4.1 > 0, cb_II/annual_profits, NA),
         # profitsratio_III = ifelse(cb_III >=0 & FS4.1 > 0, cb_III/annual_profits, NA),
         # profitsratio_IV = ifelse(cb_IV >=0 & FS4.1 > 0, cb_IV/annual_profits, NA),
         # profitsratio_V = ifelse(cb_V >=0 & FS4.1 > 0, cb_V/annual_profits, NA),
         # expratio_I = ifelse(cb_I <0 & FS5.1>total_training_costs & FS4.1 > 0, -cb_I/(FS5.1*FS4.1-total_training_costs), NA),
         # expratio_II = ifelse(cb_II <0 & FS5.1>total_training_costs & FS4.1 > 0, -cb_II/(FS5.1*FS4.1-total_training_costs), NA),
         # expratio_III = ifelse(cb_III <0 & FS5.1>total_training_costs & FS4.1 > 0, -cb_III/(FS5.1*FS4.1-total_training_costs), NA),
         # expratio_IV = ifelse(cb_IV <0 & FS5.1>total_training_costs & FS4.1 > 0, -cb_IV/(FS5.1*FS4.1-total_training_costs), NA),
         # expratio_V = ifelse(cb_V <0 & FS5.1>total_training_costs & FS4.1 > 0, -cb_V/(FS5.1*FS4.1-total_training_costs), NA),
         firm_size_bins = cut(firm_size, breaks = c(1,4,6,10,107))) %>% 
  mutate_at(vars(contains(c('annual', 'extrap')), total_training_costs), ~./605)

x %>% select(firm_size_bins, annual_revenues, annual_wage_bill, annual_non_wage_exp, annual_expenses, annual_rep_profits, annual_profits, annual_fees_extrap, apprentice_prod_extrap, total_benefits_extrap, annual_allowances_extrap, total_training_costs, annual_foregone_prod_extrap, total_costs_extrap, contains(c("extrap", 'ratio'))) %>% 
  tbl_summary(by = firm_size_bins,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no",
              digits = list(everything() ~ c(0, 0)),
              label = list(annual_revenues ~ "Revenues",
                           annual_wage_bill ~ "Wage bill",
                           annual_non_wage_exp ~ "Non-wage expenses",
                           annual_expenses ~ "Total expenses",
                           annual_rep_profits ~ "Profits (reported)",
                           annual_profits ~ "Profits² (calculated²)",
                           annual_fees_extrap ~ "Fees",
                           apprentice_prod_extrap ~ "Apprentice prod.",
                           total_benefits_extrap ~ "Total",
                           annual_allowances_extrap ~ "Allowances",
                           total_training_costs ~ "Training costs",
                           annual_foregone_prod_extrap ~ "Lost trainer prod.",
                           total_costs_extrap ~ "Total",
                           cb_I_extrap ~ "Model I",
                           cb_II_extrap ~ "Model II",
                           cb_III_extrap ~ "Model III",
                           cb_IV_extrap ~ "Model IV",
                           cb_V_extrap ~ "Model V")) %>% 
  add_overall() %>% 
  modify_header(label = "") %>% 
  modify_spanning_header(c(stat_1, stat_2, stat_3, stat_4) ~ "**Firm size¹**") %>% 
  modify_footnote(update = everything() ~ NA) %>%
  as_kable_extra(caption = "Annual net benefits per firm",
                 booktabs = T,
                 linesep = "",
                 position = "H") %>% 
  kableExtra::group_rows(start_row = 1,
                         end_row = 6,
                         group_label = "Firm Accounts") %>% 
  kableExtra::group_rows(start_row = 7,
                         end_row = 9,
                         group_label = "Projected benefits") %>% 
  kableExtra::group_rows(start_row = 10,
                         end_row = 13,
                         group_label = "Projected costs") %>% 
  kableExtra::group_rows(start_row = 14,
                         end_row = 18,
                         group_label = "Net benefits") %>% 
  kableExtra::kable_styling(latex_options="scale_down") %>% 
  footnote(general = "\\\\textit{Notes:} Mean (SD). Net benefits per firm estimated using baseline data. \nProjected costs, benefits, and net benefits calculated as mean values for all observed apprentices in \nfirm times reported number of apprentices trained. Amounts in \\\\$US.",
           number = c("Firms size calculated by author as sum of all reported workers in firm, including apprentices and occasional and family workers.",
                      "Profits recalculated by author as difference between reported revenues (first row) and reported expenses (second row)."),
           threeparttable = T,
           escape = F,
           fixed_small_size = T,
           general_title = "")

## ---- tbl-firmregs --------

x <- df %>% select(FS1.2, FS2.5_3_1, FS2.15, FS2.19, FS2.22, FS4.1, FS4.7, FS6.9, FS1.11, wave, firm_size_sans_app, selected, not_selected, did_not_apply, profits) %>% rowwise() %>% 
  mutate(wave = factor(wave, levels = 0:1, labels = c('Baseline', 'Endline')),
         age = 80-as.numeric(FS2.5_3_1),
         yos = ifelse(as.numeric(FS2.15)<23,as.numeric(FS2.15), NA),
         formal = ifelse(as.numeric(FS2.19) == 1, 1, ifelse(as.numeric(FS2.19) == 2, 0, NA)),
         assoc = 2-as.numeric(FS2.22),
         train_freq = as.numeric(FS6.9),
         revenues = FS4.7/605*FS4.1,
         profits = profits/605*FS4.1,
         apps_sans_cqp = sum(not_selected, did_not_apply, na.rm = T),
         total_apps = sum(selected, not_selected, did_not_apply, na.rm = T),
         trade = as.numeric(FS1.11)) %>%
  group_by(FS1.2, wave) %>% summarise_all(mean, na.rm = T) %>%
  mutate(apps_sans_cqp = ifelse(apps_sans_cqp > 0, log(apps_sans_cqp), NA),
         select = ifelse(selected > 0, log(selected), NA),
         revenues = ifelse(revenues > 0, log(revenues), NA),
         profits = ifelse(profits > 0, log(profits), NA),
         firm_size_sans_app = ifelse(firm_size_sans_app > 1, log(firm_size_sans_app), NA),
         did = (as.numeric(wave)-1)*selected)



m1 <- lm(revenues ~ selected + apps_sans_cqp + as.factor(wave), data = x)
m2 <- lm(revenues ~ selected + apps_sans_cqp + as.factor(wave) + firm_size_sans_app, data = x)
m3 <- lm(revenues ~ selected + apps_sans_cqp + as.factor(wave) + firm_size_sans_app + did, data = x)
m4 <- lm(revenues ~ selected + apps_sans_cqp + as.factor(wave) + firm_size_sans_app + did + age + yos + formal + assoc + train_freq + as.factor(trade), data = x)
m5 <- lm(profits ~ selected + apps_sans_cqp + as.factor(wave), data = x)
m6 <- lm(profits ~ selected + apps_sans_cqp + as.factor(wave) + firm_size_sans_app, data = x)
m7 <- lm(profits ~ selected + apps_sans_cqp + as.factor(wave) + firm_size_sans_app + did, data = x)
m8 <- lm(profits ~ selected + apps_sans_cqp + as.factor(wave) + firm_size_sans_app + did + age + yos + formal + assoc + train_freq + as.factor(trade), data = x)
m9 <- lm(firm_size_sans_app ~ selected + apps_sans_cqp + as.factor(wave), data = x)
m10 <- lm(firm_size_sans_app ~ selected + apps_sans_cqp + as.factor(wave) + did, data = x)
m11 <- lm(firm_size_sans_app ~ selected + apps_sans_cqp + as.factor(wave) + did + age + yos + formal + assoc + train_freq + as.factor(trade), data = x)
           
           
stargazer(m1, m2, m3, m4, m5, m6, m7, m8, m9, m10, m11, df = FALSE, omit = c("FS1.2", "trade)"), font.size= "scriptsize", column.sep.width = "-8pt",
          no.space = TRUE, digits = 2, header = F, table.placement = "H",
          notes = c("$^{*}$p$<$0.1; $^{**}$p$<$0.05; $^{***}$p$<$0.01", "\\textit{Notes:} $^1$Did not apply.", "$^2$Excluding apprentices.", "$^3$Registered with the Benin Chamber of Commerce and Industry (CCIB).", "$^4$Days firm stops all activities to train, per week."),
          notes.label = "", 
          notes.align = "l", 
          notes.append = F,
          covariate.labels = c("log No. of Apprentices: \\\\ \\\\
                               \\quad CQP Selected",
                               "\\quad CQP Not Selected/D.N.A.$^1$",
                               "Endline",
                               "log Firm Size$^2$",
                               "log CQP Selected x Endline",
                               "MC Age",
                               "MC Years of Schooling",
                               "Registered Firm$^3$",
                               "Trade Association",
                               "Training Frequency$^4$"),
          title = "Firm-level regressions",
          omit.stat=c("aic", "bic", "adj.rsq", "ser"),
          model.names = FALSE,
          dep.var.caption = "",
          dep.var.labels = c("log Revenues", "log Profits", "log Firm size$^1$"),
          label = "tab:tbl-firmregs",
          add.lines = list(c("Trade FE", "NO", "NO", "NO", "YES", "NO", "NO", "NO", "YES", "NO", "NO", "YES")))
