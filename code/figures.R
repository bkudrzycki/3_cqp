## ---- fig-enrollment --------

x <- read_csv("../data/API_SE.SEC.ENRR_DS2_en_csv_v2_4029558.csv", show_col_types = FALSE) %>% as.data.frame() %>% mutate(Indicator = "Enrolment ratio")

y <- read_csv("../data/EIP_2EET_SEX_RT_A-filtered-2022-05-20.csv", show_col_types = FALSE) %>% as.data.frame() %>% select(Country = "ref_area.label", value = "obs_value", Year = time) %>% mutate(Indicator = "% of youth not in\n employment,\n education, or \n training (NEET)")

z = rbind(x, y)

ggplot(z, aes(x=Year, y=value, color=Country, shape = Indicator)) +
  geom_line(aes(linetype = Indicator), size = .75) +
  labs(x = "",
       y = "NEET rate (%), Enrolment ratio (secondary) (%)",
       color = "Country",
       fill = "") +
  theme_minimal() + 
  scale_color_viridis_d(end = .5) +
  labs(caption = "Sources: ILOSTAT (NEET rate) and UNESCO (Enrolment ratio)")

## ---- fig-firmsize --------

x <- df %>% filter(firm_size > 1) %>% select(FS1.2, wave, firm_size, dossier_selected, FS3.4, FS6.1) %>%
  mutate(wave = factor(wave, levels = 0:1, labels = c('Baseline', 'Endline'))) %>% 
  group_by(FS1.2, wave) %>% summarise_all(mean, na.rm = T) %>% ungroup() %>% pivot_wider(names_from = wave, values_from = c(firm_size, FS3.4, FS6.1))

p1 <- ggplot(x, aes(x=firm_size_Baseline, y=..density..)) + geom_histogram(binwidth = 1, alpha=0.75) +  labs(y = "Density", x = "Firm size (calculated)") + theme_minimal() + theme(legend.position = "bottom")
p2 <- ggplot(x, aes(x=log(firm_size_Baseline), y=..density..)) + geom_histogram(binwidth = .33, alpha=0.75) +  labs(y = "Density", x = "log Firm size (calculated)") + theme_minimal() + theme(legend.position = "bottom")

p3 <- ggplot(x, aes(x=FS3.4_Baseline, y=..density..)) + geom_histogram(binwidth = 1, alpha=0.75) +  labs(y = "Density", x = "Firm size (reported)") + theme_minimal() + theme(legend.position = "bottom")
p4 <- ggplot(x, aes(x=log(FS3.4_Baseline), y=..density..)) + geom_histogram(binwidth = .33, alpha=0.75) +  labs(y = "Density", x = "log Firm size (reported)") + theme_minimal() + theme(legend.position = "bottom")

p5 <- ggplot(x, aes(x=FS6.1_Baseline, y=..density..)) + geom_histogram(binwidth = 1, alpha=0.75) +  labs(y = "Density", x = "Apprentices") + theme_minimal() + theme(legend.position = "bottom")
p6 <- ggplot(x, aes(x=log(FS6.1_Baseline), y=..density..)) + geom_histogram(binwidth = .33, alpha=0.75) +  labs(y = "Density", x = "log Apprentices") + theme_minimal() + theme(legend.position = "bottom")

grid.arrange(p1, p2, p3, p4, p5, p6, nrow = 3)

## ---- fig-costspie --------

x <- df %>% filter(wave == 0) %>% select(FS1.2, FS4.1, FS6.1, all_allowances, contains("FE5.1"), FS3.1, FS3.2, FS4.1, FS6.9, FS6.10, FS5.2_1_2, FS6.8, annual_foregone_prod) %>%
  mutate(all_allowances = all_allowances*4*5*FS4.1,
         FE5.1_1 = FE5.1_1 / FS6.1 * FS4.1,
         FE5.1_2 = FE5.1_2 / FS6.1 * FS4.1,
         FE5.1_3 = FE5.1_3 / FS6.1 * FS4.1,
         FE5.1_4 = FE5.1_4 / FS6.1 * FS4.1) %>% 
  group_by(FS1.2) %>% summarise_all(mean, na.rm = T) %>% ungroup() %>% pivot_longer(cols = c(all_allowances, contains("FE5.1"), annual_foregone_prod)) %>% select(c(name, value)) %>% group_by(name) %>% summarise_all(mean, na.rm = T) %>% ungroup() %>% mutate(value = value / 605) %>% mutate(labels = scales::dollar(value, accuracy = .1))

