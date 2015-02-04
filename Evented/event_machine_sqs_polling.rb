require 'eventmachine'
require 'aws-sdk'
require 'mini_magick'

def get_queue(name)
  conf_path = "#{File.expand_path(File.dirname(__FILE__))}/../aws.yml"
  AWS.config(YAML.load_file(conf_path))
  AWS::SQS.new.queues.named(name)
end

def handle_msgs(msgs)
  BackgroundJob.async do
    msgs.each do |msg|
      puts "received message = #{msg.body}"
      #do some jobs
      msg.delete
    end
  end
  .then do |msgs|
  end
  .run
end

queue = get_queue("website_downloader_dev")
DEFAULT_DELAY=5

EM.run do
  timer = EventMachine::PeriodicTimer.new(DEFAULT_DELAY) do
    BackgroundJob.async do
      puts "polling queue at #{Time.now}"
      queue.receive_message(:limit => 10)
    end
    .then do |msgs|
      handle_msgs(msgs)
      timer.interval = msgs.empty? ? DEFAULT_DELAY : 0.1
    end
    .run
  end
end