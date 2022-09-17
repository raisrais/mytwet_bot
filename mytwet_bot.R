library(ggplot2)

# Jumlah data yang akan dibangkitkan
n <- 10000

# Memilih sebaran yang akan dibangkitkan
# kita lakukan secara random
# 1 : Normal
# 2 : Exponensial
# 3 : F
dist <- sample(1:3, 1)

# Membangkitkan n data yang menyebar
# sesuai sebaran yang terpilih

if (dist == 1) {
  # membangkitkan nilai mean secara acak
  mean <- runif(1, min=0, max=10)
  # membangkitkan nilai std secara acak
  std <- runif(1, min=1, max=10)
  
  # membangkitkan 10000 data yang menyebar Normal
  # dengan mean dan std tertentu
  data <- rnorm(n, mean=mean, sd = std)
  
} else if(dist == 2) {
  # membangkitkan nilai lambda secara acak
  lambda <- runif(1, min=0.1, max=10)
  
  # membangkitkan 10000 data yang menyebar Exponensial
  # dengan lambda tertentu
  data <- rexp(n, rate=lambda)
  
} else if (dist == 3) {
  # Menentukan derajat bebas penyebut dan pembilang
  # secara acak
  df1 <- sample(1:100, 1)
  df2 <- sample(1:100, 1)
  
  # membangkitkan 10000 data yang menyebar F
  # dengan df1 dan df2 tertentu
  data <- rf(n, df1, df2)
  
}

my.data <- data.frame(data)

rand.color <- function() {
  r <- sample(0:255, 1)
  g <- sample(0:255, 1)
  b <- sample(0:255, 1)
  
  rgb(r, g, b, maxColorValue = 255)
}

# Membuat histogram dengan warna random
plot <- ggplot(data=my.data, aes(x=data)) +
  geom_histogram( color=rand.color(), fill=rand.color(), 
                  position = 'identity', bins=40, lwd=0.1)

# menyimpan plot pada temporary file
histogram_pic <- tempfile( fileext = ".jpeg")
ggsave(histogram_pic, plot = plot, device = "jpeg", 
       dpi = 96, width = 8, height = 8, units = "in" )




library(rtweet)

# membaca environment variabel
twitter_token <- rtweet::rtweet_bot(
  api_key =    Sys.getenv("TWITTER_CONSUMER_API_KEY"),
  api_secret = Sys.getenv("TWITTER_CONSUMER_API_SECRET"),
  access_token =    Sys.getenv("TWITTER_ACCESS_TOKEN"),
  access_secret =   Sys.getenv("TWITTER_ACCESS_TOKEN_SECRET")
)

# Konten yang akan di-posting
if (dist==1) {
  status <- paste("Distribusi Normal(Mean =", mean, ", std =", std, ")\n#SebaranNormal", sep=" ")
} else if(dist==2) {
  status <- paste("Distribusi Eksponensial(lambda =", lambda, ")\n#SebaranEksponensial", sep=" ")
} else if(dist==3){
  status <- paste("Distribusi F(df1=", df1, "df2 =", df2, ")\n#SebaranF", sep=" ")
}

## alt-text description
alt_text <- paste0(
  "Random distribution data generated using R"
)

# Post tweet
rtweet::post_tweet(
  status = status,
  media = histogram_pic,
  media_alt_text = alt_text,
  token = twitter_token
)