x$name = factor(x$name, ordered = TRUE, levels = c("all_allowances", "FE5.1_3", "FE5.1_4", "annual_foregone_prod", "FE5.1_1", "FE5.1_2"))

x <- x %>% mutate(name=fct_relevel(name,c("annual_foregone_prod","all_allowances")))

ggplot(x, aes(x="", y=value, fill=factor(name, levels = c("all_allowances", "annual_foregone_prod", "FE5.1_4", "FE5.1_3", "FE5.1_1", "FE5.1_2")))) +
  geom_bar(stat="identity", width=1, color="white") +
  coord_polar("y", start=0) + geom_label(aes(x = 1.25, label = labels), size = 3.25, color = c("white", "white", 1, 1, "white", "white"), position = position_stack(vjust = .5), show.legend = FALSE) + scale_fill_viridis_d(name = "", labels = c("Allowances", "Foregone trainer productivity", "Raw materials", "Books and training materials",  "Rent for training facilities",  "Equipment and tools"), guide = guide_legend(reverse = TRUE)) + theme_void()


## ---- fig-costspie2 --------

x <- df %>% filter(wave == 0, !is.na(FS6.1)) %>% select(wave, FS1.2, FS4.1, FS6.1, all_allowances, contains("FE5.1"), FS6.9, FS6.10, FS5.2_1_2, FS6.8, annual_foregone_prod) %>%
  mutate(all_allowances = all_allowances*4*5*FS4.1*FS6.1,
         FE5.1_1 = FE5.1_1 * FS4.1,
         FE5.1_2 = FE5.1_2 * FS4.1,
         FE5.1_3 = FE5.1_3 * FS4.1,
         FE5.1_4 = FE5.1_4 * FS4.1,
         annual_foregone_prod = annual_foregone_prod * FS6.1) %>% 
  group_by(FS1.2, wave) %>% summarise_all(mean, na.rm = T) %>% ungroup() %>% pivot_longer(cols = c(all_allowances, contains("FE5.1"), annual_foregone_prod)) %>% select(c(name, value)) %>% group_by(name) %>% summarise_all(mean, na.rm = T) %>% ungroup() %>% mutate(value = value / 605) %>% mutate(labels = scales::dollar(value, accuracy = .1))

x$name = factor(x$name, ordered = TRUE, levels = c("all_allowances", "FE5.1_3", "FE5.1_4", "annual_foregone_prod", "FE5.1_1", "FE5.1_2"))

x <- x %>% mutate(name=fct_relevel(name,c("annual_foregone_prod","all_allowances")))

ggplot(x, aes(x="", y=value, fill=factor(name, levels = c("all_allowances", "annual_foregone_prod", "FE5.1_4", "FE5.1_3", "FE5.1_1", "FE5.1_2")))) +
  geom_bar(stat="identity", width=1, color="white") +
  coord_polar("y", start=0) + geom_label(aes(x = 1.25, label = labels), size = 3.25, color = c("white", 1, 1, 1, "white", "white"), position = position_stack(vjust = .5), show.legend = FALSE) + scale_fill_viridis_d(name = "", labels = c("Allowances", "Foregone trainer productivity", "Raw materials", "Books and training materials",  "Rent for training facilities",  "Equipment and tools"), guide = guide_legend(reverse = TRUE)) + theme_void()

## ---- fig-apphist --------

pct01 = .01
pct05 = .05
pct10 = .10

x <- df %>% filter(wave == 0, dplyr::between(cb_I, quantile(cb_I, pct01, na.rm = T), quantile(cb_I, 1-pct01, na.rm = T))) %>% select("value" = cb_I) %>% mutate(name = "cb_I", value = value / 605, mean = mean(value), med = median(value), pct = "1%")

