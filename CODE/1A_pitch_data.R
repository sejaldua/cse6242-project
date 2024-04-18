##### scraping pitch level data

### install baseball R
library(baseballr)
library(httr)  # for handling HTTP errors

# Initialize variables


#### for R memory purposes I prefer to run this year by year and then combine years
### first date you want

### 2019


start_date <- as.Date('2019-04-02')
##last date
end_date <- as.Date('2019-10-01')
all_data_2019 <- list()  # List to store weekly data frames
max_retries <- 3  # Maximum number of retries for each week

# Loop through weeks
while(start_date < end_date) {
  # Set the end date for the current week
  current_end_date <- min(start_date + 6, end_date)
  attempts <- 0
  data_acquired <- FALSE
  
  # Attempt to scrape data for the current week, retrying up to max_retries times
  while(attempts < max_retries && !data_acquired) {
    try({
      # Scrape data for the current week
      weekly_data <- baseballr::scrape_statcast_savant_pitcher_all(start_date = format(start_date, "%Y-%m-%d"),
                                                                   end_date = format(current_end_date, "%Y-%m-%d"))
      # Check if the data frame is not empty
      if (nrow(weekly_data) > 0) {
        # Append the weekly data to the list
        all_data <- append(all_data, list(weekly_data))
        data_acquired <- TRUE
      }
    }, silent = TRUE)  # Use silent = TRUE to suppress error messages in the console
    
    attempts <- attempts + 1
  }
  
  if (!data_acquired) {
    # Print a message indicating no data was acquired for this week (optional)
    print(paste("No data acquired for week starting on", format(start_date, "%Y-%m-%d"), "after", max_retries, "attempts"))
  }
  
  # Update the start date for the next week
  start_date <- start_date + 7
}

# Combine all weekly data frames into one
final_data_2019 <- do.call(rbind, all_data_2019)

###### same thing for 2020


##### scraoing pitch level data

### install baseball R
library(baseballr)
library(httr)  # for handling HTTP errors

# Initialize variables


#### for R memory purposes I prefer to run this year by year and then combine years
### first date you want

### 2020


start_date <- as.Date('2020-04-02')
##last date
end_date <- as.Date('2020-10-01')
all_data_2019 <- list()  # List to store weekly data frames
max_retries <- 3  # Maximum number of retries for each week

# Loop through weeks
while(start_date < end_date) {
  # Set the end date for the current week
  current_end_date <- min(start_date + 6, end_date)
  attempts <- 0
  data_acquired <- FALSE
  
  # Attempt to scrape data for the current week, retrying up to max_retries times
  while(attempts < max_retries && !data_acquired) {
    try({
      # Scrape data for the current week
      weekly_data <- baseballr::scrape_statcast_savant_pitcher_all(start_date = format(start_date, "%Y-%m-%d"),
                                                                   end_date = format(current_end_date, "%Y-%m-%d"))
      # Check if the data frame is not empty
      if (nrow(weekly_data) > 0) {
        # Append the weekly data to the list
        all_data <- append(all_data, list(weekly_data))
        data_acquired <- TRUE
      }
    }, silent = TRUE)  # Use silent = TRUE to suppress error messages in the console
    
    attempts <- attempts + 1
  }
  
  if (!data_acquired) {
    # Print a message indicating no data was acquired for this week (optional)
    print(paste("No data acquired for week starting on", format(start_date, "%Y-%m-%d"), "after", max_retries, "attempts"))
  }
  
  # Update the start date for the next week
  start_date <- start_date + 7
}

# Combine all weekly data frames into one
final_data_2020 <- do.call(rbind, all_data_2020)



#### ##### scraoing pitch level data

### install baseball R
library(baseballr)
library(httr)  # for handling HTTP errors

# Initialize variables


#### for R memory purposes I prefer to run this year by year and then combine years
### first date you want

### 2021


start_date <- as.Date('2021-04-02')
##last date
end_date <- as.Date('2021-10-01')
all_data_2021 <- list()  # List to store weekly data frames
max_retries <- 3  # Maximum number of retries for each week

