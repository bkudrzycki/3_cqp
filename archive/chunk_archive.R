  ```{r anova}

data <- df %>% select(IDYouth, comp_all_trades, exp_all_trades, skills_all_trades, SELECTED, wave)

res.aov <- anova_test(
  data = data, dv = comp_all_trades, wid = IDYouth,
  between = SELECTED, within = wave
)
get_anova_table(res.aov)

res.aov <- anova_test(
  data = data, dv = exp_all_trades, wid = IDYouth,
  between = SELECTED, within = wave
)
get_anova_table(res.aov)

res.aov <- anova_test(
  data = data, dv = skills_all_trades, wid = IDYouth,
  between = SELECTED, within = wave
)
get_anova_table(res.aov)
```

``` {r improvement1, fig.width=7,fig.height=4, fig.cap = "Change in apprentice human capital scores, pooled at trade level first", fig.pos='H'}
x <- df %>% select(IDYouth, comp_all_trades, exp_all_trades, skills_all_trades, FS1.11, wave) %>% pivot_wider(names_from = wave, values_from = c(comp_all_trades, exp_all_trades, skills_all_trades)) %>% group_by(FS1.11) %>% summarise_all(mean, na.rm = T) %>% mutate(comp_diff = ifelse(comp_all_trades_0 != 0, (comp_all_trades_1-comp_all_trades_0)/comp_all_trades_0*100, 1), exp_diff = ifelse(exp_all_trades_0 > 0, (exp_all_trades_1-exp_all_trades_0)/exp_all_trades_0*100, 1), skills_diff = ifelse(skills_all_trades_0 != 0, (skills_all_trades_1-skills_all_trades_0)/skills_all_trades_0*100), 1) %>% pivot_longer(cols = c(comp_diff, exp_diff, skills_diff))

x <- x %>% rbind(x %>% mutate(FS1.11 = NA)) %>% mutate(FS1.11 = ifelse(is.na(FS1.11), 6, FS1.11)) %>% 
  select(FS1.11, name, value) %>% group_by(FS1.11, name) %>% summarise_all(mean, na.rm = T)

ggplot(data=x, aes(x=FS1.11, y=value, fill=name)) +
  geom_bar(stat="identity", color="black", position=position_dodge()) +
  labs(x = "", y = "Percent change") + scale_fill_viridis_d(name = "", labels = c("Competence", "Experience", "Knowledge")) +
  theme_minimal() + scale_x_discrete(limits = c("Masonry", "Carpentry", "Plumbing",  "Metalwork", "Electrical Inst.", "Overall"))

```

```{r compexpdiff}
comp <- df %>% select(contains("comp"), -contains("a_"), wave, IDYouth, SELECTED) %>%
  pivot_wider(names_from = wave,
              values_from = contains("comp")) %>%
  mutate(comp_elec = comp_elec_1-comp_elec_0,
         comp_macon = comp_macon_1-comp_macon_0,
         comp_menuis = comp_menuis_1-comp_menuis_0,
         comp_plomb = comp_plomb_1-comp_plomb_0,
         comp_metal = comp_metal_1-comp_metal_0,
         comp_all_trades = comp_all_trades_1-comp_all_trades_0) %>%
  select(comp_elec, comp_macon, comp_menuis, comp_plomb, comp_metal, comp_all_trades, SELECTED) %>% 
  mutate(SELECTED = factor(SELECTED, levels = c(1, 0, 3),
                           labels = c('Selected', 'Not Selected', 'Did Not Apply'))) %>% 
  tbl_summary(by=SELECTED,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no") %>% 
  add_stat(
    fns = everything() ~ add_by_n
  ) %>% 
  modify_table_body(
    ~ .x %>%
      dplyr::relocate(add_n_stat_1, .before = stat_1) %>%
      dplyr::relocate(add_n_stat_2, .before = stat_2) %>% 
      dplyr::relocate(add_n_stat_3, .before = stat_3)
  ) %>%
  modify_header(stat_by =  "**{level}**",
                starts_with("add_n_stat") ~ "**N**",
                label = "**Trade**") %>% 
  modify_footnote(
    all_stat_cols() ~ "Mean (SD). Change in scores over time."
  ) 

exp <- df %>% select(contains("exp"), -contains("a_"), wave, IDYouth, SELECTED) %>%
  pivot_wider(names_from = wave,
              values_from = contains("exp")) %>%
  mutate(exp_elec = exp_elec_1-exp_elec_0,
         exp_macon = exp_macon_1-exp_macon_0,
         exp_menuis = exp_menuis_1-exp_menuis_0,
         exp_plomb = exp_plomb_1-exp_plomb_0,
         exp_metal = exp_metal_1-exp_metal_0,
         exp_all_trades = exp_all_trades_1-exp_all_trades_0) %>%
  select(exp_elec, exp_macon, exp_menuis, exp_plomb, exp_metal, exp_all_trades, SELECTED) %>% 
  mutate(SELECTED = factor(SELECTED, levels = c(1, 0, 3),
                           labels = c('Selected', 'Not Selected', 'Did Not Apply'))) %>% 
  tbl_summary(by=SELECTED,
              type = everything() ~ "continuous",
              statistic = all_continuous() ~ c("{mean} ({sd})"),
              missing = "no") %>% 
  add_stat(
    fns = everything() ~ add_by_n
  ) %>% 
  modify_table_body(
    ~ .x %>%
      dplyr::relocate(add_n_stat_1, .before = stat_1) %>%
      dplyr::relocate(add_n_stat_2, .before = stat_2) %>% 
      dplyr::relocate(add_n_stat_3, .before = stat_3)
  ) %>%
  modify_header(stat_by =  "**{level}**",
                starts_with("add_n_stat") ~ "**N**",
                label = "**Trade**") %>% 
  modify_footnote(
    all_stat_cols() ~ "Mean (SD). Change in proportion of tasks over time."
  )

tbl_stack(list(comp, exp), group_header = c("Comp.", "Exp."), quiet = TRUE) %>% 
  as_kable_extra(caption = "Changes in competency and experience scores by CQP status", 
                 booktabs = T,
                 linesep = "",
                 position = "H")
```

```{r prodreg2, results = 'asis'}
x <- df %>% select(FS1.2, wave, firm_size, dossier_selected, FS4.7, FS5.4, FS6.1, profits) %>%
  mutate(wave = factor(wave, levels = 0:1, labels = c('Baseline', 'Endline'))) %>% 
  group_by(FS1.2, wave) %>% summarise_all(mean, na.rm = T) %>% ungroup() %>% pivot_wider(names_from = wave, values_from = c(firm_size, FS6.1, FS4.7, FS5.4, FS6.1, profits)) %>% 
  mutate(diff_firm_size = firm_size_Endline-firm_size_Baseline,
         diff_tot_apps = FS6.1_Endline-FS6.1_Baseline,
         diff_revenues = FS4.7_Endline-FS4.7_Baseline,
         diff_profits_rep = FS5.4_Endline-FS5.4_Baseline,
         diff_profits_calc = profits_Endline-profits_Baseline)

m1 <- lm(diff_revenues ~ dossier_selected + diff_tot_apps + diff_firm_size, data = x)
m2 <- lm(diff_profits_rep ~ dossier_selected + diff_tot_apps + diff_firm_size, data = x)
m3 <- lm(diff_profits_calc ~ dossier_selected + diff_tot_apps + diff_firm_size, data = x)

stargazer(m1, m2, m3, df = FALSE, model.names = FALSE, model.numbers = FALSE,
          no.space = TRUE, digits = 0, header = F, table.placement = "H",
          covariate.labels = c("CQP trainees",
                               "Total apprentices",
                               "Baseline firm size"),
          dep.var.labels = c('Revenues', 'Profits', 'Profits'),
          title = "Firm Growth",
          column.labels= c('', '(Reported)', '(Computed)'))
```


```{r skillreg1, results = 'asis'}
df$cqp_dummy <- ifelse(df$SELECTED == 1, 1, 0)
df$did <- df$wave * df$cqp_dummy

m1 <- lm(skills_all_trades ~ factor(SELECTED) + factor(FS1.2), data = df)
m2 <- lm(skills_all_trades ~ factor(SELECTED) + wave + did + factor(FS1.2), data = df)
m3 <- lm(skills_all_trades ~ factor(SELECTED) + wave + did + baseline_duration + factor(FS1.2), data = df)
m4 <- lm(skills_all_trades ~ factor(SELECTED) + wave + did + baseline_duration + firm_size + FS6.1 + dossier_selected + factor(FS1.2), data = df) #FS6.1: number apprentices
m5 <- lm(skills_all_trades ~ factor(SELECTED) + wave + did + baseline_duration + firm_size + FS6.1 + dossier_selected + FS6.8 + FS6.9 + FS6.10 + ext_training + factor(FS1.2), data = df)



stargazer(m1, m2, m3, m4, m5, omit = "FS1.2", df = FALSE, model.names = FALSE, model.numbers = FALSE,
          no.space = TRUE, digits = 3, header = F, table.placement = "H",
          covariate.labels = c("Selected into CQP",
                               "Wave",
                               "CQP x Wave",
                               "Years in training at baseline",
                               "Firm size",
                               "Total apprentices",
                               "CQP apprentices",
                               "Total instructors",
                               "Days trained per week",
                               "Duration, last training",
                               "External training"),
          label = "skillsreg1",
          title = "Apprentice Knowledge 1",
          dep.var.labels = "Fraction of correctly answered skills questions (with firm FE)",
          add.lines = list(c("Firm FE", "YES", "YES", "YES", "YES", "YES")))
```

