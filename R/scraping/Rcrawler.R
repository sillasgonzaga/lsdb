library(Rcrawler)

# https://lsdb.eu/set/194650/sean-tyas-degenerate-radio-episode-049-15-12-15

Rcrawler("https://lsdb.eu/", no_cores = 4, no_conn = 4, DIR = "crawler",
         urlregexfilter = "*/set/*")