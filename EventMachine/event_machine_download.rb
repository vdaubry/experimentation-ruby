require 'eventmachine'
require 'em-http-request'
require 'redis'

def async_get_page(url:)
  page = EventMachine::HttpRequest.new(url).get
  puts "#{url} : #{page.response.size} bytes"  
end

$redis = Redis.new(host: '104.239.165.215', port: 6379, password: ENV['REDIS_PASSWORD'])
$redis2 = Redis.new(host: '127.0.0.1', port: 6379)
urls = $redis.zrange("bc:domains:perf", 0, 1000)
$redis2.del("bc:domains:perf:em:list")
$redis2.lpush("bc:domains:perf:em:list", urls)


def get_url(url:)
  puts "GET #{url}"
  url="http://#{url}"
  page = EventMachine::HttpRequest.new(url).get
  page.errback { p "Couldn't get #{url}" }
  page.callback {
    puts "#{url} : #{page.response.size} bytes" 
  }
end

start_time = Time.now.to_f

EventMachine.run {
  EM::PeriodicTimer.new(0.1) do
    url = $redis2.lpop("bc:domains:perf:em:list")
    if url.nil?
      EM.stop
    else
      get_url(url: url)
    end
  end
}
total_time = Time.now.to_f - start_time
puts "total time = #{total_time}"
total_time