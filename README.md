# Brfss_project

I analyzed the 2013 Behavioral Risk Factor Surveillance System (BRFSS) dataset from the US CDC. A dataset description can be found [here](https://d3c33hcgiwev3.cloudfront.net/_e34476fda339107329fc316d1f98e042_brfss_codebook.html?Expires=1695427200&Signature=dacaRCig7zvD3kJD6eFEZOed9QcOYJi-BKXy5dMFM0kZ-glXDTKPE1d7~s0Y6nJpYi8DBlk0n0K-2V3GZJ5ixytrcJi2H3LaFB0u491Mh8hcB5vvfSZ4Zh9jYkZ8L5cHGTU7AqF3wmobfnuFbTsz1Bs4E2MO8sED-W-OChYIArM_&Key-Pair-Id=APKAJLTNE6QMUY6HBC5A).

The code for the analysis is in the Brffs.R file, while the dataset is the brfss2013.RData file. I performed an exploraory data analysis and visualized the relotionship among sleep and mental health, internet access and income and diabetes and body mass index.

Then, I tried to predict the diabetes status using a boosting model. I choose the foolowing predictors: income (income_2), body mass index (X_bmi5), sleeptime (sleptim1), sex (sex), education level (educa), employment status (employ1), having smoked or not at least 100 cigarets (smoke100), the number of days in the last month in which the person drank alcohol (alcday5)  and the number of days in the last month in which the person ate fruit (fruit1). For the last two variables, I had to perform some data wrangling, because the values where reported sometime for week and sometime for month.

I splitted the dataset in a train and test dataset, fitted the boosting model on the train datatset and predicted the diabetes status on the test dataset, I got a sensitivity of 0.53 and a specificity of 0.87. I plotted a confusion matrix to summarise the results of the analysis.

The Brffs_Shiny.R is a file for a Shiny app that visualizes the reletionship between the diabetes status and some demographic, physical and behavioural varaibles extrcted from the dataset by the Variables_Shiny.R file
