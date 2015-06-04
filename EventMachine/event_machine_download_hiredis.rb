require 'eventmachine'
require 'em-http-request'
require 'em-hiredis'
require 'redis'
require 'byebug'

$redis = Redis.new(host: '104.239.165.215', port: 6379, password: ENV['REDIS_PASSWORD'])
urls = $redis.zrange("bc:domains:perf", 0, 1000); nil

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

EM.run {
  $redis2 = EM::Hiredis.connect("redis://127.0.0.1:6379/4") 
  $redis2.del("bc:domains:perf:em:list")
  urls.each { |url| $redis2.lpush("bc:domains:perf:em:list", url) }

  EM::PeriodicTimer.new(0.1) do
    puts "tick"
    $redis2.lpop("bc:domains:perf:em:list") do |url|
      if url.nil?
        EM.stop
      else
        get_url(url: url)
      end
    end
  end
}

total_time = Time.now.to_f - start_time
puts "total time = #{total_time}"
total_time