library(rvest)
library(dplyr)

StartDate <- "2017/11/10"

EndDate <- "2018/4/2"

dates <- seq(as.Date(StartDate), as.Date(EndDate), "day") %>% format("%m-%d-%Y")

df <- data.frame()

##Create loop for cycling through pages

for(date in dates){
  tryCatch({
    split <- unlist(strsplit(date, "-"))
    month <- split[1]
    day <- split[2]
    year <- split[3]
    Page <- paste("https://www.sports-reference.com/cbb/boxscores/index.cgi?month=",month,"&day=",day,"&year=",year, sep="")
    
    ReadPage <- read_html(Page)
    
    NumGames <- length(ReadPage %>% html_nodes(".teams"))
    
    for(game in 1:NumGames){
      
      tryCatch({HomeTeamName <- ReadPage %>% html_nodes(paste(".nohover:nth-child(", game + 1, ") tr:nth-child(2) td:nth-child(1) a")) %>% html_text()
      
      HomeTeamName <- as.character(HomeTeamName)
      
      AwayTeamName <- ReadPage %>% html_nodes(paste(".nohover:nth-child(", game + 1, ") tr:nth-child(1) td:nth-child(1) a")) %>% html_text()
      
      AwayTeamName <- as.character(AwayTeamName)
      
      HomeTeamScore <- ReadPage %>% html_nodes(paste(".nohover:nth-child(", game + 1, ") tr:nth-child(2) td:nth-child(2)")) %>% html_text()
      
      HomeTeamScore <- as.numeric(HomeTeamScore)
      
      AwayTeamScore <- ReadPage %>% html_nodes(paste(".nohover:nth-child(", game + 1, ") tr:nth-child(1) td:nth-child(2)")) %>% html_text()
      
      AwayTeamScore <- as.numeric(AwayTeamScore)
      
      GameDate <- ReadPage %>% html_nodes(".current strong") %>% html_text()
      
      GameDate <- as.character(GameDate)
      
      tmp_df <- data.frame(GameDate, HomeTeamName, HomeTeamScore, AwayTeamName, AwayTeamScore)
      
      tmp_df <- tmp_df %>% 
        dplyr::mutate_if(is.factor, as.character)
      
      df <- dplyr::bind_rows(df, tmp_df)}, error = function(e) print(e))
      
    }}, error = function(e) print(e))
  
}