```{r skillreg2, results = 'asis'}
df$cqp_dummy <- ifelse(df$SELECTED == 1, 1, 0)
df$did <- df$wave * df$cqp_dummy

m1 <- lm(skills_all_trades ~ factor(SELECTED), data = df)
m2 <- lm(skills_all_trades ~ factor(SELECTED) + wave + did, data = df)
m3 <- lm(skills_all_trades ~ factor(SELECTED) + wave + did + baseline_duration, data = df)
m4 <- lm(skills_all_trades ~ factor(SELECTED) + wave + did + baseline_duration + firm_size + FS6.1 + dossier_selected, data = df) #FS6.1: number apprentices
m5 <- lm(skills_all_trades ~ factor(SELECTED) + wave + did + baseline_duration + firm_size + FS6.1 + dossier_selected + FS6.8 + FS6.9 + FS6.10 + ext_training, data = df)



stargazer(m1, m2, m3, m4, m5, df = FALSE, model.names = FALSE, model.numbers = FALSE,
          no.space = TRUE, digits = 3, header = F, table.placement = "H",
          covariate.labels = c("Selected into CQP",
                               "Wave",
                               "CQP x Wave",
                               "Years in training at baseline",
                               "Firm size",
                               "Total apprentices",
                               "CQP apprentices",
                               "Total instructors",
                               "Days trained per week",
                               "Duration, last training",
                               "External training"),
          label = "skillsreg2",
          title = "Apprentice Knowledge 2",
          dep.var.labels = "Fraction of correctly answered skills questions",
          add.lines = list(c("Firm FE", "NO", "NO", "NO", "NO", "NO")))
```

```{r compreg1, results = 'asis'}
df$cqp_dummy <- ifelse(df$SELECTED == 1, 1, 0)
df$did <- df$wave * df$cqp_dummy

m1 <- lm(comp_all_trades ~ factor(SELECTED) + factor(FS1.2), data = df)
m2 <- lm(comp_all_trades ~ factor(SELECTED) + wave + did + factor(FS1.2), data = df)
m3 <- lm(comp_all_trades ~ factor(SELECTED) + wave + did + duration + factor(FS1.2), data = df)
m4 <- lm(comp_all_trades ~ factor(SELECTED) + wave + did + duration + firm_size + FS6.1 + dossier_selected + factor(FS1.2), data = df) #FS6.1: number apprentices



stargazer(m1, m2, m3, m4, omit = "FS1.2", df = FALSE, model.names = FALSE, model.numbers = FALSE,
          no.space = TRUE, digits = 3, header = F,
          covariate.labels = c("Selected into CQP",
                               "Did not apply for CQP",
                               "Wave",
                               "CQP x Wave",
                               "Years in training at baseline",
                               "Firm size",
                               "Total apprentices",
                               "CQP apprentices"),
          dep.var.labels = "Fraction of tasks deemed competent (with Firm FE)",
          title = "Apprentice Competence 1",
          add.lines = list(c("Firm FE", "YES", "YES", "YES", "YES")))
```


```{r compreg2, results = 'asis'}
df$cqp_dummy <- ifelse(df$SELECTED == 1, 1, 0)
df$did <- df$wave * df$cqp_dummy

m1 <- lm(comp_all_trades ~ factor(SELECTED), data = df)
m2 <- lm(comp_all_trades ~ factor(SELECTED) + wave + did, data = df)
m3 <- lm(comp_all_trades ~ factor(SELECTED) + wave + did + duration, data = df)
m4 <- lm(comp_all_trades ~ factor(SELECTED) + wave + did + duration + firm_size + FS6.1 + dossier_selected, data = df) #FS6.1: number apprentices



stargazer(m1, m2, m3, m4, omit = "FS1.2", df = FALSE, model.names = FALSE, model.numbers = FALSE,
          no.space = TRUE, digits = 3, header = F,
          covariate.labels = c("Selected into CQP",
                               "Did not apply for CQP",
                               "Wave",
                               "CQP x Wave",
                               "Years in training at baseline",
                               "Firm size",
                               "Total apprentices",
                               "CQP apprentices"),
          dep.var.labels = "Fraction of tasks deemed competent",
          title = "Apprentice Competence 2",
          add.lines = list(c("Firm FE", "No", "No", "No", "No")))
```



```{r compreg3, results = 'asis'}
df$cqp_dummy <- ifelse(df$SELECTED == 1, 1, 0)
df$did <- df$wave * df$cqp_dummy

x <- df %>% filter(SELECTED != 3)

m1 <- lm(comp_all_trades ~ factor(SELECTED) + factor(FS1.2), data = x)
m2 <- lm(comp_all_trades ~ factor(SELECTED) + wave + did + factor(FS1.2), data = x)
m3 <- lm(comp_all_trades ~ factor(SELECTED) + wave + did + duration + factor(FS1.2), data = x)
m4 <- lm(comp_all_trades ~ factor(SELECTED) + wave + did + duration + firm_size + FS6.1 + dossier_selected + factor(FS1.2), data = x) #FS6.1: number apprentices
m5 <- lm(comp_all_trades ~ factor(SELECTED) + wave + did + duration + firm_size + FS6.1 + dossier_selected + FS6.8 + FS6.9 + FS6.10 + ext_training + factor(FS1.2), data = x)


stargazer(m1, m2, m3, m4, m5, omit = "FS1.2", df = FALSE, model.names = FALSE, model.numbers = FALSE,
          no.space = TRUE, digits = 3, header = F,
          covariate.labels = c("Selected into CQP",
                               "Wave",
                               "CQP x Wave",
                               "Years in training at baseline",
                               "Firm size",
                               "Total apprentices",
                               "CQP apprentices",
                               "Total instructors",
                               "Days trained per week",
                               "Duration, last training",
                               "External training"),
          dep.var.labels = "Fraction of tasks deemed competent (with Firm FE)",
          title = "Apprentice Competence 3",
          add.lines = list(c("Firm FE", "YES", "YES", "YES", "YES", "YES")))
```

```{r compreg4, results = 'asis'}
df$cqp_dummy <- ifelse(df$SELECTED == 1, 1, 0)
df$did <- df$wave * df$cqp_dummy

x <- df %>% filter(SELECTED != 3)

m1 <- lm(comp_all_trades ~ factor(SELECTED), data = x)
m2 <- lm(comp_all_trades ~ factor(SELECTED) + wave + did, data = x)
m3 <- lm(comp_all_trades ~ factor(SELECTED) + wave + did + duration, data = x)
m4 <- lm(comp_all_trades ~ factor(SELECTED) + wave + did + duration + firm_size + FS6.1 + dossier_selected, data = x) #FS6.1: number apprentices
m5 <- lm(comp_all_trades ~ factor(SELECTED) + wave + did + duration + firm_size + FS6.1 + dossier_selected + FS6.8 + FS6.9 + FS6.10 + ext_training, data = x)


stargazer(m1, m2, m3, m4, m5, omit = "FS1.2", df = FALSE, model.names = FALSE, model.numbers = FALSE,
          no.space = TRUE, digits = 3, header = F,
          covariate.labels = c("Selected into CQP",
                               "Wave",
                               "CQP x wave",
                               "Years in training at baseline",
                               "Firm size",
                               "Total apprentices",
                               "CQP apprentices",
                               "Total instructors",
                               "Days trained per week",
                               "Duration, last training",
                               "External training"),
          dep.var.labels = "Fraction of tasks deemed competent",
          title = "Apprentice Competence 4",
          add.lines = list(c("Firm FE", "NO", "NO", "NO", "NO", "NO")))
```




