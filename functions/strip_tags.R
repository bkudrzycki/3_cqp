# function that subsets data for one apprentice at a time
strip_tags <- function(idvar, prefix, data) {
  df <- data %>% select(tidyselect::vars_select(names(data), matches(c('FS1.2', 'FS1.6', 'FS1.9', 'wave', {{idvar}}, {{prefix}})), -matches('TEXT'))) %>% 
    mutate_all(function(x) as.numeric(as.character(x)))
  return(df)
}