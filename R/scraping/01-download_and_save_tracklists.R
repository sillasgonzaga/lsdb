source("setup.R")
source("R/funcoes/00-extract_page_urls.R")
source("R/funcoes/01-extract_set_data.R")
source("R/funcoes/02-extract_sets_from_page.R")
source("R/funcoes/_extract_page.R")

pgs <- 1:last.page

nn <- length(pgs)
for (i in 1:nn){
  message(sprintf("Página %s de %s", i, last.page))
  # while condition to make it keep running until it returns a data frame
  df <- NULL
  attempt <- 1
  max.attempts <- 20
  max.attempts <- 5
  while( is.null(df) && attempt <= max.attempts) {
    attempt <- attempt + 1
    try(
      df <- extract_sets_from_page(i),
      silent = FALSE
    )
  } 
}


