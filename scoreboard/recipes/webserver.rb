#
# Cookbook Name:: scoreboard
# Recipe:: webserver
#
# Copyright 2013, Remedy Point Solutions, Inc.
#
# All rights reserved - Do Not Redistribute
#
#

# Create application virtual host and 'docroot' directory
apps = node['apps']
if !apps.empty?
	include_recipe "apache2"
	include_recipe "apache2::mod_php5"

	apps.each do |app|
		score_app do
			app_config app
		end
	end
end

execute 'fix_mcrypt_location' do
  command 'mv -i /etc/php5/conf.d/mcrypt.ini /etc/php5/mods-available/ &&
          sudo php5enmod mcrypt &&
          sudo service apache2 restart'
  not_if { ::File.exists?('/etc/php5/mods-available/mcrypt.ini') && !::File.exists?('/etc/php5/conf.d/mcrypt.ini')}
end