```{r expreg1, results = 'asis'}
df$cqp_dummy <- ifelse(df$SELECTED == 1, 1, 0)
df$did <- df$wave * df$cqp_dummy

m1 <- lm(exp_all_trades ~ factor(SELECTED) + factor(FS1.2), data = df)
m2 <- lm(exp_all_trades ~ factor(SELECTED) + wave + did + factor(FS1.2), data = df)
m3 <- lm(exp_all_trades ~ factor(SELECTED) + wave + did + duration + factor(FS1.2), data = df)
m4 <- lm(exp_all_trades ~ factor(SELECTED) + wave + did + duration + firm_size + FS6.1 + dossier_selected + factor(FS1.2), data = df) #FS6.1: number apprentices



stargazer(m1, m2, m3, m4, omit = "FS1.2", df = FALSE, model.names = FALSE, model.numbers = FALSE,
          no.space = TRUE, digits = 3, header = F,
          covariate.labels = c("Selected into CQP",
                               "Did not apply for CQP",
                               "Wave",
                               "CQP x Wave",
                               "Years in training at baseline",
                               "Firm size",
                               "Total apprentices in firm",
                               "CQP apprentices in firm"),
          dep.var.labels = "Fraction of tasks which apprentice has experienced (with Firm FE)",
          title = "Apprentice Experience 1",
          add.lines = list(c("Firm FE", "YES", "YES", "YES", "YES")))
```


```{r expreg2, results = 'asis'}
df$cqp_dummy <- ifelse(df$SELECTED == 1, 1, 0)
df$did <- df$wave * df$cqp_dummy

x <- df %>% filter(SELECTED != 3)

m1 <- lm(exp_all_trades ~ factor(SELECTED), data = df)
m2 <- lm(exp_all_trades ~ factor(SELECTED) + wave + did, data = df)
m3 <- lm(exp_all_trades ~ factor(SELECTED) + wave + did + duration, data = df)
m4 <- lm(exp_all_trades ~ factor(SELECTED) + wave + did + duration + firm_size + FS6.1 + dossier_selected, data = df) #FS6.1: number apprentices


stargazer(m1, m2, m3, m4, omit = "FS1.2", df = FALSE, model.names = FALSE, model.numbers = FALSE,
          no.space = TRUE, digits = 3, header = F,
          covariate.labels = c("Selected into CQP",
                               "Did not apply for CQP",
                               "Wave",
                               "CQP x Wave",
                               "Years in training at baseline",
                               "Firm size",
                               "Total apprentices in firm",
                               "CQP apprentices in firm"),
          dep.var.labels = "Fraction of tasks which apprentice has experienced",
          title = "Apprentice Experience 2",
          add.lines = list(c("Firm FE", "No", "No", "No", "No")))
```


```{r expreg3, results = 'asis'}
df$cqp_dummy <- ifelse(df$SELECTED == 1, 1, 0)
df$did <- df$wave * df$cqp_dummy

x <- df %>% filter(SELECTED != 3)

m1 <- lm(exp_all_trades ~ factor(SELECTED) + factor(FS1.2), data = x)
m2 <- lm(exp_all_trades ~ factor(SELECTED) + wave + did + factor(FS1.2), data = x)
m3 <- lm(exp_all_trades ~ factor(SELECTED) + wave + did + duration + factor(FS1.2), data = x)
m4 <- lm(exp_all_trades ~ factor(SELECTED) + wave + did + duration + firm_size + FS6.1 + dossier_selected + factor(FS1.2), data = x) #FS6.1: number apprentices
m5 <- lm(exp_all_trades ~ factor(SELECTED) + wave + did + duration + firm_size + FS6.1 + dossier_selected + FS6.8 + FS6.9 + FS6.10 + ext_training + factor(FS1.2), data = x)


stargazer(m1, m2, m3, m4, m5, omit = "FS1.2", df = FALSE, model.names = FALSE, model.numbers = FALSE,
          no.space = TRUE, digits = 3, header = F,
          covariate.labels = c("Selected into CQP",
                               "Wave",
                               "CQP x Wave",
                               "Years in training at baseline",
                               "Firm size",
                               "Total apprentices",
                               "CQP apprentices",
                               "Total instructors",
                               "Days trained per week",
                               "Duration, last training",
                               "External training"),
          dep.var.labels = "Fraction of tasks which apprentice has experienced (with Firm FE)",
          title = "Apprentice Experience 3",
          add.lines = list(c("Firm FE", "YES", "YES", "YES", "YES", "YES")))
```

```{r expreg4, results = 'asis'}
df$cqp_dummy <- ifelse(df$SELECTED == 1, 1, 0)
df$did <- df$wave * df$cqp_dummy

x <- df %>% filter(SELECTED != 3)

m1 <- lm(exp_all_trades ~ factor(SELECTED), data = x)
m2 <- lm(exp_all_trades ~ factor(SELECTED) + wave + did, data = x)
m3 <- lm(exp_all_trades ~ factor(SELECTED) + wave + did + duration, data = x)
m4 <- lm(exp_all_trades ~ factor(SELECTED) + wave + did + duration + firm_size + FS6.1 + dossier_selected, data = x) #FS6.1: number apprentices
m5 <- lm(exp_all_trades ~ factor(SELECTED) + wave + did + duration + firm_size + FS6.1 + dossier_selected + FS6.8 + FS6.9 + FS6.10 + ext_training, data = x)


stargazer(m1, m2, m3, m4, m5, omit = "FS1.2", df = FALSE, model.names = FALSE, model.numbers = FALSE,
          no.space = TRUE, digits = 3, header = F,
          covariate.labels = c("Selected into CQP",
                               "Wave",
                               "CQP x Wave",
                               "Years in training at baseline",
                               "Firm size",
                               "Total apprentices",
                               "CQP apprentices",
                               "Total instructors",
                               "Days trained per week",
                               "Duration, last training",
                               "External training"),
          dep.var.labels = "Fraction of tasks which apprentice has experienced",
          title = "Apprentice Experience 4",
          add.lines = list(c("Firm FE", "NO", "NO", "NO", "NO", "NO")))
```

```{r skills2, results = 'asis'}
m1 <- lm(skills_all_trades ~ factor(SELECTED) + duration, data = df)
m2 <- lm(skills_all_trades ~ factor(SELECTED) + duration + factor(FS1.2), data = df)
m3 <- lm(skills_all_trades ~ factor(SELECTED) + duration  + firm_size + FS6.1 + dossier_selected + factor(FS1.2), data = df) #FS6.1: number apprentices
m4 <- lm(skills_all_trades ~ factor(SELECTED) + duration  + firm_size + FS6.1 + dossier_selected + FS6.8 + FS6.9 + FS6.10 + factor(FS1.2), data = df)

stargazer(m1, m2, m3, m4, omit = "FS1.2", df = FALSE, model.names = FALSE, model.numbers = FALSE, no.space = TRUE,
          covariate.labels = c("Participation in CQP",
                               "Years in Training",
                               "Firm Size",
                               "Total Apprentices Hired",
                               "CQP Apprentices",
                               "Total Instructors",
                               "Days Trained per Week",
                               "Duration of Last Training",
                               "External Training in Past Month"),
          dep.var.labels = "Fraction of Correct Answers",
          title = "Skills Questions",
          add.lines = list(c("Firm FE", "NO", "YES", "YES", "YES")))
```

```{r compreg, results = 'asis'}
df$cqp_dummy <- ifelse(df$SELECTED == 1, 1, 0)
df$did <- df$wave * df$cqp_dummy

m1 <- lm(comp_all_trades ~ factor(SELECTED), data = df)
m2 <- lm(comp_all_trades ~ factor(SELECTED) + factor(FS1.2), data = df)
m3 <- lm(comp_all_trades ~ factor(SELECTED) + wave + did + factor(FS1.2), data = df)
m4 <- lm(comp_all_trades ~ factor(SELECTED) + wave + did + duration + factor(FS1.2), data = df)
m5 <- lm(comp_all_trades ~ factor(SELECTED) + wave + did + duration + firm_size + FS6.1 + dossier_selected + factor(FS1.2), data = df) #FS6.1: number apprentices
m6 <- lm(comp_all_trades ~ factor(SELECTED) + wave + did + duration + firm_size + FS6.1 + dossier_selected + FS6.8 + FS6.9 + FS6.10 + ext_training + factor(FS1.2), data = df)


stargazer(m1, m2, m3, m4, m5, m6, omit = "FS1.2", df = FALSE, model.names = FALSE, model.numbers = FALSE,
          no.space = TRUE, digits = 3, header = F,
          covariate.labels = c("CQP participant",
                               "Did not apply for CQP",
                               "Wave",
                               "CQP x wave",
                               "Years in training",
                               "Firm size",
                               "Total apprentices",
                               "CQP apprentices",
                               "Total instructors",
                               "Days trained per week",
                               "Duration, last training",
                               "External training"),
          dep.var.labels = "Fraction of tasks - competence",
          title = "Apprentice Competence",
          add.lines = list(c("Firm FE", "NO", "YES", "YES", "YES", "YES", "YES")))
```

