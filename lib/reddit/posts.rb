require 'net/http'
require 'uri'
require 'json'

module Reddit
  class Posts

    '''
      Constructs a Posts objects and loads a new API
      instance for handling requests.
    '''
    def initialize
      @api = Reddit::API.new
    end

    '''
      Grabs all the posts from the url.
    '''
    def fetch(url="")
      @api.fetch(url)
    end
  end
end