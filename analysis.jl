#Pkg.add("DataFrames")
#Pkg.add("TextAnalysis")
using TextAnalysis
using DataFrames

"""
Cleans tweets: makes text lowercase, removes stop words, removes extra whitespace

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
    tweet = replace(tweet, r" +", " ") #remove extra whitespace
    push!(clean_tweets, tweet)
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
Calculates n-gram frequencies
Step1: creates single string of text from set of tweets (no repeats)
Step2: calculates n-gram frequencies

Input: set of tweets (should be clean), integer "n"
Output: sorted array of (n-gram, frequency) pairs
"""
function ngram_freq(tweet_set, n)
  string = " "
  for tweet in tweet_set
    string = string * tweet * " "
  end
  sd = StringDocument(string)
  tweet_ngrams = ngrams(sd, n)
  sorted_ngrams = sort(collect(tweet_ngrams), by = tuple -> last(tuple), rev=true)
  return sorted_ngrams
end


"""
Determines hashtag frequencies

Input: sorted array of (unigram, frequency) pairs
Output: sorted array of (unigram, frequency) pairs, for which all unigrams are hashtags
"""
function top_hashtags(unigram_dict)
  hashtags = []
  for unigram in unigram_dict
    if contains(unigram[1], "#")
      push!(hashtags, unigram)
    end
  end
  return hashtags
end


"""
Determines @ mention frequencies

Input: sorted array of (unigram, frequency) pairs
Output: sorted array of (unigram, frequency) pairs, for which all unigrams are @ mentions
"""
function top_mentions(unigram_dict)
  mentions = []
  for unigram in unigram_dict
    if contains(unigram[1], "@")
      push!(mentions, unigram)
    end
  end
  return mentions
end

"""
Determines total number of unigrams (including repeats)

Input: sorted array of (unigram, frequency) pairs
Output: total frequency
"""
function unigram_count(unigram_dict)
  count = 0
  for unigram in unigram_dict
    count += unigram[2]
  end
  return count
end


"""
LDA
"""
function lda(tweets)
  retweets = Set()
  string = " "
  for tweet in tweets
    if in(tweet, retweets) == false
      string = string * tweet * " "
    end
    if startswith(tweet, "rt")
      push!(retweets, tweet)
    end
  end

  crps = Corpus(Any[StringDocument(string)])
  update_lexicon!(crps)
  m = DocumentTermMatrix(crps)
  tweets_dtm = dtm(m)
  print(lda(tweets_dtm))
end


"""
Determines most frequent users

Input: list of users associated with each tweet
Output: sorted dictionary of (user, frequency) pairs
"""
function user_frequency(users)
  user_freq = Dict()
  for user in users
    if haskey(user_freq, user)
      user_freq[user] += 1
    else
      user_freq[user] = 1
    end
  end
  sorted_dict = sort(collect(user_freq), by = tuple -> last(tuple), rev=true)
  return sorted_dict
end


"""
Determines most frequent retweets

Input: list of tweets
Output: sorted dictionary of (retweet, frequency) pairs
"""
function rt_frequency(tweets)
  tweet_freq = Dict()
  for tweet in tweets
    if contains(tweet, "RT")
      if haskey(tweet_freq, tweet)
        tweet_freq[tweet] += 1
      else
        tweet_freq[tweet] = 1
      end
    end
  end
  sorted_dict = sort(collect(tweet_freq), by = tuple -> last(tuple), rev=true)
  return sorted_dict
end

"""
Determines most frequent tweets (repeats but not RT)

Input: list of tweets
Output: sorted dictionary of (repeat, frequency) pairs
"""
function tweet_frequency(tweets)
  tweet_freq = Dict()
  for tweet in tweets
    if contains(tweet, "RT") == false
      if haskey(tweet_freq, tweet)
        tweet_freq[tweet] += 1
      else
        tweet_freq[tweet] = 1
      end
    end
  end
  sorted_dict = sort(collect(tweet_freq), by = tuple -> last(tuple), rev=true)
  return sorted_dict
end


"""
Reads from text/csv files to return words associated with an emotion
Options: negative, positive, anger, anticip, disgust, fear, joy, sadness, surprise, trust

Input: emotion (as a string)
Output: list of words
"""
function emotion_words(emotion)
  emotion_df = readtable("nrc_emotions.csv")
  words = emotion_df[emotion_df[:sentiment] .== emotion, :word]
  return words