y <- df %>% filter(wave == 0, dplyr::between(cb_I, quantile(cb_I, pct05, na.rm = T), quantile(cb_I, 1-pct05, na.rm = T))) %>% select("value" = cb_I) %>% mutate(name = "cb_I", value = value / 605, mean = mean(value), med = median(value), pct = "5%")

z <- df %>% filter(wave == 0, dplyr::between(cb_I, quantile(cb_I, pct10, na.rm = T), quantile(cb_I, 1-pct10, na.rm = T))) %>% select("value" = cb_I) %>% mutate(name = "cb_I", value = value / 605, mean = mean(value), med = median(value), pct = "10%")

a <- rbind(x,y,z) %>% mutate(pct = factor(pct, levels = c("1%", "5%", "10%")))

p1 <- ggplot(a, aes(x=value, y=..density.., fill = pct)) + geom_histogram(binwidth = 20, alpha=0.75) + geom_density(alpha = .3) + labs(y = "Model I", x = "") + geom_vline(aes(xintercept=mean), linetype="dashed") + geom_text(aes(0,0,label = paste0("$ ", round(mean, 0))), vjust = -4, hjust = 2.5, size = 3, check_overlap = T) + scale_color_manual(values=c("#999999", "#E69F00", "#56B4E9"), guide = "none") + scale_fill_manual(values=c("#999999", "#999999", "#999999"), guide = "none") + theme_minimal() + facet_wrap(~ pct, scales = "free") + theme(axis.text.y=element_blank(), axis.text.x=element_text(angle=45,hjust=1), strip.text.x = element_text(size = 12))

x <- df %>% filter(wave == 0, dplyr::between(cb_II, quantile(cb_II, pct01, na.rm = T), quantile(cb_II, 1-pct01, na.rm = T))) %>% select("value" = cb_II) %>% mutate(name = "cb_II", value = value / 605, mean = mean(value), med = median(value), pct = "1%")

y <- df %>% filter(wave == 0, dplyr::between(cb_II, quantile(cb_II, pct05, na.rm = T), quantile(cb_II, 1-pct05, na.rm = T))) %>% select("value" = cb_II) %>% mutate(name = "cb_II", value = value / 605, mean = mean(value), med = median(value), pct = "5%")

z <- df %>% filter(wave == 0, dplyr::between(cb_II, quantile(cb_II, pct10, na.rm = T), quantile(cb_II, 1-pct10, na.rm = T))) %>% select("value" = cb_II) %>% mutate(name = "cb_II", value = value / 605, mean = mean(value), med = median(value), pct = "10%")

a <- rbind(x,y,z) %>% mutate(pct = factor(pct, levels = c("1%", "5%", "10%")))

p2 <- ggplot(a, aes(x=value, y=..density.., fill = pct)) + geom_histogram(binwidth = 20, alpha=0.75) + geom_density(alpha = .3) + labs(y = "Model II", x = "") + geom_vline(aes(xintercept=mean), linetype="dashed") + geom_text(aes(0,0,label = paste0("$ ", round(mean, 0))), vjust = -4, hjust = 3, size = 3, check_overlap = T) + scale_color_manual(values=c("#999999", "#E69F00", "#56B4E9"), guide = "none") + scale_fill_manual(values=c("#999999", "#999999", "#999999"), guide = "none") + theme_minimal() + facet_wrap(~ pct, scales = "free") + theme(axis.text.y=element_blank(), axis.text.x=element_text(angle=45,hjust=1), strip.text.x = element_blank())

x <- df %>% filter(wave == 0, dplyr::between(cb_III, quantile(cb_III, pct01, na.rm = T), quantile(cb_III, 1-pct01, na.rm = T))) %>% select("value" = cb_III) %>% mutate(name = "cb_III", value = value / 605, mean = mean(value), med = median(value), pct = "1%")

y <- df %>% filter(wave == 0, dplyr::between(cb_III, quantile(cb_III, pct05, na.rm = T), quantile(cb_III, 1-pct05, na.rm = T))) %>% select("value" = cb_III) %>% mutate(name = "cb_III", value = value / 605, mean = mean(value), med = median(value), pct = "5%")

