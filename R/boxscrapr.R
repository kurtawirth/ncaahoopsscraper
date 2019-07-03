#' boxscrapr
#'
#' Scrapes box scores for any season of college basketball.
#'
#' Takes inputs for beginning and end of season and scrapes www.sports-reference.com for all box scores between those dates (inclusive).
#'
#' @author Kurt Wirth
#'
#' @param x The beginning date of data scraping, in the format (TEST)
#' "yyyy/mm/dd".
#'
#' @param y The ending date of data scraping, in the format
#' "yyyy/mm/dd".
#'
#' @return A tidy dataframe with the following variables for all games within
#' the date range: XXX
#'
#' @examples
#' \dontrun{boxscrapr("2017/11/10", "2018/04/02")}
#' @export

library(rvest)

library(dplyr)

boxscrapr = function(x, y) {

  StartDate = x

  EndDate = y

  dates = seq(as.Date(StartDate), as.Date(EndDate), "day") %>% format("%m-%d-%Y")

  df = data.frame()

  ##Create loop for cycling through pages

  for(date in dates){
    tryCatch({
      split = unlist(strsplit(date, "-"))
      month = split[1]
      day = split[2]
      year = split[3]
      Page = paste("https://www.sports-reference.com/cbb/boxscores/index.cgi?month=",month,"&day=",day,"&year=",year, sep="")

      ReadPage = read_html(Page)

      NumGames = length(ReadPage %>% rvest::html_nodes(".teams"))

      GameDate = ReadPage %>% html_nodes(".current strong") %>% html_text()

      GameDate = as.character(GameDate)

      Session = rvest::html_session(Page)

      for(game in 1:NumGames){

        tryCatch({

            click = rvest::follow_link(Session, css = paste(".nohover:nth-child(", game + 1, ") .gamelink a"))

            current_url = click$url

            Team_Names = read_html(current_url) %>% rvest::html_nodes("div:nth-child(1) div strong a") %>% html_text()

            AwayTeam = Team_Names[1]

            HomeTeam = Team_Names[2]

            box.scrape.text = html_text(html_nodes(read_html(current_url), xpath='//*[contains(concat( " ", @class, " " ), concat( " ", "right", " " ))] | //*[contains(concat( " ", @class, " " ), concat( " ", "left", " " ))]'))

            HomeBoxScoreRaw = box.scrape.text[566:587]

            HomeBoxScore = data.frame("Date" = GameDate, "TeamName" = HomeTeam, "FGM" = HomeBoxScoreRaw[2], "FGA" = HomeBoxScoreRaw[3], "FG%" = round(as.numeric(HomeBoxScoreRaw[2])/as.numeric(HomeBoxScoreRaw[3]), 3), "3PTM" = HomeBoxScoreRaw[8], "3PTA" = HomeBoxScoreRaw[9], "3PT%" = round(as.numeric(HomeBoxScoreRaw[8])/as.numeric(HomeBoxScoreRaw[9]), 3), "FTM" = HomeBoxScoreRaw[11], "FTA" = HomeBoxScoreRaw[12], "FT%" = round(as.numeric(HomeBoxScoreRaw[11])/as.numeric(HomeBoxScoreRaw[12]), 3), "ORB" = HomeBoxScoreRaw[14], "DRB" = HomeBoxScoreRaw[15], "REB" = HomeBoxScoreRaw[16], "AST" = HomeBoxScoreRaw[17], "STL" = HomeBoxScoreRaw[18], "BLK" = HomeBoxScoreRaw[19], "TO" = HomeBoxScoreRaw[20], "PF" = HomeBoxScoreRaw[21], "PTS" = HomeBoxScoreRaw[22])

            df <- dplyr::bind_rows(df, HomeBoxScore)

            AwayBoxScoreRaw = box.scrape.text[267:288]

            AwayBoxScore = data.frame("Date" = GameDate, "TeamName" = AwayTeam, "FGM" = AwayBoxScoreRaw[2], "FGA" = AwayBoxScoreRaw[3], "FG%" = round(as.numeric(AwayBoxScoreRaw[2])/as.numeric(AwayBoxScoreRaw[3]), 3), "3PTM" = AwayBoxScoreRaw[8], "3PTA" = AwayBoxScoreRaw[9], "3PT%" = round(as.numeric(AwayBoxScoreRaw[8])/as.numeric(AwayBoxScoreRaw[9]), 3), "FTM" = AwayBoxScoreRaw[11], "FTA" = AwayBoxScoreRaw[12], "FT%" = round(as.numeric(AwayBoxScoreRaw[11])/as.numeric(AwayBoxScoreRaw[12]), 3), "ORB" = AwayBoxScoreRaw[14], "DRB" = AwayBoxScoreRaw[15], "REB" = AwayBoxScoreRaw[16], "AST" = AwayBoxScoreRaw[17], "STL" = AwayBoxScoreRaw[18], "BLK" = AwayBoxScoreRaw[19], "TO" = AwayBoxScoreRaw[20], "PF" = AwayBoxScoreRaw[21], "PTS" = AwayBoxScoreRaw[22])

            df <- dplyr::bind_rows(df, AwayBoxScore)}, error = function(e) print(e))

      }}, error = function(e) print(e))

  }

  assign("scores", df, envir=globalenv())

}
