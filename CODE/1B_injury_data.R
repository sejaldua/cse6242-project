##### In case we want to scrape instead of download from Fangraphs -- we can use this function to get our injury data


library(rvest)
library(dplyr)
library(httr)

# Function to scrape the injury report from FanGraphs
scrape_injury_report <- function(season = "2024") {
  # Construct the URL for the injury report page
  url <- paste0("https://www.fangraphs.com/roster-resource/injury-report?groupby=injury&timeframe=all&season=", season)
  
  # Use httr to handle the page request
  page <- httr::GET(url)
  content <- httr::content(page, as = "text")
  
  # Use rvest to parse the HTML content
  html_content <- read_html(content)
  
  # Specify the CSS selector to target the table containing the injury report
  # Note: You'll need to inspect the page to find the correct CSS selector for the table
  table_selector <- ".rgMasterTable" # This is a placeholder; update it based on actual page inspection
  
  # Extract the table and convert it into a dataframe
  injury_report_df <- html_content %>%
    html_nodes(css = table_selector) %>%
    html_table(fill = TRUE) %>%
    .[[1]] # Assuming the first table is the one we're interested in
  
  # Manipulate the dataframe as needed, e.g., rename columns, extract player IDs, etc.
  # This is a placeholder step; adapt as necessary based on the structure of your table
  injury_report_df <- injury_report_df %>%
    mutate(player_id = extract_player_id_from_some_column(some_column)) # You'll need to write or adapt a function to extract player IDs
  
  return(injury_report_df)
}



# Example usage
injury_report <- scrape_injury_report(season = "2024")
print(injury_report)




fg_injury_report <- function(season = "2023") {
  # Hypothetical parameters for the query
  params <- list(
    season = season
    # Add other parameters as needed
  )
  
  # Hypothetical URL, assuming there's a direct API for the injury report
  url <- "https://www.fangraphs.com/roster-resource/injury-report"
  
  # Construct the query URL
  fg_endpoint <- httr::modify_url(url, query = params)
  
  tryCatch({
    # Attempt to fetch the data
    response <- httr::GET(fg_endpoint)
    if (httr::status_code(response) == 200) {
      # Parse the JSON response
      data <- httr::content(response, "text", encoding = "UTF-8")
      df <- jsonlite::fromJSON(data, flatten = TRUE)
      
      # Perform any necessary data transformation
      # This part would be specific to the structure of the injury report data
      
      return(df)
    } else {
      stop("Failed to fetch data from the API.")
    }
  }, error = function(e) {
    message(glue::glue("Error: {e$message}"))
  })
}



