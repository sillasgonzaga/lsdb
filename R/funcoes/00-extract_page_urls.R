source("setup.R")

extract_page_urls <- function(lsdb_page_number){
  lsdb_page <- paste0("https://lsdb.eu/livesets?page=", lsdb_page_number)
  page <- lsdb_page %>% read_html()
  
  # extract sets urls
  set.url <- page %>% 
    html_nodes("a") %>% 
    html_attr("href") %>% 
    extract(str_detect(., "/set/") & !is.na(.))
  # 6 extract set ID from url
  
  
  # compose url
  set.url <- paste0("https://lsdb.eu", set.url)
  set.url
}

# 