z <- df %>% filter(wave == 0, dplyr::between(cb_III, quantile(cb_III, pct10, na.rm = T), quantile(cb_III, 1-pct10, na.rm = T))) %>% select("value" = cb_III) %>% mutate(name = "cb_III", value = value / 605, mean = mean(value), med = median(value), pct = "10%")

a <- rbind(x,y,z) %>% mutate(pct = factor(pct, levels = c("1%", "5%", "10%")))

p3 <- ggplot(a, aes(x=value, y=..density.., fill = pct)) + geom_histogram(binwidth = 60, alpha=0.75) + geom_density(alpha = .3) + labs(y = "Model III", x = "") + geom_vline(aes(xintercept=mean), linetype="dashed") + geom_text(aes(0,0,label = paste0("$ ", round(mean, 0))), vjust = -5, hjust = -2, size = 3, check_overlap = T) + scale_color_manual(values=c("#999999", "#E69F00", "#56B4E9"), guide = "none") + scale_fill_manual(values=c("#999999", "#999999", "#999999"), guide = "none") + theme_minimal() + facet_wrap(~ pct, scales = "free") + theme(axis.text.y=element_blank(), axis.text.x=element_text(angle=45,hjust=1), strip.text.x = element_blank())

x <- df %>% filter(wave == 0, dplyr::between(cb_IV, quantile(cb_IV, pct01, na.rm = T), quantile(cb_IV, 1-pct01, na.rm = T))) %>% select("value" = cb_IV) %>% mutate(name = "cb_IV", value = value / 605, mean = mean(value), med = median(value), pct = "1%")

y <- df %>% filter(wave == 0, dplyr::between(cb_IV, quantile(cb_IV, pct05, na.rm = T), quantile(cb_IV, 1-pct05, na.rm = T))) %>% select("value" = cb_IV) %>% mutate(name = "cb_IV", value = value / 605, mean = mean(value), med = median(value), pct = "5%")

z <- df %>% filter(wave == 0, dplyr::between(cb_IV, quantile(cb_IV, pct10, na.rm = T), quantile(cb_IV, 1-pct10, na.rm = T))) %>% select("value" = cb_IV) %>% mutate(name = "cb_IV", value = value / 605, mean = mean(value), med = median(value), pct = "10%")

a <- rbind(x,y,z) %>% mutate(pct = factor(pct, levels = c("1%", "5%", "10%")))

p4 <- ggplot(a, aes(x=value, y=..density.., fill = pct)) + geom_histogram(binwidth = 60, alpha=0.75) + geom_density(alpha = .3) + labs(y = "Model IV", x = "") + geom_vline(aes(xintercept=mean), linetype="dashed") + geom_text(aes(0,0,label = paste0("$ ", round(mean, 0))), vjust = -6, hjust = -2, size = 3, check_overlap = T) + scale_color_manual(values=c("#999999", "#E69F00", "#56B4E9"), guide = "none") + scale_fill_manual(values=c("#999999", "#999999", "#999999"), guide = "none") + theme_minimal() + facet_wrap(~ pct, scales = "free") + theme(axis.text.y=element_blank(), axis.text.x=element_text(angle=45,hjust=1), strip.text.x = element_blank())

x <- df %>% filter(wave == 0, dplyr::between(cb_V, quantile(cb_V, pct01, na.rm = T), quantile(cb_V, 1-pct01, na.rm = T))) %>% select("value" = cb_V) %>% mutate(name = "cb_V", value = value / 605, mean = mean(value), med = median(value), pct = "1%")

y <- df %>% filter(wave == 0, dplyr::between(cb_V, quantile(cb_V, pct05, na.rm = T), quantile(cb_V, 1-pct05, na.rm = T))) %>% select("value" = cb_V) %>% mutate(name = "cb_V", value = value / 605, mean = mean(value), med = median(value), pct = "5%")

