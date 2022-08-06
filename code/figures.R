#############
## Figures ##
#############

packages <- c("ggplot2", "tidyverse", "labelled", "gtsummary")

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




x <- df %>% select(firm_size_bins, cb_simple, cb_complex) %>% filter(!is.na(firm_size_bins)) %>% group_by(firm_size_bins) %>% summarise_all(mean, na.rm = T) %>% ungroup()

ggplot(data=x, aes(x=firm_size_bins, y=cb_simple)) +
  geom_bar(stat="identity", color="black", position=position_dodge())+
  theme_minimal()

ggplot(data=x, aes(x=firm_size_bins, y=cb_complex)) +
  geom_bar(stat="identity", color="black", position=position_dodge())+
  theme_minimal()

# together, relative to profits, endline
x <- df %>% filter(!is.na(firm_size_bins), !is.na(FS5.4), wave == 1, FS5.4 != 0) %>% select(FS1.2, firm_size_bins, cb_simple, cb_complex, FS5.4) %>%
  group_by(FS1.2,firm_size_bins) %>% summarise_all(mean, na.rm = T) %>% 
  mutate(cb_simple = cb_simple / FS5.4*100,
         cb_complex = cb_complex / FS5.4*100) %>% ungroup() %>% 
  select(-FS1.2) %>% 
  group_by(firm_size_bins) %>% summarise_all(mean, na.rm = T) %>% ungroup() %>% pivot_longer(cols = c("cb_simple", "cb_complex"))

ggplot(data=x, aes(x=firm_size_bins, y=value, fill=name)) +
  geom_bar(stat="identity", color="black", position=position_dodge())+
  theme_minimal() + scale_fill_manual(values=c('#999999','#E69F00'))

# together, relative to profits, endline, calculated profits
x <- df %>% filter(!is.na(firm_size_bins), !is.na(profits), wave == 0, profits != 0) %>% select(FS1.2, firm_size_bins, cb_simple, cb_complex, profits) %>%
  group_by(FS1.2,firm_size_bins) %>% summarise_all(mean, na.rm = T) %>% 
  mutate(cb_simple = cb_simple / profits*100,
         cb_complex = cb_complex / profits*100) %>% ungroup() %>% 
  select(-FS1.2) %>% 
  group_by(firm_size_bins) %>% summarise_all(mean, na.rm = T) %>% ungroup() %>% pivot_longer(cols = c("cb_simple", "cb_complex"))

ggplot(data=x, aes(x=firm_size_bins, y=value, fill=name)) +
  geom_bar(stat="identity", color="black", position=position_dodge())+
  theme_minimal() + scale_fill_manual(values=c('#999999','#E69F00'))

## ---- fig-apphist --------
pct01 = .01
pct05 = .05
pct10 = .10

x <- firms %>% filter(wave == 0, dplyr::between(cb_I, quantile(cb_I, pct01), quantile(cb_I, 1-pct01))) %>% select("value" = cb_I) %>% mutate(name = "cb_I", value = value / 605, mean = mean(value), med = median(value), pct = "1%")

y <- firms %>% filter(wave == 0, dplyr::between(cb_I, quantile(cb_I, pct05), quantile(cb_I, 1-pct05))) %>% select("value" = cb_I) %>% mutate(name = "cb_I", value = value / 605, mean = mean(value), med = median(value), pct = "5%")

z <- firms %>% filter(wave == 0, dplyr::between(cb_I, quantile(cb_I, pct10), quantile(cb_I, 1-pct10))) %>% select("value" = cb_I) %>% mutate(name = "cb_I", value = value / 605, mean = mean(value), med = median(value), pct = "10%")

a <- rbind(x,y,z) %>% mutate(pct = factor(pct, levels = c("1%", "5%", "10%")))

p1 <- ggplot(a, aes(x=value, y=..density.., fill = pct)) + geom_histogram(binwidth = 20, alpha=0.75) + geom_density(alpha = .3) + labs(y = "Density", x = "") + geom_vline(aes(xintercept=mean), linetype="dashed") + geom_text(aes(0,0,label = paste0("Mean: $", round(mean, 1))), vjust = -15, hjust = 1.5, size = 3) + scale_color_manual(values=c("#999999", "#E69F00", "#56B4E9"), guide = "none") + scale_fill_manual(values=c("#999999", "#999999", "#999999"), guide = "none") + theme_minimal() + theme(legend.position = "bottom") + facet_wrap(~ pct, scales = "fixed") + theme(axis.text.x=element_text(angle=45,hjust=1))

