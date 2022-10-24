library(rvest)
library(rtweet)
library(urlshorteneR)
library(RPostgreSQL)

# Membaca environment variabel
twitter_token <- rtweet::rtweet_bot(
  api_key =    Sys.getenv("TWITTER_CONSUMER_API_KEY"),
  api_secret = Sys.getenv("TWITTER_CONSUMER_API_SECRET"),
  access_token =    Sys.getenv("TWITTER_ACCESS_TOKEN"),
  access_secret =   Sys.getenv("TWITTER_ACCESS_TOKEN_SECRET")
)

# Konten yang akan di-posting
url <- 'https://dailyinfographic.com/'

webpage <- read_html(url)

title <- html_nodes(webpage,'h1>a') %>% 
  html_attr("title")

category <- html_nodes(webpage,'.des>.cat>a') %>% 
  html_text("a")

link <- html_nodes(webpage,'h1>a')%>%
  html_attr("href")

shorten <- bitly_shorten_link(domain = "bit.ly", group_guid = NULL, long_url = link, showRequestURL = TRUE)
short_link <- as.character(shorten$id)

drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv,
                 dbname = Sys.getenv("ELEPHANT_SQL_DBNAME"), 
                 host = Sys.getenv("ELEPHANT_SQL_HOST"),
                 port = 5432,
                 user = Sys.getenv("ELEPHANT_SQL_USER"),
                 password = Sys.getenv("ELEPHANT_SQL_PASSWORD")
)

query2 <- '
SELECT * FROM "public"."INFOGRAPHIC" ORDER BY "No" ASC;
'

data <- dbGetQuery(con, query2)
baris <- nrow(data)

## Mengecek, menyimpan dan memposting infografis baru yang ditambahkan oleh website https://dailyinfographic.com/ pada tanggal hari ini.
if (data$Judul[nrow(data)] != title)
  {
  data <- data.frame(No = baris+1,
                     Tanggal = Sys.Date(),
                     Judul = title,
                     Kategori = category,
                     Tautan = short_link)
  
  dbWriteTable(conn = con, name = "INFOGRAPHIC", value = data, append = TRUE, row.names = FALSE, overwrite=FALSE)
  
  data <- dbGetQuery(con, query2)
  
  status_details <- paste0(
    data$Judul[nrow(data)], ".", "\n",
    "Infographic category : ", data$Kategori[nrow(data)], "\n",
    "Please visit ", data$Tautan[nrow(data)], " for detail.",  "\n",
    "\n",
    "#","dailyinfographic"
  )
  
  ## Provide alt-text description
  alt_text <- paste0(
    "Daily Infographic | Learn something new everyday"
  )
  
  # Post tweet
  rtweet::post_tweet(
    status = status_details,
    media = NULL,
    media_alt_text = alt_text,
    token = twitter_token
    )
}


## Mengecek, menyimpan dan memposting infografis baru yang ditambahkan oleh website https://dailyinfographic.com/ sebelum tanggal hari ini.
title_cek <- html_nodes(webpage,'.daily>.clearfix>.block>h3>a') %>% 
  html_text("class")

categ_cek <- html_nodes(webpage,'.daily>.clearfix>.block>.author>.cat>a') %>% 
  html_text("class")

link_cek <- html_nodes(webpage,'.daily>.clearfix>.block>a') %>% 
  html_attr("href")

for (i in 1:12){
  data <- dbGetQuery(con, query2)
  if (title_cek[i] %in% data$Judul){
    print(" Sudah ada")
  } else {
    title <- title_cek[i]
    
    category <- categ_cek[i]
    
    shorten_cek <- bitly_shorten_link(domain = "bit.ly", group_guid = NULL, long_url = link_cek[i], showRequestURL = TRUE)
    short_link_cek <- as.character(shorten_cek$id)
    
    baris <- nrow(data)
    data <- data.frame(No = baris+1,
                       Tanggal = Sys.Date(),
                       Judul = title_cek[i],
                       Kategori = categ_cek[i],
                       Tautan = short_link_cek)
    
    dbWriteTable(conn = con, name = "INFOGRAPHIC", value = data, append = TRUE, row.names = FALSE, overwrite=FALSE)
    
    data <- dbGetQuery(con, query2)
    
    status_details <- paste0(
      data$Judul[nrow(data)], ".", "\n",
      "Infographic category : ", data$Kategori[nrow(data)], "\n",
      "Please visit ", data$Tautan[nrow(data)], " for detail.",  "\n",
      "\n",
      "#","dailyinfographic"
    )
    
    ## Provide alt-text description
    alt_text <- paste0(
      "Daily Infographic | Learn something new everyday"
    )
    
    # Post tweet
    rtweet::post_tweet(
      status = status_details,
      media = NULL,
      media_alt_text = alt_text,
      token = twitter_token
    )
  }
}

# save the data
data <- dbGetQuery(con, query2)
dir.create(file.path('data') )
write.csv(data, file.path("data/da_infographic.csv"))

on.exit(dbDisconnect(con))
