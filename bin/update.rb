require 'dotenv/load'
require 'twitter'
require 'httparty'
require 'nokogiri'


# Configuring the Twitter client with API keys, tokens, and secrets
twitter = Twitter::REST::Client.new do |config|
    config.consumer_key = ENV['CONSUMER_KEY']
    config.consumer_secret = ENV['CONSUMER_SECRET']
    config.access_token = ENV['ACCESS_TOKEN']
    config.access_token_secret = ENV['ACCESS_TOKEN_SECRET']
end


# Saving the the RSS feeds as an array 
feeds = ['https://www.soccercoachweekly.net/soccer-drills-and-skills/attacking/feed', 'https://www.goal.com/feeds/en/news', 'https://www.soccercoachweekly.net/feed', 'https://statsbomb.com/articles/feed/']


# set the latest_tweets variable to the latest tweets from a particular user via twitter.user_timeline() function
latest_tweets = twitter.user_timeline('footballmisters')


# set the previous_links variable to the latest tweets from a particular user via latest_tweets.map
previous_links = latest_tweets.map do |tweet|
    if tweet.urls.any?
        tweet.urls[0].expanded_url
    end
end


# Loop over each feed and for each feed do something
feeds.each do |feed|
    
    # Using HTTParty to get the the feed and save it as rss
    rss = HTTParty.get(feed)

    # Using Nokogiri to parse the returned rss feed and save it as doc
    doc = Nokogiri::XML(rss)

    # Initialize variable site_title to empty string
    site_title = ''

    # Get the first title element in the current doc and set site_title to that element's text
    doc.css('title').take(1).each do |item|
        site_title = item.text
    end
   
    # Get the first two item elements from the currect doc and do something with each one
    doc.css('item').take(1).each do |item|

        # set title to the item's title element text
        title = item.css('title').text

        # set title to the item's title element text
        link = item.css('link').text

        # set title to the item's title element text
        # category = item.css('category').text

        # puts site_title.start_with?('Attacking', 'Soccer Coach Weekly') ? "Coach Weekly" : site_title

       unless previous_links.include?(title)
            if  site_title.start_with?('Attacking', 'Soccer Coach Weekly' )
                twitter.update("Digital Coaching: #{title} #{link}")
            elsif site_title.start_with?('Articles – StatsBomb')
                twitter.update("Analysis: #{title} #{link}")
            else 
                twitter.update("#{title} #{link}")
            end
       end
    end
end

# doc.css('item').take(2).each do |item|
#     title = item.css('title').text
#     puts title
    # link = item.css('description').text

    # unless link.start_with?('http')
    #     link = item.css('link').text
    # end

    # unless previous_links.include?(link)
    #     twitter.update("#{title} #{link}")
    # end
# end
