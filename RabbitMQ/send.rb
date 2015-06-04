#!/usr/bin/env ruby
# encoding: utf-8

require "bunny"
require "byebug"
require "json"

conn = Bunny.new(:hostname => "127.0.0.1")
conn.start

ch = conn.create_channel
q = ch.queue("test", :durable => true)
MESSAGE_COUNT = (ARGV[0] || 10000).to_i

start_time = Time.now
MESSAGE_COUNT.times do |i|
  msg = {key: "sample_#{i}"}.to_json
  q.publish(msg, :persistent => true)
end

puts "Done at #{(MESSAGE_COUNT/(Time.now - start_time)).round(1)} messages / sec"
conn.close