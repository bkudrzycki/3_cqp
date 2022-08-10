#################
## Regressions ##
#################

packages <- c("MASS", "plm", "tidyverse", "labelled", "gtsummary")

# Install packages not yet installed
installed_packages <- packages %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  install.packages(packages[!installed_packages], silent = TRUE)
}

# Load packages
invisible(lapply(packages, library, character.only = TRUE))
suppressMessages(library(stargazer))

rm(packages, installed_packages)

# Set working directory
setwd("~/polybox/Youth Employment/2 CQP/Paper")

#load data
load("data/df.rda")


## Benefits for apprentices


# Skills

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
          label = "skillsreg",
          title = "Apprentice Knowledge 1",
          dep.var.labels = "Fraction of correctly answered skills questions (with firm FE)",
          add.lines = list(c("Firm FE", "YES", "YES", "YES", "YES", "YES")))

# no FE

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
          label = "skillsreg",
          title = "Apprentice Knowledge 2",
          dep.var.labels = "Fraction of correctly answered skills questions",
          add.lines = list(c("Firm FE", "NO", "NO", "NO", "NO", "NO")))



# Competencies

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

# no FE

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


# minus non-applicants ("traditional" apprentices)
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

# minus non-applicants ("traditional" apprentices), no firm FE

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

# Experience

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

# no firm FE

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


# minus non-applicants

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

# minus non-applicants, no firm FE

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


## Benefits for firms

x <- df %>% select(FS1.2, wave, firm_size, dossier_selected, FS4.7, FS5.1, FS5.3, FS5.4, FS6.1, profits) %>%
  mutate(wave = factor(wave, labels = c("Baseline", "Endline"))) %>% 
  group_by(FS1.2, wave) %>% summarise_all(mean, na.rm = T) %>% ungroup() %>% pivot_wider(names_from = wave, values_from = c(firm_size, FS6.1, FS4.7, FS5.1, FS5.3, FS5.4, FS6.1, profits)) %>% 
  mutate(diff_firm_size = firm_size_Endline-firm_size_Baseline,
         diff_tot_apps = FS6.1_Endline-FS6.1_Baseline,
         diff_revenues = FS4.7_Endline-FS4.7_Baseline,
         diff_costs = FS5.1_Endline-FS5.1_Baseline,
         diff_wages = FS5.3_Endline-FS5.3_Baseline,
         diff_profits_rep = FS5.4_Endline-FS5.4_Baseline,
         diff_profits_calc = profits_Endline-profits_Baseline)

# Size
m1 <- lm(diff_firm_size ~ dossier_selected + diff_tot_apps + firm_size_Baseline, data = x)
m2 <- lm(diff_revenues ~ dossier_selected + diff_tot_apps + diff_firm_size, data = x)

# Costs
m3 <- lm(diff_costs ~ dossier_selected + diff_tot_apps + diff_firm_size, data = x)
m4 <- lm(diff_wages ~ dossier_selected + diff_tot_apps + diff_firm_size, data = x)

# Profits
m5 <- lm(diff_profits_rep ~ dossier_selected + diff_tot_apps + diff_firm_size, data = x)
m6 <- lm(diff_profits_calc ~ dossier_selected + diff_tot_apps + diff_firm_size, data = x)

tbl_regression(m1)
tbl_regression(m2)
tbl_regression(m3)
tbl_regression(m4)
tbl_regression(m5)
tbl_regression(m6)

stargazer(m1, m2, m3, m4, m5, m6, df = FALSE, model.names = FALSE, model.numbers = FALSE,
          no.space = TRUE, digits = 0, header = F,
          covariate.labels = c("CQP trainees",
                               "Total apprentices",
                               "Baseline firm size",
                               "Firm Growth"),
          dep.var.labels = c('Revenues', 'Profits', 'Profits'),
          column.labels= c('', '(Reported)', '(Computed)'))


# costs and benefits

m1 <- lm(cb_simple ~ factor(SELECTED) + baseline_duration + factor(FS1.2), data = df)
m2 <- lm(cb_simple ~ factor(SELECTED) + baseline_duration  + firm_size + FS6.1 + dossier_selected + factor(FS1.2), data = df) #FS6.1: number apprentices
m3 <- lm(cb_simple ~ factor(SELECTED) + baseline_duration  + firm_size + FS6.1 + dossier_selected + FS6.8 + FS6.9 + FS6.10 + factor(FS1.2), data = df)

