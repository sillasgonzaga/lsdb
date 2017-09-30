library(rvest)
library(tidyverse)
library(magrittr)


url <- "https://lsdb.eu/"

genre.code <- url %>% 
  read_html() %>% 
  html_nodes("div.row_block:nth-child(5)") %>% 
  html_children() %>% 
  html_nodes("span") %>% 
  html_attr("class")

genre.name <- url %>% 
  read_html() %>% 
  html_nodes("div.row_block:nth-child(5)") %>% 
  html_children() %>% 
  html_nodes("a") %>% 
  html_text()

# the last three names are located outside of the table, so it should be discarded
genre.name <- genre.name[1:66]

df.genre <- data.frame(genre.code, genre.name, stringsAsFactors = FALSE)

# save data
saveRDS(df.genre, "data/genres.Rda")


