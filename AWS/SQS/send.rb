require 'aws-sdk'
require 'yaml'

class SQS
  def initialize(queue_url)
    conf = YAML.load_file("#{File.expand_path(File.dirname(__FILE__))}/../../aws.yml")
    @sqs = Aws::SQS::Client.new(
      region: "us-east-1",
      credentials: Aws::Credentials.new(conf['access_key_id'], conf['secret_access_key'])
    )
    @queue_url = queue_url
  end
  
  def send(msg)
    @sqs.send_message(queue_url: @queue_url,
                      message_body: "#{msg}")
  end
end


MESSAGE_COUNT = (ARGV[0] || 10000).to_i
POOL_SIZE = 40
jobs = Queue.new
MESSAGE_COUNT.times{|i| jobs.push i}

start_time = Time.now
puts "Sending #{MESSAGE_COUNT} messages with #{POOL_SIZE} threads"

threads = POOL_SIZE.times.map do
  Thread.new do
    begin
      while job = jobs.pop(true)
        SQS.new("https://sqs.us-east-1.amazonaws.com/903786739486/website_downloader").send({"foo" => "bar"})
      end
    rescue ThreadError
    end
  end
end
threads.each(&:join)

puts "Done at #{(MESSAGE_COUNT/(Time.now - start_time)).round(1)} messages / sec"