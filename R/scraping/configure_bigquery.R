source("setup.R")

# create dataset (it's like a database or DBO)
proj <- "hardstyle-181514"
dset <- "LSDB"
tb_name <- "TB_LSDB_SETS_DATA"
insert_dataset(proj, dataset = dataset)
# create table
insert_table(proj, dset, tb_name)

# teste deletar tabela
delete_table(proj, dset, tb_name)
# teste upload tabela
insert_upload_job(proj, dset, tb_name, values = head(df))

# check
con <- DBI::dbConnect(dbi_driver(), project = proj, dataset = dataset)

tb <- con %>% 
  tbl("TB_LSDB_SETS_DATA") %>%
  collect()