```{r expreg5, results = 'asis'}
df$cqp_dummy <- ifelse(df$SELECTED == 1, 1, 0)
df$did <- df$wave * df$cqp_dummy

m1 <- lm(exp_all_trades ~ factor(SELECTED), data = df)
m2 <- lm(exp_all_trades ~ factor(SELECTED) + factor(FS1.2), data = df)
m3 <- lm(exp_all_trades ~ factor(SELECTED) + wave + did + factor(FS1.2), data = df)
m4 <- lm(exp_all_trades ~ factor(SELECTED) + wave + did + duration + factor(FS1.2), data = df)
m5 <- lm(exp_all_trades ~ factor(SELECTED) + wave + did + duration + firm_size + FS6.1 + dossier_selected + factor(FS1.2), data = df) #FS6.1: number apprentices
m6 <- lm(exp_all_trades ~ factor(SELECTED) + wave + did + duration + firm_size + FS6.1 + dossier_selected + FS6.8 + FS6.9 + FS6.10 + ext_training + factor(FS1.2), data = df)


stargazer(m1, m2, m3, m4, m5, m6, omit = "FS1.2", df = FALSE, model.names = FALSE, model.numbers = FALSE,
          no.space = TRUE, digits = 3, header = F,
          covariate.labels = c("CQP participant",
                               "Did not apply for CQP",
                               "Wave",
                               "CQP x wave",
                               "Years in training",
                               "Firm size",
                               "Total apprentices",
                               "CQP apprentices",
                               "Total instructors",
                               "Days trained per week",
                               "Duration, last training",
                               "External training"),
          dep.var.labels = "Fraction of tasks - experience",
          title = "Apprentice Experience",
          add.lines = list(c("Firm FE", "NO", "YES", "YES", "YES", "YES", "YES")))
```

``` {r costsbysize}
x <- df %>% filter(wave == 0, !is.na(firm_size_bins), !is.na(FS6.1)) %>% select(FS1.2, FS6.1, all_allowances, firm_size_bins, contains("FE5.1"), FS6.9, FS6.10, FS5.2_1_2, FS6.8) %>%
  group_by(FS1.2, firm_size_bins) %>% summarise_all(mean, na.rm = T) %>% ungroup() %>% 
  mutate(all_allowances = all_allowances * 12,
         FE5.1_1 = FE5.1_1 / FS6.1 * 12,
         FE5.1_2 = FE5.1_2 / FS6.1 * 12,
         FE5.1_3 = FE5.1_3 / FS6.1 * 12,
         FE5.1_4 = FE5.1_4 / FS6.1 * 12,
         trainers_wages = (FS6.9*FS6.10*4)*(FS5.2_1_2/4/40) / FS6.1 * 12, #hours per month * hourly wage / number of apprentices
  ) %>% group_by(firm_size_bins) %>% summarise_all(mean, na.rm = T) %>% select(-FS1.2) %>% pivot_longer(cols = c(all_allowances, contains("FE5.1"), trainers_wages))

ggplot(data=x, aes(x=firm_size_bins, y=value, fill=name)) +
  geom_bar(stat="identity", color="black", position=position_dodge()) +
  labs(x = "Firm size", y = "FCFA per year") + theme_minimal() + scale_fill_discrete(name = "Costs", labels = c("Allowances", "Rent", "Equipment", "Books", "Raw materials", "Trainer wage", "Apprentice wage"))
```

``` {r costsbytrade}
x <- df %>% filter(wave == 0, !is.na(FS1.11), !is.na(FS6.1)) %>% select(FS1.2, FS6.1, all_allowances, FS1.11, contains("FE5.1"), FS6.9, FS6.10, FS5.2_1_2, FS6.8) %>%
  group_by(FS1.2, FS1.11) %>% summarise_all(mean, na.rm = T) %>% ungroup() %>% 
  mutate(all_allowances = all_allowances * 12,
         FE5.1_1 = FE5.1_1 / FS6.1 * 12,
         FE5.1_2 = FE5.1_2 / FS6.1 * 12,
         FE5.1_3 = FE5.1_3 / FS6.1 * 12,
         FE5.1_4 = FE5.1_4 / FS6.1 * 12,
         trainers_wages = (FS6.9*FS6.10*4)*(FS5.2_1_2/4/40) / FS6.1 * 12, #hours per month * hourly wage / number of apprentices
  ) %>% group_by(FS1.11) %>% summarise_all(mean, na.rm = T) %>% select(-FS1.2) %>% pivot_longer(cols = c(all_allowances, contains("FE5.1"), trainers_wages))

ggplot(data=x, aes(x=FS1.11, y=value, fill=name)) +
  geom_bar(stat="identity", color="black", position=position_dodge()) +
  labs(x = "Trade", y = "FCFA per year") + theme_minimal() + scale_fill_discrete(name = "Costs", labels = c("Allowances", "Rent", "Equipment", "Books", "Raw materials", "Trainer wage", "Apprentice wage")) + scale_x_discrete(limits = c("Masonry", "Carpentry", "Plumbing",  "Metalwork", "Electrical Inst."))
```

``` {r firmbenefitsfig1}
x <- df %>% filter(!is.na(firm_size_bins), !is.na(profits), wave == 0, profits != 0) %>% select(FS1.2, firm_size_bins, cb_1, cb_2, cb_V) %>%
  mutate(cb_1 = cb_1 / 605,
         cb_2 = cb_2 / 605,
         cb_V = cb_V / 605) %>% ungroup() %>% 
  group_by(FS1.2,firm_size_bins) %>% summarise_all(mean, na.rm = T) %>% ungroup() %>% 
  select(-FS1.2) %>% 
  group_by(firm_size_bins) %>% summarise_all(mean, na.rm = T) %>% ungroup() %>% pivot_longer(cols = c("cb_1", "cb_2", "cb_V"))

ggplot(data=x, aes(x=firm_size_bins, y=value, fill=name)) +
  geom_bar(stat="identity", color="black", position=position_dodge(), title = "Firm Benefits") +
  theme_minimal() + scale_fill_viridis_d(guide_legend(title = "Model")) +
  xlab("Firm Size") + ylab("Net benefits")
```

``` {r firmbenefitsfig2}
x <- df %>% filter(!is.na(firm_size_bins), !is.na(profits), wave == 0, profits != 0, profits > 0) %>% select(FS1.2, firm_size_bins, cb_1, cb_2, cb_V, profits) %>%
  group_by(FS1.2,firm_size_bins) %>% summarise_all(mean, na.rm = T) %>% 
  mutate(cb_1 = cb_1 / profits*100,
         cb_2 = cb_2 / profits*100,
         cb_V = cb_V / profits*100) %>% ungroup() %>% 
  select(-FS1.2) %>% 
  group_by(firm_size_bins) %>% summarise_all(mean, na.rm = T) %>% ungroup() %>% pivot_longer(cols = c("cb_1", "cb_2", "cb_V"))

ggplot(data=x, aes(x=firm_size_bins, y=value, fill=name)) +
  geom_bar(stat="identity", color="black", position=position_dodge(), title = "Firm Benefits as a Fraction of Profits") +
  theme_minimal() + scale_fill_viridis_d(guide_legend(title = "Model")) +
  xlab("Firm Size") + ylab("Net benefits proportional to earnings")
```

``` {r firmbenefitsfig3}
x <- df %>% filter(!is.na(duration), duration < 8) %>% select(duration, cb_1, cb_2, cb_V, profits) %>% 
  group_by(duration) %>% summarise_all(mean, na.rm = T) %>%
  mutate(cb_1 = cb_1 / profits*100,
         cb_2 = cb_2 / profits*100,
         cb_V = cb_V / profits*100) %>% ungroup() %>% pivot_longer(cols = c("cb_1", "cb_2", "cb_V"))

ggplot(data=x, aes(x=duration, y=value, color=name)) +
  geom_line(stat="identity") +
  xlab("Year of apprenticeship") +
  ylab("Net benefits") + scale_color_viridis_d(guide_legend(title = "Model")) +
  scale_x_discrete(limits = c(0:7)) + theme_minimal()
```

```{r sizefe, results = 'asis'}
x <- df %>% select(FS1.2, wave, firm_size_sans_app, FS3.4, FS6.1, FS1.11) %>%
  mutate(wave = factor(wave, levels = 0:1, labels = c('Baseline', 'Endline'))) %>% 
  group_by(FS1.2, wave, FS1.11) %>% summarise_all(mean, na.rm = T) %>% ungroup()

m1 <- lm(firm_size_sans_app ~ FS6.1 + wave, data = x)
m2 <- lm(firm_size_sans_app ~ FS6.1 + factor(FS1.2) + wave, data = x)
m3 <- lm(firm_size_sans_app ~ FS6.1 + factor(FS1.11) + wave, data = x)
m4 <- felm(firm_size_sans_app ~ FS6.1 + factor(FS1.2) + factor(FS1.11) + wave, data = x)


stargazer(m1, m2, m3, m4, df = FALSE, omit = "FS1.2", model.names = FALSE, model.numbers = FALSE,
          no.space = TRUE, digits = 3, header = F, table.placement = "H",
          covariate.labels = c("Apprentices",
                               "Carpentry",
                               "Plumbing",
                               "Metalwork",
                               "Electrical Inst.",
                               "Wave"),
          notes = c("Omitted trade: Masonry", "Omitted wave: Baseline"),
          notes.align = "r",
          notes.append = TRUE,
          title = "Fixed effects regression: firm size",
          dep.var.labels = c("Firm Size (excluding apprentices)"),
          add.lines = list(c("Firm FE", "NO", "YES", "NO", "YES"),
                           c("Trade FE", "NO", "NO", "YES", "YES")))
```

