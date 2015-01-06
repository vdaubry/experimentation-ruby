require 'mongo'
require 'uri'
require 'yaml'

def get_connection(url)
  return @db_connection if @db_connection
  db = URI.parse(url)
  db_name = db.path.gsub(/^\//, '')
  @db_connection = Mongo::Connection.new(db.host, db.port).db(db_name)
  @db_connection.authenticate(db.user, db.password) unless (db.user.nil? || db.password.nil?)
  @db_connection
end

conf_path = "#{File.expand_path(File.dirname(__FILE__))}/../db.yml"
url = YAML.load_file(conf_path)["url"]
db = get_connection(url)
coll = db["images"]
puts "number of documents : #{coll.count}"