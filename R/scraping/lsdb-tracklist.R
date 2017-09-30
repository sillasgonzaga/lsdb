library(purrr)
library(progress)
library(rvest)
library(tidyverse)
library(stringr)

# pegar da pagina de cada setlist:
# url
# data (retangulo preto)
# artista
# evento
# genero (mais de um se existir)
# length
# tracklist (se houver)


df_sets <- readRDS("data/lsdb_list.Rda")

df_sets %<>% map("result")

df_sets %<>% bind_rows()

vetor.set.url <- df_sets$url %>% unique

vetor.set.url <- paste0("https://lsdb.eu", vetor.set.url)


#ex <- vetor.set.url[1]

#ex <- "https://lsdb.eu/set/193341/waterman-nocturnal-qualifiers-2017-31-07-17" %>% read_html()

# # pegar nome do artista
# ex  %>%
#   html_nodes(".page_liveset > div:nth-child(1) > h1:nth-child(1) > a:nth-child(2)") %>% 
#   html_text(trim = TRUE)
# 
# # evento do liveset
# ex  %>%
#   html_nodes(".page_liveset > div:nth-child(1) > h1:nth-child(1) > a:nth-child(3)") %>% 
#   html_text(trim = TRUE)
# 
# genre.code <- ex %>% 
#   html_nodes("span") %>% 
#   html_attr("class")


extract_tracklist <- function(set.url) {
  # try to read tracklist table from url 
  x <- set.url %>% 
    read_html()
  
  
  # artist name
  artist.name <- x  %>%
    html_nodes(".page_liveset > div:nth-child(1) > h1:nth-child(1) > a:nth-child(2)") %>% 
    html_text(trim = TRUE)
  
  # event
  event <- x  %>%
    html_nodes(".page_liveset > div:nth-child(1) > h1:nth-child(1) > a:nth-child(3)") %>% 
    html_text(trim = TRUE)
  
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
    date = set.date,
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
    df.tracklist <- data.frame(df.tracklist, tracklist = tb[["X2"]])
    # return dataframe
    df.tracklist
  } else {
    # return data frame without tracklist
    df.tracklist$tracklist <- NA
    df.tracklist
  }
}

# iniciar iteracao
n  <- length(vetor.set.url)
safe_extract_tracklist <- safely(extract_tracklist)

system.time({df.tracklist <- vetor.set.url %>% map(safe_extract_tracklist)})
saveRDS(df.tracklist, "data/lsdb_tracklist.Rda")


deu_erro <- df.tracklist %>% transpose %>% .[["error"]] %>% map_lgl(function(x) !is.null(x))

# refazer iteração pra quem deu erro
vetor.erro <- vetor.set.url[deu_erro]
df2 <- vetor.erro %>% map(safe_extract_tracklist)

##### verificar erros
saveRDS(df2, "data/lsdb_tracklist2.Rda")


deu_erro2 <- df2 %>% transpose %>% .[["error"]] %>% map_lgl(function(x) !is.null(x))



df2 <- df.tracklist
df2 <- df2 %>% transpose %>% .[["result"]] %>% bind_rows

# extract artist and name of song
df2 <- df2 %>% separate_rows


# 
# df.tracklist <- map(vetor.set.url, ~{
#   barra$tick()
#   safe_extract_tracklist(.x)
# })








cnt <- 0

df.tracklist <- vector("list", length = n)

for (i in 1:n) {
  df.tracklist[[i]] <- extract_tracklist(vetor.set.url[i])
  
  # mostrador contador
  left <- n - i
  
  show(sprintf("Faltam %s loops", left))
}

