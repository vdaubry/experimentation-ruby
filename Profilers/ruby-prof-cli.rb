#DISABLE_SPRING=1 RAILS_ENV=production ruby-prof -m 1 --printer=flat_with_line_numbers bin/rails runner load_testing/ruby-prof.rb
require 'dotenv'
Dotenv.load
ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])

location="worldwide"
period="all_time"
offset=0
count=25
users_rankings = Rankings::UserCollectionRankings.new(location: location, period: period)
users = users_rankings.sorted_users(offset: offset, count: count)
Api::V0::RankingsSerializer.new(users: users, location: location).to_json