z <- df %>% filter(wave == 0, dplyr::between(cb_V, quantile(cb_V, pct10, na.rm = T), quantile(cb_V, 1-pct10, na.rm = T))) %>% select("value" = cb_V) %>% mutate(name = "cb_V", value = value / 605, mean = mean(value), med = median(value), pct = "10%")

a <- rbind(x,y,z) %>% mutate(pct = factor(pct, levels = c("1%", "5%", "10%")))

p5 <- ggplot(a, aes(x=value, y=..density.., fill = pct)) + geom_histogram(binwidth = 60, alpha=0.75) + geom_density(alpha = .3) + labs(y = "Model V", x = "") + geom_vline(aes(xintercept=mean), linetype="dashed") + geom_text(aes(0,0,label = paste0("$ ", round(mean, 0))), vjust = -6, hjust = -2, size = 3, check_overlap = T) + scale_color_manual(values=c("#999999", "#E69F00", "#56B4E9"), guide = "none") + scale_fill_manual(values=c("#999999", "#999999", "#999999"), guide = "none") + theme_minimal() + facet_wrap(~ pct, scales = "free_x") + theme(axis.text.y=element_blank(), axis.text.x=element_text(angle=45,hjust=1), strip.text.x = element_blank())

grid.arrange(p1, p2, p3, p4, p5, nrow = 5, top = textGrob("Percentile",gp=gpar(fontsize=12)), bottom = textGrob("Net benefits estimated using baseline data and truncated at first, fifth and tenth percentiles. Density on y-axis. \nLabelled dotted line indicates mean of truncated distribution.", gp=gpar(fontsize=9), x = .05, just = "left"))


## ---- fig-firmhist --------
firms_extrap <- firms %>% mutate(cb_I = FS6.1 * cb_I,
                                 cb_II = FS6.1 * cb_II,
                                 cb_III = FS6.1 * cb_III,
                                 cb_IV = FS6.1 * cb_IV,
                                 cb_V = FS6.1 * cb_V)

pct01 = .01
pct05 = .05
pct10 = .10

x <- firms_extrap %>% filter(wave == 0, dplyr::between(cb_I, quantile(cb_I, pct01, na.rm = T), quantile(cb_I, 1-pct01, na.rm = T))) %>% select("value" = cb_I) %>% mutate(name = "cb_I", value = value / 605, mean = mean(value), med = median(value), pct = "1%")

y <- firms_extrap %>% filter(wave == 0, dplyr::between(cb_I, quantile(cb_I, pct05, na.rm = T), quantile(cb_I, 1-pct05, na.rm = T))) %>% select("value" = cb_I) %>% mutate(name = "cb_I", value = value / 605, mean = mean(value), med = median(value), pct = "5%")

z <- firms_extrap %>% filter(wave == 0, dplyr::between(cb_I, quantile(cb_I, pct10, na.rm = T), quantile(cb_I, 1-pct10, na.rm = T))) %>% select("value" = cb_I) %>% mutate(name = "cb_I", value = value / 605, mean = mean(value), med = median(value), pct = "10%")

a <- rbind(x,y,z) %>% mutate(pct = factor(pct, levels = c("1%", "5%", "10%")))
                                               
p1 <- ggplot(a, aes(x=value, y=..density.., fill = pct)) + geom_histogram(binwidth = 100, alpha=0.75) + geom_density(alpha = .3) + labs(y = "Model I", x = "") + geom_vline(aes(xintercept=mean), linetype="dashed") + geom_text(aes(0,0,label = paste0("$ ", round(mean, 0))), vjust = -3, hjust = 2, size = 3, check_overlap = T) + scale_color_manual(values=c("#999999", "#E69F00", "#56B4E9"), guide = "none") + scale_fill_manual(values=c("#999999", "#999999", "#999999"), guide = "none") + theme_minimal() + facet_wrap(~ pct, scales = "free") + theme(axis.text.y=element_blank(), axis.text.x=element_text(angle=45,hjust=1), strip.text.x = element_text(size = 12))

