require 'pg'
require 'yaml'

db_conf = YAML.load_file(File.join(__dir__, 'db.yml'))
pg = PG::Connection.new(db_conf)
resultset = pg.exec("select count(*) from books")
puts resultset[0]["count"]