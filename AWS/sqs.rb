require 'aws-sdk'




class SQS
  def initialize(queue_name)
    conf_path = "#{File.expand_path(File.dirname(__FILE__))}/../aws.yml"
    AWS.config(YAML.load_file(conf_path))
    @queue = AWS::SQS.new.queues.named(queue_name)
  end
  
  def send(msg)
    @queue.send_message("#{msg}")
  end
end

number_of_message = ARGV[0] || 30
start_time = Time.now
puts "Sending #{number_of_message} messages at #{start_time}"

threads = []
number_of_message.to_i.times do
  threads << Thread.new do
    SQS.new("website_downloader_dev").send({"foo" => "bar"})
  end
end
threads.each(&:join)

puts "All messages sent in #{Time.now - start_time}"