```{r sizere, results = 'asis'}
x <- df %>% select(FS1.2, wave, firm_size_sans_app, dossier_selected, FS3.4, FS6.1, FS1.11) %>%
  mutate(wave = factor(wave, levels = 0:1, labels = c('Baseline', 'Endline'))) %>% 
  group_by(FS1.2, wave, FS1.11) %>% summarise_all(mean, na.rm = T) %>% ungroup()

m1 <- lmer(firm_size_sans_app ~ FS6.1 + wave + (1|FS1.2), data = x)
m2 <- lmer(firm_size_sans_app ~ FS6.1 + dossier_selected + wave + (1|FS1.2), data = x)
m3 <- lmer(firm_size_sans_app ~ FS6.1 + dossier_selected + wave + (1|FS1.11) + wave, data = x)
m4 <- lmer(firm_size_sans_app ~ FS6.1 + dossier_selected + wave + (1|FS1.2:FS1.11), data = x)


stargazer(m1, m2, m3, m4, df = FALSE, omit = "FS1.2", model.names = FALSE, model.numbers = FALSE,
          no.space = TRUE, digits = 3, header = F, table.placement = "H",
          covariate.labels = c("Apprentices, total",
                               "CQP apprentices (2019)3",
                               "Wave"),
          dep.var.labels = c("Firm Size (excluding apprentices)"),
          notes = c("Omitted trade: Masonry", "Omitted wave: Baseline"),
          notes.align = "r",
          notes.append = TRUE,
          add.lines = list(c("Firm FE", "NO", "YES", "NO", "YES"),
                           c("Trade FE", "NO", "NO", "YES", "YES")),
          title = "Random effects regression: firm size")
```


```{r prodreg, results = 'asis'}
x <- df %>% select(FS1.2, wave, firm_size, dossier_selected, FS3.4, FS6.1, FS1.11) %>%
  mutate(wave = factor(wave, levels = 0:1, labels = c('Baseline', 'Endline'))) %>% 
  group_by(FS1.2, wave) %>% summarise_all(mean, na.rm = T) %>% ungroup() %>% pivot_wider(names_from = wave, values_from = c(firm_size, FS3.4, FS6.1)) %>% 
  mutate(diff_firm_size = FS3.4_Endline-FS3.4_Baseline,
         diff_firm_size2 = firm_size_Endline-firm_size_Baseline,
         diff_tot_apps = FS6.1_Endline-FS6.1_Baseline)

m1 <- lm(diff_firm_size ~ dossier_selected + diff_tot_apps, data = x)
m2 <- lm(diff_firm_size ~ dossier_selected + diff_tot_apps +FS3.4_Baseline, data = x)
m3 <- lm(diff_firm_size2 ~ dossier_selected + diff_tot_apps, data = x)
m4 <- lm(diff_firm_size2 ~ dossier_selected + diff_tot_apps + firm_size_Baseline, data = x)

stargazer(m1, m2, m3, m4, df = FALSE, model.names = FALSE, model.numbers = FALSE,
          no.space = TRUE, digits = 3, header = F, table.placement = "H",
          covariate.labels = c("CQP apprentices, 2019 cohort",
                               "Diff. in total apprentices",
                               "Baseline firm size (reported)",
                               "Baseline firm size (computed)"),
          dep.var.labels = c("Firm Growth", "Firm Growth", "Firm Growth", "Firm Growth"),
          column.labels= c('Reported', 'Reported', 'Computed', 'Computed'))
```


``` {r appregfe, results = 'asis'}
x <- df %>% filter(SELECTED != 3)
m1 <- lm(exp_all_trades ~ as.factor(SELECTED) + as.factor(wave) + as.factor(FS1.2), data = df)
m2 <- plm(exp_all_trades ~ as.factor(SELECTED) + as.factor(FS1.2), data = df, index = c("IDYouth", "wave"), model = "random", effect = "twoway", random.method="walhus")
m3 <- plm(exp_all_trades ~ as.factor(SELECTED) + as.factor(FS1.2), data = x, index = c("IDYouth", "wave"), model = "random", effect = "twoway", random.method="walhus")

m4 <- lm(comp_all_trades ~ as.factor(SELECTED) + as.factor(wave) + as.factor(FS1.2), data = df)
m5 <- plm(comp_all_trades ~ as.factor(SELECTED) + as.factor(FS1.2), data = df, index = c("IDYouth", "wave"), model = "random", effect = "twoway", random.method="walhus")
m6 <- plm(comp_all_trades ~ as.factor(SELECTED) + as.factor(FS1.2), data = x, index = c("IDYouth", "wave"), model = "random", effect = "twoway", random.method="walhus")

m7 <- lm(skills_all_trades ~ as.factor(SELECTED) + as.factor(wave) + as.factor(FS1.2), data = df)
m8 <- plm(skills_all_trades ~ as.factor(SELECTED) + as.factor(FS1.2), data = df, index = c("IDYouth", "wave"), model = "random", effect = "twoway", random.method="walhus")


stargazer(m1, m2, m3, m4, m5, m6, m7, m8, df = FALSE, omit = "FS1.2", column.sep.width = "0pt",
          no.space = TRUE, digits = 2, header = F, table.placement = "H",
          notes = c("$^†$Omitted CQP category: applied but did not participate."),
          notes.align = "r",
          notes.append = TRUE,
          covariate.labels = c("CQP participant",
                               "CQP non-applicant$^{†}$",
                               "Endline"),
          title = "Apprentice regressions (firm FE)",
          omit.stat=c("aic", "bic", "adj.rsq", "ser"),
          dep.var.labels = c("Experience", "Competence", "Knowledge"),
          column.labels = c("\\textit{OLS}", "\\textit{RE}", "\\textit{RE}", "\\textit{OLS}", "\\textit{RE}", "\\textit{RE}", "\\textit{OLS}", "\\textit{RE}"),
          model.names = FALSE,
          model.numbers = FALSE,
          dep.var.caption = "",
          label = "tab:expregs",
          add.lines = list(c("Individual FE", "NO", "YES", "YES", "NO", "YES", "YES", "NO", "YES"),
                           c("Firm FE", "YES", "YES", "YES", "YES", "YES", "YES", "YES", "YES")))
```

``` {r expregnew, results = 'asis'}
x <- df %>% filter(SELECTED != 3)
m1 <- lm(exp_all_trades ~ as.factor(SELECTED) + as.factor(wave), data = df)
m2 <- lm(exp_all_trades ~ as.factor(SELECTED) + as.factor(wave) + as.factor(FS1.2), data = df)
m3 <- plm(exp_all_trades ~ as.factor(SELECTED) + baseline_duration + as.factor(FS1.2), data = df, index = c("IDYouth", "wave"), model = "random", effect = "twoway", random.method="walhus")
m4 <- plm(exp_all_trades ~ as.factor(SELECTED) + baseline_duration + firm_size_sans_app + FS6.1 + as.factor(FS1.2), data = df, index = c("IDYouth", "wave"), model = "random", effect = "twoway", random.method="walhus")
m5 <- plm(exp_all_trades ~ as.factor(SELECTED) + baseline_duration + firm_size_sans_app + FS6.1 + FS6.8 + FS6.9 + FS6.10 + as.factor(FS1.2), data = df, index = c("IDYouth", "wave"), model = "random", effect = "twoway", random.method="walhus")
m6 <- plm(exp_all_trades ~ as.factor(SELECTED) + baseline_duration + firm_size_sans_app + FS6.1 + FS6.8 + FS6.9 + FS6.10 + as.factor(FS1.2), data = x, index = c("IDYouth", "wave"), model = "random", effect = "twoway", random.method="walhus")

stargazer(m1, m2, m3, m4, m5, m6, df = FALSE, omit = "FS1.2", column.sep.width = "0pt",
          no.space = TRUE, digits = 2, header = F, table.placement = "H",
          notes = c("$^†$Omitted CQP category: applied but did not participate.", "$^{††}$Excluding apprentices."),
          notes.align = "r",
          notes.append = TRUE,
          covariate.labels = c("CQP participant",
                               "CQP non-applicant$^{†}$",
                               "Endline",
                               "Apprentice experience",
                               "Employees$^{††}$",
                               "Apprentices",
                               "Total instructors",
                               "Days trained per week",
                               "Duration, last training"),
          title = "Experience score regressions",
          omit.stat=c("aic", "bic", "adj.rsq", "ser"),
          dep.var.caption = "",
          dep.var.labels.include = FALSE,
          column.labels = c("\\textit{OLS}", "", "", "\\textit{random effects}", "", ""),
          model.names = FALSE,
          label = "tab:expregs",
          add.lines = list(c("Individual FE", "NO", "NO", "YES", "YES", "YES", "YES"),
                           c("Firm FE", "NO", "YES", "YES", "YES", "YES", "YES")))
```


