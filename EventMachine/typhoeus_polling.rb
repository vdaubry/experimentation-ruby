require 'typhoeus'
require 'redis'

$hydra = Typhoeus::Hydra.new(max_concurrency: 200)
$redis = Redis.new(host: '104.239.165.215', port: 6379, password: ENV['REDIS_PASSWORD'])
$redis2 = Redis.new(host: '127.0.0.1', port: 6379)
urls = $redis.zrange("bc:domains:perf", 0, 1000)
$redis2.del("bc:domains:perf:typhoeus:list")
$redis2.lpush("bc:domains:perf:typhoeus:list", urls)


def measure
  start_time = Time.now.to_f
  
  yield
  
  total_time = Time.now.to_f - start_time
  puts "total time = #{total_time}"
  total_time
end

def buffer_urls
  buffer = []
  loop do
    url = $redis2.lpop("bc:domains:perf:typhoeus:list")
    break if url.nil? || buffer.size > 200
    buffer << url
  end
  puts "buffered #{buffer.size} urls"
  buffer
end

def empty_buffer(buffer:)
  buffer.each do |url|
    url = "http://#{url}"
    $hydra.queue(request = Typhoeus::Request.new(url))

    request.on_complete do |response|
      puts "#{url} : #{response.body.size} bytes"
    end
  end

  $hydra.run
end

measure do
  loop do
    buffer = buffer_urls
    break if buffer.empty?
    empty_buffer(buffer: buffer)
  end
end