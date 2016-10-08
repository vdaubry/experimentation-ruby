#Run with RAILS_ENV=production bundle exec rails runner #{THIS_SCRIPT}.rb

#we're in production mode so we load all environment vars manually
require 'benchmark/ips'
require 'dotenv'

Dotenv.load
#DATABASE_URL in the form : postgres://vincentdaubry@localhost/welovefootball_development
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