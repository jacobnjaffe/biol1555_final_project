#!/usr/bin/env julia

#Pkg.add("DataFrames")
#Pkg.add("TextAnalysis")
#Pkg.add("Clustering")
#Pkg.add("Vega")

using TextAnalysis
using DataFrames
using Clustering
using Vega

"""
Cleans tweets: makes text lowercase, removes stop words, removes extra whitespace,
remove query terms and extra stop words

Input: list of unclean tweets
Output: list of clean tweets
"""
function cleaning(tweets)
  clean_tweets = []
  for tweet in tweets
    tweet = lowercase(tweet)
    sd = StringDocument(tweet)
    remove_stop_words!(sd)
    tweet = sd.text
    tweet = replace(tweet, r"\d", " ") #remove digits
    tweet = strip(tweet) #remove leading or trailing whitespace
    tweet = replace(tweet, r" +", " ") #remove further extra whitespace
    tweet = replace(tweet, "#", " ") #remove hashtags

    # for gmos
    to_remove = ["genetically", "modify", "genetic", "modified", "modifies", "gmos", "nongmo",
     "engineers", "engineering", "engineered",  "gms", "gmo", "gm", "engineer",
     "rt", "im", "dont", "cant", "ive", "via"]
    new_tweet = []
    for word in split(tweet)
      if in(word, to_remove) == false
        push!(new_tweet, word)
      end
    end
    new_tweet = join(new_tweet, " ")
    push!(clean_tweets, new_tweet)
  end
  return clean_tweets
end


"""
Calculates unigram frequencies
Step1: creates single string of text from set of tweets (no repeats)
Step2: calculates unigram frequencies

Input: set of tweets (should be clean)
Output: array of (unigram, frequency) pairs
"""
function unigram_freq(tweet_set)
  string = " "
  for tweet in tweet_set
    string = string * tweet * " "
  end
  sd = StringDocument(string)
  unigrams = ngrams(sd, 1)
  sorted_unigrams = sort(collect(unigrams), by = tuple -> last(tuple), rev=true)
  return sorted_unigrams
end


"""
For K-means clustering
Step1: creates a corpus of tweets (one tweet = one document)
Step2: creates a document-term matrix and a TF-IDF matrix
Step3: runs k-means on the TF-IDF matrix

Input: list of tweets (should be clean)
Output: list of tweets' cluster assignments
"""
function cluster(tweets)
  # creates corpus of tweets
  tweet_doc_list = []
  for tweet in tweets
    sd = StringDocument(tweet)
    push!(tweet_doc_list, sd)
  end
  crps = Corpus(tweet_doc_list)

  wc = wordcloud(x = crps)
  colorscheme!(wc, palette = ("Spectral", 11))

  update_lexicon!(crps)

  # creates document-term matrix and TF-IDF matrix
  m = DocumentTermMatrix(crps)
  D = dtm(m, :dense)
  T = tf_idf(D)
  T_transpose = transpose(T)
  println(size(T_transpose))

  # k-means
  results = kmeans(T_transpose, 5)
  println(results.counts) #prints size of each cluster
  return results.assignments

end


"""
Step1: reads in data
Step2: cleans tweets
Step3: runs k-means
Step4: determines most common words in each cluster
"""
function main()
  df = readtable("adderall_march6.csv")
  deleterows!(df, find(isna(df[:text])))
  deleterows!(df, find(isna(df[:user_screen_name])))
  clean_tweets = cleaning(df[:text])
  df[:clean_text] = clean_tweets

  unigrams = unigram_freq(Set(clean_tweets))

  # determines unigrams that occur less than 10 times across the list of tweets
  rare = []
  for unigram in unigrams
    if unigram[2] < 10
      push!(rare, unigram[1])
    end
  end

  # removes these rare unigrams, since they can be considered noise
  clean_tweets2 = []
  num_words = []
  for tweet in clean_tweets
    new_tweet = []
    for word in split(tweet)
      if in(word, rare) == false
        push!(new_tweet, word)
      end
    end
    push!(clean_tweets2, join(new_tweet, " "))
    push!(num_words, length(new_tweet))
  end
  df[:clean_text2] = clean_tweets2
  df[:num_words] = num_words

  # only retain tweets that have at least 3 words after cleaning
  df = df[df[:num_words] .> 3, :]

  # cluster the clean text
  clusters = cluster(df[:clean_text2])
  df[:clusters] = clusters

  # print out the most common words associated with each cluster
  df = sort!(df, cols = [:clusters])
  for i = 1:5
    println(i)
    text_set = Set(df[df[:clusters] .== i, :text])
    clean_text_set = Set(df[df[:clusters] .== i, :clean_text])
    println(first(text_set)) #print a random tweet assigned to the cluster
    println(unigram_freq(clean_text_set)[1:6])
  end

end

main()
