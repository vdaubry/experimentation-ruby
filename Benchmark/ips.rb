require 'benchmark/ips'
location="worldwide"
period="all_time"
offset=0
count=25

Benchmark.ips do |x|
	x.report("rankings") do |times|
	    users_rankings = Rankings::UserCollectionRankings.new(location: location, period: period)
    	users = users_rankings.sorted_users(offset: offset, count: count)
    	Api::V0::RankingsSerializer.new(users: users, location: location).to_json
  	end
end