tbl_regression(m1)
tbl_regression(m2)
tbl_regression(m3)


# now only comparing successful and unsuccessful applicants
x <- df %>% filter(SELECTED != 3)
x$did <- x$SELECTED * x$wave

m1 <- lm(cb_simple ~ factor(SELECTED) + baseline_duration + factor(FS1.2), data = x)
m2 <- lm(cb_simple ~ factor(SELECTED) + wave + baseline_duration + factor(FS1.2), data = x)
m3 <- lm(cb_simple ~ factor(SELECTED) + wave + did + baseline_duration + factor(FS1.2), data = x)

tbl_regression(m1)
tbl_regression(m2)
tbl_regression(m3)


# ordinal logistic regression robustness check

x <- df %>% select(FS1.2, wave, firm_size, FS1.11, dossier_selected, FS4.7, FS5.1, FS5.3, FS5.4, FS6.1, profits) %>%
  mutate(wave = factor(wave, labels = c("Baseline", "Endline"))) %>% 
  group_by(FS1.2, wave) %>% summarise_all(mean, na.rm = T) %>% ungroup()

m1 <- polr(factor(FS5.4) ~ dossier_selected + FS6.1 + wave, data = x, Hess=TRUE)
m2 <- polr(factor(FS5.4) ~ dossier_selected + FS6.1 + wave + as.factor(FS1.11), data = x, Hess=TRUE)
tbl_regression(m1)
tbl_regression(m2)
rm(list = ls())


# fixed effects
x <- df %>% select(FS1.2, wave, firm_size_sans_app, dossier_selected, FS3.4, FS6.1, FS1.11) %>%
  mutate(wave = factor(wave, levels = 0:1, labels = c('Baseline', 'Endline'))) %>% 
  group_by(FS1.2, wave, FS1.11) %>% summarise_all(mean, na.rm = T) %>% ungroup()

m1 <- lm(firm_size_sans_app ~ FS6.1 + wave, data = x)
m2 <- lm(firm_size_sans_app ~ FS6.1 + factor(FS1.2) + wave, data = x)
m3 <- lm(firm_size_sans_app ~ FS6.1 + factor(FS1.11) + wave, data = x)
m4 <- felm(firm_size_sans_app ~ FS6.1 + factor(FS1.2) + factor(FS1.11) + wave, data = x)
m5 <- felm(log(firm_size_sans_app) ~ log(FS6.1) + factor(FS1.2) + factor(FS1.11) + wave, data = x)

stargazer(m1, m2, m3, m4, m5, df = FALSE, omit = "FS1.2", model.names = FALSE, model.numbers = FALSE,
          no.space = TRUE, digits = 3, header = F, table.placement = "H",
          covariate.labels = c("Apprentices",
                               "log(Apprentices)",
                               "Carpentry",
                               "Plumbing",
                               "Metalwork",
                               "Electrical Inst.",
                               "Endline"),
          notes = "Omitted trade: Masonry",
          title = "Fixed effects regression results",
          dep.var.labels = c("Firm Size (excluding apprentices)", "log(Firm Size)"),
          add.lines = list(c("Firm FE", "NO", "YES", "NO", "YES", "YES"),
                           c("Trade FE", "NO", "NO", "YES", "NO", "YES")))


x <- df %>% select(IDYouth, wave, SELECTED, exp_all_trades) %>% filter(!is.na(exp_all_trades))

df <- df %>% filter(!is.na(exp_all_trades)) %>% filter(!is.nan(exp_all_trades))


# most basic pooling model

m1 <- lm(exp_all_trades ~ as.factor(SELECTED), data = df)
plm1 <- plm(exp_all_trades ~ as.factor(SELECTED), data = df, index = c("IDYouth", "wave"), model = "pooling") # same as m1
tbl_merge(list(tbl_regression(m1), tbl_regression(plm1)))

