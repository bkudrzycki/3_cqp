
```{r hist, fig.height=3, fig.cap = "Annual net benefits per apprentice (in USD), truncated at varying percentiles", results = 'asis', fig.pos='H'}
pct = .01
x <- df %>% filter(wave == 0, between(cb_II, quantile(cb_II, pct), quantile(cb_II, 1-pct))) %>% select("value" = cb_II) %>% mutate(name = "cb_II", value = value / 605, mean = mean(value), pct = "1%")
y <- df %>% filter(wave == 0, between(cb_V, quantile(cb_V, pct), quantile(cb_V, 1-pct))) %>% select("value" = cb_V) %>% mutate(name = "cb_V", value = value / 605, mean = mean(value), pct = "1%")

pct = .05
x1 <- df %>% filter(wave == 0, between(cb_II, quantile(cb_II, pct), quantile(cb_II, 1-pct))) %>% select("value" = cb_II) %>% mutate(name = "cb_II", value = value / 605, mean = mean(value), pct = "5%")
y1 <- df %>% filter(wave == 0, between(cb_V, quantile(cb_V, pct), quantile(cb_V, 1-pct))) %>% select("value" = cb_V) %>% mutate(name = "cb_V", value = value / 605, mean = mean(value), pct = "5%")

pct = .1
x2 <- df %>% filter(wave == 0, between(cb_II, quantile(cb_II, pct), quantile(cb_II, 1-pct))) %>% select("value" = cb_II) %>% mutate(name = "cb_II", value = value / 605, mean = mean(value), pct = "10%")
y2 <- df %>% filter(wave == 0, between(cb_V, quantile(cb_V, pct), quantile(cb_V, 1-pct))) %>% select("value" = cb_V) %>% mutate(name = "cb_V", value = value / 605, mean = mean(value), pct = "10%")

z <- rbind(x,y,x1,y1,x2,y2) %>% mutate(pct=fct_relevel(pct,c("1%", "5%", "10%")))

ggplot(z, aes(x=value, y=..density.., fill = name)) + geom_histogram(binwidth = 25, alpha=0.75) + geom_density(alpha = .75) + labs(y = "Density", x = "") + geom_vline(aes(xintercept=mean, color=name), linetype="dashed")+ scale_color_manual(values=c("#999999", "#E69F00", "#56B4E9"), guide = "none") + scale_fill_manual(values=c("#999999", "#E69F00", "#56B4E9"), labels = c("Model I", "Model II"), name = "") + theme_minimal() + theme(legend.position = "bottom") + facet_wrap(~ pct, scales = "free") + theme(axis.text.x=element_text(angle=45,hjust=1))
```

```{r hist2, fig.height=3, fig.cap = "Annual net benefits per firm (in USD), truncated at varying percentiles", results = 'asis', fig.pos='H'}
pct = .01
x <- df1 %>% filter(wave == 0, between(cb_II, quantile(cb_II, pct), quantile(cb_II, 1-pct))) %>% select("value" = cb_II) %>% mutate(name = "cb_II", value = value / 605, mean = mean(value), pct = "1%")
y <- df1 %>% filter(wave == 0, between(cb_V, quantile(cb_V, pct), quantile(cb_V, 1-pct))) %>% select("value" = cb_V) %>% mutate(name = "cb_V", value = value / 605, mean = mean(value), pct = "1%")

pct = .05
x1 <- df1 %>% filter(wave == 0, between(cb_II, quantile(cb_II, pct), quantile(cb_II, 1-pct))) %>% select("value" = cb_II) %>% mutate(name = "cb_II", value = value / 605, mean = mean(value), pct = "5%")
y1 <- df1 %>% filter(wave == 0, between(cb_V, quantile(cb_V, pct), quantile(cb_V, 1-pct))) %>% select("value" = cb_V) %>% mutate(name = "cb_V", value = value / 605, mean = mean(value), pct = "5%")

pct = .1
x2 <- df1 %>% filter(wave == 0, between(cb_II, quantile(cb_II, pct), quantile(cb_II, 1-pct))) %>% select("value" = cb_II) %>% mutate(name = "cb_II", value = value / 605, mean = mean(value), pct = "10%")
y2 <- df1 %>% filter(wave == 0, between(cb_V, quantile(cb_V, pct), quantile(cb_V, 1-pct))) %>% select("value" = cb_V) %>% mutate(name = "cb_V", value = value / 605, mean = mean(value), pct = "10%")

z <- rbind(x,y,x1,y1,x2,y2) %>% mutate(pct=fct_relevel(pct,c("1%", "5%", "10%")))

ggplot(z, aes(x=value, y=..density.., fill = name)) + geom_histogram(binwidth = 100, alpha=0.75) + geom_density(alpha = .75) + labs(y = "Density", x = "") + geom_vline(aes(xintercept=mean, color=name), linetype="dashed")+ scale_color_manual(values=c("#999999", "#E69F00", "#56B4E9"), guide = "none") + scale_fill_manual(values=c("#999999", "#E69F00", "#56B4E9"), labels = c("Model I", "Model II"), name = "") + theme_minimal() + theme(legend.position = "bottom") + facet_wrap(~ pct, scales = "free") + theme(axis.text.x=element_text(angle=45,hjust=1))
```