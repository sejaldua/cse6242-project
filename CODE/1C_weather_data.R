#### adding in weather data to see if there is any relationship between weather 



##install.packages("baseballr")
#install.packages("dplyr")
#install.packages("tidyverse")
library(dplyr)
library(baseballr)
library(tidyverse)

###Lookup table and data load

injuries <- read.csv("./injury_data.csv")
team_abrev <- c('ARI','ATL','BAL','BOS','CHC','CHW','CIN','CLE','COL','DET','HOU','KCR','LAA',
                'LAD','MIA','MIL','MIN','NYM','NYY','OAK','PHI','PIT','SDP','SEA','SFG','STL',
                'TBR','TEX','TOR','WSN')
team_name <- c('Arizona Diamondbacks',
               'Atlanta Braves',
               'Baltimore Orioles',
               'Boston Red Sox',
               'Chicago Cubs',
               'Chicago White Sox',
               'Cincinnati Reds',
               'Cleveland Guardians',
               'Colorado Rockies',
               'Detroit Tigers',
               'Houston Astros',
               'Kansas City Royals',
               'Los Angeles Angels',
               'Los Angeles Dodgers',
               'Miami Marlins',
               'Milwaukee Brewers',
               'Minnesota Twins',
               'New York Mets',
               'New York Yankees',
               'Oakland Athletics',
               'Philadelphia Phillies',
               'Pittsburgh Pirates',
               'San Diego Padres',
               'San Francisco Giants',
               'Seattle Mariners',
               'St. Louis Cardinals',
               'Tampa Bay Rays',
               'Texas Rangers',
               'Toronto Blue Jays',
               'Washington Nationals')
team_id <- c(109,144,110,111,112,145,113,114,115,116,117,118,108,119,146,158,142,121,147,133,143,134,135,137,136,138,139,140,141,120)

### Data clean
team_lookup <- data.frame(team_abrev,team_name,team_id)
injuries$injury_date_clean <- as.Date(injuries$Injury...Surgery.Date, format = "%m/%d/%Y")
injuries <- filter(injuries,!is.na(injury_date_clean))
injuries <- filter(injuries,injury_date_clean >= '2020-01-01')

### Pull game information for all games players got hurt in
date <-injuries[1,]$injury_date_clean
team_abrv2 <- injuries[1,]$Team
team <- filter(team_lookup,team_abrev == team_abrv2)$team_id
temp <- baseballr::mlb_game_pks(toString(date),level_ids = 1)
temp <- filter(temp,(teams.away.team.id == team | teams.home.team.id == team))
for (pk in temp$game_pk) {
  game <- mlb_game_info(pk)
  injury_game_info <- game
}
for (i in 2:nrow(injuries)){
  date <-injuries[i,]$injury_date_clean
  team_abrv2 <- injuries[i,]$Team
  team <- filter(team_lookup,team_abrev == team_abrv2)$team_id
  temp <- baseballr::mlb_game_pks(toString(date),level_ids = 1)
  temp <- filter(temp,(teams.away.team.id == team | teams.home.team.id == team)
                 for (pk in temp$game_pk) {
                   game <- mlb_game_info(pk)
                   game <- rbind(injuries$Name,game)
                   injury_game_info[nrow(injury_game_info) +1,] <- game
                 }
                 
}


### Get Player Bio data

#pulls all players for ids
all_players <-get_chadwick_lu()

#after you have ids, use to get bio information including birthday for injury date - birth date for age
mlb_people(person_ids = NULL)

### pulls stats from day t1 to t2, filter by player afterwards
bref_daily_pitcher(t1, t2)



