require 'eventmachine'
require 'em-http-request'
require 'rubydns'
require 'rubydns/system'
require 'byebug'

start_at = Time.now
successes = []
sites = ["http://google.com", "http://yahoo.com", "http://apple.com", "http://bogus.local/"]
resolver = RubyDNS::Resolver.new(RubyDNS::System::nameservers)
n=0
EventMachine.run {
  sites.each do |site|
    
    resolver.query(URI.parse(site).host) do |response|
      if response.answer.empty?
        n+=1
      else
        ip = response.answer[0][2].address.to_s
        host = response.answer[0][0].to_s
        
        domain = Addressable::URI.parse(site)
        domain.host = ip
        
        puts "get #{ip}, for #{site}"
        http = EventMachine::HttpRequest.new(domain, :connect_timeout => 15).get(:head =>{'host' => host})
        
        http.callback do
          successes << (Time.now - start_at)
          n+=1
        end
        http.errback do
          p "Couldn't get #{site}"
          n+=1
        end
      end
    end
    
  end
  
  EM::PeriodicTimer.new(0.1) do
    EM.stop if n==sites.count
  end
}

puts "success = #{successes.inspect}"