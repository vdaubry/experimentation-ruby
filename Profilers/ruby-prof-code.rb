#Run in console : RAILS_ENV=production bin/rails c

require 'ruby-prof'
location="worldwide"
period="all_time"
offset=0
count=25
users_rankings = Rankings::UserCollectionRankings.new(location: location, period: period)
users = users_rankings.sorted_users(offset: offset, count: count)


result = RubyProf.profile do
  Api::V0::RankingsSerializer.new(users: users, location: location).to_json
end

printer = RubyProf::GraphPrinter.new(result)
printer.print(STDOUT, {})