library(tidyverse)
library(magrittr)
library(stringr)

df <- feather::read_feather("data/lsdb_tracklist_cleaned.feather")


## Perguntas:
# 1  Diversity: which artists play more unique songs? which plays more repeated ones?
# Length: which artist is more lengthy?
# Rank livesets by year
# Tribute: which artists play more songs from other artists? Which one is more self-entitled? What is the average?
# Which music / artist is the most played by year?o 
# Which is the most popular music on Defqon or Qlimax?

# 1
temp <- df %>% 
  distinct(url, artist, track.name, track.artist) %>%
  mutate(same_artist = ifelse(artist == track.artist, 1, 0)) %>% 
  group_by(artist) %>% 
  summarise(media = mean(same_artist)) %>% 
  arrange(desc(media))

# top 10 most popular hardstyle artists
top.hs <- df %>% 
  filter(genre.name == "Hardstyle") %>% 
  count(track.artist) %>% 
  arrange(desc(n))

top.hs <- top.hs$track.artist[1:20]



featured.artists <- c(
  "coone", "frontliner", "gunz for hire", "dj isaac", "audiofreq", "wasted penguinz",
  "da tweekaz", "code black", "wildstylez", "noisecontrollers", "headhunterz",
  "max enforcer"
)

featured <- temp %>% filter(artist %in% top.hs)

temp %>%
  filter(media > 0 & media < 1) %>% 
  ggplot(aes(x = media)) + 
    geom_histogram(breaks = seq(0, 1, 0.10)) +
    geom_vline(data = featured, aes(xintercept = media)) + 
    geom_text_repel(data = featured, aes(x = media, label = artist), y = 200, angle = 90) + 
    scale_x_continuous(breaks = seq(0, 1, 0.10))

library(ggthemes)

temp <- df %>% 
  distinct(url, artist, track.name, track.artist) %>%
  mutate(same_artist = ifelse(artist == track.artist, 1, 0)) %>% 
  filter(str_detect(artist, "Gunz"))
  






df %>% 
  distinct(url, track.info) %>% 
  filter(str_detect(url, "qlimax")) %>% 
  count(track.info) %>% 
  arrange(desc(n))

df %>% 
  filter(str_detect(url, "defqon1-2017"), str_detect(tracklist, "Victory Forever")) %>% 
  View()

df %>% 
  filter(str_detect(url, "qlimax"), str_detect(tracklist, "God Complex")) %>% View 
  

  