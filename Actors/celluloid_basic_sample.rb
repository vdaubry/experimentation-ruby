require 'open-uri'
require 'celluloid'
 
class WebDownloader
  include Celluloid
 
  def initialize(url)
    @url = url
  end
  
  def perform
    puts URI.parse(@url).read
  end
end
 
5.times do
  fp = WebDownloader.new "https://dl.dropboxusercontent.com/u/995341/samples.json"
  fp.async.perform
end

sleep(2)