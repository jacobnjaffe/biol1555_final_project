import tweepy
import unicodecsv as csv

# consumer keys and access tokens, used for authentication
consumer_key = 'blFkAPSLfrrMhUzEFc7fBdcHU'
consumer_secret = 'dmw3B223DGAvlsdeWxrydpWZOY9lXrEfWSGdC0mRPt4ziwh3EP'
access_token = '848994112367980546-cq9ikLPZys0oOgsxe4nalro7pXGW6Mq'
access_token_secret = 'P2ihQQbt7OY6EOaZFInbgEwXViNuFy4oumD9vcywByFax'

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

	with open("/Users/Monica/Desktop/biol1555_final_project/gmolog.txt", "r") as logf:
		lastid = logf.readline()

	query = '"genetically modified" OR "genetically modify" OR gmo OR nongmo OR  \
		"genetic engineer" OR "genetic engineering" OR "genetically engineered" OR \
		"gm crops" OR "gm crop" OR "gm organism"'
	results = tweepy.Cursor(api.search, q=query, since_id=int(lastid), lang='en').items(number_tweets_to_get)

	with open("/Users/Monica/Desktop/biol1555_final_project/gmotweets.csv", "ab") as f:
		writer = csv.writer(f, encoding='utf-8')
		#header = ['text', 'created_at', 'id', 'user_screen_name', 'user_location', 'user_time_zone',
		#'coordinates', 'retweeted', 'in_reply_to_status_id', 'in_reply_to_user_id']
		#writer.writerow(header)

		ids = []
		for tweet in results:
			writer.writerow([tweet.text, tweet.created_at, tweet.id, tweet.user.screen_name, 
				tweet.user.location, tweet.user.time_zone, tweet.coordinates, tweet.retweeted,
				tweet.in_reply_to_status_id, tweet.in_reply_to_user_id])
			ids.append(tweet.id)

	if len(ids) > 0:
		with open("/Users/Monica/Desktop/biol1555_final_project/gmolog.txt", "r") as origf: 
			temp = origf.read()
		with open("/Users/Monica/Desktop/biol1555_final_project/gmolog.txt", "w") as modifiedf: 
			modifiedf.write(str(ids[0]) + '\n' + temp)
		

if __name__ == "__main__":
	main()

