require 'typhoeus'
require 'redis'
require 'json'

puts "loading urls"
f = File.open("#{File.expand_path(File.dirname(__FILE__))}/ressources/domains.json").read; nil
urls = JSON.parse(f)["domains"][0..1000]; nil
puts "loaded #{urls.count} urls"
hydra = Typhoeus::Hydra.new(max_concurrency: 200)

def measure
  start_time = Time.now.to_f
  
  yield
  
  total_time = Time.now.to_f - start_time
  puts "total time = #{total_time}"
  total_time
end

# Very fast when we can work with batch of urls : 
#  - hydra.run is blocking
#  - Adding a URL to the queue only when downloads finish means downloading 1 by 1
measure do
  urls.each do |url|
    hydra.queue(request = Typhoeus::Request.new(url))

    request.on_complete do |response|
      puts "#{url} : #{response.body.size} bytes"
    end
  end

  hydra.run
end