# add controls for: time, trade, firm, and finally individuals
m1a <- lm(exp_all_trades ~ as.factor(SELECTED) + as.factor(wave), data = df) # <- preferred
m1b <- lm(exp_all_trades ~ as.factor(SELECTED) + as.factor(wave) + as.factor(FS1.11), data = df)
m1c <- lm(exp_all_trades ~ as.factor(SELECTED) + as.factor(wave) + as.factor(FS1.11) + as.factor(FS1.2), data = df)
m1d <- lm(exp_all_trades ~ as.factor(SELECTED) + as.factor(wave) + as.factor(FS1.11) + as.factor(FS1.2) + as.factor(IDYouth), data = df)
m1e <- lm(exp_all_trades ~ as.factor(SELECTED) + as.factor(FS1.11), data = df)
m1f <- lm(exp_all_trades ~ as.factor(SELECTED) + as.factor(FS1.2), data = df)
m1g <- lm(exp_all_trades ~ as.factor(SELECTED) + as.factor(wave) + as.factor(IDYouth), data = df)
tbl_merge(list(tbl_regression(m1), tbl_regression(m1a), tbl_regression(m1b), tbl_regression(m1c), tbl_regression(m1d), tbl_regression(m1e), tbl_regression(m1f), tbl_regression(m1g)))

#To test the presence of individual and time effects in m1, using the Gourieroux, Holly, and Monfort (1982) test, we run:
plmtest(m1, effect="twoways", type="ghm")
# We CAN reject the hypothesis of no significant individual and time effects, both for the basic and the full specification

# Thus, we first run pooled OLS with individual and time fixed effects (for the full sample and CQP applicants separately)
plm2 <- plm(exp_all_trades ~ as.factor(SELECTED) + as.factor(wave), data = df, index = c("IDYouth", "wave"), model = "pooling")  # same as lm
plm3 <- plm(exp_all_trades ~ as.factor(SELECTED) + as.factor(IDYouth), data = df, index = c("IDYouth", "wave"), model = "pooling") # same as lm
tbl_merge(list(tbl_regression(plm2), tbl_regression(plm3)))
          
# random or fixed effects??
m2 <- plm(exp_all_trades ~ as.factor(SELECTED), data = df, index = c("IDYouth", "wave"), model = "within", effect="time")
m3 <- plm(exp_all_trades ~ as.factor(SELECTED), data = df, index = c("IDYouth", "wave"), model = "random", effect = "time", random.method="walhus")
phtest(m3, m4)
# We CANNOT reject the Hausman null hypothesis (it's borderline for some specifications). Thus random effects are the preferred specification


plm4 <- plm(exp_all_trades ~ as.factor(SELECTED), data = df, index = c("IDYouth", "wave"), model = "random", random.method="walhus") # same as "individual" effects
plm4a <- plm(exp_all_trades ~ as.factor(SELECTED), data = df, index = c("IDYouth", "wave"), model = "random", effect = "time", random.method="walhus") #same as "amemiya" random.method and as pooled with time fixed effects
plm4b <- plm(exp_all_trades ~ as.factor(SELECTED), data = df, index = c("IDYouth", "wave"), model = "random", effect = "individual", random.method="walhus")
plm4c <- plm(exp_all_trades ~ as.factor(SELECTED), data = df, index = c("IDYouth", "wave"), model = "random", effect = "twoways", random.method="walhus")


tbl_merge(list(tbl_regression(plm4), tbl_regression(plm4a), tbl_regression(plm4b), tbl_regression(plm4c)))

#repeat adding regressors stepwise

## FIRM SIZE
plm5 <- plm(exp_all_trades ~ as.factor(SELECTED) + firm_size_sans_app + FS6.1, data = df, index = c("IDYouth", "wave"), model = "random", random.method="walhus") #preferred
plm5a <- plm(exp_all_trades ~ as.factor(SELECTED) + firm_size_sans_app + FS6.1, data = df, index = c("IDYouth", "wave"), model = "random", effect = "time", random.method="walhus")
plm5c <- plm(exp_all_trades ~ as.factor(SELECTED) + firm_size_sans_app + FS6.1, data = df, index = c("IDYouth", "wave"), model = "random", effect = "twoways", random.method="walhus")

tbl_merge(list(tbl_regression(plm5), tbl_regression(plm5a), tbl_regression(plm5c)))


