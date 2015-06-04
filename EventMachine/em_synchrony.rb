require 'mechanize'
require 'em-synchrony'
require 'em-synchrony/em-http'
require 'redis'

def async_get_page(url:)
  page = EventMachine::HttpRequest.new(url).get
  puts "#{url} : #{page.response.size} bytes"  
end

def sync_get_page(url:)
  page = Mechanize.new.get(url)
  puts "#{url} : #{page.content.size} bytes"
end


def measure
  start_time = Time.now.to_f
  
  yield
  
  total_time = Time.now.to_f - start_time
  puts "total time = #{total_time}"
  total_time
end

$redis = Redis.new(host: '104.239.165.215', port: 6379, password: ENV['REDIS_PASSWORD'])
urls = $redis.zrange("bc:domains:perf", 0, 100)

# measure do
#   EventMachine.synchrony do
#     urls.each do |url|
#       async_get_page(url: "http://#{url}")
#     end
#     EventMachine.stop
#   end
# end

measure do
  urls.each do |url|
    sync_get_page(url: "http://#{url}")
  end
end
