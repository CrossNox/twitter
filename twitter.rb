require 'twitter'
require 'yaml'
require 'json'
require 'active_record'
require 'active_support/all'
require_relative 'model/model.rb'
require 'getoptlong'
require 'logger'

$config_data = YAML.load_file "keys.yml"

$logger = Logger.new(STDOUT)
$logger.level = Logger::INFO

def save_tweet(tweet)
	_tweet = Tweet.create(text: tweet.text, 
		user: tweet.user.screen_name,
		date: tweet.created_at,
		twitter_id: tweet.id,
		geo: tweet.geo,
		coordinates: tweet.place.bounding_box.coordinates,
		place: tweet.place,
		keyword: keyword,
		user_location: tweet.user.location
		)
	$logger.info _tweet.attributes
end

def download_keywords(keywords,_)

	client = Twitter::REST::Client.new do |config|
		config.consumer_key    = config_data['consumer_key']
		config.consumer_secret = config_data['consumer_secret']
	end

	keywords.each do |keyword|
		lang = "es" #ISO 639-1
		begin
			client.search("#{keyword} -rt", lang: lang, count: 100).each do |tweet|
				next if Tweet.exists? twitter_id: tweet.id
				save_tweet tweet
			end
		rescue Twitter::Error::TooManyRequests => error
			sleep error.rate_limit.reset_in + 1
			retry
		end
	end
end

def stream_keywords(keywords,rt)

	stream_client = Twitter::Streaming::Client.new do |config|
		config.consumer_key    = config_data['consumer_key']
		config.consumer_secret = config_data['consumer_secret']
		config.access_token 	 = config_data['access_token']
		config.access_token_secret = config_data['access_token_secret']
	end

	stream_client.filter(track: keywords.join(",")) do |object|
	  if object.is_a?(Twitter::Tweet) && (rt ? true : object.retweeted?)
		save_tweet object
	  end
	end
end

opts = GetoptLong.new(
	['--stream','-s',GetoptLong::NO_ARGUMENT],
	['--download','-d',GetoptLong::NO_ARGUMENT],
	['--keywords','-k',GetoptLong::REQUIRED_ARGUMENT],
	['--retweets','-t',GetoptLong::NO_ARGUMENT],
	)

mode = nil
keywords = nil
rt = false

opts.each do |opt,arg|
	case opt
		when '--stream'
			mode = 'stream_keywords'
		when '--download'
			mode = 'download_keywords'
		when '--retweets'
			rt = true
		when '--keywords'
			keywords = arg.split(',')
	end
end

if !mode
	$logger.error "Must specify a mode"
	exit 1
end

if !keywords
	$logger.error "No keywords specified"
	exit 1
end

send mode,keywords,rt
