library(rvest)
library(tidyverse)

extract_artist <- function(number) {
  show(number)
  url <- sprintf("https://lsdb.eu/artists/view/%s/", number)
  # see if page exists
  source.code <- try({url %>% read_html()}, silent = TRUE)
  if (inherits(source.code, "try-error")) return(data.frame())
  
  artist.name <- source.code %>% 
    html_nodes(".large-12 > h1:nth-child(2)") %>% 
    html_text(trim = TRUE)
  data.frame(artist.url = url, artist.name)
}
# test:
extract_artist(225)
extract_artist(226)
id.vector <- 1:1e5

df.artist <- id.vector %>%  map_df(extract_artist)

saveRDS(df.artist, "data/lsdb_artist.Rda")
