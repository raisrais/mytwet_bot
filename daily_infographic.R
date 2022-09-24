library(ggplot2)
library(rvest)
library(rtweet)

# membaca environment variabel
twitter_token <- rtweet::rtweet_bot(
  api_key =    Sys.getenv("TWITTER_CONSUMER_API_KEY"),
  api_secret = Sys.getenv("TWITTER_CONSUMER_API_SECRET"),
  access_token =    Sys.getenv("TWITTER_ACCESS_TOKEN"),
  access_secret =   Sys.getenv("TWITTER_ACCESS_TOKEN_SECRET")
)

library(RPostgreSQL)

drv <- dbDriver("PostgreSQL")

con <- dbConnect(drv,
                 dbname = Sys.getenv("ELEPHANT_SQL_DBNAME"), 
                 host = Sys.getenv("ELEPHANT_SQL_HOST"),
                 port = 5432,
                 user = Sys.getenv("ELEPHANT_SQL_USER"),
                 password = Sys.getenv("ELEPHANT_SQL_PASSWORD")
)


# Konten yang akan di-posting
# Specifying the url for desired website to be scraped
url <- 'https://dailyinfographic.com/'

#Reading the HTML code from the website
webpage <- read_html(url)

#Using CSS selectors to scrape the rankings section
title <- html_nodes(webpage,'h1>a') %>% 
  html_attr("title")
title

#deskripsi tema
#desk1 <- html_nodes(webpage,'.home-featured-text')
#desk2 <- html_text(desk1)
#deskripsi <- gsub('\t','',desk2)
#gsub('\n','',deskripsi)

#link selengkapnya
link <- html_nodes(webpage,'h1>a')%>%
  html_attr("href")
link

status_details <- paste0(
  title, "\n",
  link,  "\n",
  "#","dailyinfographic"
)

#images infographic
product <- webpage %>% html_nodes('.main>a')
name <- product %>% html_nodes(css='img') %>% html_attr('alt')
name[2]
imgs <- product %>% html_nodes(css='img') %>% html_attr('src')
link_pict <- imgs[2]
pict <- download.file(link_pict,tempfile(),mode="wb")

## alt-text description
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

on.exit(dbDisconnect(con))