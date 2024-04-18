CSE 6242 Final Project, Spring 2024, Team 73
Visualizing Risk Factors and Career Impacts of Injuries Among MLB Pitchers
Developed by Sumair Shah, Sejal Dua, Tim Ehlenbeck, Jake Hlavaty, Leon Hu, Matthew Schulz


DESCRIPTION

The code found in this directory can be run locally to recreate the analysis completed as part of the project. The directory contains the following code files:
 
 - 1A_pitch_data.R

This R code acquires baseball pitch level data from BaseballSavant.com for seasons 2019 to 2023. It iterates through each year, then loops through weeks within that year. For each week, it attempts to scrape data and retries on errors. Weekly dataframes are then combined for each year. Finally, all the data from each year is merged into a single dataframe and saved to a CSV file named "pitch_data.csv".

 - 1B_injury_data.R

 This R code provides functions to scrape injury data from FanGraphs. The first function, scrape_injury_report, takes a season year (defaulting to 2024) and constructs a URL for the FanGraphs injury report page. It then retrieves the content, parses the HTML, and attempts to target a table containing the injury data using a CSS selector.

 - 1C_weather_data.R

 This R code examines the relationship between baseball injuries and weather conditions. It starts by loading necessary libraries and defining lookup tables. The data cleaning process involves converting dates, filtering out incomplete data, and restricting the dataset to injuries after the date period of interest. The main loop iterates over each injury, retrieves game information for the relevant team and date, and aggregates it.

 The directory contains the following data files:




The interactive visual tool is hosted on Tableau Public and can be found at the following link: 
https://public.tableau.com/app/...

INSTALLATION

I. DATA ACQUISITION

Required R Packages / Libraries:
- library(dplyr)
- library(baseballr)
- library(tidyverse)
- library(rvest)
- library(httr)

II. DATA ANALYSIS / ALGORITHM

The file 'analysis.ipynb' requires the following libraries installed:
 - pandas
 - matplotlib
 - seaborn
 - sklearn

 The following command can be used to install the libraries:
 python3 -m pip install pandas matplotlib seaborn sklearn

EXECUTION