## TRAINING CHARACTERISTICS
plm6 <- plm(exp_all_trades ~ as.factor(SELECTED) + firm_size_sans_app + FS6.1 + FS6.8 + FS6.9 + FS6.10, data = df, index = c("IDYouth", "wave"), model = "random", random.method="walhus")
plm6a <- plm(exp_all_trades ~ as.factor(SELECTED) + firm_size_sans_app + FS6.1 + FS6.8 + FS6.9 + FS6.10, data = df, index = c("IDYouth", "wave"), model = "random", effect = "time", random.method="walhus")
plm6c <- plm(exp_all_trades ~ as.factor(SELECTED) + firm_size_sans_app + FS6.1 + FS6.8 + FS6.9 + FS6.10, data = df, index = c("IDYouth", "wave"), model = "random", effect = "twoways", random.method="walhus")

tbl_merge(list(tbl_regression(plm6), tbl_regression(plm6a), tbl_regression(plm6c)))


plm4 <- plm(exp_all_trades ~ as.factor(SELECTED), data = df, index = c("IDYouth", "wave"), model = "random", random.method="walhus") # same as "individual" effects
plm4a <- plm(exp_all_trades ~ as.factor(SELECTED), data = df, index = c("IDYouth", "wave"), model = "random", effect = "time", random.method="walhus") #same as "amemiya" random.method
plm4c <- plm(exp_all_trades ~ as.factor(SELECTED), data = df, index = c("IDYouth", "wave"), model = "random", effect = "twoways", random.method="walhus")


m2 <- lm(exp_all_trades ~ as.factor(SELECTED) + as.factor(wave), data = df)
m3 <- lm(exp_all_trades ~ as.factor(SELECTED) + as.factor(IDYouth) + as.factor(wave), data = df)
tbl_merge(list(tbl_regression(m0), tbl_regression(m1), tbl_regression(m2), tbl_regression(m3)))

plm1 <- plm(exp_all_trades ~ as.factor(SELECTED), data = df, index = c("IDYouth", "wave"), model = "pooling", effect = "individual")
plm2 <- plm(exp_all_trades ~ as.factor(SELECTED), data = df, index = c("IDYouth", "wave"), model = "pooling", effect = "time")
plm3 <- plm(exp_all_trades ~ as.factor(SELECTED), data = df, index = c("IDYouth", "wave"), model = "pooling", effect = "twoways")
tbl_merge(list(tbl_regression(plm1), tbl_regression(plm2), tbl_regression(plm3)))


m2 <- plm(exp_all_trades ~ as.factor(SELECTED) + firm_size_sans_app + FS6.1 + FS6.8 + FS6.9 + FS6.10, data = df, index = c("IDYouth", "wave"), model = "pooling")


# random or fixed effects??
m3 <- plm(exp_all_trades ~ as.factor(SELECTED) + firm_size_sans_app + FS6.1 + FS6.8 + FS6.9 + FS6.10, data = df, index = c("IDYouth", "wave"), model = "within")
m4 <- plm(exp_all_trades ~ as.factor(SELECTED) + firm_size_sans_app + FS6.1 + FS6.8 + FS6.9 + FS6.10, data = df, index = c("IDYouth", "wave"), model = "random")
phtest(m3, m4)

# We CANNOT reject the Hausman null hypothesis (it's borderline for some specifications). Thus random effects are the preferred specification
m5 <- plm(exp_all_trades ~ as.factor(SELECTED) + firm_size_sans_app + FS6.1 + FS6.8 + FS6.9 + FS6.10, data = df, index = c("IDYouth", "wave"), model = "random")
m6 <- lmer(exp_all_trades ~ as.factor(SELECTED) + FS6.1 + (1|IDYouth), data = df)
m7 <- lmer(exp_all_trades ~ as.factor(SELECTED) + FS6.1 + as.factor(wave) + (1|IDYouth), data = df)
m8 <- plm(exp_all_trades ~ as.factor(SELECTED) + FS6.1, data = df, index = c("IDYouth", "wave"), model = "random", effect = "individual")


tbl_merge(list(tbl_regression(m6), tbl_regression(m7), tbl_regression(m8)))

