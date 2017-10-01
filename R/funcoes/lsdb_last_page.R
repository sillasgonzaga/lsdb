# Get last page number
lsdb.last.page <- function(){
  library(rvest)
  library(readr)
  
  "https://lsdb.eu/livesets" %>% 
  read_html() %>% 
  html_node("div.row:nth-child(3) > div:nth-child(1) > ul:nth-child(1) > li:nth-child(11) > a:nth-child(1)") %>% 
  html_text() %>% 
  parse_number()
}