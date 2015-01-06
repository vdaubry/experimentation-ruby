require 'mongo'
require 'uri'
require 'yaml'

class DBConnection
  @@db_connection = nil
  
  def self.connection
    return @@db_connection if @@db_connection
    conf_path = "#{File.expand_path(File.dirname(__FILE__))}/../db.yml"
    url = YAML.load_file(conf_path)["url"]
    db = URI.parse(url)
    db_name = db.path.gsub(/^\//, '')
    @@db_connection = Mongo::Connection.new(db.host, db.port).db(db_name)
    @@db_connection.authenticate(db.user, db.password) unless (db.user.nil? || db.password.nil?)
    @@db_connection
  end
end


coll = DBConnection.connection["images"]
puts "number of documents : #{coll.count}"

loop do
end