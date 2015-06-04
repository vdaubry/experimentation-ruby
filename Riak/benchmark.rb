#!/usr/bin/env ruby
# encoding: utf-8

require 'bunny'
require 'riak'
require 'yaml'
require 'byebug'
require 'nokogiri'
require 'celluloid'
require 'redis'
require 'json'

class RiakClient
  def initialize(bucket_name:)
    client = Riak::Client.new(host: '127.0.0.1', :pb_port => 11087)
    @bucket = client.bucket(bucket_name)
  end
  
  def getObject(key:)
    begin
      @bucket.get(key).data
    rescue Riak::ProtobuffsFailedRequest
      nil
    end
  end
  
  def delete(key:)
    begin
      @bucket.delete(key)
    rescue Riak::ProtobuffsFailedRequest => e
      puts "Failed to delete key #{key} : #{e}"
    end
  end
end

class WebDownloader
  include Celluloid
  
  def riak_client
    @riak_client ||= RiakClient.new(bucket_name: "test")
  end
  
  def download(html:)
    res = riak_client.getObject(key: html)
    #links = Nokogiri::HTML(res).xpath('//a')
    links = res.scan(/<a\s+(?:[^>]*?\s+)?href="([^"]*)"/)
    #publish "done", html
    puts "Download HTML with #{links.count} links"
    $redis.incr("counter")
  end
  
  def delete(html:)
    riak_client.delete(key: html)
    $redis.incr("counter")
    #puts "Deleted #{html}"
  end
end


class Consumer
  include Celluloid
  
  POOL_SIZE = 20
  
  def initialize(jobs_count:)
    @jobs_count = jobs_count
    @conn = Bunny.new(:hostname => "127.0.0.1")
    @conn.start

    ch = @conn.create_channel
    #Allow only n message at a time
    ch.prefetch(100)
    @q = ch.queue("test", :durable => true)
    @workers = WebDownloader.pool size:POOL_SIZE
  end
  
  def poll
    puts "Listening for messages"
    loop do
      @q.subscribe(:manual_ack => true, :block => false) do |delivery_info, properties, body|
        @workers.async.delete(html: JSON.parse(body)["key"])
      end
      counter = $redis.get("counter") || 0
      break if counter.to_i >= @jobs_count
    end
  end
end

$redis = Redis.new
$redis.del("counter")
MESSAGE_COUNT = (ARGV[0] || 1000).to_i
start_time = Time.now
Consumer.new(jobs_count: MESSAGE_COUNT).poll
puts "Done at #{($redis.get("counter").to_i/(Time.now - start_time)).round(1)} messages / sec"

#Max : 40 msg / sec from EC2 on m3.medium instance