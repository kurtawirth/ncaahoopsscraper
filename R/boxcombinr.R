setwd("")

bsdata = list()
require(data.table)
library(dplyr)
bsdata[[1]] = data.table::fread("~/Programming/ncaahoopsscraper/data/BoxScores/201011.csv", header = T, sep = ',') %>% as.data.frame()
bsdata[[2]] = data.table::fread("~/Programming/ncaahoopsscraper/data/BoxScores/201112.csv", header = T, sep = ',') %>% as.data.frame()
bsdata[[3]] = data.table::fread("~/Programming/ncaahoopsscraper/data/BoxScores/201213.csv", header = T, sep = ',') %>% as.data.frame()
bsdata[[4]] = data.table::fread("~/Programming/ncaahoopsscraper/data/BoxScores/201314.csv", header = T, sep = ',') %>% as.data.frame()
bsdata[[5]] = data.table::fread("~/Programming/ncaahoopsscraper/data/BoxScores/201415.csv", header = T, sep = ',') %>% as.data.frame()
bsdata[[6]] = data.table::fread("~/Programming/ncaahoopsscraper/data/BoxScores/201516.csv", header = T, sep = ',') %>% as.data.frame()
bsdata[[7]] = data.table::fread("~/Programming/ncaahoopsscraper/data/BoxScores/201617.csv", header = T, sep = ',') %>% as.data.frame()
bsdata[[8]] = data.table::fread("~/Programming/ncaahoopsscraper/data/BoxScores/201718.csv", header = T, sep = ',') %>% as.data.frame()
bsdata[[9]] = data.table::fread("~/Programming/ncaahoopsscraper/data/BoxScores/201819.csv", header = T, sep = ',') %>% as.data.frame()

boxscores_total = bind_rows(bsdata) %>% select(-V1) %>% mutate(Date = as.Date(Date, "%B %d, %Y")) %>%
  rename(PCT_3 = "3PT%", PCT_FG = "FG%", PCT_FT = "FT%")

boxscore_home = boxscores_total %>% filter(Role == "Home") %>% select(-Role) %>% rename(AwayTeamName = "Opponent")
colnames(boxscore_home)[c(-1, -3)] = paste0("Home",colnames(boxscore_home)[c(-1, -3)])

boxscore_away = boxscores_total %>% filter(Role == "Away") %>% select(-Role, -Opponent) %>% rename(AwayTeamName = "TeamName")
colnames(boxscore_away)[c(-1, -2)] = paste0("Away",colnames(boxscore_away)[c(-1, -2)])

boxscores_total = boxscore_home %>% inner_join(boxscore_away, by = c("Date", "AwayTeamName"))

save(boxscores_total, file = "boxscores_total.RDA")
