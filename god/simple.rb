STDOUT.sync = true

loop do
  $stdout.puts "test"
  $stdout.flush
  sleep 1
end