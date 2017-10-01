source("setup.R")

token <- readRDS(".httr-oauth")
#set_access_cred(token)
#set_service_token(token)
set_oauth2.0_cred(token$`161c2c22532513a6d62fcb025cef84b8`$app)

# create dataset (it's like a database or DBO)
proj <- "hardstyle-181514"
dset <- "LSDB"
tb_name <- "TB_LSDB_SETS_DATA"
con <- DBI::dbConnect(dbi_driver(), project = proj, dataset = dset)

#insert_dataset(proj, dataset = dataset)
# teste deletar tabela
dbListTables(con)
delete_table(proj, dset, tb_name)
# create table
insert_table(proj, dset, tb_name)
# teste upload tabela
insert_upload_job(proj, dset, tb_name, values = head(df))

# check


tb <- con %>% 
  tbl("TB_LSDB_SETS_DATA") %>%
  collect()

