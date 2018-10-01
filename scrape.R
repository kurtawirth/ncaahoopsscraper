library(rvest)

StartPage <- "https://www.sports-reference.com/cbb/boxscores/index.cgi?month=11&day=10&year=2017"

StartDate <- "2017/11/10"

EndDate <- "2018/4/2"

ReadStartPage <- read_html(StartPage)

ReadSession <- html_session(StartPage)

dates <- seq(as.Date(StartDate), as.Date(EndDate), "day") %>% format("%B %d, %Y")

#Change the below CSS to the CSS found in the "for" loop

HomeTeamName <- ReadStartPage %>% html_nodes("h2+ .nohover .winner a") %>% html_text()

AwayTeamName <- ReadStartPage %>% html_nodes("h2+ .nohover .loser td:nth-child(1) a") %>% html_text()

HomeTeamScore <- ReadStartPage %>% html_nodes("h2+ .nohover .winner .right:nth-child(2)") %>% html_text()

AwayTeamScore <- ReadStartPage %>% html_nodes("h2+ .nohover .loser .right:nth-child(2)") %>% html_text()

GameDate <- ReadStartPage %>% html_nodes(".current strong") %>% html_text()

df <- data.frame(GameDate, HomeTeamName, HomeTeamScore, AwayTeamName, AwayTeamScore)

##Create loop for first page

#Count how many games happened that day

NumGames <- length(ReadStartPage %>% html_nodes(".teams"))

for(game in 3:NumGames + 1){
  
  HomeTeamName <- ReadStartPage %>% html_nodes(paste(".nohover:nth-child(", game, ") tr:nth-child(2) td:nth-child(1) a")) %>% html_text()
  
  AwayTeamName <- ReadStartPage %>% html_nodes(paste(".nohover:nth-child(", game, ") tr:nth-child(1) td:nth-child(1) a")) %>% html_text()
  
  HomeTeamScore <- ReadStartPage %>% html_nodes("") %>% html_text()
  
  AwayTeamScore <- ReadStartPage %>% html_nodes("") %>% html_text()
  
  GameDate <- ReadStartPage %>% html_nodes(".current strong") %>% html_text()
  
  tmp_df <- data.frame(GameDate, HomeTeamName, HomeTeamScore, AwayTeamName, AwayTeamScore)
  
  df <- dplyr::bind_rows(df, tmp_df)

    }

##Create loop for cycling through pages

#The below should be at the bottom of the loop

session %>% follow_link(css = ".next")