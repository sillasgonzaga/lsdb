source("setup.R")

lsdb <- "https://lsdb.eu/livesets"
# https://lsdb.eu/livesets.rss



# # using purrr
# df <- 1 %>% extract_page_data()
# 
# # salvar dados
# saveRDS(df, "data/lsdb_pt1.Rda")
# 
# # ver erros
# deu_erro <- transpose(df)[["error"]] %>% map_lgl(function(x) !is.null(x))
# deu_erro <- which(deu_erro == TRUE)
# 
# # refazer loop para os erros
# pages_vector_again <- pages_vector[deu_erro]
# 
# df.again <- vector("list", length(pages_vector_again))
# 
# for (i in 1:length(pages_vector_again)){
#   df.again[[i]] <- safe_extract(pages_vector_again[i])
# }
# 
# 
# # imputar erros na lista
# for (i in 1:length(pages_vector_again)){
#   ind <- deu_erro[i]
#   
#   df[[ind]] <- df.again[[i]]
# }
# 
# saveRDS(df, "data/lsdb_list.Rda")
# 
# 
# 
