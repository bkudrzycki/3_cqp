## ---- tbl-attritionapps --------

x <- df %>% filter(wave == 0) %>% 
  mutate(baseline_status = SELECTED,
         baseline_exp = duration,
         baseline_trade = FS1.11,
  ) %>% select(IDYouth, baseline_status, baseline_exp, baseline_trade)

y <- df %>% left_join(x, by = "IDYouth")

y %>% select(wave, baseline_age, sex, schooling, baseline_status, baseline_exp, baseline_trade) %>%
  mutate(baseline_trade = factor(baseline_trade, levels = 1:5, labels = c('Masonry', 'Carpentry', 'Plumbing', 'Metalworking', 'Electrical Inst.')),
         baseline_status = factor(baseline_status, levels = c(1, 0, 3),
                                  labels = c('Selected', 'Not Selected', 'Did Not Apply')),
         wave = factor(wave, levels = 0:1, labels = c('Baseline', 'Endline'))) %>% 
  tbl_summary(by = wave,
              missing = "no",
              type = baseline_exp ~ "continuous",
              label = list(baseline_trade ~ "Trade",
                           sex ~ "Male",
                           baseline_age ~ "Age",
                           schooling ~ "Education",
                           baseline_status ~ "CQP status",
                           baseline_exp ~ "Training experience, years"),
              statistic = list(all_continuous() ~ "{mean} ({sd})",
                               all_categorical() ~ "{n} ({p}%)",
                               sex ~ "{p}%")) %>% add_p() %>% 
  as_kable_extra(caption = "Apprentice Attrition",
                 booktabs = T,
                 linesep = "",
                 position = "H")

## ---- tbl-attritionfirms --------

x <- df %>% filter(wave == 0) %>% 
  mutate(baseline_size = firm_size,
         baseline_calcsize = FS3.4,
         baseline_apps = FS6.1,
         baseline_sel = dossier_selected,
         baseline_notsel = dossier_apps-dossier_selected,
         baseline_dna = FS6.1-dossier_apps,
         baseline_wage = FS3.5_2,
         baseline_paid_fam = FS3.5_3,
         baseline_unpaid_fam = FS3.5_4,
         baseline_occ = FS3.5_5,
         baseline_trade = as.numeric(FS1.11),
  ) %>% select(FS1.2, contains("baseline"))

y <- df %>% left_join(x, by = "FS1.2")

y %>% select(FS1.2, wave, baseline_apps, baseline_sel, baseline_notsel, baseline_dna, baseline_size, baseline_calcsize, baseline_wage, baseline_paid_fam, baseline_unpaid_fam, baseline_occ, baseline_trade) %>%
  group_by(FS1.2, wave) %>% summarise_all(mean, na.rm = T) %>% ungroup() %>%
  mutate(wave = factor(wave, labels = c("Baseline", "Endline")),
         baseline_trade = factor(baseline_trade, levels = 1:5, labels = c('Masonry', 'Carpentry', 'Plumbing', 'Metalworking', 'Electrical Inst.'))) %>% 
  tbl_summary(by=wave,
              type = list(c(baseline_size, baseline_calcsize, baseline_apps, baseline_sel, baseline_notsel, baseline_dna, baseline_wage, baseline_paid_fam, baseline_unpaid_fam, baseline_occ)  ~ "continuous",
                          baseline_trade ~ "categorical"),
              statistic = list(all_continuous() ~ "{mean} ({sd})"),
              missing = "no",
              label = list(baseline_size ~ "Total (calculated)",
                           baseline_calcsize ~ "Total (reported)",
                           baseline_sel ~ "Selected",
                           baseline_notsel ~ "Not Selected",
                           baseline_dna ~ "Did Not Apply",
                           baseline_apps ~ "Total",
                           baseline_wage ~ "Permanent employees",
                           baseline_paid_fam ~ "Paid family workers",
                           baseline_unpaid_fam ~ "Unpaid family workers",
                           baseline_occ ~ "Occasional workers",
                           baseline_trade ~ "Trade"),
              include = -FS1.2) %>% 
  add_p() %>% 
  as_kable_extra(caption = "Firm Attrition",
                 booktabs = T,
                 linesep = "",
                 position = "H") %>% 
  kableExtra::group_rows(start_row = 1,
                         end_row = 4,
                         group_label = "Apprentices trained",
                         escape = F,
                         indent = T,
                         bold = F) %>% 
  kableExtra::group_rows(start_row = 5,
                         end_row = 10,
                         group_label = "Firm size",
                         escape = F,
                         indent = T,
                         bold = F)

## ---- tbl-skillschangebycqp --------

y <- df  %>% select(IDYouth, comp_all_trades, exp_all_trades, skills_all_trades, SELECTED, wave) %>% pivot_wider(names_from = wave, values_from = c(comp_all_trades, exp_all_trades, skills_all_trades)) %>% mutate(comp_diff = comp_all_trades_1-comp_all_trades_0, exp_diff = exp_all_trades_1-exp_all_trades_0, skills_diff = skills_all_trades_1-skills_all_trades_0)

