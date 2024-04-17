CSE 6242 Final Project, Spring 2024, Team 73
Visualizing Risk Factors and Career Impacts of Injuries Among MLB Pitchers
Developed by Sumair Shah, Sejal Dua, Tim Ehlenbeck, Jake Hlavaty, Leon Hu, Matthew Schulz


DESCRIPTION
The code found in this directory can be run locally to recreate the analysis completed as part of the project. The directory contains the following files:
 - analysis.py >> python file responsible for creating linear regression models for each state using LASSO regression. The file is currently configured to perform analysis on Per-Capita Opioid Pill Volume (PCPV) and Opioid Related Deaths (ORD_DEATHS).
 - featurelabels.csv >> csv file mapping feature label codes to descriptions (e.g. F11984 -> Population estimate)
 - code.txt >> documentation for code portion of assignment 

The interactive visual tool is hosted on Tableau Public and can be found at the following link: 
https://public.tableau.com/app/...

INSTALLATION
The file 'analysis.ipynb' requires the following libraries installed:
 - pandas
 - matplotlib
 - seaborn
 - sklearn

 The following command can be used to install the libraries:
 python3 -m pip install pandas matplotlib seaborn sklearn


EXECUTION