x <- firms_extrap %>% filter(wave == 0, dplyr::between(cb_II, quantile(cb_II, pct01, na.rm = T), quantile(cb_II, 1-pct01, na.rm = T))) %>% select("value" = cb_II) %>% mutate(name = "cb_II", value = value / 605, mean = mean(value), med = median(value), pct = "1%")

y <- firms_extrap %>% filter(wave == 0, dplyr::between(cb_II, quantile(cb_II, pct05, na.rm = T), quantile(cb_II, 1-pct05, na.rm = T))) %>% select("value" = cb_II) %>% mutate(name = "cb_II", value = value / 605, mean = mean(value), med = median(value), pct = "5%")

z <- firms_extrap %>% filter(wave == 0, dplyr::between(cb_II, quantile(cb_II, pct10, na.rm = T), quantile(cb_II, 1-pct10, na.rm = T))) %>% select("value" = cb_II) %>% mutate(name = "cb_II", value = value / 605, mean = mean(value), med = median(value), pct = "10%")

a <- rbind(x,y,z) %>% mutate(pct = factor(pct, levels = c("1%", "5%", "10%")))

p2 <- ggplot(a, aes(x=value, y=..density.., fill = pct)) + geom_histogram(binwidth = 100, alpha=0.75) + geom_density(alpha = .3) + labs(y = "Model II", x = "") + geom_vline(aes(xintercept=mean), linetype="dashed") + geom_text(aes(0,0,label = paste0("$ ", round(mean, 0))), vjust = -5, hjust = 2, size = 3, check_overlap = T) + scale_color_manual(values=c("#999999", "#E69F00", "#56B4E9"), guide = "none") + scale_fill_manual(values=c("#999999", "#999999", "#999999"), guide = "none") + theme_minimal() + facet_wrap(~ pct, scales = "free") + theme(axis.text.y=element_blank(), axis.text.x=element_text(angle=45,hjust=1), strip.text.x = element_blank())

x <- firms_extrap %>% filter(wave == 0, dplyr::between(cb_III, quantile(cb_III, pct01, na.rm = T), quantile(cb_III, 1-pct01, na.rm = T))) %>% select("value" = cb_III) %>% mutate(name = "cb_III", value = value / 605, mean = mean(value), med = median(value), pct = "1%")

y <- firms_extrap %>% filter(wave == 0, dplyr::between(cb_III, quantile(cb_III, pct05, na.rm = T), quantile(cb_III, 1-pct05, na.rm = T))) %>% select("value" = cb_III) %>% mutate(name = "cb_III", value = value / 605, mean = mean(value), med = median(value), pct = "5%")

z <- firms_extrap %>% filter(wave == 0, dplyr::between(cb_III, quantile(cb_III, pct10, na.rm = T), quantile(cb_III, 1-pct10, na.rm = T))) %>% select("value" = cb_III) %>% mutate(name = "cb_III", value = value / 605, mean = mean(value), med = median(value), pct = "10%")

a <- rbind(x,y,z) %>% mutate(pct = factor(pct, levels = c("1%", "5%", "10%")))

p3 <- ggplot(a, aes(x=value, y=..density.., fill = pct)) + geom_histogram(binwidth = 300, alpha=0.75) + geom_density(alpha = .3) + labs(y = "Model III", x = "") + geom_vline(aes(xintercept=mean), linetype="dashed") + geom_text(aes(0,0,label = paste0("$ ", round(mean, 0))), vjust = -4, hjust = -1, size = 3, check_overlap = T) + scale_color_manual(values=c("#999999", "#E69F00", "#56B4E9"), guide = "none") + scale_fill_manual(values=c("#999999", "#999999", "#999999"), guide = "none") + theme_minimal() + facet_wrap(~ pct, scales = "free") + theme(axis.text.y=element_blank(), axis.text.x=element_text(angle=45,hjust=1), strip.text.x = element_blank())

x <- firms_extrap %>% filter(wave == 0, dplyr::between(cb_IV, quantile(cb_IV, pct01, na.rm = T), quantile(cb_IV, 1-pct01, na.rm = T))) %>% select("value" = cb_IV) %>% mutate(name = "cb_IV", value = value / 605, mean = mean(value), med = median(value), pct = "1%")

