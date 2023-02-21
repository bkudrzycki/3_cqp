#################
## Regressions ##
#################

packages <- c("haven", "tidyverse", "labelled", "gtsummary", "stargazer")

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

# load cleaned and recoded data

load("data/df.rda")
load("data/fs.rda")

# load functions
source("functions/functions.R")

df_labels <- haven::as_factor(df)

app_total_by_type <- df %>% 
  group_by(FS1.2, wave) %>% 
  summarise(num_cqp = sum(cqp, na.rm = T)) %>% ungroup()

#________

joined_long <- rbind(fs %>% select('FS1.2', 'FS3.4', 'FS4.7', 'FS5.4', 'FS6.1', 'FS6.2', 'FS6.3', 'FS6.5', 'FS6.8', 'FS6.9', 'FS6.10', 'wave'), zap_labels(fs_end %>% select('FS1.2', 'FS3.4', 'FS4.7', 'FS5.4', 'FS6.1', 'FS6.2', 'FS6.3', 'FS6.5', 'FS6.8', 'FS6.9', 'FS6.10', 'wave'))) %>% 
  mutate_at(c('FS4.7', 'FS5.4'), recode,
            `7` = 0,
            `10` = 10000,
            `11` = 30000,
            `12` = 60000,
            `13` = 100000,
            `14` = 162500,
            `15` = 250000,
            `16` = 425000,
            `17` = 550000,
            `18` = 825000,
            `19` = 1250000) %>% 
  mutate_at(c('FS4.7', 'FS5.4'), na_if, 20)

firm_averages <- df %>% select(-'IDYouth') %>% group_by(FS1.2, wave) %>% summarise_at(tidyselect::vars_select(names(df), matches(c("allow", "fees", "wages", "hours", "skills", "comp", "rating", ""))), mean) %>% ungroup() %>% 
  left_join(joined_long, by = c("FS1.2", "wave")) %>% 
  left_join(app_total_by_type, by = c("FS1.2", "wave"))

by_status_1 <- df %>% select(-'IDYouth') %>% group_by(FS1.2, wave, status) %>% summarise_at(tidyselect::vars_select(names(df), matches(c("allow", "fees", "wages", "hours", "skills", "comp", "rating"))), mean) %>% ungroup()
  
by_status_2 <- df %>% select(-'IDYouth') %>% group_by(FS1.2, wave, status2) %>% summarise_at(tidyselect::vars_select(names(df), matches(c("allow", "fees", "wages", "hours", "skills", "comp", "rating"))), mean) %>% ungroup()



# firm regressions


                                    
reg1 <- firm_averages

# create diff in diff interaction term
reg1$did1 <- reg1$wave * reg1$app_ratio
reg1$did2 <- reg1$wave * reg1$cqp_ratio
reg1$did3 <- reg1$wave * reg1$comp_all_trades
reg1$did4 <- reg1$wave * reg1$skills_all_trades

m1 <- lm(FS3.4 ~ app_ratio + wave + did1, data = reg1)
m2 <- lm(FS3.4 ~ cqp_ratio + wave + did2, data = reg1)
m3 <- lm(FS3.4 ~ comp_all_trades + wave + did3, data = reg1)
m4 <- lm(FS3.4 ~ skills_all_trades + wave + did4, data = reg1)

stargazer(m1, m2, m3, m4,
          covariate.labels = c("ratio of apprentices to employees",
                                "proportion of cqp apprentices",
                               "competency question scores",
                               "skills question scores",
                               "wave",
                               "apprentice ratio * wave",
                               "cqp ratio * wave",
                               "competency * wave",
                               "skills*wave"),
          column.labels=c('Firm Size', 'Firm Size', 'Firm Size', 'Firm Size'))
                               

m5 <- lm(FS3.4 ~ app_ratio + cqp_ratio + comp_all_trades + skills_all_trades + all_allowances + all_ratings + wave, data = reg1)

stargazer(m5,
          covariate.labels = c("ratio of apprentices to employees",
                               "proportion of cqp apprentices",
                               "competency question scores",
                               "skills question scores",
                               "total apprentice benefits disbursed",
                               "apprentice ratings of firm",
                               "wave"),
          column.labels=c('Firm Size'))

reg2 <- firm_averages