x <- firms %>% filter(wave == 0, dplyr::between(cb_II, quantile(cb_II, pct01), quantile(cb_II, 1-pct01))) %>% select("value" = cb_II) %>% mutate(name = "cb_II", value = value / 605, mean = mean(value), med = median(value), pct = "1%")

y <- firms %>% filter(wave == 0, dplyr::between(cb_II, quantile(cb_II, pct05), quantile(cb_II, 1-pct05))) %>% select("value" = cb_II) %>% mutate(name = "cb_II", value = value / 605, mean = mean(value), med = median(value), pct = "5%")

z <- firms %>% filter(wave == 0, dplyr::between(cb_II, quantile(cb_II, pct10), quantile(cb_II, 1-pct10))) %>% select("value" = cb_II) %>% mutate(name = "cb_II", value = value / 605, mean = mean(value), med = median(value), pct = "10%")

a <- rbind(x,y,z) %>% mutate(pct = factor(pct, levels = c("1%", "5%", "10%")))

p2 <- ggplot(a, aes(x=value, y=..density.., fill = pct)) + geom_histogram(binwidth = 20, alpha=0.75) + geom_density(alpha = .3) + labs(y = "Density", x = "") + geom_vline(aes(xintercept=mean), linetype="dashed") + geom_text(aes(0,0,label = paste0("Mean: $", round(mean, 1))), vjust = -15, hjust = 1.5, size = 3) + scale_color_manual(values=c("#999999", "#E69F00", "#56B4E9"), guide = "none") + scale_fill_manual(values=c("#999999", "#999999", "#999999"), guide = "none") + theme_minimal() + theme(legend.position = "bottom") + facet_wrap(~ pct, scales = "fixed") + theme(axis.text.x=element_text(angle=45,hjust=1))

x <- firms %>% filter(wave == 0, dplyr::between(cb_III, quantile(cb_III, pct01), quantile(cb_III, 1-pct01))) %>% select("value" = cb_III) %>% mutate(name = "cb_III", value = value / 605, mean = mean(value), med = median(value), pct = "1%")

y <- firms %>% filter(wave == 0, dplyr::between(cb_III, quantile(cb_III, pct05), quantile(cb_III, 1-pct05))) %>% select("value" = cb_III) %>% mutate(name = "cb_III", value = value / 605, mean = mean(value), med = median(value), pct = "5%")

z <- firms %>% filter(wave == 0, dplyr::between(cb_III, quantile(cb_III, pct10), quantile(cb_III, 1-pct10))) %>% select("value" = cb_III) %>% mutate(name = "cb_III", value = value / 605, mean = mean(value), med = median(value), pct = "10%")

a <- rbind(x,y,z) %>% mutate(pct = factor(pct, levels = c("1%", "5%", "10%")))

p3 <- ggplot(a, aes(x=value, y=..density.., fill = pct)) + geom_histogram(binwidth = 20, alpha=0.75) + geom_density(alpha = .3) + labs(y = "Density", x = "") + geom_vline(aes(xintercept=mean), linetype="dashed") + geom_text(aes(0,0,label = paste0("Mean: $", round(mean, 1))), vjust = -15, hjust = 1.5, size = 3) + scale_color_manual(values=c("#999999", "#E69F00", "#56B4E9"), guide = "none") + scale_fill_manual(values=c("#999999", "#999999", "#999999"), guide = "none") + theme_minimal() + theme(legend.position = "bottom") + facet_wrap(~ pct, scales = "fixed") + theme(axis.text.x=element_text(angle=45,hjust=1))

x <- firms %>% filter(wave == 0, dplyr::between(cb_IV, quantile(cb_IV, pct01), quantile(cb_IV, 1-pct01))) %>% select("value" = cb_IV) %>% mutate(name = "cb_IV", value = value / 605, mean = mean(value), med = median(value), pct = "1%")

y <- firms %>% filter(wave == 0, dplyr::between(cb_IV, quantile(cb_IV, pct05), quantile(cb_IV, 1-pct05))) %>% select("value" = cb_IV) %>% mutate(name = "cb_IV", value = value / 605, mean = mean(value), med = median(value), pct = "5%")

