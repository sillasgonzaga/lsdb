library(tidyverse)
library(magrittr)
library(stringr)

df.genre <- readRDS("data/genres.Rda")
df.sets <- readRDS("data/lsdb_list.Rda")
df.artists <- readRDS("data/lsdb_artist.Rda")

str(df.sets)
# join with genre names
df.sets %<>% rename(genre.code = genre, artist.name = artist)
df.sets %<>% left_join(df.genre, by =  "genre.code")

#### Artists data wranglign
# convert all names to proper case
df.sets$artist.name %<>% str_to_title()
df.artists$artist.name %<>% str_to_title()

# trim characters
df.sets$artist.name %<>% str_trim()
df.sets %<>% left_join(df.artists, by =  "artist.name")

# investigate NAs
df.sets %>% filter(is.na(artist.url)) %$% artist.name %>% unique %>% length
# remove unnecessary columns
df.sets$genre.code <- NULL

############# Data exploration ##############

# Most featured artists on lsdb?
# Most featured event?
# Most featured genre?





# most featured artists on lsdb:
df.sets %>% 
  count(artist) %>% 
  arrange(desc(n))

# most featured event
df.sets %>% 
  count(event) %>% 
  arrange(desc(n))


# most featured genres
df.sets %>% 
  count(genre.name) %>% 
  arrange(desc(n))

# most featured hardstyle events and artists
hs <- "Hardstyle"
df.sets %>% 
  filter(genre.name == hs) %>% 
  count(event) %>% 
  arrange(desc(n))

df.sets %>% 
  filter(genre.name == hs) %>% 
  count(artist) %>% 
  arrange(desc(n))

## ------------------------ TRACKLIST ANALYSIS ---------
df.tracklist <- readRDS("data/lsdb_tracklist.Rda")
# separate into different columns
df.tracklist <- df.tracklist %>% 
  mutate(set.tracklist = ifelse(is.na(set.tracklist), "", set.tracklist),
         incorrect.syntax = str_count(set.tracklist, " - ") != 1) %>% 
  separate(set.tracklist, c("artist.name", "track.name"),
           sep = " - ", remove = FALSE) %>% 
  rename(track.info = set.tracklist)

# remove badly formatted track info
df.tracklist %<>% filter(!incorrect.syntax)

str(df.tracklist)

df.tracklist %>% 
  count(artist.name) %>% 
  arrange(desc(n))



df.tracklist %>% 
  count(artist.name, track.name) %>% 
  arrange(desc(n)) %>% 
  slice(1:30)






