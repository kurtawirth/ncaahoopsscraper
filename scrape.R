library(rvest)

Page <- "https://www.sports-reference.com/cbb/boxscores/index.cgi?month=11&day=10&year=2017"

StartDate <- "2017/11/10"

EndDate <- "2018/4/2"

ReadPage <- read_html(Page)

ReadSession <- html_session(Page)

dates <- seq(as.Date(StartDate), as.Date(EndDate), "day") %>% format("%m-%d-%Y")

NumDates <- length(dates)

#Change the below CSS to the CSS found in the "for" loop

HomeTeamName <- ReadPage %>% html_nodes("h2+ .nohover .winner a") %>% html_text()

AwayTeamName <- ReadPage %>% html_nodes("h2+ .nohover .loser td:nth-child(1) a") %>% html_text()

HomeTeamScore <- ReadPage %>% html_nodes("h2+ .nohover .winner .right:nth-child(2)") %>% html_text()

AwayTeamScore <- ReadPage %>% html_nodes("h2+ .nohover .loser .right:nth-child(2)") %>% html_text()

GameDate <- ReadPage %>% html_nodes(".current strong") %>% html_text()

df <- data.frame(GameDate, HomeTeamName, HomeTeamScore, AwayTeamName, AwayTeamScore)

##Create loop for first page

#Count how many games happened that day

NumGames <- length(ReadPage %>% html_nodes(".teams"))

for(game in 2:NumGames + 1){
  
  HomeTeamName <- ReadPage %>% html_nodes(paste(".nohover:nth-child(", game, ") tr:nth-child(2) td:nth-child(1) a")) %>% html_text()
  
  AwayTeamName <- ReadPage %>% html_nodes(paste(".nohover:nth-child(", game, ") tr:nth-child(1) td:nth-child(1) a")) %>% html_text()
  
  HomeTeamScore <- ReadPage %>% html_nodes(paste(".nohover:nth-child(", game, ") tr:nth-child(2) td:nth-child(2)")) %>% html_text()
  
  AwayTeamScore <- ReadPage %>% html_nodes(paste(".nohover:nth-child(", game, ") tr:nth-child(1) td:nth-child(2)")) %>% html_text()
  
  GameDate <- ReadPage %>% html_nodes(".current strong") %>% html_text()
  
  tmp_df <- data.frame(GameDate, HomeTeamName, HomeTeamScore, AwayTeamName, AwayTeamScore)
  
  tmp_df <- tmp_df %>% 
    dplyr::mutate_if(is.factor, as.character)
  
  df <- dplyr::bind_rows(df, tmp_df)

    }

##Create loop for cycling through pages

for(date in dates){
split <- unlist(strsplit(date, "-"))
month <- split[1]
day <- split[2]
year <- split[3]
StartPage <- paste("https://www.sports-reference.com/cbb/boxscores/index.cgi?month=", month, "&day=", day, "&year=", year)

ReadPage <- read_html(Page)

ReadSession <- html_session(Page)

HomeTeamName <- ReadPage %>% html_nodes("h2+ .nohover .winner a") %>% html_text()

AwayTeamName <- ReadPage %>% html_nodes("h2+ .nohover .loser td:nth-child(1) a") %>% html_text()

HomeTeamScore <- ReadPage %>% html_nodes("h2+ .nohover .winner .right:nth-child(2)") %>% html_text()

AwayTeamScore <- ReadPage %>% html_nodes("h2+ .nohover .loser .right:nth-child(2)") %>% html_text()

GameDate <- ReadPage %>% html_nodes(".current strong") %>% html_text()

NumGames <- length(ReadPage %>% html_nodes(".teams"))

  for(game in 3:NumGames + 1){
    
    HomeTeamName <- ReadPage %>% html_nodes(paste(".nohover:nth-child(", game, ") tr:nth-child(2) td:nth-child(1) a")) %>% html_text()
    
    AwayTeamName <- ReadPage %>% html_nodes(paste(".nohover:nth-child(", game, ") tr:nth-child(1) td:nth-child(1) a")) %>% html_text()
    
    HomeTeamScore <- ReadPage %>% html_nodes("") %>% html_text()
    
    AwayTeamScore <- ReadPage %>% html_nodes("") %>% html_text()
    
    GameDate <- ReadPage %>% html_nodes(".current strong") %>% html_text()
    
    tmp_df <- data.frame(GameDate, HomeTeamName, HomeTeamScore, AwayTeamName, AwayTeamScore)
    
    df <- dplyr::bind_rows(df, tmp_df)
    
    }

}