tbl1 <- y %>% select(SELECTED, comp_diff, exp_diff) %>%
  mutate(SELECTED = factor(SELECTED, levels = c(1, 0, 3),
                           labels = c('CQP Selected', 'CQP Not Selected', 'Did Not Apply'))) %>% 
  tbl_summary(by = SELECTED, missing = "no",
              digits = list(everything() ~ 3),
              statistic = list(all_continuous() ~ "{mean} ({sd})"),
              label = list(comp_diff ~ "Competence¹",
                           exp_diff ~ "Experience¹")) %>% 
  add_p(test = everything() ~ "aov") %>% 
  modify_header(p.value = "**p-value³**",
                label = "") %>% 
  modify_footnote(update = everything() ~ NA)

z <- y %>% filter(SELECTED != 3) %>% mutate(SELECTED = factor(SELECTED, levels = c(1, 0),
                                                          labels = c('CQP Selected', 'CQP Not Selected')))

tbl2 <- z %>% select(SELECTED, comp_diff, exp_diff, skills_diff) %>% 
  tbl_summary(by = SELECTED, missing = "no",
              digits = list(everything() ~ 3),
              statistic = list(all_continuous() ~ "{mean} ({sd})"),
              label = list(comp_diff ~ "Competence¹",
                           exp_diff ~ "Experience¹",
                           skills_diff~ "Knowledge²")) %>% 
  add_p() %>% 
  modify_header(p.value = "**p-value³**",
                label = "") %>% 
  modify_footnote(update = everything() ~ NA) 

tbl_stack(list(tbl1, tbl2)) %>%  
  as_kable_extra(caption = "Change in apprentice human capital scores", 
                 booktabs = T,
                 linesep = "",
                 position = "H") %>% 
  kableExtra::kable_styling(latex_options="scale_down") %>% 
  footnote(general = "Mean (SD). Change in human capital indices between baseline and endline.",
           number = c("Percent of trade-specific tasks apprentice is deemed competent in (competence) or has already successfully attempted (experience), as reported by MC. Total of 10-15 tasks, depending on trade.", "Percent of trade-specific knowledge questions answered correctly by apprentice. Total of 4 or 5 questions, depending on trade.", "Analysis of variance for three groups, Wilcoxon rank sum test for two groups"),
           threeparttable = T,
           escape = F,
           general_title = "")


## ---- tbl-compexp2 --------

x <- df %>% filter(wave == 1, SELECTED != 3) %>% select(IDYouth, contains("comp"), -comp_dna, -a_comp_dna, -comp_all_trades, comp_all_trades) %>% pivot_longer(cols = contains("comp")) %>% mutate(side = ifelse(grepl("a_", name), "Apprentice", "Firm")) %>% mutate(name = str_remove_all(name, "a_")) %>% select(c(IDYouth, side, name, value)) %>% pivot_wider()

x <- x %>% left_join(df %>% filter(wave == 1, SELECTED != 3) %>% select(IDYouth, contains("exp"), -exp_dna, -a_exp_dna, -exp_all_trades, exp_all_trades) %>% pivot_longer(cols = contains("exp")) %>% mutate(side = ifelse(grepl("a_", name), "Apprentice", "Firm")) %>% mutate(name = str_remove_all(name, "a_")) %>% select(c(IDYouth, side, name, value)) %>% pivot_wider(), by = c("IDYouth", "side")) %>% mutate(ID = row_number())

var_label(x$comp_elec) <- "Electrical Installation"
var_label(x$comp_macon) <- "Masonry"
var_label(x$comp_menuis) <- "Carpentry"
var_label(x$comp_plomb) <- "Plumbing"
var_label(x$comp_metal) <- "Metalwork"
var_label(x$comp_cqp) <- "CQP Selected"
var_label(x$comp_notsel) <- "CQP Not Selected"
var_label(x$comp_all_trades) <- "Overall"
var_label(x$exp_elec) <- "Electrical Installation"
var_label(x$exp_macon) <- "Masonry"
var_label(x$exp_menuis) <- "Carpentry"
var_label(x$exp_plomb) <- "Plumbing"
var_label(x$exp_metal) <- "Metalwork"
var_label(x$exp_cqp) <- "CQP Selected"
var_label(x$exp_notsel) <- "CQP Not Selected"
var_label(x$exp_all_trades) <- "Overall"

comp <- x %>% select(tidyselect::vars_select(names(x), matches("comp")), side, ID) %>% 
  tbl_summary(by=side,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              digits = all_continuous() ~ 2,
              missing = "no",
              include = -ID) %>% 
  add_stat(
    fns = everything() ~ add_by_n
  ) %>% 
  modify_table_body(
    ~ .x %>%
      dplyr::relocate(add_n_stat_1, .before = stat_1) %>%
      dplyr::relocate(add_n_stat_2, .before = stat_2)
  )  %>%
  add_p(test = everything() ~ "wilcox.test") %>% 
  modify_header(stat_by =  "**{level}**",
                starts_with("add_n_stat") ~ "**N**",
                p.value = "**p-value³**",
                label = "**Trade**") %>% 
  modify_footnote(update = everything() ~ NA)

