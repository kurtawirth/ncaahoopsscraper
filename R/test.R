  StartDate <- x
  
  EndDate <- y
  
  UserEmail <- a
  
  UserPassword <- b
  
  dates <- seq(as.Date(StartDate), as.Date(EndDate), "day") %>% format("%Y-%d-%m")
  
  df <- data.frame()
  
  ##Log in
  
  Session <- html_session(Page)
  
  form <- Session %>% 
    html_node(xpath='//*[@id="login"]') %>%
    html_form() %>% 
    set_values(., "email" = UserEmail) %>%
    set_values(., "password" = UserPassword)
  
  Session %>% submit_form(form)
  
  ##Create loop for cycling through pages
  
  for(date in dates){
    tryCatch({
      Page <- paste("https://kenpom.com/archive.php?d=", date, sep = "")
      
      ReadPage <- read_html(Page)
      
      NumTeams <- length(ReadPage %>% html_nodes("td.next_left a"))
      
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
        
        assign("scores", df, envir=globalenv())
        
      }}, error = function(e) print(e))
    
  }
  
}