# create diff in diff interaction term
reg2$did1 <- reg2$wave * reg2$app_ratio
reg2$did2 <- reg2$wave * reg2$cqp_ratio
reg2$did3 <- reg2$wave * reg2$comp_all_trades
reg2$did4 <- reg2$wave * reg2$skills_all_trades

m1 <- lm(FS4.7 ~ app_ratio + wave + did1, data = reg2)
m2 <- lm(FS4.7 ~ cqp_ratio + wave + did2, data = reg2)
m3 <- lm(FS4.7 ~ comp_all_trades + wave + did3, data = reg2)
m4 <- lm(FS4.7 ~ skills_all_trades + wave + did4, data = reg2)

stargazer(m1, m2, m3, m4,
          covariate.labels = c("ratio of apprentices to employees",
                               "proportion of cqp apprentices",
                               "competency question scores",
                               "skills question scores",
                               "wave",
                               "apprentice ratio * wave",
                               "cqp ratio * wave",
                               "competency * wave",
                               "skills*wave"),
          column.labels=c('Firm Revenues', 'Firm Revenues', 'Firm Revenues', 'Firm Revenues'))


m5 <- lm(FS4.7 ~ app_ratio + cqp_ratio + comp_all_trades + skills_all_trades + all_allowances + all_ratings + wave, data = reg2)

stargazer(m5,
          covariate.labels = c("ratio of apprentices to employees",
                               "proportion of cqp apprentices",
                               "competency question scores",
                               "skills question scores",
                               "total apprentice benefits disbursed",
                               "apprentice ratings of firm",
                               "wave"),
          column.labels=c('Firm Revenues'))



reg3 <- firm_averages


reg3$did1 <- reg3$wave * reg3$app_ratio
reg3$did2 <- reg3$wave * reg3$cqp_ratio
reg3$did3 <- reg3$wave * reg3$comp_all_trades
reg3$did4 <- reg3$wave * reg3$skills_all_trades

m1 <- lm(FS5.4 ~ app_ratio + wave + did1, data = reg3)
m2 <- lm(FS5.4 ~ cqp_ratio + wave + did2, data = reg3)
m3 <- lm(FS5.4 ~ comp_all_trades + wave + did3, data = reg3)
m4 <- lm(FS5.4 ~ skills_all_trades + wave + did4, data = reg3)

stargazer(m1, m2, m3, m4,
          covariate.labels = c("ratio of apprentices to employees",
                               "proportion of cqp apprentices",
                               "competency question scores",
                               "skills question scores",
                               "wave",
                               "apprentice ratio * wave",
                               "cqp ratio * wave",
                               "competency * wave",
                               "skills*wave"),
          column.labels=c('Firm Profits', 'Firm Profits', 'Firm Profits', 'Firm Profits'))


m5 <- lm(FS5.4 ~ app_ratio + cqp_ratio + comp_all_trades + skills_all_trades + all_allowances + all_ratings + wave, data = reg3)

stargazer(m5,
          covariate.labels = c("ratio of apprentices to employees",
                               "proportion of cqp apprentices",
                               "competency question scores",
                               "skills question scores",
                               "total apprentice benefits disbursed",
                               "apprentice ratings of firm",
                               "wave"),
          column.labels=c('Firm Profits'))



reg4 <- df %>% select(tidyselect::vars_select(names(df), -matches(c("allow", "fees", "wages", "hours", "skills", "comp", "rating")))) %>%  left_join(firm_averages, by = c("FS1.2", "wave"))

reg4$app_skill <- reg4 %>% select(tidyselect::vars_select(names(reg4), matches('correct'))) %>% rowMeans(., na.rm = T)
reg4$app_comp <- reg4 %>% select(tidyselect::vars_select(names(reg4), matches('FS9'))) %>% rowMeans(., na.rm = T)

reg4$did1 <- reg4$wave * reg4$cqp.y
reg4$did2 <- reg4$wave * reg4$cqp_ratio
reg4$did3 <- reg4$wave * reg4$FS3.4
reg4$did4 <- reg4$wave * reg4$FS4.7
reg4$did5 <- reg4$wave * reg4$FS5.4

m1 <- lm(app_skill ~ cqp.y + wave + did1, data = reg4)
m2 <- lm(app_skill ~ cqp_ratio + wave + did2, data = reg4)
m3 <- lm(app_skill ~ FS3.4 + wave + did3, data = reg4)
m4 <- lm(app_skill ~ FS6.8 + wave + did4, data = reg4)
m5 <- lm(app_skill ~ FS6.9  + wave + did5, data = reg4)

