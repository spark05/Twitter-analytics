
library(sentiment)
library(plyr)
library(ggplot2)
library(wordcloud)
library(RColorBrewer)
library(tm)
library(Rstem)
library(SnowballC)
getwd()
setwd("F:Project/stm/")
getwd()
###Get the datainstall.packages("C:/sentiment_0.2.tar.gz", repos = NULL, type="source")
data <- readLines("abc.txt") 
df <- data.frame(data)
textdata <- df[df$data, ]
textdata = gsub("[[:punct:]]", "", textdata)
#Next, we remove nonessential characters such as punctuation, numbers, web addresses, etc from the text, before we begin processing the actual words themselves.  The code that follows was partially adapted from Gaston Sanchez in his work with sentiment analysis of Twitter data (Sanchez).

textdata = gsub("[[:punct:]]", "", textdata)
#textdata = gsub("[[:digit:]]", "", textdata)
textdata = gsub("http\\w+", "", textdata)
textdata = gsub("[ \t]{2,}", "", textdata)
textdata = gsub("^\\s+|\\s+$", "", textdata)
try.error = function(x)
{
  y = NA
  try_error = tryCatch(tolower(x), error=function(e) e)
  if (!inherits(try_error, "error"))
    y = tolower(x)
  return(y)
}
textdata = sapply(textdata, try.error)
textdata = textdata[!is.na(textdata)]
names(textdata) = NULL
#Next, we perform the sentiment analysis, classifying comments using a Bayesian analysis.  A polarity of positive, negative, or neutral is determined.  Finally, the comment, emotion, and polarity are combined in a single dataframe.


class_pol = classify_polarity(textdata, algorithm="bayes")
polarity = class_pol[,4]


sent_df = data.frame(text=textdata,polarity=polarity, stringsAsFactors=FALSE)
#sent_df = within(sent_df,emotion <- factor(emotion, levels=names(sort(table(emotion), decreasing=TRUE))))
#Now that we have processed the comments, we can graph the emotions and polarities.
sent_df
write.csv(sent_df, "abc.csv", row.names=FALSE)
ggplot(sent_df, aes(x=emotion)) +
  geom_bar(aes(y=..count.., fill=emotion)) +
  scale_fill_brewer(palette="Dark2") +
  labs(x="emotion categories", y="")
emotion
#distribution
ggplot(sent_df, aes(x=polarity)) +
  geom_bar(aes(y=..count.., fill=polarity)) +
  scale_fill_brewer(palette="RdGy") +
  labs(x="polarity categories", y="")
polarity

#We now prepare the data for creating a word cloud.  This includes removing common English stop words.

emos = levels(factor(sent_df$emotion))
nemo = length(emos)
emo.docs = rep("", nemo)
for (i in 1:nemo)
{
  tmp = textdata[emotion == emos[i]]
  emo.docs[i] = paste(tmp, collapse=" ")
}
emo.docs = removeWords(emo.docs, stopwords("english"))
corpus = Corpus(VectorSource(emo.docs))
tdm = TermDocumentMatrix(corpus)
tdm = as.matrix(tdm)
colnames(tdm) = emos
comparison.cloud(tdm, colors = brewer.pal(nemo, "Dark2"),
                 scale = c(3,.5), random.order = FALSE,
                 title.size = 1.5)
sentiment
