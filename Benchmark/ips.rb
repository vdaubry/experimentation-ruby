#Run in console : RAILS_ENV=production bin/rails c

#we're in production mode so we load all environment vars manually
require 'benchmark/ips'
require 'dotenv'

Dotenv.load
ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])

current_user = User.first
Benchmark.ips do |x|
  x.report("rankings") do |times|
    videos = Video.includes(:tags, :uploader)
                 .not_seen_by_user(current_user)
                 .random
                 .limit(25)
    Api::V0::VideoSerializer.serialize_array(video_array: videos, current_user: current_user)
  end
end