z <- firms %>% filter(wave == 0, dplyr::between(cb_IV, quantile(cb_IV, pct10), quantile(cb_IV, 1-pct10))) %>% select("value" = cb_IV) %>% mutate(name = "cb_IV", value = value / 605, mean = mean(value), med = median(value), pct = "10%")

a <- rbind(x,y,z) %>% mutate(pct = factor(pct, levels = c("1%", "5%", "10%")))

p4 <- ggplot(a, aes(x=value, y=..density.., fill = pct)) + geom_histogram(binwidth = 20, alpha=0.75) + geom_density(alpha = .3) + labs(y = "Density", x = "") + geom_vline(aes(xintercept=mean), linetype="dashed") + geom_text(aes(0,0,label = paste0("Mean: $", round(mean, 1))), vjust = -15, hjust = 1.5, size = 3) + scale_color_manual(values=c("#999999", "#E69F00", "#56B4E9"), guide = "none") + scale_fill_manual(values=c("#999999", "#999999", "#999999"), guide = "none") + theme_minimal() + theme(legend.position = "bottom") + facet_wrap(~ pct, scales = "fixed") + theme(axis.text.x=element_text(angle=45,hjust=1))

x <- firms %>% filter(wave == 0, dplyr::between(cb_IV, quantile(cb_IV, pct01), quantile(cb_IV, 1-pct01))) %>% select("value" = cb_IV) %>% mutate(name = "cb_IV", value = value / 605, mean = mean(value), med = median(value), pct = "1%")

y <- firms %>% filter(wave == 0, dplyr::between(cb_IV, quantile(cb_IV, pct05), quantile(cb_IV, 1-pct05))) %>% select("value" = cb_IV) %>% mutate(name = "cb_IV", value = value / 605, mean = mean(value), med = median(value), pct = "5%")

z <- firms %>% filter(wave == 0, dplyr::between(cb_IV, quantile(cb_IV, pct10), quantile(cb_IV, 1-pct10))) %>% select("value" = cb_IV) %>% mutate(name = "cb_IV", value = value / 605, mean = mean(value), med = median(value), pct = "10%")

a <- rbind(x,y,z) %>% mutate(pct = factor(pct, levels = c("1%", "5%", "10%")))

p5 <- ggplot(a, aes(x=value, y=..density.., fill = pct)) + geom_histogram(binwidth = 20, alpha=0.75) + geom_density(alpha = .3) + labs(y = "Density", x = "") + geom_vline(aes(xintercept=mean), linetype="dashed") + geom_text(aes(0,0,label = paste0("Mean: $", round(mean, 1))), vjust = -15, hjust = 1.5, size = 3) + scale_color_manual(values=c("#999999", "#E69F00", "#56B4E9"), guide = "none") + scale_fill_manual(values=c("#999999", "#999999", "#999999"), guide = "none") + theme_minimal() + theme(legend.position = "bottom") + facet_wrap(~ pct, scales = "fixed") + theme(axis.text.x=element_text(angle=45,hjust=1))

grid.arrange(p1, p2, p3, p4, p5, nrow = 5)


## ---- fig-firmhist --------
firms_extrap <- firms %>% mutate(cb_I = FS6.1 * cb_I,
                                 cb_II = FS6.1 * cb_II,
                                 cb_III = FS6.1 * cb_III,
                                 cb_IV = FS6.1 * cb_IV,
                                 cb_V = FS6.1 * cb_V)

pct01 = .01
pct05 = .05
pct10 = .10

x <- firms_extrap %>% filter(wave == 0, dplyr::between(cb_I, quantile(cb_I, pct01), quantile(cb_I, 1-pct01))) %>% select("value" = cb_I) %>% mutate(name = "cb_I", value = value / 605, mean = mean(value), med = median(value), pct = "1%")

y <- firms_extrap %>% filter(wave == 0, dplyr::between(cb_I, quantile(cb_I, pct05), quantile(cb_I, 1-pct05))) %>% select("value" = cb_I) %>% mutate(name = "cb_I", value = value / 605, mean = mean(value), med = median(value), pct = "5%")

z <- firms_extrap %>% filter(wave == 0, dplyr::between(cb_I, quantile(cb_I, pct10), quantile(cb_I, 1-pct10))) %>% select("value" = cb_I) %>% mutate(name = "cb_I", value = value / 605, mean = mean(value), med = median(value), pct = "10%")

