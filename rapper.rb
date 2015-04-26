#!/usr/bin/env ruby

# vim: set ft=ruby
require 'bundler'
# require_relative '../lib/dpx_active_tags'
Bundler.require

# require 'pg'



# Output a table of current connections to the DB
#conn = PG.connect( dbname: 'postgres' )
#conn.exec( "SELECT * FROM pg_stat_activity" ) do |result|
#  puts "     PID | User             | Query"
#  result.each do |row|
#  #   puts " %7d | %-16s | %s " %
#  #            row.values_at('procpid', 'usename', 'current_query')
#    puts "  #{row.values_at('procid')}| #{row.values_at('usename')} | #{row.values_at('current_query')}"
#  end
#end

class DbConnection
  def initialize(connection)
    @conn = PG.connect(connection)
  end

  def query(query, parameters = [], &mapper)
    result = @conn.exec_params(query, parameters )
    list = []
    if block_given?
      result.each do |row|
        list << mapper.call(row) 
      end
    end
    return list
  end
end

class Stat
  attr_accessor :procpid, :usename, :current_query
end


conn = DbConnection.new(dbname: 'postgres')
results = conn.query "select * from pg_stat_activity" do |row|
  stat = Stat.new
  stat.procpid = row.values_at('procpid')
  stat.usename = row.values_at('usename')
  stat.current_query = row.values_at('current_query')
  stat
end

puts results.inspect

