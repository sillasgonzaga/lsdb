source("setup.R")
source("R/funcoes/01-extract_set_data.R")
source("R/funcoes/02-extract_sets_from_page.R")
source("R/funcoes/_extract_page.R")

pgs <- 1:last.page

# configure bigquery
#proj <- "hardstyle-181514"
#dset <- "LSDB"
#tb_name <- "TB_LSDB_SETS_DATA"
# token
#token <- readRDS(".httr-oauth")
#set_access_cred(token)
#set_service_token(token)
#set_oauth2.0_cred(token$`161c2c22532513a6d62fcb025cef84b8`$app)

nn <- length(pgs)
for (i in 1:nn){
  message(sprintf("Página %s de %s", i, last.page))
  # while condition to make it keep running until it returns a data frame
  df <- NULL
  attempt <- 1
  max.attempts <- 5
  while( is.null(df) && attempt <= max.attempts) {
    attempt <- attempt + 1
    try(
      df <- extract_sets_from_page(i),
      silent = TRUE
    )
  } 
  # 
  # # convert columns types
  # df$set.date %<>% as.Date()
  # df$upload.date %<>% ymd_hms()
  # df$length %<>% str_sub(1, 8)
  # df$length %<>% hms()
  # # replace dots in colnames
  # names(df) <- str_replace_all(names(df), "\\.", "_")
  # # upload it to bigquery
  # insert_upload_job(proj, dset, tb_name, values = df)
}



# chec