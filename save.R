library(RPostgreSQL)
library(rtweet)

drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv,
                 dbname = Sys.getenv("ELEPHANT_SQL_DBNAME"), 
                 host = Sys.getenv("ELEPHANT_SQL_HOST"),
                 port = 5432,
                 user = Sys.getenv("ELEPHANT_SQL_USER"),
                 password = Sys.getenv("ELEPHANT_SQL_PASSWORD")
)

# Memanggil Tabel, untuk membuat Primary Key nya berurutan.
query2 <- '
SELECT * FROM "public"."INFOGRAPHIC"
'
data <- dbGetQuery(con, query2)

library(rvest)

# membaca environment variabel
twitter_token <- rtweet::rtweet_bot(
  api_key =    Sys.getenv("TWITTER_CONSUMER_API_KEY"),
  api_secret = Sys.getenv("TWITTER_CONSUMER_API_SECRET"),
  access_token =    Sys.getenv("TWITTER_ACCESS_TOKEN"),
  access_secret =   Sys.getenv("TWITTER_ACCESS_TOKEN_SECRET")
)

# Konten yang akan di-posting
# Spesifikasi URL dari website yang akan diambil informasinya
url <- 'https://dailyinfographic.com/'

#Membaca html dari website
webpage <- read_html(url)

title <- html_nodes(webpage,'h1>a') %>% 
  html_attr("title")
title

category <- html_nodes(webpage,'.des>.cat>a') %>% 
  html_text("a")
category

#link selengkapnya
library(urlshorteneR)
link <- html_nodes(webpage,'h1>a')%>%
  html_attr("href")

bitly_shorten_link(
  domain = "bit.ly",
  group_guid = "o_3kviv9q8nt",
  long_url = link,
  showRequestURL = TRUE
)

shorten <- bitly_shorten_link(long_url = link, showRequestURL = TRUE)
short_link <- as.character(shorten$id)
short_link

baris <- nrow(data)
baris
data <- data.frame(No = baris+1,
                   Tanggal = Sys.Date(),
                   Judul = title,
                   Kategori = category,
                   Tautan = short_link)

dbWriteTable(conn = con, name = "INFOGRAPHIC", value = data, append = TRUE, row.names = FALSE, overwrite=FALSE)

on.exit(dbDisconnect(con))
