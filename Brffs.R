# Load libraries and data -------------------------------------------------
library(tidyverse)
library(ggmosaic)
library(gbm)

load("brfss2013.RData")

# Plot of Internet access against income ----------------------------

brfss_internet<-brfss2013 |> 
  select(income2, internet)|>
  filter(!is.na(income2)) |>  
  filter(!is.na(internet)) |>  
  mutate(Income= case_when(
    income2=="Less than $10,000" ~ "<10",
    income2=="Less than $15,000" ~ "<15",
    income2== "Less than $20,000"~ "<20",
    income2=="Less than $25,000"~ "<25",    
    income2== "Less than $35,000" ~ "<35",
    income2=="Less than $50,000"~ "<50",
    income2== "Less than $75,000" ~ "<75",
    TRUE ~">75"))|> 
    mutate(Income = factor(Income, 
      levels = c("<10", "<15", "<20", "<25", "<35", "<50","<75",">75")))

ggsave(filename="Income_and_Internet_usage.png",
  ggplot(data= brfss_internet) +
  geom_mosaic(aes(x = product(internet,Income), fill = internet))+
  theme_classic()+
  labs(title="Income and Internet usage", x="Income (in k$)",
       y = "Internet use during last month")+
  theme(plot.title = element_text(hjust = 0.5)),
  width = 7, height = 4, dpi = 300, units = "in", device='png')


#Create table of internet access against income ---------------------------------

internet_access_vs_income<-brfss2013 |>  
  filter(!is.na(income2)) |>
  filter(!is.na(internet)) |> 
  group_by(income2,internet) |>
  summarise(n = n())|>
  rename("income" = "income2") |>
  rename("internet_access" = "internet") |>
  mutate(frequency = n / sum(n)) |>
  mutate (sample_size= sum(n))|>
  filter(internet_access=="Yes")|>
  select(!n)                
write.csv(internet_access_vs_income, "internet_access_vs_income.csv")

# Plot of sleep and mental health -------------------------------------------------

brfss2013_sleep<-brfss2013 |>
  select(sleptim1,menthlth)|>
  filter(!is.na(sleptim1)) |> 
  filter(sleptim1<=24) |> 
  filter(!is.na(menthlth)) |>  
  filter(menthlth<=30) |> 
  mutate(sleep = ifelse(sleptim1 < 6, "<6", ifelse(sleptim1 <=10,"7-10",">10")))|> 
  mutate(mental_health=ifelse(menthlth==0,"None","At least 1")) |> 
  mutate(sleep = factor(sleep, levels = c("<6", "7-10", ">10"))) |>
  mutate(mental_health = factor(mental_health, levels = c("None","At least 1")))

ggsave(filename="Sleep_and_mental_health.png",
  ggplot(data= brfss2013_sleep) + 
  geom_mosaic(aes(x = product(mental_health, sleep), fill = mental_health)) +   
    theme_classic()+
  labs(y="Monthly days mental health not good", x="Daily sleep hours",
       title = "Sleep time and mental health",fill="Mental health")+
  theme(plot.title = element_text(hjust = 0.5)),
  width = 6, height = 4, dpi = 300, units = "in", device='png')


#Create table of sleep and mental health -------------------------------------------------

sleep_and_mental_health <-brfss2013_sleep |>
  group_by(sleep, mental_health) |>
  summarise(n = n()) |>
  mutate(frequency = n / sum(n)) |>
  filter(mental_health=="At least 1") |>
  mutate (sample_size= sum(n)) |>
  rename("Daily_hours_sleeping" ="sleep")|>
  rename("Days_bad_mental_health_for_month" ="mental_health") |>
  select(!n)
                                                              
write.csv(sleep_and_mental_health, "sleep_and_mental_health.csv")

# Plot of Diabetes and Body max index ---------------------------------------------

