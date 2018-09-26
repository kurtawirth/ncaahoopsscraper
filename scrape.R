startpage <- read_html("https://www.sports-reference.com/cbb/boxscores/index.cgi?month=4&day=2&year=2018")

session <- html_session("https://www.sports-reference.com/cbb/boxscores/index.cgi?month=4&day=2&year=2018")

WinningTeamName <- startpage %>% html_nodes(".winner a") %>% html_text()

LosingTeamName <- startpage %>% html_nodes(".loser td:nth-child(1) a") %>% html_text()

HomeTeamName <- session %>% follow_link(css = ".gamelink a") %>% html_nodes("#line-score .thead~ tr+ tr a") %>% html_text()

VisitorTeamName <- session %>% follow_link(css = ".gamelink a") %>% html_nodes("#line-score .thead~ tr+ tr a") %>% html_text()
