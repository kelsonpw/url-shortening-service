require "sinatra"
require "redis"

redis = Redis.new

helpers do
  include Rack::Utils
  alias_method :h, :escape_html

  def random_string(len)
    rand(36 ** len).to_s(36)
  end
end

get "/" do
  erb :index
end

post "/" do
  if params[:url] and not params[:url].empty?
    shortcode = random_string 5
    @base_url = request.url + shortcode
    redis.setnx "links:#{shortcode}", params[:url]
  end
  erb :index
end

get "/:shortcode" do
  @url = redis.get "links:#{params[:shortcode]}"
  redirect @url || "/"
end
