require 'open-uri'
require 'celluloid'
require 'mongo'
require 'uri'
require 'yaml'


class DBConnection
  @@db_connection = nil
  
  def self.connection(env)
    return @@db_connection if @@db_connection
    conf_path = "#{File.expand_path(File.dirname(__FILE__))}/../db.yml"
    url = YAML.load_file(conf_path)[env]["url"]
    db = URI.parse(url)
    db_name = db.path.gsub(/^\//, '')
    @@db_connection = Mongo::Connection.new(db.host, db.port, :pool_size => 100).db(db_name)
    @@db_connection.authenticate(db.user, db.password) unless (db.user.nil? || db.password.nil?)
    @@db_connection
  end
end

class WebDownloader
  class SomeHTTPError < StandardError; end
  
  def initialize(json)
    @json = json
  end
  
  def perform
    i = Random.new.rand(10)
    puts "i = #{i}"
    if i==3
      raise SomeHTTPError, "http error" 
    end
    coll = DBConnection.connection["images"]
    puts "number of documents : #{coll.count}"
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

thread_number = 5
number_of_count = 50
listeners = QueueListner.pool size:thread_number

#wait for opening a connection pool to DB
puts "Connecting to db..."
DBConnection.connection(:production)
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