exp <- x %>% select(tidyselect::vars_select(names(x), matches("exp"), -expenses), side, IDYouth) %>% 
  tbl_summary(by=side,
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
      dplyr::relocate(add_n_stat_2, .before = stat_2)
  ) %>%
  add_p(test = everything() ~ "wilcox.test") %>% 
  modify_header(stat_by =  "**{level}**",
                starts_with("add_n_stat") ~ "**N**",
                p.value = "**p-value³**",
                label = "**Trade**") %>% 
  modify_footnote(update = everything() ~ NA)

tbl_stack(list(comp, exp), group_header = c("Competence", "Experience"), quiet = TRUE) %>% 
  as_kable_extra(caption = "Competence and experience, MC vs. apprentice assessment", 
                 booktabs = T,
                 linesep = "") %>% 
  kableExtra::row_spec(c(8,16),bold=T) %>% 
  kableExtra::kable_styling(latex_options="scale_down") %>% 
  footnote(general = "Mean (SD). Proportion of tasks reported by apprentices and firms at endline. Comparison only possibly at endline as apprentices were not asked to self-assess competence and experience at baseline.",
           number = c("Percent of trade-specific tasks apprentice is deemed competent in (competence) or has already successfully attempted (experience), as reported by MC. Total of 10-15 tasks, depending on trade.", "Percent of trade-specific knowledge questions answered correctly by apprentice. Total of 4 or 5 questions, depending on trade.", "Wilcoxon rank sum test"),
           threeparttable = T,
           escape = F,
           general_title = "")

## ---- tbl-appreg2 --------

x <- df %>% filter(SELECTED != 3) %>% mutate(total_apps = selected + not_selected + did_not_apply,
                                             SELECTED = factor(SELECTED, levels = c(1, 0, 3), labels = c('CQP Selected', 'CQP Not Selected', 'Did Not Apply')))


m1 <- lm(exp_all_trades ~ as.factor(SELECTED) + as.factor(wave) + baseline_duration + firm_size_sans_app + total_apps, data = x)
m2 <- lm(exp_all_trades ~ as.factor(SELECTED) + as.factor(wave) + baseline_duration + firm_size_sans_app + total_apps + as.factor(FS1.2), data = x)
m3 <- lm(exp_all_trades ~ as.factor(SELECTED) + as.factor(wave) + did + baseline_duration + firm_size_sans_app + total_apps, data = x)
m4 <- lm(exp_all_trades ~ as.factor(SELECTED) + as.factor(wave) + did + baseline_duration + firm_size_sans_app + total_apps + as.factor(FS1.2), data = x)


m5 <- lm(comp_all_trades ~  as.factor(SELECTED) + as.factor(wave) + baseline_duration + firm_size_sans_app + total_apps, data = x)
m6 <- lm(comp_all_trades ~ as.factor(SELECTED) + as.factor(wave) + baseline_duration + firm_size_sans_app + total_apps + as.factor(FS1.2), data = x)
m7 <- lm(comp_all_trades ~ as.factor(SELECTED) + as.factor(wave) + did + baseline_duration + firm_size_sans_app + total_apps, data = x)
m8 <- lm(comp_all_trades ~ as.factor(SELECTED) + as.factor(wave) + did + baseline_duration + firm_size_sans_app + total_apps + as.factor(FS1.2), data = x)


stargazer(m1, m3, m4, m5, m7, m8, df = FALSE, omit = "FS1.2", font.size= "small", column.sep.width = "-8pt",
          no.space = TRUE, digits = 2, header = F, table.placement = "H",
          notes = c("Omitted category: CQP Selected.",
                    "$^1$Years of training prior to 2019.",
                    "$^2$Excluding apprentices."),
          notes.align = "r",
          notes.append = TRUE,
          covariate.labels = c("CQP Not Selected",
                               "Endline",
                               "CQP Selected x Endline",
                               "Baseline experience$^1$",
                               "Firm size$^2$",
                               "Total apprentices in firm"),
          title = "Effects of Training on Human Capital, Excluding CQP Non Applicants",
          omit.stat=c("aic", "bic", "adj.rsq", "ser"),
          dep.var.labels = c("Experience", "Competence", "Knowledge"),
          model.names = FALSE,
          dep.var.caption = "",
          label = "tab:appreg",
          add.lines = list(c("Firm FE", "NO", "NO", "YES", "NO", "NO", "YES")))

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

## ---- tbl-fees2 --------

baseline <- df %>% filter(wave == 0) %>% select(c("fee_entry", "fee_formation", "fee_liberation", "fee_materials", "fee_contract", "fee_application", "total_fees", "SELECTED")) %>% 
  mutate(across(contains("fee"), ~./605)) %>% 
  mutate(SELECTED = factor(SELECTED, levels = c(1, 0, 3),
                           labels = c('CQP Selected', 'CQP Not Selected', 'Did Not Apply'))) %>% 
  tbl_summary(by=SELECTED,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no",
              digits = all_continuous() ~ 2) %>% 
  modify_footnote(update = everything() ~ NA)

endline <- df %>% filter(wave == 1) %>% select(c("fee_entry", "fee_formation", "fee_liberation", "fee_materials", "fee_contract", "fee_application", "total_fees", "SELECTED")) %>% 
  mutate(across(contains("fee"), ~./605)) %>% 
  mutate(SELECTED = factor(SELECTED, levels = c(1, 0, 3),
                           labels = c('CQP Selected', 'CQP Not Selected', 'Did Not Apply'))) %>% 
  tbl_summary(by=SELECTED,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no",
              digits = all_continuous() ~ 2) %>% 
  modify_footnote(update = everything() ~ NA)

