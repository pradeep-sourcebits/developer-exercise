# ASSUMPTIONS
# 
# Not using any Gem, but a direct HTTP request to access YouTube provided API.
# The value of the KEYWORD string to search through YouTube is given as static as 'football'
require "net/https"
require "uri"
require 'json'

class YouTube
  attr_accessor :keyword
  KEYWORD = "football"

  def initialize(keyword)
    @keyword = keyword
  end

  # To frame the request body.
  def frame_request(keyword=nil)
    # Parsing the YouTube query URL.
    uri = URI.parse("https://gdata.youtube.com/feeds/api/videos?q=#{keyword}&max-results=3&alt=json&orderby=relevance&v=2")

    # Creating a new http object using Net::HTTP with ssl enabled.
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    # Creating HTTP request using the formatted URI.
    request = Net::HTTP::Get.new(uri.request_uri)
    return http, request
  end

  # To hit YouTube and parse the response
  def search
    http, request = frame_request @keyword

    # Getting response from YouTube
    response = http.request(request)

    # Parsing for serialization of the response
    json_response = JSON.parse(response.body)

    # Any mishaps inside the code-block will return an empty array.
    begin
      json_response['feed']['entry'].map{ |rsp| 
        rsp['media$group']['media$content'].first.send(:[],'url')
      }
    rescue
      []
    end
  end
end

# Example to check with the keyword provided as a constant inside YouTube class
you_tube = YouTube.new YouTube::KEYWORD

# Displaying the result (maximum of 3 urls an an array).
puts you_tube.search.inspect

require 'test/unit'

class YouTubeTest < Test::Unit::TestCase
  def setup
    @you_tube = YouTube.new YouTube::KEYWORD
    @keyword = @you_tube.keyword
  end

  # To test the Keyword.
  def test_keyword
    assert_equal @you_tube.keyword, YouTube::KEYWORD
  end

  # To test the custom Keyword.
  def test_custom_keyword
    @you_tube = YouTube.new "benchprep"
    assert_equal @you_tube.keyword, "benchprep"
  end

  # Test for maximum size of the result array.
  def test_search
    assert @you_tube.search.length <= 3
  end

  # Test for empty result array.
  def test_for_empty_result
    assert_not_equal @you_tube.search.length, 0
  end
end