``` {r expregnofirm, results = 'asis'}
x <- df %>% filter(SELECTED != 3)
m1 <- lm(exp_all_trades ~ as.factor(SELECTED) + as.factor(wave), data = df)
m2 <- lm(exp_all_trades ~ as.factor(SELECTED) + as.factor(wave) + baseline_duration, data = df)
m3 <- plm(exp_all_trades ~ as.factor(SELECTED) + baseline_duration, data = df, index = c("IDYouth", "wave"), model = "random", effect = "twoway", random.method="walhus")
m4 <- plm(exp_all_trades ~ as.factor(SELECTED) + baseline_duration + firm_size_sans_app + FS6.1, data = df, index = c("IDYouth", "wave"), model = "random", effect = "twoway", random.method="walhus")
m5 <- plm(exp_all_trades ~ as.factor(SELECTED) + baseline_duration + firm_size_sans_app + FS6.1 + FS6.8 + FS6.9 + FS6.10, data = df, index = c("IDYouth", "wave"), model = "random", effect = "twoway", random.method="walhus")
m6 <- plm(exp_all_trades ~ as.factor(SELECTED) + baseline_duration + firm_size_sans_app + FS6.1 + FS6.8 + FS6.9 + FS6.10, data = x, index = c("IDYouth", "wave"), model = "random", effect = "twoway", random.method="walhus")

stargazer(m1, m2, m3, m4, m5, m6, df = FALSE, omit = "FS1.2", column.sep.width = "0pt",
          no.space = TRUE, digits = 2, header = F, table.placement = "H",
          notes = c("$^†$Omitted CQP category: applied but did not participate.", "$^{††}$Excluding apprentices."),
          notes.align = "r",
          notes.append = TRUE,
          covariate.labels = c("CQP participant",
                               "CQP non-applicant$^{†}$",
                               "Endline",
                               "Apprentice experience",
                               "Employees$^{††}$",
                               "Apprentices",
                               "Total instructors",
                               "Days trained per week",
                               "Duration, last training"),
          title = "Experience score regressions (no firm FE)",
          omit.stat=c("aic", "bic", "adj.rsq", "ser"),
          dep.var.caption = "",
          dep.var.labels.include = FALSE,
          column.labels = c("\\textit{OLS}", "\\textit{OLS}", "", "\\textit{random effects}"),
          model.names = FALSE,
          label = "tab:expregs",
          add.lines = list(c("Individual FE", "NO", "NO", "YES", "YES", "YES", "YES")))
```

``` {r expregselonly, results = 'asis'}
x <- df %>% filter(SELECTED != 3)
m1 <- lm(exp_all_trades ~ as.factor(SELECTED) + as.factor(wave), data = x)
m2 <- lm(exp_all_trades ~ as.factor(SELECTED) + as.factor(wave) + as.factor(FS1.2), data = x)
m3 <- plm(exp_all_trades ~ as.factor(SELECTED) + baseline_duration + firm_size_sans_app + FS6.1, data = x, index = c("IDYouth", "wave"), model = "random", effect = "twoways", random.method="walhus")
m4 <- plm(exp_all_trades ~ as.factor(SELECTED) + baseline_duration + firm_size_sans_app + FS6.1 + FS6.8 + FS6.9 + FS6.10, data = x, index = c("IDYouth", "wave"), model = "random", effect = "twoways", random.method="walhus")
m5 <- plm(exp_all_trades ~ as.factor(SELECTED) + baseline_duration + firm_size_sans_app + FS6.1 + FS6.8 + FS6.9 + FS6.10 + as.factor(FS1.2), data = x, index = c("IDYouth", "wave"), model = "random", effect = "twoways", random.method="walhus")

stargazer(m1, m2, m3, m4, m5, df = FALSE, omit = "FS1.2", column.sep.width = "0pt",
          no.space = TRUE, digits = 2, header = F, table.placement = "H",
          notes = c("$^{†}$Excluding apprentices."),
          notes.align = "r",
          notes.append = TRUE,
          covariate.labels = c("CQP participant",
                               "Endline",
                               "Apprentice experience",
                               "Employees$^{†}$",
                               "Apprentices",
                               "Total instructors",
                               "Days trained per week",
                               "Duration, last training"),
          title = "Apprentice regressions (CQP applicants only)",
          omit.stat=c("aic", "bic", "adj.rsq", "ser"),
          dep.var.caption = "",
          dep.var.labels.include = FALSE,
          column.labels = c("\\textit{OLS}"),
          model.names = FALSE,
          label = "tab:expregs2",
          add.lines = list(c("Individual FE", "NO", "NO", "YES", "YES", "YES"),
                           c("Firm FE", "NO", "YES", "NO", "NO", "YES")))
```

``` {r compregnew, results = 'asis'}
x <- df %>% filter(SELECTED != 3)
m1 <- lm(comp_all_trades ~ as.factor(SELECTED) + as.factor(wave), data = df)
m2 <- lm(comp_all_trades ~ as.factor(SELECTED) + as.factor(wave) + as.factor(FS1.2), data = df)
m3 <- plm(comp_all_trades ~ as.factor(SELECTED) + baseline_duration + as.factor(FS1.2), data = df, index = c("IDYouth", "wave"), model = "random", effect = "twoway", random.method="walhus")
m4 <- plm(comp_all_trades ~ as.factor(SELECTED) + baseline_duration + firm_size_sans_app + FS6.1 + as.factor(FS1.2), data = df, index = c("IDYouth", "wave"), model = "random", effect = "twoway", random.method="walhus")
m5 <- plm(comp_all_trades ~ as.factor(SELECTED) + baseline_duration + firm_size_sans_app + FS6.1 + FS6.8 + FS6.9 + FS6.10 + as.factor(FS1.2), data = df, index = c("IDYouth", "wave"), model = "random", effect = "twoway", random.method="walhus")
m6 <- plm(comp_all_trades ~ as.factor(SELECTED) + baseline_duration + firm_size_sans_app + FS6.1 + FS6.8 + FS6.9 + FS6.10 + as.factor(FS1.2), data = x, index = c("IDYouth", "wave"), model = "random", effect = "twoway", random.method="walhus")

stargazer(m1, m2, m3, m4, m5, m6, df = FALSE, omit = "FS1.2", column.sep.width = "0pt",
          no.space = TRUE, digits = 2, header = F, table.placement = "H",
          notes = c("$^†$Omitted CQP category: applied but did not participate.", "$^{††}$Excluding apprentices."),
          notes.align = "r",
          notes.append = TRUE,
          covariate.labels = c("CQP participant",
                               "CQP non-applicant$^{†}$",
                               "Endline",
                               "Apprentice experience",
                               "Employees$^{††}$",
                               "Apprentices",
                               "Total instructors",
                               "Days trained per week",
                               "Duration, last training"),
          title = "Competence score regressions",
          omit.stat=c("aic", "bic", "adj.rsq", "ser"),
          dep.var.caption = "",
          dep.var.labels.include = FALSE,
          column.labels = c("\\textit{OLS}", "", "", "\\textit{random effects}", "", ""),
          model.names = FALSE,
          label = "tab:compregs",
          add.lines = list(c("Individual FE", "NO", "NO", "YES", "YES", "YES", "YES"),
                           c("Firm FE", "NO", "YES", "YES", "YES", "YES", "YES")))
```

