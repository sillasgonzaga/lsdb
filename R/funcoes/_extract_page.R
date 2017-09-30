#### DEPRECATED: DO NOT USE IT


# create function to extract page data
extract_page_data <- function(lsdb_page_number) {
  browser()
  # create vector of links from page one to last
  #pages_vector <- paste0("https://lsdb.eu/livesets?page=", 1:last.page)
  lsdb_page <- paste0("https://lsdb.eu/livesets?page=", lsdb_page_number)
  
  
  #show(lsdb_page)
  
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
  # 6 extract set ID from url
  set.id <- str_replace_all(myurl, "/set/", "") %>% str_replace_all("/.*", "")
  
  # compose url
  set.url <- paste0("https://lsdb.eu", set.url)
  
  # extract tracklist data
  df_tracklist <- set.url %>% map_df(extract_set_data)
  
  
  # return page dataframe
  df_page <- data.frame(
    #  set.date = set.date,
    set.id = set.id,
    artist = set.artist,
    event = set.event,
    genre = set.genre,
    has_tracklist = set.has_tracklist,
    url = set.url,
    stringsAsFactors = FALSE)
  
  # join page data with sets data
  df_page <- left_join(df_page, df_tracklist, by = "set.id")
  df_page
  #show(lsdb_page)
  
}

# Get last page number
last.page <- "https://lsdb.eu/livesets" %>% 
  read_html() %>% 
  html_node("div.row:nth-child(3) > div:nth-child(1) > ul:nth-child(1) > li:nth-child(11) > a:nth-child(1)") %>% 
  html_text() %>% 
  parse_number()