# Loop through weeks
while(start_date < end_date) {
  # Set the end date for the current week
  current_end_date <- min(start_date + 6, end_date)
  attempts <- 0
  data_acquired <- FALSE
  
  # Attempt to scrape data for the current week, retrying up to max_retries times
  while(attempts < max_retries && !data_acquired) {
    try({
      # Scrape data for the current week
      weekly_data <- baseballr::scrape_statcast_savant_pitcher_all(start_date = format(start_date, "%Y-%m-%d"),
                                                                   end_date = format(current_end_date, "%Y-%m-%d"))
      # Check if the data frame is not empty
      if (nrow(weekly_data) > 0) {
        # Append the weekly data to the list
        all_data <- append(all_data, list(weekly_data))
        data_acquired <- TRUE
      }
    }, silent = TRUE)  # Use silent = TRUE to suppress error messages in the console
    
    attempts <- attempts + 1
  }
  
  if (!data_acquired) {
    # Print a message indicating no data was acquired for this week (optional)
    print(paste("No data acquired for week starting on", format(start_date, "%Y-%m-%d"), "after", max_retries, "attempts"))
  }
  
  # Update the start date for the next week
  start_date <- start_date + 7
}

# Combine all weekly data frames into one
final_data_2021<- do.call(rbind, all_data_2021)

##### scraoing pitch level data

### install baseball R
library(baseballr)
library(httr)  # for handling HTTP errors

# Initialize variables


#### for R memory purposes I prefer to run this year by year and then combine years
### first date you want

### 2022


start_date <- as.Date('2022-04-02')
##last date
end_date <- as.Date('2022-10-01')
all_data_2022 <- list()  # List to store weekly data frames
max_retries <- 3  # Maximum number of retries for each week

# Loop through weeks
while(start_date < end_date) {
  # Set the end date for the current week
  current_end_date <- min(start_date + 6, end_date)
  attempts <- 0
  data_acquired <- FALSE
  
  # Attempt to scrape data for the current week, retrying up to max_retries times
  while(attempts < max_retries && !data_acquired) {
    try({
      # Scrape data for the current week
      weekly_data <- baseballr::scrape_statcast_savant_pitcher_all(start_date = format(start_date, "%Y-%m-%d"),
                                                                   end_date = format(current_end_date, "%Y-%m-%d"))
      # Check if the data frame is not empty
      if (nrow(weekly_data) > 0) {
        # Append the weekly data to the list
        all_data <- append(all_data, list(weekly_data))
        data_acquired <- TRUE
      }
    }, silent = TRUE)  # Use silent = TRUE to suppress error messages in the console
    
    attempts <- attempts + 1
  }
  
  if (!data_acquired) {
    # Print a message indicating no data was acquired for this week (optional)
    print(paste("No data acquired for week starting on", format(start_date, "%Y-%m-%d"), "after", max_retries, "attempts"))
  }
  
  # Update the start date for the next week
  start_date <- start_date + 7
}

# Combine all weekly data frames into one
final_data_2022 <- do.call(rbind, all_data_2022)


##### scraoing pitch level data

### install baseball R
library(baseballr)
library(httr)  # for handling HTTP errors

# Initialize variables


#### for R memory purposes I prefer to run this year by year and then combine years
### first date you want

### 2023


start_date <- as.Date('2023-04-02')
##last date
end_date <- as.Date('2023-10-01')
all_data_2023 <- list()  # List to store weekly data frames
max_retries <- 3  # Maximum number of retries for each week

# Loop through weeks
while(start_date < end_date) {
  # Set the end date for the current week
  current_end_date <- min(start_date + 6, end_date)
  attempts <- 0
  data_acquired <- FALSE
  
  # Attempt to scrape data for the current week, retrying up to max_retries times
  while(attempts < max_retries && !data_acquired) {
    try({
      # Scrape data for the current week
      weekly_data <- baseballr::scrape_statcast_savant_pitcher_all(start_date = format(start_date, "%Y-%m-%d"),
                                                                   end_date = format(current_end_date, "%Y-%m-%d"))
      # Check if the data frame is not empty
      if (nrow(weekly_data) > 0) {
        # Append the weekly data to the list
        all_data <- append(all_data, list(weekly_data))
        data_acquired <- TRUE
      }
    }, silent = TRUE)  # Use silent = TRUE to suppress error messages in the console
    
    attempts <- attempts + 1
  }
  
  if (!data_acquired) {
    # Print a message indicating no data was acquired for this week (optional)
    print(paste("No data acquired for week starting on", format(start_date, "%Y-%m-%d"), "after", max_retries, "attempts"))
  }
  
  # Update the start date for the next week
  start_date <- start_date + 7
}

# Combine all weekly data frames into one
final_data_2023 <- do.call(rbind, all_data_2023)


### combine all the data or you can write each year to its own .csv


pitch_data <- rbind(final_data_2019,final_data_2020,final_data_2021,final_data_2022,final_data_2023)

### write it to a .csv

write.csv('pitch_data.csv')