overall <- df %>% select(c("fee_entry", "fee_formation", "fee_liberation", "fee_materials", "fee_contract", "fee_application", "total_fees", "SELECTED")) %>% 
  mutate(SELECTED = factor(SELECTED, levels = c(1, 0, 3),
                           labels = c('CQP Selected', 'CQP Not Selected', 'Did Not Apply'))) %>% 
  mutate(across(contains("fee"), ~./605)) %>% 
  tbl_summary(by=SELECTED,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no",
              digits = all_continuous() ~ 2) %>% 
  modify_footnote(update = everything() ~ NA)

tbl_stack(list(baseline, endline, overall), group_header = c("Baseline", "Endline", "Overall"), quiet = TRUE) %>% 
  as_kable_extra(caption = "Fees reported by firm", 
                 booktabs = T,
                 linesep = "",
                 position = "H") %>% 
  kableExtra::kable_styling(latex_options="scale_down") %>% 
  footnote(general = "Mean (SD). All fees are total amounts to be paid over the course of the apprenticeship. Amounts in \\\\$US.",
           threeparttable = T,
           escape = F,
           fixed_small_size = T,
           general_title = "")

## ---- tbl-allowances --------

baseline <- df %>% filter(wave == 0) %>% select(SELECTED, "allow_food", "allow_transport", "allow_pocket_money", "allow_other", "all_allowances") %>% 
  mutate(SELECTED = factor(SELECTED, levels = c(1, 0, 3),
                           labels = c('CQP Selected', 'CQP Not Selected', 'Did Not Apply'))) %>% 
  mutate_at(c("allow_food", "allow_transport", "allow_pocket_money", "allow_other", "all_allowances"), ~.*5*4/605) %>% 
  tbl_summary(by=SELECTED,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no",
              digits = all_continuous() ~ 2) %>% 
  add_overall() %>% 
  modify_header(stat_by =  "**{level}**") %>% 
  modify_footnote(update = everything() ~ NA)

endline <- df %>% filter(wave == 1) %>% select(SELECTED, "allow_food", "allow_transport", "allow_pocket_money", "allow_other", "all_allowances") %>% 
  mutate(SELECTED = factor(SELECTED, levels = c(1, 0, 3),
                           labels = c('CQP Selected', 'CQP Not Selected', 'Did Not Apply'))) %>% 
  mutate_at(c("allow_food", "allow_transport", "allow_pocket_money", "allow_other", "all_allowances"), ~.*5*4/605) %>%  
  tbl_summary(by=SELECTED,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no",
              digits = all_continuous() ~ 2) %>% 
  add_overall() %>% 
  modify_header(stat_by =  "**{level}**") %>% 
  modify_footnote(update = everything() ~ NA)

overall <- df %>% select(SELECTED, "allow_food", "allow_transport", "allow_pocket_money", "allow_other", "all_allowances") %>% 
  mutate(SELECTED = factor(SELECTED, levels = c(1, 0, 3),
                           labels = c('CQP Selected', 'CQP Not Selected', 'Did Not Apply'))) %>% 
  mutate_at(c("allow_food", "allow_transport", "allow_pocket_money", "allow_other", "all_allowances"), ~.*5*4/605) %>%  
  tbl_summary(by=SELECTED,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no",
              digits = all_continuous() ~ 2) %>% 
  add_overall() %>% 
  modify_header(stat_by =  "**{level}**") %>% 
  modify_footnote(update = everything() ~ NA)

tbl_stack(list(baseline, endline, overall), group_header = c("Baseline", "Endline", "Overall"), quiet = TRUE) %>% 
  as_kable_extra(caption = "Monthly allowances", 
                 booktabs = T,
                 linesep = "",
                 position = "H") %>% 
  footnote(general = "Mean (SD). Amounts in \\\\$US.",
           threeparttable = T,
           escape = F,
           fixed_small_size = T,
           general_title = "") %>% 
  kableExtra::kable_styling(latex_options="scale_down")

## ---- tbl-allowancebounds --------
# code upper and lower bounds

x <- df %>% mutate("allow_food_low" = allow_food, "allow_transport_low" = allow_transport, "allow_pocket_money_low" = allow_pocket_money, "allow_other_low" = allow_other, "allow_food_high" = allow_food, "allow_transport_high" = allow_transport, "allow_pocket_money_high" = allow_pocket_money, "allow_other_high" = allow_other)

