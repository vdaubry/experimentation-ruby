#!/usr/bin/env ruby
# encoding: utf-8

require 'riak'
require 'celluloid'

class RiakClient
  def initialize(bucket_name:)
    client = Riak::Client.new(host: '127.0.0.1', :pb_port => 11087)
    @bucket = client.bucket(bucket_name)
  end
  
  def putObject(key:, data:)
    begin
      obj = Riak::RObject.new(@bucket, key)
      obj.content_type = "text/html"
      obj.raw_data = data
      obj.store
    rescue Riak::ProtobuffsFailedRequest
      nil
    end
  end
end

NUMBER_FILE = 1000
riak_client = RiakClient.new(bucket_name: "test")
puts "loading #{NUMBER_FILE} into riak"
start_time = Time.now
data = File.read("sample.html")
(1..NUMBER_FILE).each do |i|
  riak_client.putObject(key: "sample_#{i}", data: data)
end
puts "Finished in #{Time.now - start_time}"