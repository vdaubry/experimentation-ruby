#!/usr/bin/env ruby
# encoding: utf-8

require "bunny"
require 'aws-sdk'
require 'yaml'
require 'byebug'
require 'nokogiri'
require 'celluloid'
require 'redis'

class S3
  def initialize(bucket_name:)
    conf = YAML.load_file("#{File.expand_path(File.dirname(__FILE__))}/../../aws.yml")
    Aws.config.update({
      access_key_id: conf['access_key_id'],
      secret_access_key: conf['secret_access_key'],
      region: 'us-east-1'
    })
    @s3 = Aws::S3::Client.new
    @bucket_name = bucket_name
  end
  
  def getObject(key:)
    @s3.get_object(bucket: @bucket_name,
                    key: key).body
  end
end

class WebDownloader
  include Celluloid
  
  def download(html:)
    res = S3.new(bucket_name: "vda-public-bucket").getObject(key: html)
    doc = Nokogiri::HTML(res.string)
    #publish "done", html
    puts "Download HTML with #{doc.xpath('//a').count} links"
    $redis.incr("counter")
  end
end


class Consumer
  include Celluloid
  
  POOL_SIZE = 20
  
  def initialize(jobs_count:)
    @jobs_count = jobs_count
    @conn = Bunny.new(:hostname => "54.83.30.48")
    @conn.start

    ch = @conn.create_channel
    #Allow only n message at a time
    ch.prefetch(100)
    @q = ch.queue("hello", :durable => true)
    @workers = WebDownloader.pool size:POOL_SIZE
  end
  
  def poll
    loop do
      @q.subscribe(:manual_ack => true, :block => false) do |delivery_info, properties, body|
        @workers.async.download(html: "sample.html")
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
