#start sidekiq with 'sidekiq -c 50 -r ./Threads/sidekiq/get_url_worker.rb -q bench'

require 'redis'
require 'sidekiq'
require 'sidekiq/api'
require_relative 'redis'
require_relative 'get_url_worker'

def measure
  start_time = Time.now.to_f
  
  yield
  
  total_time = Time.now.to_f - start_time
  puts "total time = #{total_time}"
  total_time
end


Sidekiq::Queue.new.clear
$redis.set("bc:domains:seed:counter", 0)
urls = $redis.zrange("bc:domains:perf", 0, 200)
measure do
  urls.each do |url|
    puts "add #{url} to queue"
    url = "http://#{url}"
    GetUrlWorker.perform_async(url)
  end

  loop do
    url_done = $redis.get("bc:domains:seed:counter").to_i
    puts "url done = #{url_done}"
    break if url_done>=urls.size
  end
end
