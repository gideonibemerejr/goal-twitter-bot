require 'dotenv/load'
require 'twitter'
require 'httparty'
require 'nokogiri'

twitter = Twitter::REST::Client.new do |config|
    config.consumer_key = ENV['CONSUMER_KEY']
    config.consumer_secret = ENV['CONSUMER_SECRET']
    config.access_token = ENV['ACCESS_TOKEN']
    config.access_token_secret = ENV['ACCESS_TOKEN_SECRET']
end

# set the latest_tweets variable to the latest tweets from a particular user via twitter.user_timeline() function
latest_tweets = twitter.user_timeline('footballmisters')

# set the previous_links variable to the latest tweets from a particular user via latest_tweets.map
previous_links = latest_tweets.map do |tweet|
    if tweet.urls.any?
        tweet.urls[0].expanded_url
    end
end

# rss = HTTParty.get('https://www.goal.com/feeds/en/news') 
# doc = Nokogiri::XML(rss)


feeds = ['https://www.soccercoachweekly.net/soccer-drills-and-skills/attacking/feed', 'https://www.goal.com/feeds/en/news', 'https://www.soccercoachweekly.net/feed']


feeds.each do |feed|
    rss = HTTParty.get(feed)
    doc = Nokogiri::XML(rss)
    count = 1
    site_title = ''

    doc.css('title').take(1).each do |item|
        site_title = item.text
    end
   

    doc.css('item').take(2).each do |item|
        title = item.css('title').text
        link = item.css('link').text
        category = item.css('category').text
        if site_title.start_with?('Attacking', 'Soccer Coach Weekly')
            puts "Soccer Coach Weekly + #{site_title}"
        end
        if category.start_with?('@')
            category = 'none'
        end
        puts "Site: #{site_title} Count: #{count} Title: #{title}, Link: #{link}"
        count += 1
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
