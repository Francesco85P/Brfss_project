# Load packages ----
library(shiny)
library(tidyverse)
library(ggmosaic)
source("Variables_Shiny.R")



# User interface ----
ui <- fluidPage (
  titlePanel(h2("Diabetes association with demographic, physical and behavioural variables",
             align = "center")),

  sidebarLayout(
    sidebarPanel(width=12,
      helpText("Create plots"),
      
      selectInput("Plot", 
                  label = "Choose a variable for the  plot",
                  choices = c("Education level" = "Education_level",
                              "Sex", 
                              "Income", 
                              "Employment status" = "Employment_status",
                              "Smoking",
                              "BMI"),
                  selected = "Education_level"),
      
    ),
  
    mainPanel(width=12,
      plotOutput("Plot1", 
                 )
  )
),

)
server <- function(input, output){
  
  
  output$Plot1 <- renderPlot({
    if (input$Plot %in% c ("Education_level","Income","Employment_status", "Sex",
      "Smoking")){
        ggplot(data=brfss_diabetes_predict) + 
        geom_mosaic(aes(x = product(diabetes,!!sym(input$Plot)), fill=!!sym(input$Plot))) +   
        theme_classic()+
        labs(y="Diabetes", x= input$Plot, title = paste0("Diabetes and ",  gsub("\\_", " ", input$Plot )))+
        theme(plot.title = element_text(hjust = 0.5))+
        theme(axis.title.x=element_blank(),
            axis.text.x=element_blank(),
            axis.ticks.x=element_blank())}
  else{ 
    ggplot(data=brfss_diabetes_predict, aes(x=diabetes,y=get(input$Plot)))+
    theme_classic()+
    geom_boxplot(aes(fill=diabetes))+
    labs(y="Diabetes", x= gsub("\\_", " ", input$Plot ),
           title = paste0("Diabetes and ", gsub("\\_", " ", input$Plot )))+
    theme(plot.title = element_text(hjust = 0.5))}
    
}) 

  
}
shinyApp(ui, server)



