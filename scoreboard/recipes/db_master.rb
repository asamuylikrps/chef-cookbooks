#
# Cookbook Name:: scoreboard
# Recipe:: db_master
#
# Copyright 2013, Remedy Point Solutions, Inc.
#
# All rights reserved - Do Not Redistribute
#

# Create application data base
apps = node['apps']
if !apps.empty?
	apps.each do |app_config|
		score_db app_config[:name] do
		  db_name app_config[:db_name]
		  db_user app_config[:db_user]
		  db_pass app_config[:db_pass]
		end
	end
end