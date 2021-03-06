##### Run the playoffs
## Need to run the season first using run_model.R

source("/Users/kim.larsen/Documents/Code/NBA_RANKINGS/functions/sim_playoffs.R")
library(stringr)
library(stringi)

inwindow <- filter(box_scores_plus, DATE_INDEX<=max_real_date & DATE_INDEX>max_real_date-playing_time_window+1)
thisseason <- filter(inwindow, DATE==max(DATE))[1,"season"]
win_perc1 <- winpercentages(inwindow, thisseason, w)
win_perc2 <- win_perc1

inwindow_active <- mutate(inwindow,
                          today=as.Date(end_date),                        
                          injured=ifelse(is.na(injury_status), 0, ifelse(today>=injury_scrape_date & today<return_date, 1, 0))
)
injured_players <- unique(subset(inwindow_active, injured==1)$PLAYER_FULL_NAME)
if (length(injured_players)>0){
  print(paste0("Injuries: ", injured_players))
  inwindow_active <- filter(inwindow_active, injured==0)
}

combine <- function(x, ...) {
  lapply(seq_along(x),
         function(i) c(x[[i]], lapply(list(...), function(y) y[[i]])))
}

ncore <- detectCores()-1
registerDoParallel(ncore)
sims <- 100
loopResult <- foreach(i=1:sims, .combine='combine', .multicombine=TRUE,
                      .init=list(list(), list())) %dopar% {
  playoffs <- sim_playoff(results[[2]], inwindow_active, playing_time_window, win_perc1, win_perc2, datemap, 1, "/Users/kim.larsen/Documents/Code/NBA_RANKINGS", c, max_real_date, thisseason, end_date, seed=1000*i + runif(1)*1000)
  playoffs[[2]]$sim <- i
  return(list(playoffs[[2]], playoffs[[3]]))
}

title_chances <- data.frame(rbindlist(loopResult[[1]])) %>%
  filter(winner != "NONE" & loser != "NONE") %>%
  group_by(round, winner) %>%
  summarise(n=n(), games=mean(game)) %>%
  mutate(perc_wins=n/sims) %>%
  select(-n)

probs <- data.frame(rbindlist(loopResult[[1]])) %>%
  filter(selected_team=="Golden State") %>%
  group_by(round, selected_team) %>%
  summarise(prob=mean(prob_selected_team_win))

probs <- data.frame(rbindlist(loopResult[[1]])) %>%
  filter(selected_team=="Golden State") %>%
  group_by(selected_team) %>%
  summarise(prob=mean(prob_selected_team_win))

View(title_chances)
View(probs)

decomps <- data.frame(rbindlist(loopResult[[2]]))

write.csv(decomps, "/Users/kim.larsen/Documents/Code/NBA_RANKINGS/modeldetails/2017_playoff_decomp.csv", row.names = FALSE)
