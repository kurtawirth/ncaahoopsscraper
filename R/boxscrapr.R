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

            AwayTeamName = Team_Names[1]

            HomeTeamName = Team_Names[2]

            box.scrape.text = html_text(html_nodes(read_html(current_url), xpath='//*[contains(concat( " ", @class, " " ), concat( " ", "right", " " ))] | //*[contains(concat( " ", @class, " " ), concat( " ", "left", " " ))]'))

            AwayBoxScoreTotal = box.scrape.text[(which(box.scrape.text=="School Totals")[1]+1) : (which(box.scrape.text=="School Totals")[1]+22)] %>%
              t() %>% data.frame() %>% select(-1,-5,-6,-7) %>% mutate(TeamName = AwayTeamName, Opponent = HomeTeamName, Role = "Away", Date = GameDate)

            colnames(AwayBoxScoreTotal) = c("FGM","FGA","FG%","3PTM","3PTA","3PT%","FTM","FTA","FT%","ORB","DRB","REB","AST","STL","BLK","TO","PF","PTS","TeamName","Opponent","Role","Date")

            AwayBoxScoreTotal = AwayBoxScoreTotal[,c(22,19,21,20,18,1,2,3,4,5,6,7,8,9,10,11,12,13,16,14,15,17)]

            AwayBoxScoreTotal <- AwayBoxScoreTotal %>%
              dplyr::mutate_if(is.factor, as.character)

            df <- dplyr::bind_rows(df, AwayBoxScoreTotal)

            HomeBoxScoreTotal = box.scrape.text[(which(box.scrape.text=="School Totals")[2]+1) : (which(box.scrape.text=="School Totals")[2]+22)] %>%
              t() %>% data.frame() %>% select(-1,-5,-6,-7) %>% mutate(TeamName = HomeTeamName, Opponent = AwayTeamName, Role = "Home", Date = GameDate)

            colnames(HomeBoxScoreTotal) = c("FGM","FGA","FG%","3PTM","3PTA","3PT%","FTM","FTA","FT%","ORB","DRB","REB","AST","STL","BLK","TO","PF","PTS","TeamName","Opponent","Role","Date")

            HomeBoxScoreTotal = HomeBoxScoreTotal[,c(22,19,21,20,18,1,2,3,4,5,6,7,8,9,10,11,12,13,16,14,15,17)]

            HomeBoxScoreTotal <- HomeBoxScoreTotal %>%
              dplyr::mutate_if(is.factor, as.character)

            df <- dplyr::bind_rows(df, HomeBoxScoreTotal)}, error = function(e) print(e))

      }}, error = function(e) print(e))

  }

  assign("scores", df, envir=globalenv())

}
