#Abort main thread when an exception is raised
threads = []
3.times do |i|
  puts "creating thread #{i}"
  t = Thread.new do
    url = URI.parse('http://www.google.fr')
    req = Net::HTTP::Get.new(url.to_s)
    res = Net::HTTP.start(url.host, url.port) {|http|
      http.request(req)
    }
    puts "failing now..."
    raise "failed calling from thread #{i}"
  end
  t.abort_on_exception=true
  threads << t
end
sleep(3) #joining threads would also raise exception