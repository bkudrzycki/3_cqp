#for joining selected variables that appear for both CQP and non-CQP apprentices
JoinCQP <- function(vars) {
  joined_cqps <- rbind(base_cqps %>% select(c({{vars}}, "IDYouth", "wave")), end_cqps %>% select(c({{vars}}, "IDYouth", "wave"))) %>% drop_na('IDYouth')
  return(joined_cqps)
}

JoinTrad <- function(vars) {
  joined_trad <- rbind(base_trad %>% select(c({{vars}}, "IDYouth", "wave")), end_trad %>% select(c({{vars}}, "IDYouth", "wave"))) %>% drop_na('IDYouth')
  return(joined_trad)
}

JoinCQPMatch <- function(vars) {
  joined_cqps <- rbind(base_cqps %>% select(tidyselect::vars_select(names(base_cqps), matches(c({{vars}}))), "IDYouth", "wave"), end_cqps %>% select(tidyselect::vars_select(names(end_cqps), matches(c({{vars}}))), "IDYouth", "wave")) %>% drop_na('IDYouth')
  return(joined_cqps)
}

JoinTradMatch <- function(vars) {
  joined_trad <- rbind(base_trad %>% select(tidyselect::vars_select(names(base_trad), matches(c({{vars}}))), "IDYouth", "wave"), end_trad %>% select(tidyselect::vars_select(names(end_trad), matches(c({{vars}}))), "IDYouth", "wave")) %>% drop_na('IDYouth')
  return(joined_trad)
}
