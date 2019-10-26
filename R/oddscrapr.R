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
  
  select <- dplyr::select; rename <- dplyr::rename; mutate <- dplyr::mutate
  
  summarize <- dplyr::summarize; arrange <- dplyr::arrange; filter <- dplyr::filter; slice <- dplyr::slice
  
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
      
      Page = paste("https://www.pickmonitor.com/past-odds/",year,"-",month,"-",day, sep="")
      
      #ReadPage = read_html(Page)
      
      GameDate = date
      
      OddsText = html_text(html_nodes(read_html(Page), xpath = "//td | //h3"))
      
      Begin = which(OddsText=="NCAA Basketball") + 1
      
      End = Begin + min(which((grepl("^[A-Za-z ]+$", OddsText[Begin : length(OddsText)])) == TRUE)) - 2
      
      Odds = as.data.frame(matrix(OddsText[Begin : End], ncol = 5, byrow = TRUE)) %>% select(-V1, -V3, -V5) %>%
        tidyr::separate(V2, into = c("AwayTeamName", "HomeTeamName"), sep = "vs") %>%
        tidyr::separate(V4, into = c("Line", "ProfitLine"), sep = " ") %>% 
        mutate(AwayTeamName = str_trim(gsub('[0-9]+', '', AwayTeamName))) %>%
        mutate(HomeTeamName = str_trim(gsub('[0-9]+', '', HomeTeamName))) %>%
        mutate(Line = as.numeric(Line)) %>% mutate(ProfitLine = as.numeric(ProfitLine)) %>%
        mutate(Date = as.Date(paste(year, month, day, sep = "-")))
      
      }, error = function(e) print(e))
    
    df <- dplyr::bind_rows(df, Odds)
    
  }
  assign("BettingLines", df, envir=globalenv())
}