a <- rbind(x,y,z) %>% mutate(pct = factor(pct, levels = c("1%", "5%", "10%")))
                                               
p1 <- ggplot(a, aes(x=value, y=..density.., fill = pct)) + geom_histogram(binwidth = 100, alpha=0.75) + geom_density(alpha = .3) + labs(y = "Model I", x = "") + geom_vline(aes(xintercept=mean), linetype="dashed") + geom_text(aes(0,0,label = paste0("$ ", round(mean, 0))), vjust = -4, hjust = 2, size = 3, check_overlap = T) + scale_color_manual(values=c("#999999", "#E69F00", "#56B4E9"), guide = "none") + scale_fill_manual(values=c("#999999", "#999999", "#999999"), guide = "none") + theme_minimal() + facet_wrap(~ pct, scales = "free") + theme(axis.text.y=element_blank(), axis.text.x=element_text(angle=45,hjust=1), strip.text.x = element_text(size = 12))

x <- firms_extrap %>% filter(wave == 0, dplyr::between(cb_II, quantile(cb_II, pct01), quantile(cb_II, 1-pct01))) %>% select("value" = cb_II) %>% mutate(name = "cb_II", value = value / 605, mean = mean(value), med = median(value), pct = "1%")

y <- firms_extrap %>% filter(wave == 0, dplyr::between(cb_II, quantile(cb_II, pct05), quantile(cb_II, 1-pct05))) %>% select("value" = cb_II) %>% mutate(name = "cb_II", value = value / 605, mean = mean(value), med = median(value), pct = "5%")

z <- firms_extrap %>% filter(wave == 0, dplyr::between(cb_II, quantile(cb_II, pct10), quantile(cb_II, 1-pct10))) %>% select("value" = cb_II) %>% mutate(name = "cb_II", value = value / 605, mean = mean(value), med = median(value), pct = "10%")

a <- rbind(x,y,z) %>% mutate(pct = factor(pct, levels = c("1%", "5%", "10%")))

p2 <- ggplot(a, aes(x=value, y=..density.., fill = pct)) + geom_histogram(binwidth = 100, alpha=0.75) + geom_density(alpha = .3) + labs(y = "Model II", x = "") + geom_vline(aes(xintercept=mean), linetype="dashed") + geom_text(aes(0,0,label = paste0("$ ", round(mean, 0))), vjust = -6, hjust = 2, size = 3, check_overlap = T) + scale_color_manual(values=c("#999999", "#E69F00", "#56B4E9"), guide = "none") + scale_fill_manual(values=c("#999999", "#999999", "#999999"), guide = "none") + theme_minimal() + facet_wrap(~ pct, scales = "free") + theme(axis.text.y=element_blank(), axis.text.x=element_text(angle=45,hjust=1), strip.text.x = element_blank())

x <- firms_extrap %>% filter(wave == 0, dplyr::between(cb_III, quantile(cb_III, pct01), quantile(cb_III, 1-pct01))) %>% select("value" = cb_III) %>% mutate(name = "cb_III", value = value / 605, mean = mean(value), med = median(value), pct = "1%")

y <- firms_extrap %>% filter(wave == 0, dplyr::between(cb_III, quantile(cb_III, pct05), quantile(cb_III, 1-pct05))) %>% select("value" = cb_III) %>% mutate(name = "cb_III", value = value / 605, mean = mean(value), med = median(value), pct = "5%")

z <- firms_extrap %>% filter(wave == 0, dplyr::between(cb_III, quantile(cb_III, pct10), quantile(cb_III, 1-pct10))) %>% select("value" = cb_III) %>% mutate(name = "cb_III", value = value / 605, mean = mean(value), med = median(value), pct = "10%")

a <- rbind(x,y,z) %>% mutate(pct = factor(pct, levels = c("1%", "5%", "10%")))

p3 <- ggplot(a, aes(x=value, y=..density.., fill = pct)) + geom_histogram(binwidth = 200, alpha=0.75) + geom_density(alpha = .3) + labs(y = "Model III", x = "") + geom_vline(aes(xintercept=mean), linetype="dashed") + geom_text(aes(0,0,label = paste0("$ ", round(mean, 0))), vjust = -3, hjust = -1, size = 3, check_overlap = T) + scale_color_manual(values=c("#999999", "#E69F00", "#56B4E9"), guide = "none") + scale_fill_manual(values=c("#999999", "#999999", "#999999"), guide = "none") + theme_minimal() + facet_wrap(~ pct, scales = "free") + theme(axis.text.y=element_blank(), axis.text.x=element_text(angle=45,hjust=1), strip.text.x = element_blank())

