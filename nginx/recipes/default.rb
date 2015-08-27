#
# Cookbook Name:: nginx
# Recipe:: default
#
# Copyright (C) 2015 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#

directory "/srv/www/shared" do
	mode 0755
	owner 'root'
	group 'root'
	recursive true
	action :create
end

cookbook_file "/srv/www/shared/example_data.json" do
	source "example_data.json"
	mode 0644
	action :create_if_missing
end

