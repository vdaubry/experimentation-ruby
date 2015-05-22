require 'mechanize'
require_relative 'redis'

class GetUrlWorker
  include Sidekiq::Worker
  
  def perform(url)
    puts "Get #{url}"
    begin
      agent = Mechanize.new.get(url)
    rescue StandardError => e
      puts "Couldn't get #{url} : #{e}"
    ensure
      $redis.incr("bc:domains:seed:counter")
    end
  end
end