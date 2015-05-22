#!/usr/bin/env ruby
# encoding: utf-8

require "bunny"

conn = Bunny.new(:hostname => "54.83.30.48")
conn.start

ch   = conn.create_channel
q    = ch.queue("hello", :durable => true)

#Allow only n message at a time
ch.prefetch(100);

start_time = Time.now
MESSAGE_COUNT=(ARGV[0] || 1000).to_i

puts "Receiving #{MESSAGE_COUNT} messages"
i=0
begin
  q.subscribe(:manual_ack => true, :block => true) do |delivery_info, properties, body|
    sleep 10
    ch.ack(delivery_info.delivery_tag)
    i+=1
    if i>=MESSAGE_COUNT
      puts "Done at #{(MESSAGE_COUNT/(Time.now - start_time)).round(1)} messages / sec"
      exit(0)
    end
  end
rescue Interrupt => e
  conn.close
end