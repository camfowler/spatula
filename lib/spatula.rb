require "spatula/version"
require "spatula/rss_check"

require 'dotenv'
Dotenv.load

raise ".env file missing" if ENV['PAPRIKA_TOKEN'].nil?

module Spatula


  # Your code goes here...
end
