require 'celluloid'

class Subscriber
  include Celluloid
  include Celluloid::Notifications

  def initialize
    subscribe('topic', :handler)
  end

  def handler(topic, *args)
    puts "notified of #{topic}"
  end
end

class Publisher
  include Celluloid
  include Celluloid::Notifications

  def notify
    publish('topic')
  end
end

Subscriber.new
Publisher.new.notify