
using DataFrames
table = readtable("testfile.txt", separator = '\t')

text = table[:text]

using TextAnalysis 
n_gram_document = NGramDocument("testfile.txt")


sd = StringDocument("testfile.txt")

n_gram_document.tokens

sample = "this is some sample text"


sample = split(sample, r"\s+")
  
tokens = Dict()
  
  for m in 1
    for index in 1:(length(words) - m + 1)
      token = join(words[index:(index + m - 1)], " ")
      if has(tokens, token)
        tokens[token] = tokens[token] + 1
      else
        tokens[token] = 1
      end
    end
  end
  
  tokens
end




