require 'net/http'

#Simple threads example
threads = []
3.times do |i|
  puts "creating thread #{i}"
  t = Thread.new do
    url = URI.parse('http://www.google.fr')
    req = Net::HTTP::Get.new(url.to_s)
    res = Net::HTTP.start(url.host, url.port) {|http|
      http.request(req)
    }
    puts "Thread #{i} done"
  end
  threads << t
end
threads.each {|t| t.join}