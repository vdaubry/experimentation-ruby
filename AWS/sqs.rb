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

3.times do
  SQS.new("website_downloader_dev").send({"foo" => "bar"})
end