#' oddscrapr
#'
#' Scrapes betting lines for any season of college basketball.
#'
#' Takes inputs for beginning and end of season and scrapes www.covers.com for all box scores between those dates (inclusive).
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
#' \dontrun{oddscrapr("2017/11/10", "2018/04/02")}
#' @export

library(rvest)

library(dplyr)

library(stringr)

oddscrapr = function(x, y) {

  StartDate = x

  EndDate = y

  dates = seq(as.Date(StartDate), as.Date(EndDate), "day") %>% format("%m-%d-%Y")

  df = data.frame()

  strsplit <- function(x,
                       split,
                       type = "remove",
                       perl = FALSE,
                       ...) {
    if (type == "remove") {
      # use base::strsplit
      out <- base::strsplit(x = x, split = split, perl = perl, ...)
    } else if (type == "before") {
      # split before the delimiter and keep it
      out <- base::strsplit(x = x,
                            split = paste0("(?<=.)(?=", split, ")"),
                            perl = TRUE,
                            ...)
    } else if (type == "after") {
      # split after the delimiter and keep it
      out <- base::strsplit(x = x,
                            split = paste0("(?<=", split, ")"),
                            perl = TRUE,
                            ...)
    } else {
      # wrong type input
      stop("type must be remove, after or before!")
    }
    return(out)
  }

  for(date in dates){
    tryCatch({

      split = unlist(strsplit(date, "-"))
      month = split[1]
      day = split[2]
      year = split[3]

      Page = paste("https://www.sportsbookreview.com/betting-odds/ncaa-basketball/pointspread/?date=",year,month,day, sep="")

      ReadPage = read_html(Page)

      NumGames = length(ReadPage %>% rvest::html_nodes("._3zKaX"))

      GameDate = date

      TeamNames = html_text(html_nodes(read_html(Page), xpath = '//*[contains(concat( " ", @class, " " ), concat( " ", "_3O1Gx", " " ))]'))

      TeamNamesDF = data.frame(TeamName = gsub("\\s*\\([^\\)]+\\) ","",as.character(TeamNames)))

      Odds1 = data.frame(TeamName = TeamNamesDF[seq(1,nrow(TeamNamesDF) - 1, 2),], OpponentName = TeamNamesDF[seq(2,nrow(TeamNamesDF), 2),]) %>% mutate(order = row_number())

      Odds2 = Odds1 %>% rename(TeamName = OpponentName, OpponentName = TeamName) %>% select(TeamName, OpponentName) %>% mutate(order = row_number())

      LinesText = html_text(html_nodes(read_html(Page), xpath = '//*[contains(concat( " ", @class, " " ), concat( " ", "_3zKaX", " " ))]'))

      LinesPct = sapply(LinesText, function(x) str_split(x, "%", simplify = TRUE)[3], USE.NAMES = FALSE)

      LinesDash = sapply(LinesText, function(x) str_split(x, "--", simplify = TRUE)[2], USE.NAMES = FALSE)

      Lines = data.frame(LinesPct = LinesPct, LinesDash = LinesDash) %>% mutate(LinesPct = as.character(LinesPct), LinesDash = as.character(LinesDash)) %>% mutate(Lines = coalesce(LinesPct, LinesDash)) %>% select(3)

      LinesSplit = as.data.frame(matrix(unlist(strsplit(Lines$Lines, "\\+|-", type="before")), ncol = 4, byrow = TRUE)) %>%
        sapply(function(x) str_replace(x,"[½]",".5")) %>% as.data.frame() %>%
        sapply(function(x) as.numeric(str_replace(x,"[\\+]",""))) %>% as.data.frame()

      AwayOdds = bind_cols(Odds1, Line = LinesSplit$V1)

      HomeOdds = bind_cols(Odds2, Line = LinesSplit$V3)

      Odds = HomeOdds %>% bind_rows(AwayOdds) %>% arrange(order) %>% select(-order) %>% mutate(Date = as.Date(paste(year, month, day, sep = "-")))

    }, error = function(e) print(e))

    df <- dplyr::bind_rows(df, Odds)

  }
  assign("BettingLines", df, envir=globalenv())
}
