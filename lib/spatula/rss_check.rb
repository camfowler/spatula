require 'rss'
require 'open-uri'
require 'time'
require 'fileutils'
require 'digest/sha1'
require 'logger'

class Spatula::RSSCheck

  # amount of days to check on first run
  FIRST_RUN_PAST_DAYS = 60

  def initialize(feed_urls, logger = Logger.new(STDOUT))
    @feed_urls = feed_urls
    @logger = logger
  end

  def check
    @feed_urls.each do |url|
      parse_feed(url)
    end
  end

  private

  def file_path(feed_url)
    "timestamps/#{Digest::SHA1.hexdigest(feed_url)}"
  end

  def lookup_latest_timestamp(feed_url)
    file = file_path(feed_url)
    if File.exist?(file)
      File.mtime file
    else
      day_in_seconds = 1*60*60*24
      Time.now - (FIRST_RUN_PAST_DAYS * day_in_seconds)
    end
  end

  def store_new_timestamp(feed_url, time)
    FileUtils.touch file_path(feed_url), mtime: time
  end

  def import_into_paprika(url)
    @logger.info "imported to paprika-scrape #{url}"
    `phantomjs paprika-scrape.js #{url}`
  end

  def parse_feed(url)
    open(url) do |rss|
      feed = RSS::Parser.parse(rss, false)

      case feed.feed_type
      when 'rss'
        parse_rss_items(feed.items, url)
      when 'atom'
        parse_atom_items(feed.items, url)
      end

    end
  end

  def parse_atom_items(items, url)
    @logger.info "Not implemented"
  end

  def parse_rss_items(items, url)
    items.sort_by(&:pubDate).each do |item|

      # lookup the last fetched date, as we only want new articles
      last_item_timestamp = lookup_latest_timestamp(url)

      # If there is a new item
      if item.pubDate > last_item_timestamp
        # @logger.info "Item: #{item.title}"
        @logger.info "Link: #{item.link}"
        @logger.info "Pubdate: #{item.pubDate}"

        # import the url
        import_into_paprika(item.link)

        # Store the new timestamp
        store_new_timestamp(url, item.pubDate)
      end
    end
  end

end


