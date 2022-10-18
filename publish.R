library(RPostgreSQL)

drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv,
                 dbname = Sys.getenv("ELEPHANT_SQL_DBNAME"), 
                 host = Sys.getenv("ELEPHANT_SQL_HOST"),
                 port = 5432,
                 user = Sys.getenv("ELEPHANT_SQL_USER"),
                 password = Sys.getenv("ELEPHANT_SQL_PASSWORD")
)

query2 <- '
SELECT * FROM "public"."INFOGRAPHIC"
'

data <- dbGetQuery(con, query2)

status_details <- paste0(
  data$Judul[nrow(data)], ".", "\n",
  "Infographic category : ", data$Kategori[nrow(data)], "\n",
  "Please visit ", data$Tautan[nrow(data)], " for detail.",  "\n",
  "\n",
  "#","dailyinfographic"
)

# Publish to Twitter
library(rtweet)

## Create Twitter token
twitter_token <- rtweet::rtweet_bot(
  api_key =    Sys.getenv("TWITTER_CONSUMER_API_KEY"),
  api_secret = Sys.getenv("TWITTER_CONSUMER_API_SECRET"),
  access_token =    Sys.getenv("TWITTER_ACCESS_TOKEN"),
  access_secret =   Sys.getenv("TWITTER_ACCESS_TOKEN_SECRET")
)

## Provide alt-text description
alt_text <- paste0(
  "Daily Infographic | Learn something new everyday"
)

# save the data
dir.create(file.path('data') )
write.csv(data, file.path("data/da_infographic.csv"))

# Post tweet
rtweet::post_tweet(
  status = status_details,
  media = NULL,
  media_alt_text = alt_text,
  token = twitter_token
)

on.exit(dbDisconnect(con))
