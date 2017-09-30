library(tidyverse)
library(magrittr)
library(stringr)
library(lubridate)

# Import data
df.tracklist <- readRDS("data/lsdb_tracklist.Rda")
df.genre <- readRDS("data/genres.Rda")

# give a look at the data
glimpse(df.tracklist)


### fix character variables
df.tracklist %<>% mutate_at(vars(url, artist, tracklist), str_to_lower)

### convert set date to Date class
df.tracklist %<>% mutate(
  date = as.Date(date),
  upload.date = as.Date(ymd_hms(upload.date)),
  length = hms(str_sub(length, 1, 8))
)


### we need to separate the last column into two different ones
df.tracklist <- df.tracklist %>% 
  mutate(tracklist = ifelse(is.na(tracklist), "", tracklist),
         incorrect.syntax = str_count(tracklist, " - ") != 1) %>% 
  separate(tracklist, c("track.artist", "track.name"),
           sep = " - ", remove = FALSE) %>% 
  # keep old column but with different name
  rename(track.info = tracklist)

# see how much data have been lost
df.tracklist %>% 
  filter(!is.na(track.info)) %>% 
  count(incorrect.syntax) %>% 
  mutate(percent = 100 * n/sum(n))
  

# remove badly formatted track info
df.tracklist %<>% filter(!incorrect.syntax)


#### add genre name
# split rows with multiple genres
df.tracklist <- df.tracklist %>% 
  separate_rows(genre.code, sep = " _ ") %>% 
  left_join(df.genre, by = "genre.code")

## see if any join error occured
sum(is.na(df.tracklist$genre.name)) == 0


# everything is cool. let's save it to analyze it.
feather::write_feather(df.tracklist, "data/lsdb_tracklist_cleaned.feather")