y <- firms_extrap %>% filter(wave == 0, dplyr::between(cb_IV, quantile(cb_IV, pct05, na.rm = T), quantile(cb_IV, 1-pct05, na.rm = T))) %>% select("value" = cb_IV) %>% mutate(name = "cb_IV", value = value / 605, mean = mean(value), med = median(value), pct = "5%")

z <- firms_extrap %>% filter(wave == 0, dplyr::between(cb_IV, quantile(cb_IV, pct10, na.rm = T), quantile(cb_IV, 1-pct10, na.rm = T))) %>% select("value" = cb_IV) %>% mutate(name = "cb_IV", value = value / 605, mean = mean(value), med = median(value), pct = "10%")

a <- rbind(x,y,z) %>% mutate(pct = factor(pct, levels = c("1%", "5%", "10%")))

p4 <- ggplot(a, aes(x=value, y=..density.., fill = pct)) + geom_histogram(binwidth = 300, alpha=0.75) + geom_density(alpha = .3) + labs(y = "Model IV", x = "") + geom_vline(aes(xintercept=mean), linetype="dashed") + geom_text(aes(0,0,label = paste0("$ ", round(mean, 0))), vjust = -4, hjust = -1, size = 3, check_overlap = T) + scale_color_manual(values=c("#999999", "#E69F00", "#56B4E9"), guide = "none") + scale_fill_manual(values=c("#999999", "#999999", "#999999"), guide = "none") + theme_minimal() + facet_wrap(~ pct, scales = "free") + theme(axis.text.y=element_blank(), axis.text.x=element_text(angle=45,hjust=1), strip.text.x = element_blank())

x <- firms_extrap %>% filter(wave == 0, dplyr::between(cb_V, quantile(cb_V, pct01, na.rm = T), quantile(cb_V, 1-pct01, na.rm = T))) %>% select("value" = cb_V) %>% mutate(name = "cb_V", value = value / 605, mean = mean(value), med = median(value), pct = "1%")

y <- firms_extrap %>% filter(wave == 0, dplyr::between(cb_V, quantile(cb_V, pct05, na.rm = T), quantile(cb_V, 1-pct05, na.rm = T))) %>% select("value" = cb_V) %>% mutate(name = "cb_V", value = value / 605, mean = mean(value), med = median(value), pct = "5%")

z <- firms_extrap %>% filter(wave == 0, dplyr::between(cb_V, quantile(cb_V, pct10, na.rm = T), quantile(cb_V, 1-pct10, na.rm = T))) %>% select("value" = cb_V) %>% mutate(name = "cb_V", value = value / 605, mean = mean(value), med = median(value), pct = "10%")

a <- rbind(x,y,z) %>% mutate(pct = factor(pct, levels = c("1%", "5%", "10%")))

p5 <- ggplot(a, aes(x=value, y=..density.., fill = pct)) + geom_histogram(binwidth = 300, alpha=0.75) + geom_density(alpha = .3) + labs(y = "Model V", x = "") + geom_vline(aes(xintercept=mean), linetype="dashed") + geom_text(aes(0,0,label = paste0("$ ", round(mean, 0))), vjust = -4, hjust = -1, size = 3, check_overlap = T) + scale_color_manual(values=c("#999999", "#E69F00", "#56B4E9"), guide = "none") + scale_fill_manual(values=c("#999999", "#999999", "#999999"), guide = "none") + theme_minimal() + facet_wrap(~ pct, scales = "free_x") + theme(axis.text.y=element_blank(), axis.text.x=element_text(angle=45,hjust=1), strip.text.x = element_blank())

grid.arrange(p1, p2, p3, p4, p5, nrow = 5, top = textGrob("Percentile",gp=gpar(fontsize=12)), bottom = textGrob("Net benefits estimated using baseline data and truncated at first, fifth and tenth percentiles. Firm benefits \ncalculated as mean net benefits of all observed apprentices in firm times reported number of apprentices \ntrained. Density on y-axis. Labelled dotted line indicates mean of truncated distribution.", gp=gpar(fontsize=9), x = .05, just = "left"))
