library(baseballr)
library(httr)  # for handling HTTP errors

# Initialize variables
start_date <- as.Date('2019-04-02')
end_date <- as.Date('2019-10-01')
all_data <- list()  # List to store weekly data frames
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
final_data <- do.call(rbind, all_data)


write.csv(final_data,'pitchdata_2019.csv')