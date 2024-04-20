CSE 6242 Final Project, Spring 2024, Team 73
Visualizing Risk Factors and Career Impacts of Injuries Among MLB Pitchers
Developed by Sumair Shah, Sejal Dua, Tim Ehlenbeck, Jake Hlavaty, Leon Hu, Matthew Schulz


DESCRIPTION

The code found in this directory can be run locally to recreate the analysis completed as part of the project.

The directory contains the following code files:
 
>>  1A_pitch_data.R

This R code acquires baseball pitch level data from BaseballSavant.com for seasons 2019 to 2023. It iterates through each year, then loops through weeks within that year. For each week, it attempts to scrape data and retries on errors. Weekly dataframes are then combined for each year. Finally, all the data from each year is merged into a single dataframe and saved to a CSV file named "pitch_data.csv".

>> 1B_injury_data.R

This Python code scrapes injury report tables from FanGraphs for seasons 2019 to 2023, using Requests-HTML to render pages. It then concatenates the scraped data into a single DataFrame and saves it as a CSV file named "injury_data.csv".

>> 1C_weather_data.R

This R code examines the relationship between baseball injuries and weather conditions. It starts by loading necessary libraries and defining lookup tables. The data cleaning process involves converting dates, filtering out incomplete data, and restricting the dataset to injuries after the date period of interest. The main loop iterates over each injury, retrieves game information for the relevant team and date, and aggregates it.

Code files 1A_pitch_data.R and 1B_injury_data.R should produce the following data files in your local directory:
>> pitchdata_2019.csv
>> pitchdata_2020.csv
>> pitchdata_2021.csv
>> pitchdata_2022.csv
>> pitchdata_2023.csv
>> injury_data.csv

Note: in your programming language of choice, union the 5 pitchdata files to create a file containing all pitch data (we sometimes refer to this as combined pitch data).

>> 2A_analysis.py & 2A_analysis.html

NOTE: this Python/SQL notebook was developed and executed within the Azure Databricks (community edition) environment and may not be possible to run locally; some cells transform the data using SQL and some use Python. For this reason, a .html file showing what the notebook looks like is also provided. This file contains code for the following analytical subtasks:
- data ingestion and merging
- preprocessing & injury location labeling / mapping
- developing candidate pACWR metrics
- statistical testing on pACWR
- subgroup analyses

>> 3A_preprocessing.sql

Using a SQL server of choice, the data transformation steps in this file should be followed to replicate the data sources powering the Tableau dashboard. Please see the EXECUTION section for more details.

INSTALLATION

To install R packages, use the following command in the console: install.packages([PACKAGE])
To install Python packages, use the following command in the terminal: python3 -m pip install [PACKAGE]

I. DATA ACQUISITION

Required R Packages / Libraries:
- library(dplyr)
- library(baseballr)
- library(tidyverse)
- library(rvest)
- library(httr)

Required Python Packages:
- beautifulsoup4
- requests_html
- lxml[html_clean]

II. DATA ANALYSIS / ALGORITHM

The file 'analysis.ipynb' requires the following libraries installed:
 - pandas
 - matplotlib
 - seaborn
 - sklearn
 - scipy

 III. VISUALIZATION

 Tableau Desktop 2023.3.2 (Professional Edition)


EXECUTION (Loading the Tableau Workbook locally)

The interactive visual tool we developed hosted on Tableau Public and can be found at the following link: 
https://public.tableau.com/app/profile/matthew.schulz3502/viz/InjuryImpactsAmongMLBPitchers/Introduction?publish=yes

>> team073viz.twbx

We have also provided the workbook as a Tableau workbook extract (.twbx) file. Since the data sources are all extracts in the provided files, no connectivity instructions should be absolutely necessary to load the visualization locally. However, for the sake of being thorough, below are instructions for how to set up the Tableau backend data sources assuming that all data has been acquired successfully:

The data sources powering the Tableau dashboard are as follows:
A. PrePostInjPerf
B. 7Days
C. 28Days

A. PrePostInjPerf

The purpose of the PrePostInjury table is to establish a dataset that displays performance before and after injury. There are two sources needed for this creation that are referenced in the 3A_preprocessing.sql code:
-#CombinedPitchData (a table containing all years of pitch data)
-#InjuryMaster (a table with player names & injury dates)

Some preprocessing is necessary to clean up these two data sources, but it can be implemented using any programming language. In our case, since the injury data was so small, these steps were implemented in Microsoft Excel.
1. Create a new field (pitchdata_player_name) to get the player name in the correct format (last name, first name) to merge with the pitch data.
2. Create a new flag (INCLUDE) to differentiate pitcher & non-pitcher injuries. The raw data did include a position field but on a few occasions this field proved inaccurate. By matching the original injury list to the pitch data, we found some injured players listed as pitchers had no pitch data and, similarly, some non-pitchers had pitch data. Each match/mismatch in the two scenarios was investigated using baseball-reference.com game logs to determine if the player was actually a pitcher or if the player was a fielder asked to pitch on the rare occasion or two. This field should be filtered to 'Y' to analyze pitcher-only injuries.

B. 7Days 

The purpose of the 7Days dataset is to provide data for the numerator for the pACWR calculation. The table is an aggregate of the number of pitches thrown within the last 7 days of each Player-Game Date. The steps for creating this dataset can be found in 2A_analysis.ipynb. The relevant fields to export to a csv include player_name, game_date, pitch_count_7_days.

C. 28Days 

The purpose of the 28Days dataset is to provide data for the numerator for the pACWR calculation. The table is an aggregate of the number of pitches thrown within the last 28 days of each Player-Game Date. The steps for creating this dataset can be found in 2A_analysis.ipynb. The relevant fields to export to a csv include player_name, game_date, pitch_count_28_days.

Local Tableau Steps:
1. In Tableau Desktop, in the 'Data' menu select 'Add New Data Source'
2. Select 'Text File' for csvs or 'More' for extracts and select the file
3. Under 'Connection' in the top right, select 'Extract' to create a local data file (or 'Live' for automatic live connection)
4. Select a worksheet or dashboard to begin the extract build
To establish data source relationships:
1. In Tableau Desktop, in the 'Data' menu select 'Edit Blend Relationships'
2. The primary data source should always be set to the PrePostInjPerf data source
3. For each data source, select its respective name under 'Secondary data source', select 'Custom', and then 'Add'
4. In the dialog, link the Game Date and Player Name between sources

You should now be able to click into each of the two dashboard tabs and see data populating without error.