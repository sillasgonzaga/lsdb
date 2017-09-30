source("setup.R")

# create dataset (it's like a database or DBO)
proj <- "hardstyle-181514"
dataset <- "LSDB"
table <- "TB_LSDB_SETS_DATA"
insert_dataset(proj, dataset = dataset)
# create table
insert_table(proj, dataset, table)


# check
con <- DBI::dbConnect(dbi_driver(), project = proj, dataset = dataset)

tb <- con %>% 
  tbl("TB_LSDB_SETS_DATA")