# Load packages ----
library(shiny)
library(tidyverse)
library(ggmosaic)
source("Variables_Shiny.R")



# User interface ----
ui <- fluidPage (
  titlePanel("Diabetes association with demographic, physical and behavioural variables"),
  sidebarLayout(
    sidebarPanel(
      helpText("Create plots"),
      
      selectInput("Mosaic", 
                  label = "Choose a variable for the histogram plot",
                  choices = c("Education_level","Income","employment_status","smoked_at_least_100_cigaretes"),
                  selected = "Education_level"),
      
      selectInput("Boxplot", 
                  label = "Choose a variable for the boxplot",
                  choices = c("BMI","drinks_per_month","days_at_least_one_drink_last_month"),
                  selected = "BMI"),
      br(),
      br(),
      br()
      
      
    ),
  
    mainPanel(br(),
              br(),
      plotOutput("Plot1"),
      br(),
      plotOutput("Plot2"))
  )
)


server <- function(input, output){
  
  output$Plot1 <- renderPlot({
    
    ggplot(data=brfss_diabetes_predict) + 
      geom_mosaic(aes(x = product(diabetes,!!sym(input$Mosaic)), fill=!!sym(input$Mosaic))) +   
      theme_classic()+
      labs(title = paste0("Diabestes and ", input$Mosaic))+
      theme(plot.title = element_text(hjust = 0.5))+
      theme(axis.title.x=element_blank(),
            axis.text.x=element_blank(),
            axis.ticks.x=element_blank())
  
       })
    
    
  output$Plot2 <- renderPlot({   
    
  ggplot(data=brfss_diabetes_predict, aes(x=diabetes,y=log(get(input$Boxplot))))+
    theme_classic()+
    geom_boxplot(aes(fill=diabetes))+
    xlab("Diabetic")+
    labs(fill = "Diabetic")+
    theme(plot.title = element_text(hjust = 0.5))
})
    

  
}

shinyApp(ui, server)

