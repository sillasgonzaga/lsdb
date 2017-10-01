source("setup.R")

# create to function to extract set urls from a given page and extract all set data from that page
extract_sets_from_page <- function(lsdb_page_number){
  
  set.url <- extract_page_urls(lsdb_page_number = lsdb_page_number)
  
  # for each of the urls collected, extract set data
  df_tracklist <- set.url %>% map_df(extract_set_data)
  # save data frame as a local file
  pg_num <- str_pad(lsdb_page_number, width = 4, pad = "0")

  file.name <- sprintf("data-raw/tracklist-page-%s.Rds", pg_num)
  saveRDS(df_tracklist, file.name)
  #df_tracklist
}


# exemplo:
# system.time({
#   df_complete <- extract_sets_from_page(1)
# })

