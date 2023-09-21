#Read the data
load("brfss2013.RData")
# Select variables to visualize
brfss_diabetes_predict<-brfss2013 |> 
  select(diabete3, X_bmi5, income2, sleptim1, sex, educa, employ1,smoke100, alcday5, fruit1)|>
  na.omit()|>
  filter(sleptim1<=24) |>
  mutate(diabetes =as.factor(
           case_when(grepl("No", diabete3) ~ "Yes",
                     TRUE ~ "No")))|>
  mutate(fruit_per_month = 
           case_when (fruit1 == 0 ~ 0, 
                      fruit1 <  200 ~ (fruit1-100)*30/7,
                      fruit1 < 300 ~ fruit1-200,
                      TRUE ~ 0))|>
  mutate(drinks_per_month = 
           case_when (fruit1 == 0 ~ 0, 
                      fruit1 <  200 ~ (fruit1-100)*30/7,
                      fruit1 < 300 ~ fruit1-200,
                      TRUE ~ 0))|>
  mutate(days_at_least_one_drink_last_month = 
           case_when (alcday5 == 0 ~ 0, 
                      alcday5 <  200 ~ (fruit1-100)*30/7,
                      TRUE ~ fruit1-200))|>
  mutate(sleep = as.factor(ifelse(sleptim1 < 6, "<6", ifelse(sleptim1 <=10,"7-10",">10"))))|>
  rename("BMI" = "X_bmi5")|>
  rename("Income" = "income2") |>
  rename("Education_level" = "educa") |>
  rename("Employment_status"= "employ1") |>
  rename("Smoking"= "smoke100") |>
  rename("Sex" = "sex")|>
  select(!c(diabete3, sleptim1, alcday5, fruit1))