``` {r compregnofirm, results = 'asis'}
x <- df %>% filter(SELECTED != 3)
m1 <- lm(comp_all_trades ~ as.factor(SELECTED) + as.factor(wave), data = df)
m2 <- lm(comp_all_trades ~ as.factor(SELECTED) + as.factor(wave) + baseline_duration, data = df)
m3 <- plm(comp_all_trades ~ as.factor(SELECTED) + baseline_duration, data = df, index = c("IDYouth", "wave"), model = "random", effect = "twoway", random.method="walhus")
m4 <- plm(comp_all_trades ~ as.factor(SELECTED) + baseline_duration + firm_size_sans_app + FS6.1, data = df, index = c("IDYouth", "wave"), model = "random", effect = "twoway", random.method="walhus")
m5 <- plm(comp_all_trades ~ as.factor(SELECTED) + baseline_duration + firm_size_sans_app + FS6.1 + FS6.8 + FS6.9 + FS6.10, data = df, index = c("IDYouth", "wave"), model = "random", effect = "twoway", random.method="walhus")
m6 <- plm(comp_all_trades ~ as.factor(SELECTED) + baseline_duration + firm_size_sans_app + FS6.1 + FS6.8 + FS6.9 + FS6.10, data = x, index = c("IDYouth", "wave"), model = "random", effect = "twoway", random.method="walhus")

stargazer(m1, m2, m3, m4, m5, m6, df = FALSE, omit = "FS1.2", column.sep.width = "0pt",
          no.space = TRUE, digits = 2, header = F, table.placement = "H",
          notes = c("$^†$Omitted CQP category: applied but did not participate.", "$^{††}$Excluding apprentices."),
          notes.align = "r",
          notes.append = TRUE,
          covariate.labels = c("CQP participant",
                               "CQP non-applicant$^{†}$",
                               "Endline",
                               "Apprentice experience",
                               "Employees$^{††}$",
                               "Apprentices",
                               "Total instructors",
                               "Days trained per week",
                               "Duration, last training"),
          title = "Competence score regressions (no firm FE)",
          omit.stat=c("aic", "bic", "adj.rsq", "ser"),
          dep.var.caption = "",
          dep.var.labels.include = FALSE,
          column.labels = c("\\textit{OLS}", "\\textit{OLS}", "", "\\textit{random effects}"),
          model.names = FALSE,
          label = "tab:compregs",
          add.lines = list(c("Individual FE", "NO", "NO", "YES", "YES", "YES", "YES")))
```

``` {r compregselonly, results = 'asis'}
x <- df %>% filter(SELECTED != 3)
m1 <- lm(comp_all_trades ~ as.factor(SELECTED) + as.factor(wave), data = x)
m2 <- lm(comp_all_trades ~ as.factor(SELECTED) + as.factor(wave) + as.factor(FS1.2), data = x)
m3 <- plm(comp_all_trades ~ as.factor(SELECTED) + baseline_duration + firm_size_sans_app + FS6.1, data = x, index = c("IDYouth", "wave"), model = "random", effect = "twoways", random.method="walhus")
m4 <- plm(comp_all_trades ~ as.factor(SELECTED) + baseline_duration + firm_size_sans_app + FS6.1 + FS6.8 + FS6.9 + FS6.10, data = x, index = c("IDYouth", "wave"), model = "random", effect = "twoways", random.method="walhus")
m5 <- plm(comp_all_trades ~ as.factor(SELECTED) + baseline_duration + firm_size_sans_app + FS6.1 + FS6.8 + FS6.9 + FS6.10 + as.factor(FS1.2), data = x, index = c("IDYouth", "wave"), model = "random", effect = "twoways", random.method="walhus")

stargazer(m1, m2, m3, m4, m5, df = FALSE, omit = "FS1.2", column.sep.width = "0pt",
          no.space = TRUE, digits = 2, header = F, table.placement = "H",
          notes = c("$^{†}$Excluding apprentices."),
          notes.align = "r",
          notes.append = TRUE,
          covariate.labels = c("CQP participant",
                               "Endline",
                               "Apprentice experience",
                               "Employees$^{†}$",
                               "Apprentices",
                               "Total instructors",
                               "Days trained per week",
                               "Duration, last training"),
          title = "Competence score regressions",
          omit.stat=c("aic", "bic", "adj.rsq", "ser"),
          dep.var.caption = "",
          dep.var.labels.include = FALSE,
          column.labels = c("\\textit{OLS}"),
          model.names = FALSE,
          label = "tab:compregs2",
          add.lines = list(c("Individual FE", "NO", "NO", "YES", "YES", "YES"),
                           c("Firm FE", "NO", "YES", "NO", "NO", "YES")))
```



``` {r skillregnew, results = 'asis'}
x <- df %>% filter(SELECTED != 3)
m1 <- lm(skills_all_trades ~ as.factor(SELECTED) + as.factor(wave), data = df)
m2 <- lm(skills_all_trades ~ as.factor(SELECTED) + as.factor(wave) + as.factor(FS1.2), data = df)
m3 <- plm(skills_all_trades ~ as.factor(SELECTED) + baseline_duration + as.factor(FS1.2), data = df, index = c("IDYouth", "wave"), model = "random", effect = "twoway", random.method="walhus")
m4 <- plm(skills_all_trades ~ as.factor(SELECTED) + baseline_duration + firm_size_sans_app + FS6.1 + as.factor(FS1.2), data = df, index = c("IDYouth", "wave"), model = "random", effect = "twoway", random.method="walhus")
m5 <- plm(skills_all_trades ~ as.factor(SELECTED) + baseline_duration + firm_size_sans_app + FS6.1 + FS6.8 + FS6.9 + FS6.10 + as.factor(FS1.2), data = df, index = c("IDYouth", "wave"), model = "random", effect = "twoway", random.method="walhus")
m6 <- plm(skills_all_trades ~ as.factor(SELECTED) + baseline_duration + firm_size_sans_app + FS6.1 + FS6.8 + FS6.9 + FS6.10 + as.factor(FS1.2), data = x, index = c("IDYouth", "wave"), model = "random", effect = "twoway", random.method="walhus")

stargazer(m1, m2, m3, m4, m5, m6, df = FALSE, omit = "FS1.2", column.sep.width = "0pt",
          no.space = TRUE, digits = 2, header = F, table.placement = "H",
          notes = c("$^{†}$Excluding apprentices."),
          notes.align = "r",
          notes.append = TRUE,
          covariate.labels = c("CQP participant",
                               "Endline",
                               "Apprentice experience",
                               "Employees$^{†}$",
                               "Apprentices",
                               "Total instructors",
                               "Days trained per week",
                               "Duration, last training"),
          title = "Knowledge score regressions",
          omit.stat=c("aic", "bic", "adj.rsq", "ser"),
          dep.var.caption = "",
          dep.var.labels.include = FALSE,
          column.labels = c("\\textit{OLS}", "", "", "\\textit{random effects}", "", ""),
          model.names = FALSE,
          label = "tab:skillregs",
          add.lines = list(c("Individual FE", "NO", "NO", "YES", "YES", "YES", "YES"),
                           c("Firm FE", "NO", "YES", "YES", "YES", "YES", "YES")))
```

``` {r skillregnofirm, results = 'asis'}
x <- df %>% filter(SELECTED != 3)
m1 <- lm(skills_all_trades ~ as.factor(SELECTED) + as.factor(wave), data = df)
m2 <- lm(skills_all_trades ~ as.factor(SELECTED) + as.factor(wave) + baseline_duration, data = df)
m3 <- plm(skills_all_trades ~ as.factor(SELECTED) + baseline_duration, data = df, index = c("IDYouth", "wave"), model = "random", effect = "twoway", random.method="walhus")
m4 <- plm(skills_all_trades ~ as.factor(SELECTED) + baseline_duration + firm_size_sans_app + FS6.1, data = df, index = c("IDYouth", "wave"), model = "random", effect = "twoway", random.method="walhus")
m5 <- plm(skills_all_trades ~ as.factor(SELECTED) + baseline_duration + firm_size_sans_app + FS6.1 + FS6.8 + FS6.9 + FS6.10, data = df, index = c("IDYouth", "wave"), model = "random", effect = "twoway", random.method="walhus")
m6 <- plm(skills_all_trades ~ as.factor(SELECTED) + baseline_duration + firm_size_sans_app + FS6.1 + FS6.8 + FS6.9 + FS6.10, data = x, index = c("IDYouth", "wave"), model = "random", effect = "twoway", random.method="walhus")

stargazer(m1, m2, m3, m4, m5, m6, df = FALSE, omit = "FS1.2", column.sep.width = "0pt",
          no.space = TRUE, digits = 2, header = F, table.placement = "H",
          notes = c("$^{†}$Excluding apprentices."),
          notes.align = "r",
          notes.append = TRUE,
          covariate.labels = c("CQP participant",
                               "Endline",
                               "Apprentice experience",
                               "Employees$^{†}$",
                               "Apprentices",
                               "Total instructors",
                               "Days trained per week",
                               "Duration, last training"),
          title = "Knowledge score regressions (no firm FE)",
          omit.stat=c("aic", "bic", "adj.rsq", "ser"),
          dep.var.caption = "",
          dep.var.labels.include = FALSE,
          column.labels = c("\\textit{OLS}", "\\textit{OLS}", "", "\\textit{random effects}"),
          model.names = FALSE,
          label = "tab:skillregs",
          add.lines = list(c("Individual FE", "NO", "NO", "YES", "YES", "YES", "YES")))
```