brfss_diabetes<-brfss2013 |> 
  select(diabete3, X_bmi5)|>
  filter(!is.na(diabete3)) |> 
  filter(!is.na(X_bmi5)) |> 
  mutate(diabetes =
    case_when(grepl("No", diabete3) ~ "No",
            TRUE ~ "Yes")
  )|>
  select(!diabete3)|>
  rename("BMI"="X_bmi5")


ggsave(filename="Diabetes_and_BMI.png",  
  ggplot(data=brfss_diabetes,aes(diabetes, BMI))+
  theme_classic()+
  geom_boxplot(aes(fill=diabetes))+
  xlab("Diabetic")+
  labs(fill = "Diabetic")+
  theme(plot.title = element_text(hjust = 0.5)),
  width = 6, height = 4, dpi = 300, units = "in", device='png')
  

# Predict Diabetes-----------------------------------------------------------

# Select variables from the dataset for prediction and perform data wrangling
brfss_diabetes_predict<-brfss2013 |> 
  select(diabete3, X_bmi5, income2, sleptim1, sex, educa, employ1,smoke100, alcday5, fruit1)|>
  na.omit()|>
  filter(sleptim1<=24) |>
  mutate(diabetes =
      case_when(grepl("No", diabete3) ~ 1,
                     TRUE ~ 0))|>
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
    rename("employment_status"= "employ1") |>
    rename("smoked_at_least_100_cigaretes"= "smoke100") |>
    select(!c(diabete3, sleptim1, alcday5, fruit1))


#Split the dataset in train and test datasets  
  train <- sample ( c ( TRUE , FALSE ) , nrow (brfss_diabetes_predict) ,
                    replace = TRUE )
Diabetes_predict_test <- brfss_diabetes_predict$diabetes[!train]
Diabetes_test<-brfss_diabetes_predict[!train,]


#Perform boosting on the train dataset
boost.diabetes<- gbm ( diabetes ~. , data = brfss_diabetes_predict [ train , ] ,
                    distribution = "bernoulli" , n.trees = 1000 ,
                    interaction.depth = 1, shrinkage = 0.01)



#Predict the diabetes status on the test dataset based on the model fitted on the train dataset
yhat.boost <- predict ( boost.diabetes ,
                        newdata = brfss_diabetes_predict [!train , ] , n.trees = 1000, 
                        type="response")
yhat.boost2<-ifelse(yhat.boost > 0.5,1,0)



#Create a dataframe to plot the confusion matrix
confusion_matrix<-table (yhat.boost2 , Diabetes_predict_test)
Predictions <- factor(c("Yes", "Yes", "No", "No"))
Reference <- factor(c("Yes", "No", "Yes", "No"))
Y      <- c(confusion_matrix[1,1], confusion_matrix[1,2], confusion_matrix[2,1], confusion_matrix[2,2])
df <- data.frame(Predictions , Reference, Y)


#Calculate specificity and sensitivity
Sensitivity= confusion_matrix[1,1]/(confusion_matrix[1,1]+confusion_matrix[1,2])
Specificity = confusion_matrix[2,2]/(confusion_matrix[2,2]+confusion_matrix[2,1])


#Plot the confusion matrix
ggsave(filename="Confusion matrix.png", 
  ggplot(data =  df, mapping = aes(x = Predictions, y = Reference)) +
  geom_tile(aes(fill = Y), colour = "white") +
  geom_text(aes(label = sprintf("%1.0f", Y),fontface="bold", size=4), vjust = 1) +
  theme_bw() + theme(legend.position = "none")+
  labs(title="Predicted vs observed diabetes cases in the test dataset",
       subtitle=paste0("Sensitivity = ", round(Sensitivity,2), "   Specificity = ", round(Specificity,2)))+
  scale_fill_gradient(low = "blue",
                        high = "red",
                        trans = "log")+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(plot.subtitle = element_text(hjust = 0.5)),
  width = 6, height = 6, dpi = 300, units = "in", device='png')
  
  
##

