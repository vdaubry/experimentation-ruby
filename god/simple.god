current_path = File.expand_path File.dirname(__FILE__)

puts "#{current_path}/output.log"

God.watch do |w|
  w.name        = "simple"
  w.start       = "ruby #{current_path}/simple.rb > #{current_path}/output.log"
  w.keepalive
end