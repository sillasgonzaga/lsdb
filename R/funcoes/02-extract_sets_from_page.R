source("setup.R")

# create to function to extract set urls from a given page and extract all set data from that page
extract_sets_from_page <- function(lsdb_page_number){
  browser()
  
  lsdb_page <- paste0("https://lsdb.eu/livesets?page=", lsdb_page_number)
  page <- lsdb_page %>% read_html()
  
  # 5 extract sets urls
  set.url <- page %>% 
    html_nodes("a") %>% 
    html_attr("href") %>% 
    extract(str_detect(., "/set/") & !is.na(.))
  # 6 extract set ID from url
  set.id <- str_replace_all(set.url, "/set/", "") %>% str_replace_all("/.*", "")
  
  # compose url
  set.url <- paste0("https://lsdb.eu", set.url)
  
  # for each of the urls collected, extract set data
  df_tracklist <- set.url %>% map_df(extract_set_data)
  # save data frame as a local file
  
  df_tracklist
}

# exemplo:
# system.time({
#   df_complete <- extract_sets_from_page(1)
# })
