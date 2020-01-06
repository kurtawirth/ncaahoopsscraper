library(dplyr)

library(readr)

Lines = read_csv("D:/Users/Kurt/Documents/Programming/ncaahoopsscraper/data/BettingLines2010_2019.csv") %>% as.data.frame()

#load("D:/Users/Kurt/Documents/Programming/ncaahoopsscraper/data/BoxScores/boxscores_total.RDA")
#
# BoxScoresTeams = select(BoxScores, TeamName) %>% unique() %>% mutate(label = "BoxScores")
#
# Combined = rbind(BoxScoresTeams, LinesTeams)
#

load("~/Programming/project/data/notd1teams.RDA")

#
# Outliers = Combined %>% group_by(TeamName) %>% filter(n() == 1) %>% group_by() %>% mutate(TeamName = as.character(TeamName)) %>% arrange(TeamName) %>%
#   filter(!(TeamName %in% notd1teams))

load("~/Programming/ncaahoopsscraper/data/BoxScores/advanced_boxscores.RDA")

Away_Outliers = (Lines %>% filter(!(AwayTeamName %in% notd1teams)) %>%
  filter(!(AwayTeamName %in% c(advanced_df2$HomeTeamName, advanced_df2$AwayTeamName))))$AwayTeamName %>%
  unique() %>% sort()

Home_Outliers = (Lines %>% filter(!(HomeTeamName %in% notd1teams)) %>%
  filter(!(HomeTeamName %in% c(advanced_df2$HomeTeamName, advanced_df2$AwayTeamName))))$HomeTeamName %>%
  unique() %>% sort()

teamcombined_edited <- read_csv("~/Programming/project/data/teamcombined_edited.csv") %>% as.data.frame()

normalized_lines = Lines %>% select(-X1) %>%
  left_join(teamcombined_edited, by = c("AwayTeamName" = "LinesNames")) %>%
  rename(AwayTeamName2 = BoxScoresNames) %>% left_join(teamcombined_edited, by = c("HomeTeamName" = "LinesNames")) %>%
  rename(HomeTeamName2 = BoxScoresNames) %>%
  mutate(HomeTeamName = ifelse(!is.na(HomeTeamName2), HomeTeamName2, HomeTeamName)) %>%
  mutate(AwayTeamName = ifelse(!is.na(AwayTeamName2), AwayTeamName2, AwayTeamName)) %>%
  select(-AwayTeamName2, -HomeTeamName2) %>% group_by(Date, HomeTeamName, AwayTeamName) %>%
  slice(1) %>% mutate(MoneyLine = ifelse(MoneyLine == "-", NA, MoneyLine)) %>% mutate(MoneyLine = as.numeric(MoneyLine)) %>%
  mutate(OverUnder = ifelse(OverUnder == "-", NA, OverUnder)) %>% mutate(OverUnder = as.numeric(OverUnder))

write.csv(normalized_lines, "~/Programming/project/data/LinesNormalized.csv", row.names = FALSE)
