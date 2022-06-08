# function codes 1 if answer is correct for each skills question
code_answers <- function(data, question, correct_answer) {
  df <- data %>% 
    mutate(x = ifelse({{question}} == correct_answer, 1, 0)) %>% 
    rename("correct_{{question}}" := "x")
  return(df)
}