#!/usr/bin/env ruby
# encoding: utf-8

require 'riak'
require 'celluloid'
require 'redis'
require 'json'

class RiakClient
  def initialize(bucket_name:)
    client = Riak::Client.new(host: '127.0.0.1', :pb_port => 11087)
    @bucket = client.bucket(bucket_name)
  end
  
  def put_object(key:)
    begin
      object = @bucket.get_or_new(key)
      object.raw_data = "{'field':'value'}"
      object.content_type = "application/json"
      object.store
    rescue Riak::ProtobuffsFailedRequest
      nil
    end
  end
end


class Consumer
  include Celluloid
  
  def riak_client
    @riak_client ||= RiakClient.new(bucket_name: "test")
  end
  
  def write(key:)
    riak_client.put_object(key: key)
    $redis.incr("counter")
  end
end


POOL_SIZE = 10
MESSAGE_COUNT = 10000
start_time = Time.now
$redis = Redis.new
$redis.del("counter")

puts "writing #{MESSAGE_COUNT} object in Riak"
workers = Consumer.pool size:POOL_SIZE

i=0
loop do
  workers.async.write(key: "tstobj_#{i}")
  counter = $redis.get("counter") || 0
  break if counter.to_i >= MESSAGE_COUNT
  i+=1
end

puts "Done at #{MESSAGE_COUNT.to_i/(Time.now - start_time).round(1)} messages / sec"