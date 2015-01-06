require 'open-uri'
require 'celluloid'
require 'uri'
require 'yaml'
require 'mongoid'
require 'aws-sdk'

class JobWorker
  class SomeError < StandardError; end
  
  def initialize(json)
    @json = json
  end
  
  def perform
    i = Random.new.rand(10)
    if i==3
      raise SomeError, "raised some random error"
    end
    puts "Done handling message : #{@json}"
  end
end
 
class OtherWorker
  include Celluloid
  
  def initialize
    async.long_run
  end
    
  def long_run
    i = 0
    loop do
      puts "#{i+=1}"
      sleep 1
    end
  end
end 

class QueueListener
  include Celluloid
  
  def initialize(queue_name)
    conf_path = "#{File.expand_path(File.dirname(__FILE__))}/../aws.yml"
    AWS.config(YAML.load_file(conf_path))
    @queue = AWS::SQS.new.queues.named(queue_name)
    async.listen
  end
  
  def listen
    @queue.poll do |received_message| 
      JobWorker.new(received_message.body).perform
    end
  end
end


class QueueListenerGroup < Celluloid::SupervisionGroup
  supervise QueueListener, as: :job_worker_listener, args:["website_downloader_dev"]
  supervise OtherWorker, as: :other_job
end


#wait for opening a connection pool to DB
puts "Connecting to db..."
Mongoid.load!("#{File.expand_path(File.dirname(__FILE__))}/../mongoid.yml", :production)
puts "Connected"

loop do
  begin
    QueueListenerGroup.run
  rescue Celluloid::DeadActorError => e
    puts "Actor crashed : #{e}"
  end
end