import tweepy
import unicodecsv as csv

# consumer keys and access tokens, used for authentication
consumer_key = "0nYkqnwBBBn3EZ6ytFsKYZFWZ"
consumer_secret = "hMkI5O8mfSHVCCiUkq6QPIrMpaIWh5tJZ3N0AmyH6wVCvfe7Gp"
access_token = "283687352-YDmmRLE7tFVArR1g3qjHrAR2AJh4gu8RDWfQDT6N"
access_token_secret = "7R0COiJFYSd5dTTIZDn0TJVvvUsH6bLLSm2gVCFzQFJbX"

number_tweets_to_get = 2500

def initialize():
	"""
	Produces an authenticated API object that can access tweets
	"""
	auth = tweepy.OAuthHandler(consumer_key, consumer_secret)
	auth.set_access_token(access_token, access_token_secret)
	api = tweepy.API(auth)
	return api

def main():
	api = initialize()

	with open("/Users/Monica/Desktop/biol1555_final_project/adderalllog.txt", "r") as logf:
		lastid = logf.readline()

	query = " 'addy OR adderall'"
	#query = " 'addy OR adderall' 'final OR finals OR exam OR exams OR paper OR papers OR college OR library"
	results = tweepy.Cursor(api.search, q=query, since_id=int(lastid), lang='en').items(number_tweets_to_get)
	#results = tweepy.Cursor(api.search, q=query, lang='en').items(number_tweets_to_get)

	with open("/Users/Monica/Desktop/biol1555_final_project/adderalltweets.csv", "ab") as f:
		writer = csv.writer(f, encoding='utf-8')
		"""
		header = ['text', 'created_at', 'id', 'user_screen_name', 'user_location', 'user_time_zone',
		'coordinates', 'retweeted', 'in_reply_to_status_id', 'in_reply_to_user_id']
		writer.writerow(header)
		"""
		ids = []
		for tweet in results:
			writer.writerow([tweet.text, tweet.created_at, tweet.id, tweet.user.screen_name, 
				tweet.user.location, tweet.user.time_zone, tweet.coordinates, tweet.retweeted,
				tweet.in_reply_to_status_id, tweet.in_reply_to_user_id])
			ids.append(tweet.id)
			
	if len(ids) > 0:
		with open("/Users/Monica/Desktop/biol1555_final_project/adderalllog.txt", "r") as origf: 
			temp = origf.read()
		with open("/Users/Monica/Desktop/biol1555_final_project/adderalllog.txt", "w") as modifiedf: 
			modifiedf.write(str(ids[0]) + '\n' + temp)
		

if __name__ == "__main__":
	main()

