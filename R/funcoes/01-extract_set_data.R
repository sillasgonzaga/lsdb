extract_set_data <- function(set.url) {
  
  # test if url is valid
  url_status <- httr::GET(set.url)$status_code
  if (url_status == 500) return(NULL)
  
  #browser()
  # try to read tracklist table from url 
  x <- set.url %>% 
    read_html()
  
  # extract set id from url
  set.id <- set.url %>% 
    str_replace_all("https://lsdb.eu/set/", "") %>%
    str_replace_all("/.*", "")
  
  # artist name
  artist.name <- x  %>%
    html_nodes(".page_liveset > div:nth-child(1) > h1:nth-child(1) > a:nth-child(2)") %>% 
    html_text(trim = TRUE)
  
  # event
  event <- x  %>%
    html_nodes(".page_liveset > div:nth-child(1) > h1:nth-child(1) > a:nth-child(3)") %>% 
    html_text(trim = TRUE)
  # if event returns an empty character, use another css selector method
  if (length(event) == 0){
    event <- x %>% 
      html_nodes(css = "a:nth-child(4)") %>% 
      html_text()
  }
  
  
  genre.code <- x %>% 
    html_nodes("span") %>% 
    html_attr("class")
  genre.code <- genre.code[str_detect(genre.code, "gt gt")]
  # remove NAs
  genre.code <- genre.code[!is.na(genre.code)]
  # collapse multiple elements into one
  genre.code <- paste0(genre.code, collapse = " _ ")
  
  # data do set
  dates <- x %>% 
    html_nodes("time") %>% 
    html_attr("datetime")
  set.date <- dates[1]
  set.upload.date <- dates[2]
  
  # length
  set.length <- x %>% 
    html_nodes(".set_meta > div:nth-child(1)") %>% 
    html_text() %>% 
    str_split("[\n]") %>% 
    unlist() %>% 
    .[str_detect(., "Length")] %>% 
    str_replace_all("[More info]|Length", "")
  
  # if length is not found, return NA
  if (length(set.length) == 0) {
    set.length <- NA
  } else{
    # if first character is :, remove it
    if (str_sub(set.length, 1, 1) == ":") set.length <- sub("^.", "", set.length)
  }
  
  # rating
  rating <- x %>% 
    html_nodes(".rating_total") %>% 
    html_text() %>% 
    as.numeric()
  
  # create data frame output
  df.tracklist <- data.frame(
    url = set.url,
    set.id = set.id,
    set.date = set.date,
    upload.date = set.upload.date,
    artist = artist.name,
    event = event,
    genre.code = genre.code,
    length = set.length,
    rating = rating,
    #tracklist = tb[["X2"]],
    stringsAsFactors = FALSE
  )
  
  ## tracklist table
  tb <- x %>% 
    html_table() 
  
  # if length(tb) == 0 then an error occured
  if (length(tb) > 0) {
    tb <- tb[[1]]
    df.tracklist <- data.frame(
      df.tracklist,
      tracklist = tb[["X2"]],
      stringsAsFactors = FALSE
    )
    # return dataframe
    df.tracklist
  } else {
    # return data frame without tracklist
    df.tracklist$tracklist <- NA
    df.tracklist
  }
}


