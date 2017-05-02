
# coding: utf-8

# In[1]:

import csv
import pandas as pd


# In[2]:

f = open("gmotweets.csv") 


# In[3]:

csv_f = csv.reader(f)


# In[5]:

df = pd.read_csv("gmotweets.csv")




# In[6]:

df.head()


# In[7]:

text = df['text']
   


# In[8]:

import re
text2 = []
for line in text:
    line = re.sub(r'http[^\s]+','', line)
    line = re.sub(r'[^#@\w\s]','', line)
    line = re.sub('https','', line)
    text2.append(line + '\n')
print text2


# In[9]:

for line in text: 
    print line


# In[10]:

se = pd.Series(text2)


# In[11]:

df['text'] = se.values


# In[12]:

df.head()


# In[13]:

df.to_csv("testfile.txt", sep='\t', encoding='utf-8')


# In[ ]:



