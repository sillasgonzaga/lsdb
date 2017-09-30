source("setup.R")
source("R/funcoes/01-extract_set_data.R")
source("R/funcoes/02-extract_sets_from_page.R")

df <- extract_sets_from_page(15)
# convert columns types
df$set.date %<>% as.Date()
df$upload.date %<>% ymd_hms()
df$length %<>% str_sub(1, 8)
df$length %<>% hms()
# replace dots in colnames
names(df) <- str_replace_all(names(df), "\\.", "_")

# upload it to bigquery
proj <- "hardstyle-181514"
dataset <- "LSDB"
table <- "TB_LSDB_SETS_DATA"
x <- head(df)
insert_upload_job(proj, dataset, table, values = x)

# chec