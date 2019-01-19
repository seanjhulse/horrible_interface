require 'net/http'
require 'uri'
require 'json'

module Reddit
  class API
    @@BASE_URL="https://oauth.reddit.com"
    
    @@TOKEN_URI=URI.parse("https://www.reddit.com/api/v1/access_token")
    @@CLIENT_ID=Rails.application.credentials.reddit[:client_id]
    @@CLIENT_SECRET=Rails.application.credentials.reddit[:client_secret]
    @@USER_AGENT="Web Application Horrible Interface v.0.0"
    # won't exist until request is made
    @@CLIENT_TOKEN=nil
    @@CLIENT_TOKEN_EXPIRATION=nil
    
    def initialize
      get_token
    end

    '''
      Sets @@CLIENT_TOKEN to the post_token request if
      it is expired, nil, false, undefined, or falsey.
      @return @@CLIENT_TOKEN
    '''
    def get_token
      if token_expired
        @@CLIENT_TOKEN = post_token_request
      else
        @@CLIENT_TOKEN ||= post_token_request
      end
    end

    '''
      Checks to see if the token expiration date has been reached.
      @return {boolean}
    '''
    def token_expired
      # check to see if the token exists and if it is expired or about to expire
      @@CLIENT_TOKEN_EXPIRATION && DateTime.now >= @@CLIENT_TOKEN_EXPIRATION - 30.seconds
    end

    '''
      Makes a request to Reddit for a valid API token.
      @return token
    '''
    def post_token_request
      # create the request
      request = Net::HTTP::Post.new(@@TOKEN_URI,
                                    "User-Agent": @@USER_AGENT,
                                    "Content-Type": "application/json")
      request.set_form_data("grant_type" => "client_credentials")
      request.basic_auth(@@CLIENT_ID, @@CLIENT_SECRET)

      # make the request
      response = Net::HTTP.start(hostname, port, use_ssl: scheme == "https") do |http|
        http.request(request)
      end

      # parse the response
      response = JSON.parse(response.body)
      @@CLIENT_TOKEN_EXPIRATION = DateTime.now + response["expires_in"].seconds
      return response["access_token"]
    end

    '''
      Grabs the data based on some endpoint. By default
      it returns the frontpage.
      
      @params {string} a URL string NOT a URI
      @returns {JSON} posts
    '''
    def fetch(url="")
      uri=URI.parse("#{@@BASE_URL}#{url}")
      request = Net::HTTP::Get.new("#{uri}.json",
                                   "User-Agent": "#{user_agent}",
                                   "Content-Type": "application/json")
      request["Authorization"] = "BEARER #{get_token}"

      # make the request
      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
        http.request(request)
      end

      return response.body
    end

    def user_agent
      return @@USER_AGENT
    end

    def hostname
      return @@TOKEN_URI.hostname
    end

    def port
      return @@TOKEN_URI.port
    end

    def scheme
      return @@TOKEN_URI.scheme
    end
  end
end