``` {r expregasdfad, results = 'asis'}
# interaction term
df$did <- ifelse(df$SELECTED == 1, (as.numeric(df$SELECTED)-1)*df$wave, 0)

x <- df %>% filter(SELECTED != 3)

m1 <- lm(exp_all_trades ~ as.factor(SELECTED) + as.factor(wave), data = df)
m2 <- lm(exp_all_trades ~ as.factor(SELECTED) + as.factor(wave) + did, data = df)
m3 <- lm(exp_all_trades ~ as.factor(SELECTED) + as.factor(wave) + did + as.factor(FS1.11), data = df)
m4 <- lm(exp_all_trades ~ as.factor(SELECTED) + as.factor(wave) + did + as.factor(FS1.11), data = x)
m5 <- lm(exp_all_trades ~ as.factor(SELECTED) + as.factor(wave) + did + as.factor(FS1.2), data = df)
m6 <- lm(exp_all_trades ~ as.factor(SELECTED) + as.factor(wave) + did + as.factor(FS1.2), data = x)
m7 <- lm(exp_all_trades ~ as.factor(SELECTED) + as.factor(wave) + did + as.factor(IDYouth), data = df)
m8 <- lm(exp_all_trades ~ as.factor(SELECTED) + as.factor(wave) + did + as.factor(IDYouth), data = x)



stargazer(m1, m2, m3, m4, m5, m6, m7, m8, df = FALSE, omit = c("IDYouth", "FS1.2"), column.sep.width = "0pt",
          no.space = TRUE, digits = 2, header = F, table.placement = "H",
          notes = c("Omitted CQP category: applied but did not participate.", "Omitted Trade: Masonry"),
          notes.align = "r",
          notes.append = TRUE,
          covariate.labels = c("CQP",
                               "Did not apply",
                               "Endline",
                               "CQP x Endline",
                               "Carpentry",
                               "Plumbing",
                               "Metalwork",
                               "Electrical Inst."),
          title = "Experience regressions - further fixed effects",
          omit.stat=c("aic", "bic", "adj.rsq", "ser"),
          dep.var.labels = "Experience",
          model.names = FALSE,
          dep.var.caption = "",
          label = "tab:expregs",
          add.lines = list(c("Firm FE", "NO", "NO", "NO", "NO", "YES", "YES", "NO", "NO"),
                           c("Individual FE", "NO", "NO", "NO", "NO", "NO", "NO", "YES", "YES")))
```


``` {r expregasdfad2, results = 'asis'}
# interaction term
df$did <- ifelse(df$SELECTED == 1, (as.numeric(df$SELECTED)-1)*df$wave, 0)

x <- df %>% filter(SELECTED != 3)

m1 <- lm(comp_all_trades ~ as.factor(SELECTED) + as.factor(wave), data = df)
m2 <- lm(comp_all_trades ~ as.factor(SELECTED) + as.factor(wave) + did, data = df)
m3 <- lm(comp_all_trades ~ as.factor(SELECTED) + as.factor(wave) + did + as.factor(FS1.11), data = df)
m4 <- lm(comp_all_trades ~ as.factor(SELECTED) + as.factor(wave) + did + as.factor(FS1.11), data = x)
m5 <- lm(comp_all_trades ~ as.factor(SELECTED) + as.factor(wave) + did + as.factor(FS1.2), data = df)
m6 <- lm(comp_all_trades ~ as.factor(SELECTED) + as.factor(wave) + did + as.factor(FS1.2), data = x)
m7 <- lm(comp_all_trades ~ as.factor(SELECTED) + as.factor(wave) + did + as.factor(IDYouth), data = df)
m8 <- lm(comp_all_trades ~ as.factor(SELECTED) + as.factor(wave) + did + as.factor(IDYouth), data = x)



stargazer(m1, m2, m3, m4, m5, m6, m7, m8, df = FALSE, omit = c("IDYouth", "FS1.2"), column.sep.width = "0pt",
          no.space = TRUE, digits = 2, header = F, table.placement = "H",
          notes = c("Omitted CQP category: applied but did not participate.", "Omitted Trade: Masonry"),
          notes.align = "r",
          notes.append = TRUE,
          covariate.labels = c("CQP",
                               "Did not apply",
                               "Endline",
                               "CQP x Endline",
                               "Carpentry",
                               "Plumbing",
                               "Metalwork",
                               "Electrical Inst."),
          title = "Competence regressions - further fixed effects",
          omit.stat=c("aic", "bic", "adj.rsq", "ser"),
          dep.var.labels = "Competence",
          model.names = FALSE,
          dep.var.caption = "",
          label = "tab:expregs",
          add.lines = list(c("Firm FE", "NO", "NO", "NO", "NO", "YES", "YES", "NO", "NO"),
                           c("Individual FE", "NO", "NO", "NO", "NO", "NO", "NO", "YES", "YES")))
```

``` {r cbregsapp, results = 'asis'}
df$did <- ifelse(df$SELECTED == 1, (as.numeric(df$SELECTED)-1)*df$wave, 0)

x <- df %>% select(FS1.2, wave, SELECTED, cb_2, cb_V, firm_size_sans_app, baseline_duration, IDYouth, did) %>%
  mutate(wave = factor(wave, levels = 0:1, labels = c('Baseline', 'Endline')),
         cb_2 = cb_2 / 605,
         cb_V = cb_V / 605)

z <- x %>% filter(SELECTED != 3)

m1 <- lm(cb_2 ~ as.factor(SELECTED) + as.factor(wave) + firm_size_sans_app, data = x)
m2 <- lm(cb_2 ~ as.factor(SELECTED) + as.factor(wave) + firm_size_sans_app + did, data = x)
m3 <- lm(cb_2 ~ as.factor(SELECTED) + as.factor(wave) + firm_size_sans_app + did + as.factor(IDYouth), data = x)
m4 <- lm(cb_2 ~ as.factor(SELECTED) + as.factor(wave) + firm_size_sans_app + did + as.factor(IDYouth), data = z)

m5 <- lm(cb_V ~ as.factor(SELECTED) + as.factor(wave) + firm_size_sans_app, data = x)
m6 <- lm(cb_V ~ as.factor(SELECTED) + as.factor(wave) + firm_size_sans_app + did, data = x)
m7 <- lm(cb_V ~ as.factor(SELECTED) + as.factor(wave) + firm_size_sans_app + did + as.factor(IDYouth), data = x)
m8 <- lm(cb_V ~ as.factor(SELECTED) + as.factor(wave) + firm_size_sans_app + did + as.factor(IDYouth), data = z)


stargazer(m1, m2, m3, m4, m5, m6, m7, m8, df = FALSE, omit = "IDYouth", column.sep.width = "-8pt",
          no.space = TRUE, digits = 1, header = F, table.placement = "H",
          notes = c("Omitted wave: Baseline", "$^†$Excluding apprentices."),
          notes.align = "r",
          notes.append = TRUE,
          covariate.labels = c("CQP participant",
                               "CQP non-applicant",
                               "Endline",
                               "Firm size$^†$",
                               "CQP x Endline"),
          title = "Apprentice-level cost benefit regressions",
          omit.stat=c("aic", "bic", "adj.rsq", "ser"),
          model.names = FALSE,
          dep.var.caption = "Annual Net Benefits in USD",
          dep.var.labels = c("Model I", "Model II", "Model III"),
          add.lines = list(c("Indiv. FE", "NO", "NO", "YES", "YES", "NO", "NO", "YES", "YES")),
          label = "tab:cbregsapp")
```

``` {r cbregsfirm2, results = 'asis'}
x <- df %>% select(FS1.2, wave, cb_2, cb_V, firm_size_sans_app, dossier_selected, FS6.1, profits) %>%
  mutate(wave = factor(wave, levels = 0:1, labels = c('Baseline', 'Endline')),
         cb_2 = cb_2 / 605,
         cb_V = cb_V / 605) %>% 
  group_by(FS1.2, wave) %>% summarise_all(mean, na.rm = T) %>% ungroup()

m1 <- lm(cb_2 ~ FS6.1 + dossier_selected + firm_size_sans_app + as.factor(wave) + as.factor(FS1.2), data = x)
m2 <- plm(cb_2 ~ FS6.1 + as.factor(wave), data = x, index = c("FS1.2", "wave"), model = "within")
m3 <- lm(cb_V ~ FS6.1 + dossier_selected + firm_size_sans_app + as.factor(wave) + as.factor(FS1.2), data = x)
m4 <- plm(cb_V ~ FS6.1 + as.factor(wave), data = x, index = c("FS1.2", "wave"), model = "within")


stargazer(m1, m2, m3, m4, df = FALSE, omit = "FS1.2",
          no.space = TRUE, digits = 2, header = F, table.placement = "H",
          notes = c("Omitted wave: Baseline", "$^†$Excluding apprentices."),
          notes.align = "r",
          notes.append = TRUE,
          covariate.labels = c("Apprentices",
                               "CQPs",
                               "Endline",
                               "Firm size$^†$"),
          title = "Firm-level cost benefit regressions",
          omit.stat=c("aic", "bic", "adj.rsq", "ser"),
          model.names = FALSE,
          dep.var.caption = "Annual Net Benefits in USD",
          dep.var.labels = c("Model I", "Model II", "Model III"),
          add.lines = list(c("Firm FE", "NO", "YES", "NO", "YES", "NO", "YES")),
          label = "tab:firmregs")
```