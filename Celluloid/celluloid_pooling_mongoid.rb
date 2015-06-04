require 'open-uri'
require 'celluloid'
require 'uri'
require 'yaml'
require 'mongoid'

class Image
  include Mongoid::Document
  
end

class WebDownloader
  class SomeHTTPError < StandardError; end
  
  def initialize(json)
    @json = json
  end
  
  def perform
    i = Random.new.rand(10)
    if i==3
      raise SomeHTTPError, "http error" 
    end
    puts "number of documents : #{Image.count}"
  end
end
 

class QueueListner
  include Celluloid
  @@query_count = 0
  
  def self.query_count
    @@query_count
  end
  
  def self.query_count=(val)
    @@query_count=val
  end
  
  def perform
    begin
      WebDownloader.new({"foo" => "bar"}).perform
      @@query_count+=1
    rescue StandardError => e
      puts "Actor crashed : #{e}"
    end
  end
end

thread_number = 15
number_of_count = 50
listeners = QueueListner.pool size:thread_number

#wait for opening a connection pool to DB
puts "Connecting to db..."
Mongoid.load!("#{File.expand_path(File.dirname(__FILE__))}/../mongoid.yml", :production)
puts "number of documents : #{Image.count}"
puts "Connected"

3.times do
  start_time = Time.now
  QueueListner.query_count = 0
  while(QueueListner.query_count < number_of_count) do
    listeners.async.perform
  end

  File.open("results.txt", "a") do |f|
   f.puts "time for #{number_of_count} count with #{thread_number} threads: #{Time.now - start_time}"
  end
  puts File.read("results.txt")
end