x <- firms_extrap %>% filter(wave == 0, dplyr::between(cb_IV, quantile(cb_IV, pct01), quantile(cb_IV, 1-pct01))) %>% select("value" = cb_IV) %>% mutate(name = "cb_IV", value = value / 605, mean = mean(value), med = median(value), pct = "1%")

y <- firms_extrap %>% filter(wave == 0, dplyr::between(cb_IV, quantile(cb_IV, pct05), quantile(cb_IV, 1-pct05))) %>% select("value" = cb_IV) %>% mutate(name = "cb_IV", value = value / 605, mean = mean(value), med = median(value), pct = "5%")

z <- firms_extrap %>% filter(wave == 0, dplyr::between(cb_IV, quantile(cb_IV, pct10), quantile(cb_IV, 1-pct10))) %>% select("value" = cb_IV) %>% mutate(name = "cb_IV", value = value / 605, mean = mean(value), med = median(value), pct = "10%")

a <- rbind(x,y,z) %>% mutate(pct = factor(pct, levels = c("1%", "5%", "10%")))

p4 <- ggplot(a, aes(x=value, y=..density.., fill = pct)) + geom_histogram(binwidth = 200, alpha=0.75) + geom_density(alpha = .3) + labs(y = "Model IV", x = "") + geom_vline(aes(xintercept=mean), linetype="dashed") + geom_text(aes(0,0,label = paste0("$ ", round(mean, 0))), vjust = -3, hjust = -1, size = 3, check_overlap = T) + scale_color_manual(values=c("#999999", "#E69F00", "#56B4E9"), guide = "none") + scale_fill_manual(values=c("#999999", "#999999", "#999999"), guide = "none") + theme_minimal() + facet_wrap(~ pct, scales = "free") + theme(axis.text.y=element_blank(), axis.text.x=element_text(angle=45,hjust=1), strip.text.x = element_blank())

x <- firms_extrap %>% filter(wave == 0, dplyr::between(cb_IV, quantile(cb_IV, pct01), quantile(cb_IV, 1-pct01))) %>% select("value" = cb_IV) %>% mutate(name = "cb_IV", value = value / 605, mean = mean(value), med = median(value), pct = "1%")

y <- firms_extrap %>% filter(wave == 0, dplyr::between(cb_IV, quantile(cb_IV, pct05), quantile(cb_IV, 1-pct05))) %>% select("value" = cb_IV) %>% mutate(name = "cb_IV", value = value / 605, mean = mean(value), med = median(value), pct = "5%")

z <- firms_extrap %>% filter(wave == 0, dplyr::between(cb_IV, quantile(cb_IV, pct10), quantile(cb_IV, 1-pct10))) %>% select("value" = cb_IV) %>% mutate(name = "cb_IV", value = value / 605, mean = mean(value), med = median(value), pct = "10%")

a <- rbind(x,y,z) %>% mutate(pct = factor(pct, levels = c("1%", "5%", "10%")))

p5 <- ggplot(a, aes(x=value, y=..density.., fill = pct)) + geom_histogram(binwidth = 250, alpha=0.75) + geom_density(alpha = .3) + labs(y = "Model V", x = "") + geom_vline(aes(xintercept=mean), linetype="dashed") + geom_text(aes(0,0,label = paste0("$ ", round(mean, 0))), vjust = -3, hjust = -1, size = 3, check_overlap = T) + scale_color_manual(values=c("#999999", "#E69F00", "#56B4E9"), guide = "none") + scale_fill_manual(values=c("#999999", "#999999", "#999999"), guide = "none") + theme_minimal() + facet_wrap(~ pct, scales = "free") + theme(axis.text.y=element_blank(), axis.text.x=element_text(angle=45,hjust=1), strip.text.x = element_blank())

grid.arrange(p1, p2, p3, p4, p5, nrow = 5, top = textGrob("Percentile",gp=gpar(fontsize=12)), bottom = textGrob("Firm benefits calculated as mean net benefits of all observed apprentices in firm times reported number of \napprentices trained. Estimated using baseline data. Density shown on y-axis. Labelled dotted line indicates \nmean of truncated distribution.", gp=gpar(fontsize=9), x = .05, just = "left"))
