#!/usr/bin/env ruby
# encoding: utf-8

require "bunny"
require "byebug"

conn = Bunny.new(:hostname => "54.83.30.48")
conn.start

ch = conn.create_channel
q = ch.queue("hello", :durable => true)
msg  = "Hello World!"
MESSAGE_COUNT = (ARGV[0] || 10000).to_i

start_time = Time.now
MESSAGE_COUNT.times do |variable|
  q.publish(msg, :persistent => true)
end

puts "Done at #{(MESSAGE_COUNT/(Time.now - start_time)).round(1)} messages / sec"
conn.close