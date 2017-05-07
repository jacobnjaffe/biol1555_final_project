import csv
import pandas as pd
import re

df = pd.read_csv("adderall_march6_unclean.csv", encoding = "ISO-8859-1")

#remove tweets whose screen name includes "addy"
df = df[df['user_screen_name'].str.lower().str.contains('addy') == False]

text = df['text']

text2 = []
for line in text:
	line = re.sub(r'[^\x00-\x7f]','', line)  #remove none-unicode characters
	line = re.sub(r'http[^\s]+','', line) #remove urls
	line = re.sub(r'[^#@\w\s]','', line) #remove special characters except for # and @
	line = re.sub(r'_', '', line)
	line = re.sub('amp','and', line)
	line = line.replace('\n', ' ')
	line = line.replace('\r', ' ')
	line = line.rstrip()
	text2.append(line)
se = pd.Series(text2)
df['text'] = se.values

#splits tweets based on term
df_adderall = df[df['text'].str.lower().str.contains('adderall') == True]
df_addy = df[df['text'].str.lower().str.contains('addy') == True]

#combines the two
df_full = pd.concat([df_addy, df_adderall])

df_full.to_csv("adderall_full_march6.csv", index=False, encoding='utf-8')
df_addy.to_csv("addy_march6.csv", index=False, encoding='utf-8')
df_adderall.to_csv("adderall_march6.csv", index=False, encoding='utf-8')
