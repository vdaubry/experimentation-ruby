#!/usr/bin/env ruby
require 'redis'
$redis = Redis.new(:host => '127.0.0.1', :port => 6379)

#Sets
1000.times { |i| $redis.sadd "a::set", i }

iterator = 0
loop do |variable|
  iterator, values = $redis.sscan "a::set", iterator
  values.each {|v| puts v}
  break if iterator=="0"
end

