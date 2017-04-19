The Winner of the 2017 NBA Playoffs is... The Golden State Warriors!
====================================================================

As we all know, the 2017 NBA playoffs kicked off last weekend. But what you didn't know is that I've attempted to predict the outcome by running the qualifying teams through playoff tree using the [Elastic NBA Ratings](https://github.com/klarsen1/NBA_RANKINGS).

Let's get straight to the key results:

-   First, a not-so-controversial prediction: The Golden State Warriors will reclaim the title this year. They won in every single simulation, barely losing any games along the way.
-   More interestingly, however, is that the model picks the Boston Celtics as Golden State's opponent in the finals.
-   Also, the model favors the Spurs over Houston to advance to the Western Conference Finals.

Obviously, this is just a model, and many things can happen between now and the finals and the style of play is different in the playoffs. But, barring any serious injuries, I feel confident that the Golden State will take the title this year. I feel less confident, however, that Boston will advance past the Cavs -- especially considering that they're down two games to Chicago -- and I also doubt that San Antonio will beat Houston.

About the Simulations
=====================

-   No data from the 2017 playoffs were used to make the predictions. Only regular season data were used.
-   Simulated each game in the playoff tree. For each game, the minutes played by each player were varied randomly, where the level of variation was based on historical data for the 2016-2017 season.
-   I seemed to get very similar answers whether I simulated the playoffs 100 or 1,000 times.
-   All injury information is current.
-   The results described in the following section reflect the most commonly occurring outcomes.

Should We Trust the Model?
==========================

First of all, we should never completely trust any statistical model. Model predictions should always be combined with a healthy dose of skepticism and common sense.

One way to build trust in a model is to look at model accuracy through back-testing. Common sense still needs to be applied, but this is a place to start. One can argue that model accuracy is a necessary, but not sufficient condition, for a model to be useful and trustworthy.

When I first did a [backtest](https://github.com/klarsen1/NBA_RANKINGS) of the Elastic Rankings, the accuracy was around 66%. For the first half of the 2016-2017 season, the one-week-ahead accuracy was 63%. This was computed by comparing the predictions stored every Sunday to the games during the following week, from the beginning of December to the end of February. Part of the decline in accuracy is due to the fact that the beginning of the season is harder to predict, part of of it is due to reasons that I have not dug into.

Breaking Down the Predictions
=============================

Let's say, for now, that we trust the model. The next questions are then: why does model favor the Warriors in every simulation? What's the big deal about Boston and how can San Antonio possibly beat the Rockets in a seven game series?

The answer these questions, we can decompose the playoff predictions across all simulations.

Decomposing Predictions into Three Parts
----------------------------------------

As described in the [readme file](https://github.com/klarsen1/NBA_RANKINGS), we can decompose the predictions from the Elastic model into three parts:

-   Roster -- archetype allocation deficits/surpluses. These are the variables labeled "share\_minutes\_cluster\_XX" described above. This group of variables reflects the quality of the roster.
-   Performance -- e.g., win percentages, previous match-ups.
-   Circumstances -- e.g., travel, rest, home-court advantage

The decomposition essentially takes advantage of the fact that the model is additive in the log-odds scale to break down the prediction contributions. The code below plots the playoff predictions for all 100 simulations:

``` r
library(tidyr)
library(dplyr)
library(knitr)
library(ggplot2)

f <-
  "https://raw.githubusercontent.com/klarsen1/NBA_RANKINGS/master/modeldetails/2017_playoff_decomp.CSV"
 
center <- function(x){return(x-median(x))}
read.csv(f, stringsAsFactors = FALSE) %>%
  select(selected_team, roster, circumstances, performance) %>%
  group_by(selected_team) %>%
  #inner_join(qualifiers, by="selected_team") %>%
  summarise_each(funs(mean)) %>% ## get averages across games by team
  ungroup() %>%
  mutate_each(funs(center), which(sapply(., is.numeric))) %>% ## standardize across teams
  gather(modelpart, value, roster:performance) %>% ## transpose
  rename(team=selected_team) %>%
  ggplot(aes(team, value)) + geom_bar(aes(fill=modelpart), stat="identity") + coord_flip() +
  xlab("") + ylab("") + theme(legend.title = element_blank())
```

![](playoffs_2017_files/figure-markdown_github/unnamed-chunk-1-1.png)

### So What Does this Chart Mean?

The bars show the contribution from each part of the model. Longer, more positive bars means that the team is stronger in that category compared to their playoff competitors, and vice versa for negative bars. Some interesting observations from this chart:

-   The red bars show that circumstances -- e.g., traveling -- does not matter much in the playoffs.
-   Golden state gets the highest score both in terms of performance (weighted winning percentage) and relative quality of the roster (surplus of stronger player archetypes). See the readme file for more details on this metrics.
-   The model impressed by San Antonio's ability to beat teams, but not impressed by its roster.
-   The model favors Boston over Cleveland due to Cleveland's recent poor performance (illustrated by the green bars). Cleveland does well in terms of the quality and diversity of the roster, but not in terms of performance. But we all know that this can change in the playoffs.
-   It seems like the model is picking home-court advantage and winning history over roster quality in the San Antonio match-up.

Last Words
----------

The only thing I know is that all models are wrong. Having said that, as stated in the intro, I feel confident that Golden State will reclaim the trophy this year -- barring any serious injuries. It seems like a safe prediction and the model seems to agree.

As mentioned above, we always need to skeptical of models. Often, we must intervene because we know something the model doesn't know. For example, despite what the model says, I think (and hope) we'll see a match-up against Cleveland -- the recent performance we've seen from Cleveland is not indicative of what they can do in the playoffs.