x <- x %>% mutate_at(c("allow_food_low", "allow_transport_low", "allow_pocket_money_low", "allow_other_low"), recode,
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

x <- x %>% mutate_at(c("allow_food_high", "allow_transport_high", "allow_pocket_money_high", "allow_other_high"), recode,
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



x$all_allowances_high <- x %>% select(c("allow_food_high", "allow_transport_high", "allow_pocket_money_high", "allow_other_high")) %>% 
  rowSums(., na.rm = T)

x$all_allowances_low <- x %>% select(c("allow_food_low", "allow_transport_low", "allow_pocket_money_low", "allow_other_low")) %>% 
  rowSums(., na.rm = T)


x <- x %>% mutate_at(c("allow_food_high", "allow_transport_high", "allow_pocket_money_high", "allow_other_high", "all_allowances_high"), ~replace(., all_allowances_high == 0, NA))
x <- x %>% mutate_at(c("allow_food_low", "allow_transport_low", "allow_pocket_money_low", "allow_other_low", "all_allowances_low"), ~replace(., all_allowances_low == 0, NA))

x <- x %>% mutate("YS4.38_low" = YS4.38, "YS4.38_high" = YS4.38, "YE3.22_low" = YE3.22, "YE3.22_high" = YE3.22)

x <- x %>% mutate_at("YS4.38_low", recode,
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

x <- x %>% mutate_at("YE3.22_low", recode,
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

x <- x %>% mutate_at("YS4.38_high", recode,
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

x <- x %>% mutate_at("YE3.22_high", recode,
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

x$a_allow_low <- coalesce(x$YS4.38_low, x$YE3.22_low)

x$a_allow_high <- coalesce(x$YS4.38_high, x$YE3.22_high)

#coalesce days/week reported by apprentices

x <- x %>% mutate(YS4.10 = as.numeric(coalesce(YS4.10, YE3.15)))

x <- x %>% mutate(YS4.10 = as.double(YS4.10)) %>% select(wave, contains(c("all_allowances", "a_allow")), FS1.2, FS3.1, FS4.1, YS4.10) %>% rename(all_allowances_mid = all_allowances, a_allow_mid = a_allow) %>% 
  group_by(FS1.2, wave) %>% summarise_all(mean, na.rm = T) %>% ungroup()
x <- x[,c(2,5,3,4,7,6,8:11)] %>% mutate(wave = factor(wave, labels = c("Baseline", "Endline")))

x <- x %>% mutate_at(c("all_allowances_high", "all_allowances_mid", "all_allowances_low"), ~./605)

var_label(x$all_allowances_low) <- "lower"
var_label(x$all_allowances_mid) <- "mid"
var_label(x$all_allowances_high) <- "upper"
var_label(x$a_allow_low) <- "lower"
var_label(x$a_allow_mid) <- "mid"
var_label(x$a_allow_high) <- "upper"

tbl1 <- x %>% select(wave, contains("all_allow")) %>% mutate(across(contains("all_allow"), ~(.x*20*12))) %>% 
  tbl_summary(by = wave,
              statistic = all_continuous() ~ c("{mean} ({median})"),
              digits = all_continuous() ~ 2,
              missing = "no") %>%
  modify_header(label = "Bound") %>% 
  add_overall() %>% 
  modify_footnote(update = everything() ~ NA)

tbl2 <- x %>% select(wave, contains("all_allow"), FS4.1) %>% mutate(across(contains("all_allow"), ~(.x*20*FS4.1))) %>% 
  tbl_summary(by = wave,
              statistic = all_continuous() ~ c("{mean} ({median})"),
              digits = all_continuous() ~ 2,
              include = -FS4.1,
              missing = "no") %>%
  modify_header(label = "Bound") %>% 
  add_overall() %>% 
  modify_footnote(update = everything() ~ NA)

tbl3 <- x %>% select(wave, contains("all_allow"), FS3.1) %>% mutate(across(contains("all_allow"), ~(.x*4*FS3.1*12))) %>% 
  tbl_summary(by = wave,
              statistic = all_continuous() ~ c("{mean} ({median})"),
              digits = all_continuous() ~ 2,
              include = -FS3.1,
              missing = "no") %>%
  modify_header(label = "Bound") %>% 
  add_overall() %>% 
  modify_footnote(update = everything() ~ NA)

tbl4 <- x %>% select(wave, contains("all_allow"), FS3.1, FS4.1) %>% mutate(across(contains("all_allow"), ~(.x*4*FS3.1*FS4.1))) %>% 
  tbl_summary(by = wave,
              statistic = all_continuous() ~ c("{mean} ({median})"),
              digits = all_continuous() ~ 2,
              include = -c(FS3.1, FS4.1),
              missing = "no") %>%
  modify_header(label = "Bound") %>% 
  add_overall() %>% 
  modify_footnote(update = everything() ~ NA)

tbl5 <- x %>% select(wave, contains("all_allow"), YS4.10) %>% mutate(across(contains("all_allow"), ~(.x*4*YS4.10*12))) %>% 
  tbl_summary(by = wave,
              statistic = all_continuous() ~ c("{mean} ({median})"),
              digits = all_continuous() ~ 2,
              include = -YS4.10,
              missing = "no") %>%
  modify_header(label = "Bound") %>% 
  add_overall() %>% 
  modify_footnote(update = everything() ~ NA)

tbl6 <- x %>% select(wave, contains("all_allow"), FS4.1, YS4.10) %>% mutate(across(contains("all_allow"), ~(.x*4*YS4.10*FS4.1))) %>% 
  tbl_summary(by = wave,
              statistic = all_continuous() ~ c("{mean} ({median})"),
              digits = all_continuous() ~ 2,
              include = -c(FS4.1, YS4.10),
              missing = "no") %>%
  modify_header(label = "Bound") %>% 
  add_overall() %>% 
  modify_footnote(update = everything() ~ NA)

tbl_stack(list(tbl1, tbl2, tbl3, tbl4, tbl5, tbl6), group_header = c("12 months/year |\n 20 days/month", "(F) months/year |\n 20 days/month", "12 months/year |\n 4 x (F) weeks/month", "(F) months/year |\n 4 x (F) weeks/month", "12 months/year |\n 4 x (A) weeks/month", "firm months |\n 4 x (A) weeks/month")) %>%
  modify_header(groupname_col = "Assumption") %>% 
  as_kable_extra(caption = "Allowances per apprentice per year, reported by firm",
                 booktabs = T,
                 linesep = "",
                 position = "H") %>% #cost per apprentice per year
  footnote(general = "Mean (Median). (F): reported by firm; (A): reported by apprentices. Amounts in \\\\$US.",
           threeparttable = T,
           escape = F,
           fixed_small_size = T,
           general_title = "") %>% 
  kableExtra::kable_styling(latex_options="scale_down")

## ---- tbl-allowboundsapp -------- 

var_label(x$a_allow_low) <- "lower"
var_label(x$a_allow_mid) <- "mid"
var_label(x$a_allow_high) <- "upper"

tbl7 <- x %>% select(wave, contains("a_allow")) %>% mutate(across(contains("a_allow"), ~(.x*4*12/605))) %>%
  tbl_summary(by = wave,
              statistic = all_continuous() ~ c("{mean} ({median})"),
              digits = all_continuous() ~ 2,
              missing = "no") %>%
  modify_header(label = "Bound") %>%
  add_overall()

tbl8 <- x %>% select(wave, contains("a_allow"), FS4.1) %>% mutate(across(contains("a_allow"), ~(.x*4*FS4.1/605))) %>%
  tbl_summary(by = wave,
              statistic = all_continuous() ~ c("{mean} ({median})"),
              digits = all_continuous() ~ 2,
              include = -FS4.1,
              missing = "no") %>%
  modify_header(label = "Bound") %>%
  add_overall()

tbl_stack(list(tbl7, tbl8), group_header = c("12 months/year |\n 4 weeks/month", "(F) months/year |\n 4 weeks/month")) %>%
  modify_header(groupname_col = "Assumption") %>% 
  as_kable_extra(caption = "Allowances per apprentice per year, reported by apprentice", 
                 booktabs = T,
                 linesep = "",
                 position = "H") %>% 
  footnote(general = "Mean (Median). (F): reported by firm; (A): reported by apprentices. Amounts in \\\\$US.",
           threeparttable = T,
           escape = F,
           fixed_small_size = T,
           general_title = "") %>% 
  kableExtra::kable_styling(latex_options="scale_down")

## ---- tbl-wages --------

df %>% select(contains("FS5.2"), wave, FS1.2) %>%
  mutate(wave = factor(wave, levels = 0:1, labels = c('Baseline', 'Endline'))) %>% 
  group_by(FS1.2, wave) %>% summarise_all(mean, na.rm = T) %>% ungroup() %>% 
  mutate(across(contains('FS5.2'), ~./605)) %>% 
  tbl_summary(by=wave,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no",
              include = -FS1.2,
              digits = list(everything() ~ c(0, 0)),
              label = list(FS5.2_1_7 ~ "Firm owner",
                           FS5.2_1_1 ~ "Former apprentice (diff. workshop)",
                           FS5.2_1_2 ~ "Former apprentice (same workshop)",
                           FS5.2_1_3 ~ "Worker with secondary educ. or more",
                           FS5.2_1_4 ~ "Worker with primary educ. or less",
                           FS5.2_1_5 ~ "Paid family worker",
                           FS5.2_1_6 ~ "Occassional worker",
                           FS5.2_1_8 ~ "Traditional apprentice (first year)",
                           FS5.2_1_9 ~ "Traditional apprentice (third year)",
                           FS5.2_1_10 ~ "CQP apprentice (first year)",
                           FS5.2_1_11 ~ "CQP apprentice (third year)"))  %>% 
  add_stat(
    fns = everything() ~ add_by_n
  ) %>% 
  modify_table_body(
    ~ .x %>%
      dplyr::relocate(add_n_stat_1, .before = stat_1) %>%
      dplyr::relocate(add_n_stat_2, .before = stat_2)
  ) %>%
  modify_header(stat_by =  "**{level}**",
                starts_with("add_n_stat") ~ "**N**",
                label = "") %>% 
  modify_footnote(
    all_stat_cols() ~ "Mean (SD). Monthly wages in \\\\$US."
  ) %>% 
  as_kable_extra(caption = "Monthly wages", 
                 booktabs = T,
                 linesep = "")

## ---- tbl-netbenefitsbywave --------

var_label(df$cb_I) <- "Model I"
var_label(df$cb_II) <- "Model II"
var_label(df$cb_III) <- "Model III"
var_label(df$cb_IV) <- "Model IV"
var_label(df$cb_V) <- "Model V"

bl <- df %>% filter(wave == 0) %>% select(cb_I, cb_II, cb_III, cb_IV, cb_V, IDYouth, SELECTED) %>% 
  mutate_at(c("cb_I", "cb_II", "cb_III", "cb_IV", "cb_V"), ~./605) %>% ungroup() %>% 
  mutate(SELECTED = factor(SELECTED, levels = c(1, 0, 3),
                           labels = c('CQP Selected', 'CQP Not Selected', 'Did Not Apply'))) %>% 
  tbl_summary(by=SELECTED,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no",
              digits = all_continuous() ~ 2,
              include = -IDYouth) %>% 
  modify_header(stat_by =  "**{level}**",
                label = "") %>% 
  add_overall() %>% 
  modify_footnote(update = everything() ~ NA) 

el <- df %>% filter(wave == 1) %>% select(cb_I, cb_II, cb_III, cb_IV, cb_V, IDYouth, SELECTED) %>% 
  mutate(cb_II = cb_II/605,
         cb_V = cb_V/605) %>% 
  mutate(SELECTED = factor(SELECTED, levels = c(1, 0, 3),
                           labels = c('CQP Selected', 'CQP Not Selected', 'Did Not Apply'))) %>% 
  tbl_summary(by=SELECTED,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no",
              digits = all_continuous() ~ 2,
              include = -IDYouth) %>% 
  modify_header(stat_by =  "**{level}**",
                label = "") %>% 
  add_overall() %>% 
  modify_footnote(update = everything() ~ NA) 

overall <- df %>% select(cb_I, cb_II, cb_III, cb_IV, cb_V, IDYouth, SELECTED) %>% 
  mutate(cb_II = cb_II/605,
         cb_V = cb_V/605) %>% 
  mutate(SELECTED = factor(SELECTED, levels = c(1, 0, 3),
                           labels = c('CQP Selected', 'CQP Not Selected', 'Did Not Apply'))) %>% 
  tbl_summary(by=SELECTED,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no",
              digits = all_continuous() ~ 2,
              include = -IDYouth) %>% 
  modify_header(stat_by =  "**{level}**",
                label = "") %>% 
  add_overall() %>% 
  modify_footnote(update = everything() ~ NA) 

tbl_stack(list(bl, el, overall), group_header = c("Baseline", "Endline", "Overall"), quiet = TRUE) %>% 
  as_kable_extra(caption = "Net benefits", 
                 booktabs = T,
                 linesep = "",
                 position = "H") %>% 
  kableExtra::kable_styling(latex_options="scale_down") %>% 
  footnote(general = "Mean (SD). Amounts in \\\\$US per apprentice per year.",
           threeparttable = T,
           escape = F,
           fixed_small_size = T,
           general_title = "")

## ---- tbl-appnetbenefitsbytrade --------

x <- df %>% filter(wave == 0) %>% rowwise() %>% mutate_at(c("fee_entry", "fee_formation", "fee_liberation", "fee_materials", "fee_contract", "fee_application"), ~./4) %>% mutate_at(c("allow_food", "allow_transport", "allow_pocket_money", "allow_other"), ~.*5*4*FS4.1) %>% 
  mutate_at(c(vars(contains("FE5.1"))), ~.*FS4.1/FS6.1) %>% 
  select("FS1.2", "FS1.11", "annual_fees", "fee_entry", "fee_formation", "fee_liberation", "fee_materials", "fee_contract", "fee_application", "annual_app_prod", "total_benefits", "annual_allowances", "allow_food", "allow_transport", "allow_pocket_money", "allow_other", "annual_training_costs", contains("FE5.1"), "annual_foregone_prod", "total_costs", contains("cb")) %>%
  mutate_at(c("annual_fees", "fee_entry", "fee_formation", "fee_liberation", "fee_materials", "fee_contract", "fee_application", "annual_app_prod", "total_benefits", "annual_allowances", "allow_food", "allow_transport", "allow_pocket_money", "allow_other", "annual_training_costs", "FE5.1_1", "FE5.1_2", "FE5.1_3", "FE5.1_4", "annual_foregone_prod", "total_costs", "cb_I", "cb_II", "cb_III", "cb_IV", "cb_V"), ~./605) %>% ungroup()

var_label(x$annual_fees) <- "Fees¹"
var_label(x$fee_entry) <- "Entry"
var_label(x$fee_formation) <- "Formation"
var_label(x$fee_liberation) <- "Liberation"
var_label(x$fee_materials) <- "Materials"
var_label(x$fee_contract) <- "Contract"
var_label(x$fee_application) <- "Application"
var_label(x$annual_app_prod) <- "Apprentice prod."
var_label(x$total_benefits) <- "Total"
var_label(x$annual_allowances) <- "Allowances¹"
var_label(x$allow_food) <- "Food"
var_label(x$allow_transport) <- "Transport"
var_label(x$allow_pocket_money) <- "Pocket money"
var_label(x$allow_other) <- "Other"
var_label(x$annual_training_costs) <- "Training costs"
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

tbl_summary(x, by = FS1.11,
            type = everything() ~ "continuous",
            statistic = all_continuous() ~ c("{mean} ({sd})"),
            include = -c(FS1.2),
            missing = "no",
            digits = everything() ~ 2) %>% 
  add_overall() %>% 
  add_p() %>%
  modify_header(label = "") %>% 
  modify_spanning_header(c(stat_1, stat_2, stat_3, stat_4) ~ "**Trade**") %>% 
  modify_footnote(update = everything() ~ NA) %>% 
  modify_header(update = list(all_stat_cols(FALSE) ~ "**{level}**",
                              stat_0 ~ "**Overall**")) %>% 
  as_kable_extra(caption = "Annual costs and benefits by trade",
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
  kableExtra::row_spec(c(9,21),bold=T) %>% 
  kableExtra::kable_styling(latex_options="scale_down") %>% 
  footnote(general = "Mean (SD). Amounts in \\\\$US per apprentice per year, calculated using responses from baseline survey.",
           number = "Fees and allowances reported by firm owner. Annual fees assume apprenticeship duration of four years, annual allowances assume 20-day apprentice workweek.",
           threeparttable = T,
           escape = F,
           fixed_small_size = T,
           general_title = "")

## ---- tbl-firmnetbenefitsbytrade --------

x <- df %>% filter(wave == 0) %>% select(FS1.2, FS1.11, FS3.4, FS4.1, FS4.7, annual_app_prod, FS5.1, FS5.3, FS5.4, FS6.1, FS6.2, firm_size, profits, expenses, annual_fees, total_benefits, annual_allowances, annual_training_costs, annual_foregone_prod, total_costs, contains("cb")) %>%
  mutate(FS1.11 = as.numeric(FS1.11)) %>% 
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
         annual_wage_bill = FS5.3 * FS4.1,
         annual_non_wage_exp = FS5.1 * FS4.1,
         annual_expenses = expenses * FS4.1,
         annual_rep_profits = FS5.4 * FS4.1,
         annual_profits = profits * FS4.1,
         firm_size_bins = cut(firm_size, breaks = c(1,4,6,10,107))) %>% 
  mutate_at(vars(contains(c('annual', 'extrap'))), ~./605) %>% 
  mutate(FS1.11 = factor(FS1.11, levels = c(1:5), labels = c("Masonry", "Carpentry", "Plumbing", "Metalwork", "Electrical Inst.")))

x %>% select(FS1.11, annual_revenues, annual_wage_bill, annual_non_wage_exp, annual_expenses, annual_rep_profits, annual_profits, annual_fees_extrap, apprentice_prod_extrap, total_benefits_extrap, annual_allowances_extrap, annual_training_costs_extrap, annual_foregone_prod_extrap, total_costs_extrap, contains("extrap")) %>% 
  tbl_summary(by = FS1.11,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no",
              digits = list(everything() ~ c(0, 0)),
              label = list(annual_revenues ~ "Revenues",
                           annual_wage_bill ~ "Wage bill",
                           annual_non_wage_exp ~ "Non-wage expenses",
                           annual_expenses ~ "Total expenses",
                           annual_rep_profits ~ "Profits (reported)",
                           annual_profits ~ "Profits (calculated²)",
                           annual_fees_extrap ~ "Fees",
                           apprentice_prod_extrap ~ "Apprentice prod.",
                           total_benefits_extrap ~ "Total",
                           annual_allowances_extrap ~ "Allowances",
                           annual_training_costs_extrap ~ "Training costs",
                           annual_foregone_prod_extrap ~ "Lost trainer prod.",
                           total_costs_extrap ~ "Total",
                           cb_I_extrap ~ "Model I",
                           cb_II_extrap ~ "Model II",
                           cb_III_extrap ~ "Model III",
                           cb_IV_extrap ~ "Model IV",
                           cb_V_extrap ~ "Model V")) %>% 
  add_overall() %>% 
  add_p() %>% 
  modify_header(label = "") %>% 
  modify_spanning_header(c(stat_1, stat_2, stat_3, stat_4) ~ "**Trade**") %>% 
  modify_footnote(update = everything() ~ NA) %>%
  as_kable_extra(caption = "Annual net benefits per firm",
                 booktabs = T,
                 linesep = "",
                 position = "H") %>% 
  kableExtra::group_rows(start_row = 1,
                         end_row = 6,
                         group_label = "Firm Accounts") %>% 
  kableExtra::group_rows(start_row = 7,
                         end_row = 10,
                         group_label = "Projected benefits") %>% 
  kableExtra::group_rows(start_row = 11,
                         end_row = 13,
                         group_label = "Projected costs") %>% 
  kableExtra::group_rows(start_row = 14,
                         end_row = 18,
                         group_label = "Net benefits") %>% 
  kableExtra::kable_styling(latex_options="scale_down") %>% 
  footnote(general = "Mean (SD). Net benefits per firm estimated using baseline data. \nProjected costs, benefits, and net benefits calculated as mean values for all observed apprentices in \nfirm times reported number of apprentices trained. Density on y-axis. Amounts in \\\\$US.",
           number = c("Firms size calculated by author as sum of all reported workers in firm, including apprentices and occasional and family workers.",
                      "Profits recalculated by author as difference between reported revenues (first row) and reported expenses (second row)."),
           threeparttable = T,
           escape = F,
           fixed_small_size = T,
           general_title = "")