end

"""
Determines frequency of words associated with a certain emotion

Input: array of (unigram, frequency) pairs; emotion (as a string)
Output: array of (unigram, frequency) pairs, only for a given emotion
"""
function emotion_freq(unigram_frequencies, emotion)
  emotion_wordlist = emotion_words(emotion)
  emotion_freqs = []
  for unigram in unigram_frequencies
    if unigram[1] in emotion_wordlist
      push!(emotion_freqs, unigram)
    end
  end
  return emotion_freqs
end


"""
Calculates ratio of positive and negative words

Input: list of tweets (clean)
Output: list of associated sentiment ratings
"""
function posneg_sent(tweets)
  sentiment_ratings = []
  pos_words = emotion_words("positive")
  neg_words = emotion_words("negative")

  for tweet in tweets
    println(tweet)
    pos_count = 0
    neg_count = 0
    for word in split(tweet, " ")
      word = replace(word, "#", "") #includes hashtags in sentiment analysis
      if word in pos_words
        pos_count += 1
      elseif word in neg_words
        neg_count += 1
      end
    end
    if pos_count == 0 && neg_count == 0
      rating = 0
    else
      rating = (pos_count - neg_count) / (pos_count + neg_count)
    end
    println(rating)
    push!(sentiment_ratings, rating)
  end
  return sentiment_ratings
end


function main()
  df = readtable("adderall_march6.csv")
  deleterows!(df, find(isna(df[:text])))
  deleterows!(df, find(isna(df[:user_screen_name])))
  text = df[:text]
  users = df[:user_screen_name]

  """Adds column of clean tweets"""
  clean_tweets = cleaning(text)
  df[:clean_text] = clean_tweets

  """Prints top users"""
  top_users = user_frequency(users)[1:5] #top 5 users
  println(top_users)

  """Prints tweets by top user"""
  top_user = top_users[1][1] #top user_screen_name
  top_user_tweets = df[df[:user_screen_name] .== top_user, :text]
  for tweet in top_user_tweets
    println(tweet)
  end

  """Prints most common RTs"""
  top_rts = rt_frequency(text)[1:5]
  for rt in top_rts
    println(rt)
  end

  """Prints most common non-RT tweets"""
  top_tweets = tweet_frequency(text)[1:5]
  for tweet in top_tweets
    println(tweet)
  end

  """Prints number of unique tweets"""
  println("There are ", length(unique(text)), " unique tweets.")

  """Prints most common unigrams"""
  unigrams = unigram_freq(Set(df[:clean_text]))
  top_unigrams = unigrams[1:20] #top 20
  for unigram in top_unigrams
    println(unigram)
  end

  """Prints most common unigrams, bigrams, and trigrams"""
  top_ngrams = ngram_freq(Set(df[:clean_text]), 3)[1:40]
  for ngram in top_ngrams
    println(ngram)
  end

  """Prints most common hashtags"""
  hashtags = top_hashtags(unigrams)[1:15]
  for hashtag in hashtags
    println(hashtag)
  end

  """Prints most common @ mentions"""
  mentions = top_mentions(unigrams)[1:10]
  for mention in mentions
    println(mention)
  end

  """Prints frequencies of specified terms"""
  #to_search = ["organic", "monsanto"]
  to_search = ["library", "study"]
  for term in to_search
    println(term, " ", Dict(unigrams)[term])
  end

  #print(lda(df[:clean_text])) #LDA not working

  #print(posneg_sent(df[:clean_text])) #perhaps not necessary

  """Prints most common words associated with an emotion"""
  println("Total number of unigrams is ", unigram_count(unigrams))
  println("anger ", emotion_freq(unigrams, "anger")[1:10])
  println("disgust ", emotion_freq(unigrams, "disgust")[1:10])
  println("joy ", emotion_freq(unigrams, "joy")[1:10])
  println("sadness ", emotion_freq(unigrams, "sadness")[1:10])
  println("trust ", emotion_freq(unigrams, "trust")[1:10])
  println("negative ", emotion_freq(unigrams, "negative")[1:10])
  println("positive ", emotion_freq(unigrams, "positive")[1:10])

end

main()
