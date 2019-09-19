library(dplyr)

Lines = read_csv("D:/Users/Kurt/Documents/Programming/ncaahoopsscraper/data/BettingLines201819.csv") %>% select(-X1) %>%
  select(Date, TeamName, OpponentName, Line) %>% as.data.frame()

LinesTeams = select(Lines, TeamName) %>% unique() %>% mutate(label = "Lines")

BoxScores = read_csv("D:/Users/Kurt/Documents/Programming/ncaahoopsscraper/data/BoxScores/201011.csv") %>% select(-X1) %>%
  as.data.frame()

BoxScoresTeams = select(BoxScores, TeamName) %>% unique() %>% mutate(label = "BoxScores")

Combined = rbind(BoxScoresTeams, LinesTeams)

load("~/Programming/project/data/notd1teams.RDA")

Outliers = Combined %>% group_by(TeamName) %>% filter(n() == 1) %>% group_by() %>% mutate(TeamName = as.character(TeamName)) %>% arrange(TeamName) %>%
  filter(!(TeamName %in% notd1teams))

TeamNames = read_csv("~/Programming/project/data/LinesNamesCorrections.csv") %>% as.data.frame() %>% rename(TeamName = LinesNames) %>%
  rename(TeamNames = BoxScoresNames)

OpponentNames = read_csv("~/Programming/project/data/LinesNamesCorrections.csv") %>% as.data.frame() %>% rename(OpponentName = LinesNames) %>%
  rename(OpponentNames = BoxScoresNames)

LinesCorrected = Lines %>% full_join(TeamNames) %>% full_join(OpponentNames) %>% mutate(TeamNameNormalized = ifelse(is.na(TeamNames), TeamName, TeamNames)) %>%
  mutate(OpponentTeamNameNormalized = ifelse(is.na(OpponentNames), OpponentName, OpponentNames)) %>% select(Date, TeamNameNormalized, OpponentTeamNameNormalized, Line) %>%
  rename(TeamName = TeamNameNormalized, OpponentName = OpponentTeamNameNormalized)

write.csv(LinesCorrected, "~/Programming/project/data/LinesNormalized.csv", row.names = FALSE)
