  StartDate <- x

  EndDate <- y

  UserEmail <- a

  UserPassword <- b

  dates <- seq(as.Date(StartDate), as.Date(EndDate), "day") %>% format("%Y-%d-%m")

  df <- data.frame()

  Page <- "https://kenpom.com/archive.php?d=2017-11-10"

  ##Log in

  Session <- html_session(Page)

  form <- Session %>%
    html_node(xpath='//*[@id="login"]') %>%
    html_form() %>%
    set_values(., "email" = UserEmail) %>%
    set_values(., "password" = UserPassword)

  Session %>% submit_form(form)

  ##Code from help

  library(data.table)
  library(httr)
  library(XML)
  library(pbapply)
  httr::set_config(config(ssl_verifypeer = 0L))
  base_url = 'https://kenpom.com/index.php?y='
  dat_list <- pblapply(2003:2018, function(x){
    Sys.sleep(1)
    r <- GET(paste0(base_url, x))
    out <- readHTMLTable(as.character(content(r)), stringAsFactors=FALSE)
    out <- data.table(Season=x, out[[1]])
    return(out)
  })
  dat = rbindlist(dat_list)
  fwrite(dat, '~/datasets/pomdata.csv')

  ##My attempt

  dat_list <- function(x){
    login <- "https://kenpom.com/archive.php?d=2017-11-10"
    pars <- list(
      email = UserEmail,
      password = UserPassword
    )
    POST(login, body = pars)
    Sys.sleep(1)
    r <- GET(paste("https://kenpom.com/archive.php?d=", x, sep = ""))
    out <- readHTMLTable(as.character(content(r)), stringAsFactors=FALSE)
    out <- data.table(Season=x, out[[1]])
    return(out)
  }

  ##Create loop for cycling through pages

  for(date in dates){
    tryCatch({
      Page <- paste("https://kenpom.com/archive.php?d=", date, sep = "")

      ReadPage <- GET(paste("https://kenpom.com/archive.php?d=", x, sep = ""))

      out <- readHTMLTable(as.character(content(ReadPage)), stringAsFactors=FALSE)

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

#COMBINE FILES

library(data.table)

setwd("D:/Users/Kurt/Documents/Programming/ncaahoopsscraper/data/DailyRatings/2017-18/Aggregate")

files = list.files(pattern="*.csv")

DT = do.call(rbind, lapply(files, fread))

write.csv(DT, "201718.csv")