stargazer(m1, m2, m3, m4, m5,
          covariate.labels = c("participation in CQP",
                               "proportion of cqp apprentices in firm",
                               "firm size",
                               "number of trainers",
                               "number of days trained last week",
                               "wave",
                               "cqp * wave",
                               "cqp ratio * wave",
                               "firm size * wave",
                               "num. trainers * wave",
                               "num. days trained * wave"),
          column.labels=c('Skills', 'Skills','Skills','Skills','Skills'))



m1 <- lm(app_comp ~ cqp.y + wave + did1, data = reg4)
m2 <- lm(app_comp ~ cqp_ratio + wave + did2, data = reg4)
m3 <- lm(app_comp ~ FS3.4 + wave + did3, data = reg4)
m4 <- lm(app_comp ~ FS6.8 + wave + did4, data = reg4)
m5 <- lm(app_comp ~ FS6.9  + wave + did5, data = reg4)

stargazer(m1, m2, m3, m4, m5,
          covariate.labels = c("participation in CQP",
                               "proportion of cqp apprentices in firm",
                               "firm size",
                               "number of trainers",
                               "number of days trained last week",
                               "wave",
                               "cqp * wave",
                               "cqp ratio * wave",
                               "firm size * wave",
                               "num. trainers * wave",
                               "num. days trained * wave"),
          column.labels=c('Competencies', 'Competencies','Competencies','Competencies','Competencies'))


# baseline table for individual apprentices baseline/endline -> must match regression!
# firm level -> revenues, profits, etc...
# firm fixed effects -> number of cqps on revenues etc. -> control for firm fixed effects
# absolute number of CQPs, control 

## ---- tbl-knowreg --------
# interaction term
df$did <- ifelse(df$SELECTED == 1, (as.numeric(df$SELECTED)-1)*df$wave, 0)

x <- df %>% filter(SELECTED != 3)

m1 <- lm(skills_all_trades ~ as.factor(SELECTED) + as.factor(wave), data = df)
m2 <- lm(skills_all_trades ~ as.factor(SELECTED) + as.factor(wave) + did, data = df)
m3 <- lm(skills_all_trades ~ as.factor(SELECTED) + as.factor(wave) + did + as.factor(IDYouth), data = df)
m4 <- lm(skills_all_trades ~ as.factor(SELECTED) + as.factor(wave) + did + as.factor(IDYouth), data = x)

m5 <- lm(skills_all_trades ~ as.factor(SELECTED) + as.factor(wave) + did + baseline_duration, data = df)
m6 <- lm(skills_all_trades ~ as.factor(SELECTED) + as.factor(wave) + did + baseline_duration + firm_size_sans_app + FS6.1, data = df)
m7 <- lm(skills_all_trades ~ as.factor(SELECTED) + as.factor(wave) + did + baseline_duration + firm_size_sans_app + FS6.1 + FS6.8 + FS6.9 + FS6.10 + ext_training, data = df)
m8 <- lm(skills_all_trades ~ as.factor(SELECTED) + as.factor(wave) + did + baseline_duration + firm_size_sans_app + FS6.1 + FS6.8 + FS6.9 + FS6.10 + ext_training, data = x)

stargazer(m1, m2, m3, m4, m5, m6, m7, m8, df = FALSE, omit = "IDYouth", column.sep.width = "0pt",
          no.space = TRUE, digits = 2, header = F, table.placement = "H",
          notes = c("Omitted CQP category: applied but did not participate."),
          notes.align = "r",
          notes.append = TRUE,
          covariate.labels = c("CQP participant",
                               "Endline",
                               "CQP x Endline",
                               "Experience",
                               "Firm size",
                               "Total apprentices",
                               "Total instructors",
                               "Days trained per week",
                               "Duration, last training",
                               "External training"),
          title = "Knowledge regressions",
          omit.stat=c("aic", "bic", "adj.rsq", "ser"),
          dep.var.labels = "Knowledge",
          model.names = FALSE,
          dep.var.caption = "",
          label = "tab:knowreg",
          add.lines = list(c("Individual FE", "NO", "NO", "YES", "YES", "NO", "NO", "NO", "NO")))
