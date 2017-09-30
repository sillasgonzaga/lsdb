library(rvest)
library(tidyverse)
library(stringr)
library(magrittr)

lsdb <- "https://lsdb.eu/livesets"
# https://lsdb.eu/livesets.rss

# create function to extract set data
extract_set_data <- function(lsdb_page) {
  
  show(lsdb_page)
  
  page <- lsdb_page %>% read_html()
  
  # 1: extract date of set (or upload date)
  set.date <- page %>% 
    html_nodes("time") %>% 
    html_attr("datetime") %>% 
    as.Date()
  
  # 2 extract class tag (set genre)
  set.genre <- page %>% 
    html_nodes("span") %>% 
    html_attr("class") %>% 
    extract(str_detect(., "gt") & !is.na(.))
  
  # 3 extract if set has tracklist
  set.has_tracklist <- page %>% 
    html_nodes("i") %>% 
    html_attr("title") %>% 
    extract(!is.na(.))
  
  # remove 'New link requested' from vector
  set.has_tracklist <- set.has_tracklist[set.has_tracklist != "New link requested"]
  
  set.has_tracklist[set.has_tracklist != "No tracklist"] <- TRUE
  set.has_tracklist[set.has_tracklist == "No tracklist"] <- FALSE
  set.has_tracklist %<>% as.logical()
  
  # 4 extract set artist and event
  set.artist_and_event <- page %>% 
    html_nodes("a") %>% 
    html_text() %>% 
    extract(str_detect(., "@")) %>% 
    str_trim() %>% # remove excessive whitespace
    str_sub(start = 30) %>% 
    str_trim() %>% 
    str_split("@")
  set.artist <- set.artist_and_event %>% map(1) %>% str_trim()
  set.event <- set.artist_and_event %>% map(2) %>% str_trim()
  
  # 5 extract sets urls
  set.url <- page %>% 
    html_nodes("a") %>% 
    html_attr("href") %>% 
    extract(str_detect(., "/set/") & !is.na(.))
  
  # return final data.frame
  data.frame(date = set.date, artist = set.artist,
             event = set.event, genre = set.genre,
             has_tracklist = set.has_tracklist, url = set.url,
             stringsAsFactors = FALSE)
  
  #show(lsdb_page)
  
}

# Get last page number
last.page <- "https://lsdb.eu/livesets" %>% 
  read_html() %>% 
  html_node("div.row:nth-child(3) > div:nth-child(1) > ul:nth-child(1) > li:nth-child(11) > a:nth-child(1)") %>% 
  html_text() %>% 
  parse_number()

# create vector of links from page one to last
pages_vector <- paste0("https://lsdb.eu/livesets?page=", 1:last.page)

# using purrr
safe_extract <- safely(extract_set_data)
df <- pages_vector %>% map(safe_extract)


# apply function to all pages
# df <- vector("list", length = length(pages_vector))
# system.time({
#   for (i in 1:length(pages_vector)) {
#     message(
#       paste0("Loop ", i, " de ", length(pages_vector))
#       )
#     df_loop <- extract_set_data(pages_vector[i])
#     df[[i]] <- df_loop
#     arquivo <- paste0("lsdb-", str_pad(i, 4, "left", "0"))
#     saveRDS(df_loop)
#   }
# })

# salvar dados
saveRDS(df, "data/lsdb_pt1.Rda")

# ver erros
deu_erro <- transpose(df)[["error"]] %>% map_lgl(function(x) !is.null(x))
deu_erro <- which(deu_erro == TRUE)

# refazer loop para os erros
pages_vector_again <- pages_vector[deu_erro]

df.again <- vector("list", length(pages_vector_again))

for (i in 1:length(pages_vector_again)){
  df.again[[i]] <- safe_extract(pages_vector_again[i])
}


# imputar erros na lista
for (i in 1:length(pages_vector_again)){
  ind <- deu_erro[i]
  
  df[[ind]] <- df.again[[i]]
}

saveRDS(df, "data/lsdb_list.Rda")



