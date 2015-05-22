#
# Export multiples SQL request as CSV and merge them by column
#
#!/usr/bin/env ruby

require 'erb'
require 'fileutils'
require 'csv'
current_path = File.expand_path File.dirname(__FILE__)

(0..30).each do |n|
  renderer = ERB.new(File.new("#{current_path}/retention.sql.erb").read)
  days = n
  File.open("#{current_path}/retention.sql", 'w') do |f|
    f.puts renderer.result(binding)
  end
  `psql -h youboox.cupxp6ibrqls.eu-west-1.redshift.amazonaws.com -p 5439 -d youbooxproduction -U youboox_db -t -f #{current_path}/retention.sql`
  
  old_values = File.exists?("retention.csv") ? CSV.open("retention.csv", "r").to_a : []
  
  CSV.open("retention.csv", "w") do |final|
    inter = CSV.open("retention_#{days}.csv", 'r').to_a
    inter[0..-1].each_with_index do |value, index|
      row = old_values[index] || [value.first]
      final << row.push(value.last)
    end 
    if old_values.count > inter.count
      old_values[inter.count..-1].each {|r| final << r}
    end   
  end
  FileUtils.rm "retention_#{days}.csv"
end
FileUtils.rm "#{current_path}/retention.sql"