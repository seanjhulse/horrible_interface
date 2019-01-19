class HomeController < ApplicationController
  def index
    @posts = $redis.get("/")
    # if @posts have expired or DNE, fetch them and set them in Redis
    unless @posts
      @reddit = Reddit::Posts.new
      $redis.set("/", @reddit.fetch("/"))
      $redis.expire("/", 1800)
    end

    @posts = JSON.parse(@posts)
  end
end
