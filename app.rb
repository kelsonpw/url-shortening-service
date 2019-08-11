require "sinatra"
require "redis"
require "json"

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
    redis.setnx("links:#{shortcode}", params[:url])
  end
  erb :index
end

get "/:shortcode" do
  @url = redis.get("links:#{params[:shortcode]}")
  redirect @url || "/"
end

post "/api/compress" do
  content_type :json
  request.body.rewind
  params = JSON.parse(request.body.read, :symbolize_names => true)
  if params[:url]
    shortcode = random_string(5)
    url = request.base_url + "/" + shortcode
    redis.setnx("links:#{shortcode}", params[:url])
    {
      :shortcode => shortcode,
      :url => url,
    }.to_json
  else
    {
      :error => "No URL provided.",
    }.to_json
  end
end

post "/api/expand" do
  content_type :json
  request.body.rewind
  params = JSON.parse(request.body.read, :symbolize_names => true)

  if params[:shortcode]
    url = redis.get("links:#{params[:shortcode]}")
    {
      :url => url,
      :shortcode => params[:shortcode],
    }.to_json
  else
    {
      :error => "No shortcode provided.",
    }.to_json
  end
end
