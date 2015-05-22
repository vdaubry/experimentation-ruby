require 'aws-sdk'
require 'yaml'
require 'byebug'

class SQS
  def initialize(queue_name)
    conf = YAML.load_file("#{File.expand_path(File.dirname(__FILE__))}/../../aws.yml")
    #AWS.config(YAML.load_file(conf_path))
    Aws.config.update({
      access_key_id: conf['access_key_id'],
      secret_access_key: conf['secret_access_key'],
      region: 'us-east-1'
    })
    @sqs_client = Aws::SQS::Client.new
    resp = @sqs_client.get_queue_url(queue_name: queue_name)
    @queue_url = resp.queue_url
    @poller = Aws::SQS::QueuePoller.new(queue_url: @queue_url,
                                        max_number_of_messages: 10,
                                        wait_time_seconds: 0.1)
    @poller.instance_variable_set(:@queue_url, resp.queue_url)
    #@poller.instance_variable_set(:@wait_time_seconds, 0.1)
    
  end
  
  def stop_when
    @poller.before_request do |stats|
      throw :stop_polling if (yield stats)
    end
  end
  
  def poll
    @poller.poll do |msg|
      begin
        yield msg
      rescue
        # unexpected error occurred while processing messages,
        # log it, and skip delete so it can be re-processed later
        throw :skip_delete
      end
    end
  end
  
  def get_messages
    resp = @sqs_client.receive_message(
      queue_url: @queue_url,
      max_number_of_messages: 10,
      wait_time_seconds: 1
    )
    yield resp.messages
  end
end

start_time = Time.now
MESSAGE_COUNT = 1000
sqs = SQS.new("website_downloader")

# puts "Start long polling #{MESSAGE_COUNT} messages"

# sqs.stop_when do |stats|
#   stats.request_count >= MESSAGE_COUNT
# end

# sqs.poll do |msg|
#   #do something with msg
# end


POOL_SIZE = 2
jobs = Queue.new
#We poll messages 10 by 10
(MESSAGE_COUNT/10).times{|i| jobs.push i}

puts "Start short polling #{MESSAGE_COUNT} messages"

threads = POOL_SIZE.times.map do
  Thread.new do
    begin
      while job = jobs.pop(true)
        sqs.get_messages do |messages|
          #do something with messages body
        end
      end
    rescue ThreadError
    end
  end
end
threads.each(&:join)

puts "Done polling at #{(MESSAGE_COUNT/(Time.now - start_time)).round(1)} messages / sec"