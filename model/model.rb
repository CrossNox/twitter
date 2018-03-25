require 'active_record'
require 'upsert'
require 'upsert/active_record_upsert'
require 'mysql2'
require 'yaml'

db_config = YAML::load(File.open(File.dirname(__FILE__)+'/db.yml'))
ActiveRecord::Base.establish_connection(db_config)

class Tweet < ActiveRecord::Base
end
