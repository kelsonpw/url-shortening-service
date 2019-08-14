helpers do
  include Rack::Utils
  alias_method :h, :escape_html

  def encode(string)
    SecureRandom.urlsafe_base64(5)
  end

  def toURL(host, encoded_key)
    "http://#{host}/v1/#{encoded_key}"
  end

  def redis_save_url(rd, shortcode, url)
    formatted_url = smart_add_url_protocol(url)
    rd.setnx("links:#{shortcode}", formatted_url)
  end

  def redis_read_url(rd, shortcode)
    rd.get("links:#{shortcode}")
  end

  def parse(body)
    body.rewind
    JSON.parse(body.read, :symbolize_names => true)
  end

  def smart_add_url_protocol(url)
    if url && !url_protocol_present?(url)
      "http://#{url}"
    else
      url
    end
  end

  def url_protocol_present?(url)
    url[/\Ahttp:\/\//] || url[/\Ahttps:\/\//]
  end
end
