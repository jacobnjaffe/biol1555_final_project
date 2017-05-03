#!/usr/bin/julia

using DataFrames
using TextAnalysis

table = readtable("testfile.txt", separator = '\t')

text = table[:text]

# Create big string to then look at each tweet
string = ""
space = " "
for i in text   
    string = string * i 
    string = string * space
end


# Cleaning data
sd = StringDocument(string)
remove_case!(sd)
remove_punctuation!(sd)
remove_indefinite_articles!(sd)
remove_definite_articles!(sd)
remove_prepositions!(sd)
remove_pronouns!(sd)


# making unigrams
n = ngrams(sd)
n_sorted = sort(collect(n), by = tuple -> last(tuple), rev=true)[1:20] #get first 20 entries
@show n_sorted


# make bigrams (i dont think this works lolz) 
n = ngrams(sd,2)
n_sorted_2 = sort(collect(n), by = tuple -> last(tuple), rev=true)[1:20] #get first 20 entries
@show n_sorted_2

# make a corpus
