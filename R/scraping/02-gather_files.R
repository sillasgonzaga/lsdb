source("setup.R")

files <- dir("data-raw", pattern = "tracklist-page", full.names = TRUE)

system.time(df_tracklist <- files %>% map(readRDS))

df_tracklist <- bind_rows(df_tracklist)

# save data
df_tracklist %>% saveRDS("data/tracklist-all-pages.Rds")