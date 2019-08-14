require_relative "helpers"

redis = Redis.new

get "/" do
  erb :index
end

post "/" do
  if params[:url] and not params[:url].empty?
    shortcode = encode(params[:url])
    redis_save_url(redis, shortcode, params[:url])
    @base_url = toURL(request.host_with_port, shortcode)
  end
  erb :index
end

get "/v1/:shortcode" do
  @url = redis_read_url(redis, params[:shortcode])
  redirect @url || "/"
end

post "/api/compress" do
  content_type :json
  params = parse(request.body)
  if params[:url]
    shortcode = encode(params[:url])
    redis_save_url(redis, shortcode, params[:url])
    url = toURL(request.host_with_port, shortcode)
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
  params = parse(request.body)
  if params[:shortcode]
    url = redis_read_url(redis, params[:shortcode])
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
