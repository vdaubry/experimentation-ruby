JOBS_NUMBER = 1000
POOL_SIZE = 40
jobs = Queue.new
JOBS_NUMBER.times{|i| jobs.push Hash[:payload, "foo"] }

start_time = Time.now
puts "Starting #{POOL_SIZE} threads to execute #{JOBS_NUMBER} jobs"

threads = POOL_SIZE.times.map do
  Thread.new do
    begin
      while job = jobs.pop(true)
        sleep(0.01)
      end
    rescue ThreadError
    end
  end
end
threads.each(&:join)

puts "All jobs done at #{(JOBS_NUMBER/(Time.now - start_time)).round(1)} jobs / sec"